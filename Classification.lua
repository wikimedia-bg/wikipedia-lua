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

	local result =
		'<tr><td style="text-align: right; padding-right: 5px;">' .. rank .. ':</td>' ..
		'<td ' .. (bgLabel and '' or 'colspan="2"') .. ' style="text-align: left; white-space:nowrap;">' .. latinName .. '</td>' ..
		'<td style="text-align: left;">[[' .. bgLabel .. ']]</td></tr>'

	if parentTaxon and parentTaxon ~= 'Липсва стойност' then
		local parentTaxonId = 'Q' .. parentTaxon
		result = getTaxon(parentTaxonId) .. '<br>' .. result
	end
	
	return result
end

function p.test(frame)
	local id = frame.args[1]
	local result = getTaxon(id)

	return '<table style="width:260px" border="1"><tr><td><table style="width:260px">' .. result .. '</table></td></tr></table>'
end

return p
