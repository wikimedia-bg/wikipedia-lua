local p = {}
local wikidata = require("Модул:Wikidata")

function p.test(frame)
	return frame.args[1];
end

return p
