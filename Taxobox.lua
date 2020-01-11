-- TODO: 'sect.', 'subg.', 'subsp.'

local p = {}

local RANK
local KINGDOM
local LATINNAME
local AUTHORITY

local MONTHS = { 'януари', 'февруари', 'март', 'април', 'май', 'юни', 'юли', 'август', 'септември', 'октомври', 'ноември', 'декември' }

local ITEM = {
	EXTINCT_SPECIES = 'Q237350',
	RECOMBINATION = 'Q14594740',
	FOSSIL_TAXON = 'Q23038290',
	MONOTYPIC_TAXON = 'Q310890',
	MALE_ORGANISM = 'Q44148',
	FEMALE_ORGANISM = 'Q43445'
}

local PROPERTY = {
	IMAGE = 'P18',
	SEX_OR_GENDER = 'P21',
	INSTANCE_OF = 'P31',
	AUDIO = 'P51',
	TAXON_RANK = 'P105',
	IUCN = 'P141',
	PARENT_TAXON = 'P171',
	RANGE_MAP = 'P181',
	TAXON_NAME = 'P225',
	COMMONS_CATEGORY = 'P373',
	TAXON_AUTHOR = 'P405',
	BOTANIST_NAME = 'P428',
	TAXON_DATE = 'P574',
	IUCN_ID = 'P627',
	FAMILY_NAME = 'P734',
	DISAPPEARED_DATE = 'P746',
	RETRIEVED = 'P813',
	ZOOLOGY_NAME = 'P835',
	TAXON_SYNONYM = 'P1420',
	MEDIA_LEGEND = 'P2096'
}

local IUCNSTATUS = {
	Q211005 = 'LC',
	Q719675 = 'NT',
	Q278113 = 'VU',
	Q11394 = 'EN',
	Q219127 = 'CR',
	Q239509 = 'EW',
	Q237350 = 'EX',
	Q3245245 = 'DD'
}

local TAXONOMICRANK = {
	Q0 = { id = 0, name = '(без ранг)', ignore = true },
	Q22666877 = { id = 1, name = 'надимперия', ignore = true },
	Q146481 = { id = 2, name = 'империя', ignore = true },
	Q19858692 = { id = 3, name = 'надцарство', ignore = true },
	Q36732 = { id = 4, name = 'царство', ignore = false },
	Q2752679 = { id = 5, name = 'подцарство', ignore = true },
	Q3150876 = { id = 6, name = 'инфрацарство', ignore = true },
	Q3978005 = { id = 7, name = 'надтип', ignore = true },
	Q38348 = { id = 8, name = 'тип', ignore = false },
	Q1153785 = { id = 9, name = 'подтип', ignore = true },
	Q2361851 = { id = 10, name = 'инфратип', ignore = true },
	Q3504061 = { id = 11, name = 'надклас', ignore = true },
	Q60922428 = { id = 12, name = 'мегаклас', ignore = true },
	Q37517 = { id = 13, name = 'клас', ignore = false },
	Q5867051 = { id = 14, name = 'подклас', ignore = true },
	Q2007442 = { id = 15, name = 'инфраклас', ignore = true },
	Q6054237 = { id = 16, name = 'magnorder', ignore = true },
	Q5868144 = { id = 17, name = 'надразред', ignore = true },
	Q6462265 = { id = 18, name = 'grandorder', ignore = true },
	Q7506274= { id = 19, name = 'mirorder', ignore = true },
	Q36602 = { id = 20, name = 'разред', ignore = false },
	Q5867959 = { id = 21, name = 'подразред', ignore = true },
	Q2889003 = { id = 22, name = 'инфраразред', ignore = true },
	Q6311258= { id = 23, name = 'parvorder', ignore = true },
	Q2136103 = { id = 24, name = 'надсемейство', ignore = true },
	Q35409 = { id = 25, name = 'семейство', ignore = false },
	Q164280 = { id = 26, name = 'подсемейство', ignore = true },
	Q14817220 = { id = 27, name = 'надтриб', ignore = true },
	Q227936 = { id = 28, name = 'триб', ignore = false },
	Q3965313 = { id = 29, name = 'подтриб', ignore = true },
	Q34740 = { id = 30, name = 'род', ignore = false },
	Q3238261 = { id = 31, name = 'подрод', ignore = true },
	Q3181348 = { id = 32, name = 'секция', ignore = false },
	Q7432 = { id = 33, name = 'вид', ignore = false },
	Q68947 = { id = 34, name = 'подвид', ignore = false },
	Q767728 = { id = 35, name = 'вариетет', ignore = false },
	Q713623 = { id = 36, name = 'клон', ignore = false }
}

local COLORMAP = {
	{ { 'animalia' }, '#D3D3A4' },
	{ { 'plantae' }, '#90EE90' },
	{ { 'fungi' }, '#ADD8E6' },
	{ { 'bacteria' }, '#E0D3E0' },
	{ { 'chromista', 'chromalveolata' }, '#ADFF2F' },
	{ { 'virus', 'i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'i-vii' }, '#EE82EE' },
	{ { 'archaea', 'euryarchaeota', 'crenarchaeota', 'korarchaeota', 'nanoarchaeota', 'thaumarchaeota' }, '#E2B7B7' },
	{ { 'protista' }, '#F0E68C' },
	{ { 'amoebozoa' }, '#FFC8A0' },
	{ { 'rhizaria', 'excavata' }, '#EEE9E9' },
	{ { 'eukaryota', 'bikonta', 'unikonta', 'opisthokonta', 'choanomonada', 'prokaryota' }, '#CDC9C9' }
}

local to = {
	link = function(str)
		return str and string.format('[[%s]]', str) or ''
	end,
	italic = function(str)
		return str and string.format("''%s''", str) or ''
	end,
	bold = function(str)
		return str and string.format("'''%s'''", str) or ''
	end
}

local function isAllowedRank(rank)
	return (RANK.id <= TAXONOMICRANK.Q36602.id and rank.id >= TAXONOMICRANK.Q36732.id) or not rank.ignore
end

local function toItalicIfUnderGenus(str, rank)
	if rank and rank.id >= TAXONOMICRANK.Q34740.id and string.match(str, '[A-z]') then
		return to.italic(str)
	end
	return str
end

local function createSectionNode(content, color)
	local node = mw.html.create('tr')
		:tag('td')
			:attr('colspan', 2)
			:css('text-align', 'center')
			:css('border', '1px solid #aaa')
			:css('background', color)
			:wikitext(content)
			:allDone()
			
	return node
end

local function createFileNode(file)
	local title = ''
	local caption = ''
	if file and file.description then
		title = '|' .. file.description
		caption = string.format('<div>%s</div>', file.description)
	end
	
	local node = mw.html.create('tr')
		:tag('td')
			:attr('colspan', 2)
			:css('padding', '5px')
			:css('text-align', 'center')
				:tag('div')
				:css('display', 'inline-block')
				:wikitext(to.link(string.format('File:%s|frameless%s|240px', file.name, title)) .. caption)
				:allDone()
		
	return node
end

local function getAuthority(taxonNameClaim, isCurrentTaxon)
	local qualifiers = taxonNameClaim[1].qualifiers
	if qualifiers then
		local authorityName
		local localAuthorityName
		local taxonAuthor = qualifiers[PROPERTY.TAXON_AUTHOR]
		if taxonAuthor then
			for i = 1, #taxonAuthor do
				local authorAbbreviation
				local authorItemId = taxonAuthor[i].datavalue.value.id
				local authorEntity = mw.wikibase.getEntity(authorItemId)
				local zoologyName = authorEntity.claims[PROPERTY.ZOOLOGY_NAME]
				if zoologyName and zoologyName[1].mainsnak.datavalue then
					authorAbbreviation = zoologyName[1].mainsnak.datavalue.value
				else
					local botanistName = authorEntity.claims[PROPERTY.BOTANIST_NAME]
					if botanistName and botanistName[1].mainsnak.datavalue then
						authorAbbreviation = botanistName[1].mainsnak.datavalue.value
					else
						local familyName = authorEntity.claims[PROPERTY.FAMILY_NAME]
						if familyName and familyName[1].mainsnak.datavalue then
							authorAbbreviation = mw.wikibase.getEntity(familyName[1].mainsnak.datavalue.value.id):getLabel()
						else
							local splittedEnName = mw.text.split(authorEntity:getLabel('en'), ' ')
							authorAbbreviation = splittedEnName[#splittedEnName]
						end
					end
				end
				
				local authorNameLink = authorEntity:getSitelink('bgwiki')
				local currentName = authorNameLink and to.link(authorNameLink .. '|' .. authorAbbreviation) or authorAbbreviation
				if i == 1 then
					authorityName = currentName
					localAuthorityName = authorAbbreviation
				elseif i ~= #taxonAuthor then
					authorityName = authorityName .. ', ' .. currentName
					localAuthorityName = localAuthorityName .. ', ' .. authorAbbreviation
				else
					authorityName = authorityName .. ' & ' .. currentName
					localAuthorityName = localAuthorityName .. ' & ' .. authorAbbreviation
				end
			end
		end

		local authorityDate
		local localAuthorityDate
		local taxonDate = qualifiers[PROPERTY.TAXON_DATE]
		if taxonDate then
			datetime = taxonDate[1].datavalue.value.time
			localAuthorityDate = mw.text.split(mw.ustring.sub(datetime, 2), '-')[1]
			authorityDate = localAuthorityDate .. ' г.'
		end
	
		local result = (authorityName and authorityDate) and (authorityName .. ', ' .. authorityDate) or (authorityName or authorityDate or '')
		
		if isCurrentTaxon then
			AUTHORITY = (localAuthorityName and localAuthorityDate) and (localAuthorityName .. ', ' .. localAuthorityDate) or (localAuthorityName or localAuthorityDate or '')
		end

		local instanceOf = qualifiers[PROPERTY.INSTANCE_OF]
		local parentheses
		if instanceOf and instanceOf[1].datavalue.value.id == ITEM.RECOMBINATION then
			parentheses = true
		end
		
		return parentheses and '(' .. result .. ')' or result
	end
end

local function getSynonym(synonymId, rank)
	local synonymEntity = mw.wikibase.getEntity(synonymId)
	if synonymEntity then
		local taxonNameClaim = synonymEntity.claims[PROPERTY.TAXON_NAME]
		if taxonNameClaim then
			local synonymName = taxonNameClaim[1].mainsnak.datavalue.value
			if synonymName then
				local authority = getAuthority(taxonNameClaim)
				return '<li>' .. toItalicIfUnderGenus(to.bold(synonymName), rank) .. ' <small>' .. (authority or '') .. '</small></li>'
			end
		end
	end
end

local function getStatus(status)
	if status then
		local result = to.link(string.format('File:Status iucn3.1 %s bg.svg|200px|%s', status, status)) .. '<br/>'
		local category = ''
		if status == 'LC' then
			result = result .. to.link('Незастрашен вид|Незастрашен')
			category = 'Незастрашени'
		elseif status == 'NT' then
			result = result .. to.link('Почти застрашен вид|Почти застрашен')
			category = 'Почти застрашени'
		elseif status == 'VU' then
			result = result .. to.link('Уязвим вид|Уязвим')
			category = 'Уязвими'
		elseif status == 'EN' then
			result = result .. to.link('Застрашен вид|Застрашен')
			category = 'Застрашени'
		elseif status == 'CR' then
			result = result .. to.link('Критично застрашен вид|Критично застрашен')
			category = 'Критично застрашени'
		elseif status == 'EW' then
			result = result .. to.link('Изчезнал в природата вид|Изчезнал в природата')
			category = 'Изчезнали в природата'
		elseif status == 'EX' then
			result = result .. to.link('Изчезнал вид|Изчезнал')
			category = 'Изчезнали'
		elseif status == 'DD' then
			result = result .. 'Недостатъчно данни'
			category = 'Недостатъчно проучени'
		else
			return nil
		end
	
		if mw.title.getCurrentTitle().namespace == 0 then
			return result .. to.link(string.format('Категория:%s видове', category))
		else
			return result
		end
	end
end

local function getFileDescription(claim)
	if claim.qualifiers then
		local mediaLegend = claim.qualifiers[PROPERTY.MEDIA_LEGEND]
		if mediaLegend then
			for j, lang in pairs(mediaLegend) do
				local language = lang.datavalue.value.language
				if language == 'bg' then
					return lang.datavalue.value.text
				end
			end
		end
	end
end

local function getDate(value)
	-- '+2020-01-22T11:06:23Z'
	local datetime = value.time
	if datetime then
		-- { 2020, 1, 22, 11, 6, 23 }
		local datetimeTable = {}
		for m in string.gmatch(datetime, '[^%d]*0?(%d+)[^%d]*') do
			table.insert(datetimeTable, m)
		end
		if datetimeTable[1] then
			if value.precision == 11 then
				-- 22 януари 2020 г.
				if datetimeTable[3] and datetimeTable[2] then
					return string.format('%s %s %s г.', datetimeTable[3], MONTHS[tonumber(datetimeTable[2])], datetimeTable[1])
				end
			elseif value.precision == 9 then
				-- 2020 г.
				return datetimeTable[1] .. ' г.'
			end
		end
	end
end

local function getColor(kingdom)
	for i, color in pairs(COLORMAP) do
		for j, name in pairs(color[1]) do
			if name == kingdom then
				return color[2]
			end
		end
	end
	
	return '#FFF'
end

local function getbgLabel(entity)
	if entity.labels.bg and entity.labels.bg.language == 'bg' then
		local bgLabel = mw.language.getContentLanguage():ucfirst(entity.labels.bg.value)
		if mw.ustring.match(bgLabel, '[А-я]') then
			return bgLabel
		end
	end
end

local function getClaim(entity, property, index)
	local claims = entity.claims[property]
	if claims then
		if index then
			local mainsnak = claims[index].mainsnak
			if mainsnak.snaktype ~= 'novalue' and mainsnak.datavalue then
				return entity:getBestStatements(property)[index].mainsnak.datavalue.value.id
			end
		else
			local result = nil
			for i, claim in pairs(claims) do
				if claim.mainsnak.snaktype ~= 'novalue' and claim.mainsnak.datavalue then
					local valueId = entity:getBestStatements(property)[i].mainsnak.datavalue.value.id	
					result = i == 1 and valueId or result .. ',' .. valueId
				end
			end
			return result
		end
	end
end

local function getClassification(itemId, isHighlighted, taxons)
	local entity = mw.wikibase.getEntityObject(itemId)
	local parentTaxonId = getClaim(entity, PROPERTY.PARENT_TAXON, 1)
	local rankId = getClaim(entity, PROPERTY.TAXON_RANK, 1)
	local rank = rankId and TAXONOMICRANK[rankId] or TAXONOMICRANK.Q0
	
	local latinName = ''
	local taxonName = entity.claims[PROPERTY.TAXON_NAME]
	if taxonName and taxonName[1].mainsnak.datavalue then
		latinName = taxonName[1].mainsnak.datavalue.value
		if RANK.name == rank.name then
			LATINNAME = latinName
		end
	end
	
	local bgLabel = getbgLabel(entity)
	local bgSiteLink = entity:getSitelink('bgwiki')
	
	if rank.name == 'царство' then
		KINGDOM = latinName
	end
	
	local instanceOf = getClaim(entity, PROPERTY.INSTANCE_OF)
	local isMonotypic = instanceOf and string.match(instanceOf, ITEM.MONOTYPIC_TAXON)
	local isFossil = instanceOf and string.match(instanceOf, ITEM.FOSSIL_TAXON)
	isHighlighted = RANK.name == rank.name or (isHighlighted and (RANK.name == rank.name or isMonotypic))
	
	local authority
	if isHighlighted then
		local taxonNameClaim = entity.claims[PROPERTY.TAXON_NAME]
		if taxonNameClaim then
			authority = { 
				link = entity:getSitelink('specieswiki') or latinName,
				name = getAuthority(taxonNameClaim, rank.name == RANK.name)
			}
		end
	end
		
	table.insert(taxons, {
		rank = rank,
		latinName = latinName,
		bgLabel = bgLabel,
		bgSiteLink = bgSiteLink,
		authority = authority,
		isFossil = isFossil,
		isHighlighted = isHighlighted
	})
	
	return parentTaxonId and getClassification(parentTaxonId, isHighlighted, taxons) or taxons
end

local function getTaxobox(itemId)
	local taxobox = { image1 = {}, image2 = {}, audio = {}, map = {} }
	
	-- GET TITLE
	local currentPageName = mw.title.getCurrentTitle().text
	local entity = mw.wikibase.getEntity(itemId)
	if entity and entity.claims then
		taxobox.title = getbgLabel(entity) or entity:getSitelink('bgwiki') or currentPageName
	else
		taxobox.title = currentPageName
		return taxobox
	end
	
	-- GET RANK
	localRankItem = getClaim(entity, PROPERTY.TAXON_RANK, 1)
	RANK = localRankItem and TAXONOMICRANK[localRankItem] or TAXONOMICRANK.Q0
	taxobox.title = toItalicIfUnderGenus(taxobox.title, RANK)
	
	-- GET IMAGES
	if entity.claims[PROPERTY.IMAGE] then
		local sexImage1
		local sexImage2
		local images = entity:getBestStatements(PROPERTY.IMAGE)
		if images then
			for i, image in pairs(images) do
				if image.qualifiers then
					local description = getFileDescription(image)
					if description then
						if taxobox.image1.name then
							taxobox.image2.name = image.mainsnak.datavalue.value
							taxobox.image2.description = description
						else
							taxobox.image1.name = image.mainsnak.datavalue.value
							taxobox.image1.description = description
						end
					end
					
					if not taxobox.image2.name then
						if not taxobox.image1.name and not sexImage2 then
							local sexOrGender = image.qualifiers[PROPERTY.SEX_OR_GENDER]
							if sexOrGender then
								local sex
								local sexItemId = sexOrGender[1].datavalue.value.id
								if sexItemId == ITEM.MALE_ORGANISM then
									sex = to.link('мъжки|♂') .. ' ' .. taxobox.title
								elseif sexItemId == ITEM.FEMALE_ORGANISM then
									sex = to.link('женски|♀') .. ' ' .. taxobox.title
								end
								if sexImage1 then
									sexImage2 = { name = image.mainsnak.datavalue.value, description = sex }
								else
									sexImage1 = { name = image.mainsnak.datavalue.value, description = sex }
								end
							end
						end
					else
						break
					end
				end
			end
			
			if not taxobox.image1.name then
				if sexImage1 then
					taxobox.image1.name = sexImage1.name
					taxobox.image1.description = sexImage1.description
					if sexImage2 then
						taxobox.image2.name = sexImage2.name
						taxobox.image2.description = sexImage2.description
					end
				else
					taxobox.image1.name = images[1].mainsnak.datavalue.value
				end
			end
		end
	end
	
	-- GET AUDIO
	if entity.claims[PROPERTY.AUDIO] then
		local audio = entity:getBestStatements(PROPERTY.AUDIO)
		if audio[1].mainsnak.datavalue then
			taxobox.audio.name = audio[1].mainsnak.datavalue.value
			taxobox.audio.description = getFileDescription(audio[1])
		end
	end

	-- GET DISTRIBUTION MAP
	if entity.claims[PROPERTY.RANGE_MAP] then
		local map = entity:getBestStatements(PROPERTY.RANGE_MAP)
		if map[1].mainsnak.datavalue then
			taxobox.map.name = map[1].mainsnak.datavalue.value
			taxobox.map.description = getFileDescription(map[1])
		end
	end
	
	-- GET CLASSIFICATION AND AUTHORITY
	local taxons = getClassification(itemId, true, {})
	local result = nil
	local authorityResult = nil
	for i=#taxons, 1, -1 do
		local taxon = taxons[i]
		if taxon.isHighlighted or isAllowedRank(taxon.rank) then
			result = (result or '') .. '<tr><td style="text-align:right; padding-right:5px">' .. taxon.rank.name .. ':</td><td style="text-align:left">'
			local latinName = mw.ustring.gsub(taxon.latinName, '(.)%w+%s', '%1.&nbsp;')
			local dead = taxon.isFossil and '†' or ''
			if taxon.isHighlighted then
				latinName = toItalicIfUnderGenus(to.bold(latinName), taxon.rank)
				if taxon.bgLabel then
					result = result .. to.bold(taxon.bgLabel) .. ' <small>(' .. dead .. latinName ..  ')</small>'
				else
					result = result .. dead .. latinName
				end
				
				authorityResult = (authorityResult or '') .. to.link('File:Wikispecies-logo.svg|16px|Уикивидове') .. ' ' .. to.italic(to.bold(to.link('wikispecies:' .. taxon.authority.link .. '|' .. taxon.latinName)))
				if taxon.authority.name then
					authorityResult = authorityResult .. '<div style="text-align:center; font-size:smaller">' .. taxon.authority.name .. '</div>'
				end
			else
				if taxon.bgLabel then
					latinName = toItalicIfUnderGenus(latinName, taxon.rank)
					local bgLink = (taxon.bgSiteLink and taxon.bgSiteLink ~= taxon.bgLabel) and taxon.bgSiteLink .. '|' or ''
					result = result .. to.link(bgLink .. taxon.bgLabel) .. ' <small>(' .. dead .. latinName ..  ')</small>'
				else
					latinName = to.link(taxon.latinName == latinName and latinName or taxon.latinName .. '|' .. latinName)
					latinName = toItalicIfUnderGenus(latinName, taxon.rank)
					result = result .. dead .. latinName
				end
			end
			result = result .. '</td></tr>'
		end 
	end
	taxobox.classification = result
	taxobox.authority = authorityResult

	-- GET IUCN STATUS
	local iucnClaim = entity.claims[PROPERTY.IUCN]
	if iucnClaim then
		local status = iucnClaim[1].mainsnak.datavalue.value.id
		if status and status ~= '' then
			taxobox.status = getStatus(IUCNSTATUS[status])
			if status == ITEM.EXTINCT_SPECIES and iucnClaim[1].qualifiers then
				local qualifiers = iucnClaim[1].qualifiers
				local disappearedDate = qualifiers[PROPERTY.DISAPPEARED_DATE]
				if disappearedDate and disappearedDate[1].datavalue.value then
					taxobox.status = taxobox.status .. string.format(' (%s)', getDate(disappearedDate[1].datavalue.value))
				end
			end
			
			-- Get IUCN Status Reference
			local iucnIdClaim = entity.claims[PROPERTY.IUCN_ID]
			if iucnIdClaim then
				local iucnTaxonId = iucnIdClaim[1].mainsnak.datavalue.value
				if iucnTaxonId then
					local taxonName = LATINNAME .. (AUTHORITY and string.format(' (%s)', AUTHORITY) or '')
					local link = string.format('[https://apiv3.iucnredlist.org/api/v3/taxonredirect/%s %s]', iucnTaxonId, taxonName)
					local redListLink = '[[Международен съюз за защита на природата|IUCN]] [[Червен списък на световнозастрашените видове|Red List of Threatened Species]]'
					local refDate = ''
					if iucnClaim[1].references then
						local retrieved = iucnClaim[1].references[1].snaks[PROPERTY.RETRIEVED]
						if retrieved and retrieved[1].datavalue.value then
							local datetime = getDate(retrieved[1].datavalue.value)
							refDate = datetime and ' Посетен на ' .. datetime or ''
						end
					end
					local ref = string.format('%s. // %s. International Union for Conservation of Nature.%s <small>(на английски)</small>', link, redListLink, refDate)

					taxobox.status = taxobox.status .. mw.getCurrentFrame():extensionTag('ref', ref)
				end
			end
		end
	end
	
	-- GET SYNONYMS
	local taxonSynonymClaim = entity.claims[PROPERTY.TAXON_SYNONYM]
	if taxonSynonymClaim then
		for i=1, #taxonSynonymClaim do
			local synonymId = taxonSynonymClaim[i].mainsnak.datavalue.value.id
			if synonymId then
				local synonym = getSynonym(synonymId, RANK)
				if synonym then
					taxobox.synonyms = (taxobox.synonyms or '') .. synonym
				end
			end
		end
	end

	-- GET COMMONS CATEGORY
	local commonsCategoryClaim = entity.claims[PROPERTY.COMMONS_CATEGORY]
	if commonsCategoryClaim then
		local commons = commonsCategoryClaim[1].mainsnak.datavalue.value
		if commons then
			local commonsLink = tostring(mw.uri.canonicalUrl('Commons:Category:' .. commons))
			taxobox.commons = to.bold('[' .. commonsLink .. '?uselang=bg ' .. taxobox.title .. ']') .. ' в ' .. to.link('Общомедия')
		end
	end
	
	-- GET COLOR
	taxobox.color = getColor(KINGDOM:lower())

	return taxobox
end

local function renderTaxobox(taxobox)
	-- TITLE
	titleNode = mw.html.create('tr')
		:tag('td')
			:attr('colspan', 2)
			:css('text-align', 'center')
			:css('border', '1px solid #aaa')
			:css('background', taxobox.color)
			:css('font-size', '125%')
			:css('font-weight', 'bold')
			:css('border-spacing', '6px')
			:wikitext(taxobox.title)
			:allDone()
	
	-- IMAGES
	if taxobox.image1.name then
		image1Node = createFileNode(taxobox.image1)
		if taxobox.image2.name then
			image2Node = createFileNode(taxobox.image2)
		end
	end

	-- AUDIO
	if taxobox.audio.name then
		audioNode = createFileNode(taxobox.audio)
	end
	
	-- STATUS
	if taxobox.status then
		statusNode = mw.html.create()
			:node(createSectionNode(to.bold('Природозащитен статут'), taxobox.color))
			:tag('tr')
				:tag('td')
					:attr('colspan', 2)
					:attr('align', 'center')
					:css('text-align', 'center')
					:wikitext(taxobox.status)
					:allDone()
	end
	
	-- CLASSIFICATION
	if taxobox.classification then
		classificationNode = mw.html.create()
			:node(createSectionNode(to.bold('Класификация'), taxobox.color))
			:tag('tr')
				:tag('td')
					:attr('colspan', 2)
					:attr('align', 'center')
					:css('text-align', 'center')
					:tag('table')
						:css('width', '100%')
						:wikitext(taxobox.classification)
						:allDone()
	end
	
	-- AUTHORITY
	if taxobox.authority then
		authorityNode = mw.html.create()
			:node(createSectionNode(to.bold('Научно наименование'), taxobox.color))
			:tag('tr')
				:attr('valign', 'top')
				:tag('td')
					:attr('colspan', 2)
					:css('text-align', 'center')
					:wikitext(taxobox.authority)
					:allDone()
	end

	-- DISTRIBUTION MAP
	if taxobox.map.name then
		distributionNode = mw.html.create()
			:node(createSectionNode(to.bold('Разпространение'), taxobox.color))
			:node(createFileNode(taxobox.map))
			:allDone()
	end
	
	-- SYNONYMS
	if taxobox.synonyms then
		synonymsNode = mw.html.create()
			:node(createSectionNode(to.bold('Синоними'), taxobox.color))
			:tag('tr')
				:tag('td')
					:attr('colspan', 2)
					:css('text-align', 'left')
					:tag('ul')
						:wikitext(taxobox.synonyms)
						:allDone()
	end
	
	-- COMMONS CATEGORY
	if taxobox.commons then
		commonsNode = mw.html.create()
			:node(createSectionNode(taxobox.commons, taxobox.color))
	end

	local root = mw.html.create('table')
		:addClass('infobox infobox-lua')
		:css('width', '22em')
		:css('background', '#F2F2F2')
		:css('border', '1px solid #CCD2D9')
		:css('border-spacing', '6px')
		:css('infobox_v2 vcard')
		:node(titleNode)
		:node(image1Node)
		:node(image2Node)
		:node(audioNode)
		:node(statusNode)
		:node(classificationNode)
		:node(authorityNode)
		:node(distributionNode)
		:node(synonymsNode)
		:node(commonsNode)
		:allDone()

	return tostring(root)
end

function p.get(frame)
	local itemId = frame.args[1] or mw.wikibase.getEntityIdForCurrentPage()
	local taxobox = getTaxobox(itemId)
	
	return renderTaxobox(taxobox)
end

return p
