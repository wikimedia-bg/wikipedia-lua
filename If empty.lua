local p = {}

function p.main(frame)
	local args = require('Модул:Arguments').getArgs(frame, {wrappers = 'Шаблон:If empty', removeBlanks = false})

	for k,v in ipairs(args) do
		if v ~= '' then
			return v
		end
	end
end

return p
