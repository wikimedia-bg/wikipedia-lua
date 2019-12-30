local p = {}
local wikidata = require("Модул:Wikidata")
local noValue = 'Липсва стойност'
--local allowedParentTaxonRanks = {'царство', 'отдел', 'тип', 'надклас', 'клас', 'подклас', 'разред', 'надсемейство', 'семейство', 'подсемейство', 'род', 'вид'}
local bs = '\''
local fossilTaxonItemId = 23038290
local monotypicTaxonItemId = 310890
local localRank

--function isAllowedRank(rank)
--  for i = 1, #allowedParentTaxonRanks do
--     if allowedParentTaxonRanks[i] == rank then return true end
--  end
--  return false
--end

function toLink(str)
	return str and '[[' .. str .. ']]' or ''
end

function toItalic(str)
	return str and bs .. bs .. str .. bs .. bs or ''
end

function toBold(str)
	return str and bs .. toItalic(str) .. bs or ''
end

function getTaxonClassification(id)
	local parentTaxon = wikidata.claim({ ['args'] = { ['id'] = id, 'P171', ['parameter'] = 'numeric-id' } })
	local rank = wikidata.claim({ ['args'] = { ['id'] = id, 'P105' } })
	local latinName = wikidata.claim({ ['args'] = { ['id'] = id, 'P225' } })
	local bgLabel = wikidata.getLabel({ ['args'] = { ['id'] = id, ['lang'] = 'bg' } })
	local instanceOf = wikidata.claim({ ['args'] = { ['id'] = id, 'P31', ['parameter'] = 'numeric-id' } })

	local fossil = (instanceOf and instanceOf == fossilTaxonItemId) and '†' or ''
	local isLocalTaxon = localRank == rank
	local result = parentTaxon and parentTaxon ~= noValue and getTaxonClassification('Q' .. parentTaxon) or ''
	if rank ~= noValue and rank ~= 'надимперия' then
		rank = rank == noValue and '(без ранг)' or rank
		result = result .. '<tr><td style="text-align:right; padding-right:5px">' .. rank .. ':</td><td style="text-align:left; white-space:nowrap"'
		
		local latinNameText = mw.ustring.gsub(latinName, '(.)%w+%s', "%1. ")
		if bgLabel and mw.ustring.match(bgLabel, '[А-я]') then
			bgLabel = mw.ustring.upper(mw.ustring.sub(bgLabel, 0, 1)) .. mw.ustring.sub(bgLabel, 2)
			local bgLabelText = isLocalTaxon and toBold(bgLabel) or toLink(bgLabel)
			latinNameText = isLocalTaxon and toBold(latinNameText) or latinNameText
			if rank == 'род' or rank == 'подрод' or rank == 'вид' or rank == 'подвид' then
				latinNameText = toItalic(latinNameText)
			end
			result = result .. '>' .. fossil .. latinNameText .. '</td><td style="text-align: left">' .. bgLabelText .. '</td>'
		else
			latinNameText = isLocalTaxon and toBold(latinNameText) or toLink(latinName == latinNameText and latinNameText or latinName .. '|' .. latinNameText)
			if rank == 'род' or rank == 'подрод' or rank == 'вид' or rank == 'подвид' then
				latinNameText = toItalic(latinNameText)
			end
			result = result .. 'colspan="2">' .. fossil .. latinNameText .. '</td>'
		end
	end
	return result
end

function p.test(frame)
	local itemId = frame.args[1]
	if itemId then
		localRank = wikidata.claim({ ['args'] = { ['id'] = itemId, 'P105' } })
		
		return '<table style="width:260px" border="1"><tr><td><table style="width:260px">' .. getTaxonClassification(itemId) .. '</table></td></tr></table>'
	end
	
	return nil
end

return p
