-- This module implements {{italic title}}.

local p = {}

function p.main(frame)
	local args = require('Module:Arguments').getArgs(frame, {
		wrappers = 'Шаблон:Курсив'
	})
	local title = mw.title.getCurrentTitle()

	-- Find the parts before and after the disambiguation parentheses, if any.
	local prefix, parentheses = mw.ustring.match(title.text, '^(.+) (%([^%(%)]+%))$')

	-- If parentheses were found, italicise only the part before them. Otherwise
	-- italicise the whole title.
	local result
	if prefix and parentheses and args.all ~= 'yes' then
		result = "''" .. prefix .. "'' " .. parentheses
	else
		result = "''" .. title.text .. "''"
	end

	-- Add the namespace if we're not in mainspace.
	if title.namespace ~= 0 then
		result = mw.site.namespaces[title.namespace].name .. ':' .. result
	end

	-- Call displaytitle with the text we generated.
	return mw.getCurrentFrame():callParserFunction(
		'DISPLAYTITLE',
		result,
		args[1]
	)
end    

return p