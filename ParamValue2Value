local p = {}

--[=[
Helper function that escapes all pattern characters so that they will be treated
as plain text. Copied from [[:en:Module:String]].
]=]
local function escapePattern(pattern_str)
	return mw.ustring.gsub(pattern_str, '([%(%)%.%%%+%-%*%?%[%^%$%]])', '%%%1')
end

-- вызов шаблона, при ошибке возвращает пустую строку
local function expand(frame, tname, targs)
	local success, result = pcall(
		frame.expandTemplate,
		frame,
		{title = tname, args = targs}
	)
	if success then
		return result
	else
		return ''
	end
end

local function is_exception(arg, exceptions)
	return mw.ustring.find(exceptions, '/' .. escapePattern(arg) .. '/')
end

function p.main(frame)
	if not getArgs then
		getArgs = require('Module:Arguments').getArgs
	end
	local args = getArgs(frame, {
		trim = false,
		removeBlanks = false
	})
	local tname = args._pass_to
	local exceptions = args._exceptions and '/' .. args._exceptions .. '/' or ''
	local targs, i = {}, 1
	for k, v in pairs(args) do
		if type(k) == 'number' then --неименованные параметры
			targs[i] = v
			i = i+1
		elseif not k:find('^_') and not is_exception(k, exceptions) then --именованные параметры, исключая настройки вызывающего шаблона
			targs[i] = k .. "=" .. v
			i = i+1
		elseif k ~= '_pass_to' and k ~= '_exceptions' then --настройки вызывающего шаблона
			targs[k] = v
		end
	end
	
	return tostring(expand(frame, tname, targs))
end

return p