local p = {}
local wikidata = require("Модул:Wikidata")

function p.test(frame)
	return wikidata.claim(frame.args[1]);
end

return p
