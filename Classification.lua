local p = {}
local wikidata = require("Модул:Wikidata")
local wd = require("Модул:Wd")

function getTaxon(id)
	local frame = {}
	frame.args = {}
	frame.args["id"] = id
	frame.args[1] = "P171"
	frame.args["parameter"] = "numeric-id"
	local parent = Q..wikidata.claim(frame)
	
	return parent
end

function p.test(frame)
	local id = frame.args[1]
	local result = getTaxon(id)

	return result
end

return p
