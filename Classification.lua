local p = {}
local wikidata = require("Модул:Wikidata")
local wd = require("Модул:Wd")

function getTaxon(id)

end

function p.test(frame)
	local property = frame.args[1]
	
	frame.args[1] = "P171"
	frame.args["id"] = "Q1263887"
	frame.args["parameter"] = "numeric-id"
	
	return wikidata.claim(frame)
end

return p
