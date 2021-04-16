local p={}

function p.main(frame)
    local parent=frame.getParent(frame) or {}
    local reserved_value={}
    local reserved_function,reserved_contents
    for k,v in pairs(parent.args or {}) do
        _G[k]=tonumber(v) or v -- transfer every parameter directly to the global variable table
    end
    for k,v in pairs(frame.args or {}) do
        _G[k]=tonumber(v) or v -- transfer every parameter directly to the global variable table
    end
     --- Alas Scribunto does NOT implement coroutines, according to
     --- http://www.mediawiki.org/wiki/Extension:Scribunto/Lua_reference_manual#string.format
     --- this will not stop us from trying to implement one single lousy function call
    if _G[1] then
        reserved_function,reserved_contents=mw.ustring.match(_G[1],"^%s*(%a[^%s%(]*)%(([^%)]*)%)%s*$")
    end
    if reserved_contents then
        local reserved_counter=0
        repeat
            reserved_counter=reserved_counter+1
            reserved_value[reserved_counter]=_G[mw.ustring.match(reserved_contents,"([^%,]+)")]
            reserved_contents=mw.ustring.match(reserved_contents,"[^%,]+,(.*)$")
        until not reserved_contents
    end
    local reserved_arraypart=_G
    while mw.ustring.match(reserved_function,"%.") do
        reserved_functionpart,reserved_function=mw.ustring.match(reserved_function,"^(%a[^%.]*)%.(.*)$")
        reserved_arraypart=reserved_arraypart[reserved_functionpart]
    end
    local reserved_call=reserved_arraypart[reserved_function]
    if type(reserved_call)~="function" then
        return tostring(reserved_call)
    else reserved_output={reserved_call(unpack(reserved_value))}
        return reserved_output[reserved_return or 1]
    end
end

local function tonumberOrString(v)
	return tonumber(v) or v:gsub("^\\", "", 1)
end

local function callWithTonumberOrStringOnPairs(f, ...)
	local args = {}
	for _, v in ... do
		table.insert(args, tonumberOrString(v))
	end
	return (f(unpack(args)))
end

--[[
------------------------------------------------------------------------------------
-- ipairsAtOffset

-- This is an iterator for arrays. It can be used like ipairs, but with
-- specified i as first index to iterate. i is an offset from 1
--
------------------------------------------------------------------------------------
--]]
local function ipairsAtOffset(t, i)
	local f, s, i0 = ipairs(t)
	return f, s, i0+i
end

local function get(s)
	local G = _G; for _ in mw.text.gsplit(
		mw.text.trim(s, '%s'), '%s*%.%s*'
	) do
		G = G[_]
	end
	return G
end

--[[
------------------------------------------------------------------------------------
-- call
--
-- This function is usually useful for debugging template parameters.
-- Prefix parameter with backslash (\) to force interpreting parameter as string.
-- The leading backslash will be removed before passed to Lua function.
--
-- Example:
--    {{#invoke:LuaCall|call|mw.log|a|1|2|3}} will return results of mw.log('a', 1, 2, 3)
--    {{#invoke:LuaCall|call|mw.logObject|\a|321|\321| \321 }} will return results of mw.logObject('a', 321, '321', ' \\321 ')
--
-- This example show the debugging to see which Unicode characters are allowed in template parameters,
--    {{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x0061}}}} return 97
--    {{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x0000}}}} return 65533
--    {{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x0001}}}} return 65533
--    {{#invoke:LuaCall|call|string.format|0x%04x|{{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x0002}}}}}} return 0xfffd
--    {{#invoke:LuaCall|call|string.format|0x%04x|{{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x007e}}}}}} return 0x007e
--    {{#invoke:LuaCall|call|string.format|0x%04x|{{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x007f}}}}}} return 0x007f
--    {{#invoke:LuaCall|call|string.format|0x%04x|{{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x0080}}}}}} return 0x0080
--    {{#invoke:LuaCall|call|string.format|0x%04x|{{#invoke:LuaCall|call|mw.ustring.codepoint|{{#invoke:LuaCall|call|mw.ustring.char|0x00a0}}}}}} return 0x00a0
--
------------------------------------------------------------------------------------
--]]
function p.call(frame)
	return callWithTonumberOrStringOnPairs(get(frame.args[1]),
		ipairsAtOffset(frame.args, 1)
	)
end

--local TableTools = require('Module:TableTools')
--[[
------------------------------------------------------------------------------------
-- get
--
-- Example:
--    {{#invoke:LuaCall|get| math.pi }} will return value of math.pi
--    {{#invoke:LuaCall|get|math|pi}} will return value of math.pi
--    {{#invoke:LuaCall|get| math |pi}} will return value of _G[' math '].pi
--    {{#invoke:LuaCall|get|_G| math.pi }} will return value of _G[' math.pi ']
--    {{#invoke:LuaCall|get|obj.a.5.c}} will return value of obj.a['5'].c
--    {{#invoke:LuaCall|get|obj|a|5|c}} will return value of obj.a[5].c
--
------------------------------------------------------------------------------------
--]]
function p.get(frame)
	-- #frame.args always return 0, regardless of number of unnamed
	-- template parameters, so check manually instead
	if frame.args[2] == nil then
		-- not do tonumber() for this args style,
		-- always treat it as string,
		-- so 'obj.1' will mean obj['1'] rather obj[1]
		return get(frame.args[1])
	else
		local G = _G
		for _, v in ipairs(frame.args) do
			G = G[tonumberOrString(v)]
		end
		return G
	end
end

--[[
------------------------------------------------------------------------------------
-- invoke
--
-- This function is used by Template:Invoke
--
------------------------------------------------------------------------------------
--]]
function p.invoke(frame)
	local func
	local offset
	if frame.args[1] ~= nil then
		local m = require('Module:' .. frame.args[1])
		if frame.args[2] ~= nil then
			func = m[frame.args[2]]
			frame.args = frame:getParent().args
			offset = 0
		else
			frame.args = frame:getParent().args
			func = m[frame.args[1]]
			offset = 1
		end
	else
		frame.args = frame:getParent().args
		func = require('Module:' .. frame.args[1])[frame.args[2]]
		offset = 2
	end
	local args = {}
	for _, v in ipairsAtOffset(frame.args, offset) do
		table.insert(args, v)
	end
	frame.args = args
	return func(frame)
end

return p
