local p = {}
local wikidata = require("Модул:Wikidata")

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

	local result = '{{Taxobox/row|' .. rank .. '|' .. latinName .. '|' .. bgLabel .. '}}'
	if parentTaxon and parentTaxon ~= 'Липсва стойност' then
		local parentTaxonId = 'Q' .. parentTaxon
		result = getTaxon(parentTaxonId) .. '<br>' .. result
	end
	
	return result
end

function p.test(frame)
	local id = frame.args[1]
	local result = getTaxon(id)

	return '<table style="width:100%">' .. result .. '</table>'
end

return p
