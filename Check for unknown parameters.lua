-- This module may be used to compare the arguments passed to the parent
-- with a list of arguments, returning a specified result if an argument is
-- not on the list
local p = {}

local function trim(s)
	return s:match('^%s*(.-)%s*$')
end

local function isnotempty(s)
	return s and s:match('%S')
end

local function clean(text)
	-- Return text cleaned for display and truncated if too long.
	-- Strip markers are replaced with dummy text representing the original wikitext.
	local pos, truncated
	local function truncate(text)
		if truncated then
			return ''
		end
		if mw.ustring.len(text) > 25 then
			truncated = true
			text = mw.ustring.sub(text, 1, 25) .. '...'
		end
		return mw.text.nowiki(text)
	end
	local parts = {}
	for before, tag, remainder in text:gmatch('([^\127]*)\127[^\127]*%-(%l+)%-[^\127]*\127()') do
		pos = remainder
		table.insert(parts, truncate(before) .. '&lt;' .. tag .. '&gt;...&lt;/' .. tag .. '&gt;')
	end
	table.insert(parts, truncate(text:sub(pos or 1)))
	return table.concat(parts)
end

function p.check (frame)
	local args = frame.args
	local pargs = frame:getParent().args
	local ignoreblank = isnotempty(args['ignoreblank'])
	local showblankpos = isnotempty(args['showblankpositional'])
	local knownargs = {}
	local unknown = args['unknown'] or 'Found _VALUE_, '
	local preview = args['preview']

	local values = {}
	local res = {}
	local regexps = {}

	-- create the list of known args, regular expressions, and the return string
	for k, v in pairs(args) do
		if type(k) == 'number' then
			v = trim(v)
			knownargs[v] = 1
		elseif k:find('^regexp[1-9][0-9]*$') then
			table.insert(regexps, '^' .. v .. '$')
		end
	end
	if isnotempty(preview) then
		preview = '<div class="hatnote" style="color:red"><strong>Warning:</strong> ' .. preview .. ' (this message is shown only in preview).</div>'
	elseif preview == nil then
		preview = unknown
	end

	-- loop over the parent args, and make sure they are on the list
	for k, v in pairs(pargs) do
		if type(k) == 'string' and knownargs[k] == nil then
			local knownflag = false
			for _, regexp in ipairs(regexps) do
				if mw.ustring.match(k, regexp) then
					knownflag = true
					break
				end
			end
			if not knownflag and ( not ignoreblank or isnotempty(v) )  then
				table.insert(values, clean(k))
			end
		elseif type(k) == 'number' and
			knownargs[tostring(k)] == nil and
			( showblankpos or isnotempty(v) )
		then
			table.insert(values, k .. ' = ' .. clean(v))
		end
	end

	-- add results to the output tables
	if #values > 0 then
		if frame:preprocess( "{{REVISIONID}}" ) == "" then
			unknown = preview
		end
		for _, v in pairs(values) do
			if v == '' then
				-- Fix odd bug for | = which gets stripped to the empty string and
				-- breaks category links
				v = ' '
			end
			-- avoid error with v = 'example%2' ("invalid capture index")
			local r =  unknown:gsub('_VALUE_', {_VALUE_ = v})
			table.insert(res, r)
		end
	end

	return table.concat(res)
end

return p
