local p = {}
local wikidata = require("Модул:Wikidata")
local wd = require("Модул:Wd")

function getTaxon(id)
	local frame = {}
	frame.args = {}
	frame.args['id'] = id
	frame.args[1] = 'P171'
	frame.args["parameter"] = 'numeric-id'
	local parent = wikidata.claim(frame)
	if parent then
		return 'Q' .. parent
	end
	
	return nil
end

function p.test(frame)
	local id = frame.args[1]
	local result = getTaxon(id)

	return result
end

return p
