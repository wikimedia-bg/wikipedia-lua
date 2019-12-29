local p = {}
local wikidata = require("Модул:Wikidata")

function p.test(frame)
	local property = frame.args[1]
	
	return wikidata.claim(frame);
end

return p
