local p = {}
local wikidata = require("Модул:Wikidata")

function firstToUpper(str)
    return (str:sub(1,1):upper()..str:sub(2))
end

function getTaxon(id)
	local frame = {}
	frame.args = { ['id'] = id, [1] = 'P171', ['parameter'] = 'numeric-id' }
	local parentTaxon = wikidata.claim(frame)
	
	frame = {}
	frame.args = { ['id'] = id, [1] = 'P105' }
	local rank = wikidata.claim(frame)
	
	frame = {}
	frame.args = { ['id'] = id, [1] = 'P225' }
	local latinName = wikidata.claim(frame)
	
	frame = {}
	frame.args = { ['id'] = id, ['lang'] = 'bg' }
	local bgLabel = wikidata.getLabel(frame)
	if bgLabel then return bgLabel end
	
	local result = rank .. ': ' .. latinName .. ' [[' .. bgLabel .. ']]'
	if parentTaxon then
		result = 'Q' .. parentTaxon .. '<br>' .. result
	end
	
	return result
end

function p.test(frame)
	local id = frame.args[1]
	local result = getTaxon(id)

	return result
end

return p
