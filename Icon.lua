-- This module implements [[Template:Icon]].

local data = mw.loadData('Module:Icon/data')

local p = {}

function p._main(args)
	local code = args.class or args[1]
	local iconData
	if code then
		code = code:match('^%s*(.-)%s*$'):lower() -- trim whitespace and put in lower case
		iconData = data[code]
	end
	if not iconData then
		iconData = data._DEFAULT
	end
	return string.format(
		'[[File:%s%s|%s|link=]]',
		iconData.image,
		iconData.tooltip and '|' .. iconData.tooltip or '',
		args.size or '16x16px'
	)
end

function p.main(frame)
	local args = {}
	for k, v in pairs(frame:getParent().args) do
		args[k] = v
	end
	return p._main(args)
end

return p
