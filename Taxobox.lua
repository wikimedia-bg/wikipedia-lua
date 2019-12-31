local p = {}
local noValue = 'без стойност'
local notAllowedParentTaxonRanks = {'grandorder', 'magnorder', 'надимперия' , noValue}
local bs = '\''
local firstValueFormat = '^([^,]+).*$'
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

function getItalicText(str, rank)
	if rank == 'род' or rank == 'подрод' or rank == 'вид' or rank == 'подвид' then
		 return toItalic(str)
	end
	return str
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

function getClaim(entity, property, index)
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

function getPropertyValue(entity, p)
	if entity then
		local values = entity:formatPropertyValues(p)
		if values then
			return values.value
		end
	end
	return
end

function getTaxonClassification(id, isLocalTaxon)
	local entity = mw.wikibase.getEntityObject(id)
	local parent = getClaim(entity, 'P171', 1)
	local parentTaxon = parent and parent.id or nil
	local rank = mw.ustring.gsub(getPropertyValue(entity, 'P105'), firstValueFormat, '%1')
	local latinName = mw.ustring.gsub(getPropertyValue(entity, 'P225'), firstValueFormat, '%1')
	local bgLabel = mw.wikibase.getLabelByLang(id, 'bg')
	local instanceOf = getPropertyValue(entity, 'P31')
	local fossil = (instanceOf and string.match(instanceOf, fossilTaxonName)) and '†' or ''
	
	isLocalTaxon = localRank == rank or (isLocalTaxon and (localRank == rank or (instanceOf and string.match(instanceOf, monotypicTaxonName))))
	local result = parentTaxon and parentTaxon ~= noValue and getTaxonClassification(parentTaxon, isLocalTaxon) or ''
	if isAllowedRank(rank) then
		result = result .. '<tr><td style="text-align:right; padding-right:5px">' .. rank .. ':</td><td style="text-align:left; white-space:nowrap"'
		local latinNameText = mw.ustring.gsub(latinName, '(.)%w+%s', '%1. ')
		if bgLabel and mw.ustring.match(bgLabel, '[А-я]') then
			bgLabel = mw.ustring.upper(mw.ustring.sub(bgLabel, 0, 1)) .. mw.ustring.sub(bgLabel, 2)
			local bgLabelText = isLocalTaxon and toBold(bgLabel) or toLink(bgLabel)
			latinNameText = isLocalTaxon and toBold(latinNameText) or latinNameText
			latinNameText = getItalicText(latinNameText, rank)
			result = result .. '>' .. fossil .. latinNameText .. '</td><td style="text-align: left">' .. bgLabelText .. '</td>'
		else
			latinNameText = isLocalTaxon and toBold(latinNameText) or toLink(latinName == latinNameText and latinNameText or latinName .. '|' .. latinNameText)
			latinNameText = getItalicText(latinNameText, rank)
			result = result .. 'colspan="2">' .. fossil .. latinNameText .. '</td>'
		end
	end
	return result
end

function p.get(frame)
	local itemId = frame.args[1]
	if itemId then
		local entity = mw.wikibase.getEntityObject(itemId)
		localRank = getPropertyValue(entity, 'P105')

		return '<table style="width:100%">' .. getTaxonClassification(itemId, true) .. '</table>'
	end
	
	return nil
end

return p
