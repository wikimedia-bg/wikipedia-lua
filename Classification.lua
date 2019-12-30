local p = {}
local wikidata = require("Модул:Wikidata")
local noValue = 'Липсва стойност'

function getTaxonClassification(id)
	local parentTaxon = wikidata.claim({ ['args'] = { ['id'] = id, 'P171', ['parameter'] = 'numeric-id' } })
	local rank = wikidata.claim({ ['args'] = { ['id'] = id, 'P105' } })
	local latinName = wikidata.claim({ ['args'] = { ['id'] = id, 'P225' } })
	local bgLabel = wikidata.getLabel({ ['args'] = { ['id'] = id, ['lang'] = 'bg' } })
	
	local result = ''
	if parentTaxon and parentTaxon ~= noValue then
		result = getTaxonClassification('Q' .. parentTaxon)
	end
	
	rank = rank == noValue and '(без ранг)' or rank
	result = result .. '<tr><td style="text-align:right; padding-right:5px">' .. rank .. ':</td><td style="text-align:left; white-space:nowrap"'
	
	if bgLabel and mw.ustring.match(bgLabel, '[А-я]') then
		bgLabel = mw.ustring.upper(mw.ustring.sub(bgLabel, 0, 1)) .. mw.ustring.sub(bgLabel, 2)
		result = result .. '>' .. latinName .. '</td><td style="text-align: left">[[' .. bgLabel .. ']]</td>'
	else
		result = result .. 'colspan="2">[[' .. latinName .. ']]</td>'
	end
	
	return result
end

function p.test(frame)
	local itemId = frame.args[1]
	if itemId then
		return '<table style="width:260px" border="1"><tr><td><table style="width:260px">' .. getTaxonClassification(itemId) .. '</table></td></tr></table>'
	end
	
	return nil
end

return p
