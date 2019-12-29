local p = {}
local wikidata = require("Модул:Wikidata")
local wd = require("Модул:Wd")

function getTaxon(id)

end

function p.test(frame)
	local property = frame.args[1]
	
	frame.args[1] = "P171"
	frame.args["id"] = property
	frame.args["parameter"] = "numeric-id"
	local val = wikidata.claim(frame)
	
	return val
end

return p
