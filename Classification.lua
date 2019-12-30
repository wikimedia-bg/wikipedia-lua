local p = {}
local noValue = 'без стойност'
local notAllowedParentTaxonRanks = {'grandorder', 'magnorder', 'надимперия' , noValue}
local bs = '\''
local fossilTaxonName = 'изкопаем таксон'
local monotypicTaxonName = 'монотипен таксон'
local localRank

function isAllowedRank(rank)
  for i = 1, #notAllowedParentTaxonRanks do
     if notAllowedParentTaxonRanks[i] == rank then return false end
  end
  return true
end

function toLink(str)
	return str and '[[' .. str .. ']]' or ''
end

function toItalic(str)
	return str and bs .. bs .. str .. bs .. bs or ''
end

function toBold(str)
	return str and bs .. toItalic(str) .. bs or ''
end

local function orderedpairs(array, order)
	if not order then return pairs(array) end
	local i = 0
	return function()
		i = i + 1
		if order[i] then
			return order[i], array[order[i]]
		end
	end
end

function getClaim(id, property, index)
	local entity = mw.wikibase.getEntityObject(id)
	if not entity or not entity.claims then return end
	
	local claimsss = entity.claims[property]
	local sortindices = {}
	for idx in pairs(claimsss) do
		sortindices[#sortindices + 1] = idx
	end

	local comparator = function(a, b)
		local rankmap = { deprecated = 2, normal = 1, preferred = 0 }
		local ranka = rankmap[claimsss[a].rank or "normal"] ..  string.format("%08d", a)
		local rankb = rankmap[claimsss[b].rank or "normal"] ..  string.format("%08d", b)
		return ranka < rankb
	end
	table.sort(sortindices, comparator)
	
	local claim = claimsss[sortindices[1]]
	if claim then
		local mainsnak = claim.mainsnak 
		if mainsnak and mainsnak.datavalue then
			local value = mainsnak.datavalue.value
			if value then
				return value
			end
		end
	end
	return
end

function getPropertyValue(id, p)
	local entity = mw.wikibase.getEntity(id)
	if entity then
		local values = entity:formatPropertyValues(p)
		if values then
			return values.value
		end
	end
	return
end

function getTaxonClassification(id)
	local parent = getClaim(id, 'P171', 1)
	local parentTaxon = parent and parent.id or nil
	local rank = mw.ustring.gsub(getPropertyValue(id, 'P105'), '^([^,]+).*$', '%1')
	local latinName = mw.wikibase.getEntity(id)['claims']['P225'][1].mainsnak.datavalue.value
	local bgLabel = mw.wikibase.getLabelByLang(id, 'bg')
	local instanceOf = getPropertyValue(id, 'P31')
	local fossil = (instanceOf and string.match(instanceOf, fossilTaxonName)) and '†' or ''
	local isLocalTaxon = localRank == rank
	local result = parentTaxon and parentTaxon ~= noValue and getTaxonClassification(parentTaxon) or ''
	if isAllowedRank(rank) then
		result = result .. '<tr><td style="text-align:right; padding-right:5px">' .. rank .. ':</td><td style="text-align:left; white-space:nowrap"'
		local latinNameText = mw.ustring.gsub(latinName, '(.)%w+%s', '%1. ')
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

function p.get(frame)
	local itemId = frame.args[1]
	if itemId then
		localRank = getPropertyValue(itemId, 'P105')

		return '<table style="width:260px" border="1"><tr><td><table style="width:260px">' .. getTaxonClassification(itemId) .. '</table></td></tr></table>'
	end
	
	return nil
end

return p
