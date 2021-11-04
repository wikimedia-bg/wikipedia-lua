local p = {}
local ext = require("Модул:TEMP2")

function p.get(frame)
	return '[[Категория:Тест ' .. ext.get(frame) .. ']]'
end

return p
