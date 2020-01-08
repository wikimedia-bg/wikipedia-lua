local p = {}
local localRank
local noRank = '(без ранг)'
local ignoredRanks = { 'надимперия', 'надцарство', 'подцарство', 'инфрацарство', 'подтип', 'инфратип', 'надклас', 'подклас', 'надразред', 'grandorder', 'magnorder', 'подразред', 'надсемейство', 'подсемейство' , noRank }
local kingdom = ''
local LOCALLATINNAME = 'TEST'
local LOCALAUTHORNAME
local LOCALAUTHORDATE

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

local TAXONOMICRANK = {
	Q146481 = 'империя',	-- { 'империя', 1 }
	Q19858692 = 'надцарство',
	Q36732 = 'царство',
	Q2752679 = 'подцарство',
	Q3150876 = 'инфрацарство',
	Q3978005 = 'надтип',
	Q38348 = 'тип',
	Q1153785 = 'подтип',
	Q2361851 = 'инфратип',
	Q3504061 = 'надклас',
	Q60922428 = 'мегаклас',
	Q37517 = 'клас',
	Q5867051 = 'подклас',
	Q2007442 = 'инфраклас',
	Q5868144 = 'надразред',
	Q36602 = 'разред',
	Q5867959 = 'подразред',
	Q2889003 = 'инфраразред',
	Q2136103 = 'надсемейство',
	Q35409 = 'семейство',
	Q164280 = 'подсемейство',
	Q14817220 = 'надтриб',
	Q227936 = 'триб',
	Q3965313 = 'подтриб',
	Q34740 = 'род',
	Q3238261 = 'подрод',
	Q3181348 = 'секция',
	Q7432 = 'вид',
	Q68947 = 'подвид',
	Q767728 = 'вариетет',
	Q713623 = 'клон'
}

local IUCN_STATUS = {
	Q211005 = 'LC',
	Q719675 = 'NT',
	Q278113 = 'VU',
	Q11394 = 'EN',
	Q219127 = 'CR',
	Q239509 = 'EW',
	Q237350 = 'EX',
	Q3245245 = 'DD'
}

local COLORMAP = {
	{ { 'animalia' }, '#D3D3A4' },
	{ { 'plantae' }, '#90EE90' },
	{ { 'fungi' }, '#ADD8E6' },
	{ { 'bacteria' }, '#E0D3E0' },
	{ { 'chromista', 'chromalveolata' }, '#ADFF2F' },
	{ { 'virus', 'i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'ivii' }, '#EE82EE' },
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

local function createNewTrSectionNode(content, color)
	local titleNode = mw.html.create('tr')
		:tag('td')
			:attr('colspan', 2)
			:css('text-align', 'center')
			:css('border', '1px solid #aaa')
			:css('background', color)
			:wikitext(content)
			:allDone()
			
	return titleNode
end

local function getAuthority(entity, kingdom)
	local taxonName = entity.claims[PROPERTY.TAXON_NAME]
	if taxonName then
		local qualifiers = taxonName[1].qualifiers
		if qualifiers then
			local authorityName
			local taxonAuthor = qualifiers[PROPERTY.TAXON_AUTHOR]
			if taxonAuthor then
				local n = #taxonAuthor
				for i = 1, n do
					local authorItemId = taxonAuthor[i].datavalue.value.id
					local authorEntity = mw.wikibase.getEntity(authorItemId)
					local authorName = authorEntity:getLabel('en')
					local zoologyName = authorEntity.claims[PROPERTY.ZOOLOGY_NAME]
					if kingdom == 'Animalia' and zoologyName and zoologyName[1].mainsnak.datavalue then
						authorAbbreviation = zoologyName[1].mainsnak.datavalue.value
					else
						local botanistName = authorEntity.claims[PROPERTY.BOTANIST_NAME]
						if (kingdom == 'Plantae' or kingdom == 'Fungi') and botanistName and botanistName[1].mainsnak.datavalue then
							authorAbbreviation = botanistName[1].mainsnak.datavalue.value
						else
							local familyName = authorEntity.claims[PROPERTY.FAMILY_NAME]
							if familyName and familyName[1].mainsnak.datavalue then
								authorAbbreviation = mw.wikibase.getEntity(familyName[1].mainsnak.datavalue.value.id):getLabel()
							else
								local splittedName = mw.text.split(authorName, ' ')
								authorAbbreviation = splittedName[#splittedName]
							end
						end
					end
					
					-- TODO: remove the link to author when it is from authorName (latin), so when bgwiki page doesn't exist
					local authorNameLink = authorEntity:getSitelink('bgwiki') or authorName
					if i == 1 then
						authorityName = to.link(authorNameLink .. '|' .. authorAbbreviation)
					elseif i ~= n then
						authorityName = authorityName .. ', ' .. to.link(authorNameLink .. '|' .. authorAbbreviation)
					else
						authorityName = authorityName .. ' & ' .. to.link(authorNameLink .. '|' .. authorAbbreviation)
					end
				end
			end

			local authorityDate
			local taxonDate = qualifiers[PROPERTY.TAXON_DATE]
			if taxonDate then
				datetime = taxonDate[1].datavalue.value.time
				authorityDate = mw.text.split(mw.ustring.sub(datetime, 2), '-')[1] .. ' г.'
			end
		
			local result = (authorityName and authorityDate) and (authorityName .. ', ' .. authorityDate) or (authorityName or authorityDate or '')

			local instanceOf = qualifiers[PROPERTY.INSTANCE_OF]
			local parentheses
			if instanceOf and instanceOf[1].datavalue.value.id == ITEM.RECOMBINATION then
				parentheses = true
			end
			
			return parentheses and '(' .. result .. ')' or result
		end
	end
end

local function getSynonym(synonymId, kingdom)
	local synonymEntity = mw.wikibase.getEntity(synonymId)
	if synonymEntity then
		local taxonName = synonymEntity.claims[PROPERTY.TAXON_NAME]
		if taxonName then
			local synonymName = taxonName[1].mainsnak.datavalue.value
			if synonymName then
				-- TODO: if kingdom less than genus => synonymName in intalic
			
				local authority = getAuthority(synonymEntity, kingdom)
				return '<li>' .. to.bold(synonymName) .. ' <small>' .. (authority or '') .. '</small></li>'
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

local function getDate(dateValue)
	local datetime = dateValue.time										-- '+2020-01-22T11:06:23Z'
	if datetime then
		local datetimeTable = {}
		for m in string.gmatch(datetime, '[^%d]*0?(%d+)[^%d]*') do
			table.insert(datetimeTable, m)								-- m = { 2020, 1, 22, 11, 6, 23 }
		end
		if datetimeTable[1] then
			if dateValue.precision == 11 then
				if datetimeTable[3] and datetimeTable[2] then
					-- 22 януари 2020 г.
					return string.format('%s %s %s г.', datetimeTable[3], MONTHS[tonumber(datetimeTable[2])], datetimeTable[1])
				end
			elseif dateValue.precision == 9 then
				-- 2020 г.
				return datetimeTable[1] .. ' г.'
			end
		end
	end
end

local function getColor(kingdom)
	for i, color in pairs(COLORMAP) do
		for j, name in pairs(color[1]) do
			-- name:gsub('-', '')
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

local function isAllowedRank(rank)
	for i = 1, #ignoredRanks do
		if ignoredRanks[i] == rank then
			return false
		end
	end
	return true
end

local function getItalicText(str, rank)
	if rank == 'род' or rank == 'подрод' or rank == 'вид' or rank == 'подвид' then
		 return to.italic(str)
	end
	return str
end

local function getClaim(entity, property)
	local claims = entity.claims[property]
	if claims and claims[1].mainsnak.snaktype ~= 'novalue' and claims[1].mainsnak.datavalue then
		return entity:getBestStatements(property)[1].mainsnak.datavalue.value.id
	end
end

local function getClassification(id, isHighlighted)
	local entity = mw.wikibase.getEntityObject(id)
	local parentTaxonId = getClaim(entity, PROPERTY.PARENT_TAXON)
	local rankId = getClaim(entity, PROPERTY.TAXON_RANK)
	local rank = TAXONOMICRANK[rankId] or noRank
	
	local latinName = ''
	local taxonName = entity.claims[PROPERTY.TAXON_NAME]
	if taxonName and taxonName[1].mainsnak.datavalue then
		latinName = taxonName[1].mainsnak.datavalue.value
	end
	
	local bgLabel = getbgLabel(entity)

	if rank == 'царство' then
		kingdom = latinName
	end
	local instanceOf = getClaim(entity, PROPERTY.INSTANCE_OF)
	local isMonotypic = instanceOf == ITEM.MONOTYPIC_TAXON
	local isFossil = instanceOf == ITEM.FOSSIL_TAXON
		
	isHighlighted = localRank == rank or (isHighlighted and (localRank == rank or isMonotypic))
	local result = parentTaxonId and parentTaxonId ~= 'без стойност' and getClassification(parentTaxonId, isHighlighted) or ''
	if isAllowedRank(rank) then
		result = result .. '<tr><td style="text-align:right; padding-right:5px">' .. rank .. ':</td>' .. 
			'<td style="text-align:left">'
		local latinNameText = mw.ustring.gsub(latinName, '(.)%w+%s', '%1.&nbsp;')
		if bgLabel then
			local bgLabelText = isHighlighted and to.bold(bgLabel) or to.link(bgLabel)
			latinNameText = isHighlighted and to.bold(latinNameText) or latinNameText
			latinNameText = getItalicText(latinNameText, rank)
			result = result .. bgLabelText .. ' <small>(' .. (isFossil and '†' or '') .. latinNameText ..  ')</small></td></tr>'
		else
			latinNameText = isHighlighted and to.bold(latinNameText) or to.link(latinName == latinNameText and latinNameText or latinName .. '|' .. latinNameText)
			latinNameText = getItalicText(latinNameText, rank)
			result = result .. (isFossil and '†' or '') .. latinNameText .. '</td></tr>'
		end
	end
	return result
end

local function createFileNode(file)
	local title = ''
	local caption = ''
	if file.description then
		title = '|' .. file.description
		caption = string.format('<div>%s</div>', file.description)
	end
	
	local fileNode = mw.html.create('tr')
		:tag('td')
			:attr('colspan', 2)
			:css('padding', '5px')
			:css('text-align', 'center')
				:tag('div')
				:css('display', 'inline-block')
				:wikitext(to.link(string.format('File:%s|frameless%s|240px', file.name, title)) .. caption)
				:allDone()
		
	return fileNode
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
	if taxobox.status.iucn then
		statusNode = mw.html.create()
			:node(createNewTrSectionNode(taxobox.status.title, taxobox.color))
			:tag('tr')
				:tag('td')
					:attr('colspan', 2)
					:attr('align', 'center')
					:css('text-align', 'center')
					:wikitext(taxobox.status.iucn)
					:allDone()
	end
	
	-- CLASSIFICATION
	if taxobox.classification.list then	--taxobox.classification.list[1]
		classificationNode = mw.html.create()
			:node(createNewTrSectionNode(taxobox.classification.title, taxobox.color))
			:tag('tr')
				:tag('td')
					:attr('colspan', 2)
					:attr('align', 'center')
					:css('text-align', 'center')
					:tag('table')
						:css('width', '100%')
						:wikitext(taxobox.classification.list)
						:allDone()

		-- AUTHORITY
		if taxobox.authority.name then -- mw.ustring.match(TAXONRANK, 'species')
			local taxonName = LOCALLATINNAME
			authority = to.link('File:Wikispecies-logo.svg|16px|Уикивидове') .. ' ' .. to.italic(to.bold(to.link('wikispecies:' .. taxobox.authority.link .. '|' .. taxonName)))
			
			if taxobox.authority.name then
				authority = authority .. '<div style="text-align:center; font-size:smaller">' .. taxobox.authority.name .. '</div>'
			end
			
			authorityNode = mw.html.create()
				:node(createNewTrSectionNode(to.bold('Научно наименование'), taxobox.color))
				:tag('tr')
					:attr('valign', 'top')
					:tag('td')
						:attr('colspan', 2)
						:css('text-align', 'center')
						:wikitext(authority)
						:allDone()
		end
	end

	-- DISTRIBUTION
	if taxobox.distribution.title then
		distributionNode = mw.html.create()
			:node(createNewTrSectionNode(taxobox.distribution.title, taxobox.color))
			:node(createFileNode(taxobox.distribution))
			:allDone()
	end
	
	-- SYNONYMS
	if taxobox.synonyms.title then
		synonymsNode = mw.html.create()
			:node(createNewTrSectionNode(taxobox.synonyms.title, taxobox.color))
			:tag('tr')
				:tag('td')
					:attr('colspan', 2)
					:css('text-align', 'left')
					:tag('ul')
						:wikitext(taxobox.synonyms.list)
						:allDone()
	end
	
	-- COMMONS CATEGORY
	if taxobox.commons.text then
		commonsNode = mw.html.create()
			:node(createNewTrSectionNode(taxobox.commons.text, taxobox.color))
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

local function getTaxobox(itemId)
	local taxobox = {
		image1 = {},
		image2 = {},
		audio = {},
		status = {},
		classification = {
			list = {
				[1] = {
					rank = '',
					latinName = '',
					bgName = '',
					bgSiteLink = '',
					isFossil = false,
					--isMonotypic = false,
					isHighlighted = false
				}
			}
		},
		authority = {},
		distribution = {},
		synonyms = {},
		commons = {}
	}
	
	-- GET TITLE
	local currentPageName = mw.title.getCurrentTitle().text
	local entity = mw.wikibase.getEntity(itemId)
	if entity and entity.claims then
		taxobox.title = getbgLabel(entity) or currentPageName
	else
		taxobox.title = currentPageName
		return taxobox
	end
	
	-- GET RANK
	localRank = TAXONOMICRANK[getClaim(entity, PROPERTY.TAXON_RANK)] or noRank
	taxobox.rank = localRank
	
	-- GET IMAGES
	if entity.claims[PROPERTY.IMAGE] then
		local sexImage1
		local sexImage2
		local images = entity:getBestStatements(PROPERTY.IMAGE)
		if images then
			for i, image in pairs(images) do
				if image.qualifiers then
					local mediaLegend = image.qualifiers[PROPERTY.MEDIA_LEGEND]
					if mediaLegend then
						for j, lang in pairs(mediaLegend) do
							local language = lang.datavalue.value.language
							if language == 'bg' then
								if taxobox.image1.name then
									taxobox.image2.name = image.mainsnak.datavalue.value
									taxobox.image2.description = lang.datavalue.value.text
								else
									taxobox.image1.name = image.mainsnak.datavalue.value
									taxobox.image1.description = lang.datavalue.value.text
								end
								break
							end
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
			if audio[1].qualifiers then
				local mediaLegend = audio[1].qualifiers[PROPERTY.MEDIA_LEGEND]
				if mediaLegend then
					for j, lang in pairs(mediaLegend) do
						local language = lang.datavalue.value.language
						if language == 'bg' then
							taxobox.audio.description = lang.datavalue.value.text
							break
						end
					end
				end
			end
		end
	end
	
	-- GET IUCN STATUS
	local iucnClaim = entity.claims[PROPERTY.IUCN]
	if iucnClaim then
		local status = iucnClaim[1].mainsnak.datavalue.value.id
		if status and status ~= '' then
			taxobox.status.title = to.bold('Природозащитен статут')
			taxobox.status.iucn = getStatus(IUCN_STATUS[status])
			if status == ITEM.EXTINCT_SPECIES and iucnClaim[1].qualifiers then
				local qualifiers = iucnClaim[1].qualifiers
				local disappearedDate = qualifiers[PROPERTY.DISAPPEARED_DATE]
				if disappearedDate and disappearedDate[1].datavalue.value then
					taxobox.status.iucn = taxobox.status.iucn .. string.format(' (%s)', getDate(disappearedDate[1].datavalue.value))
				end
			end
			
			-- Get IUCN Status Reference
			local iucnIdClaim = entity.claims[PROPERTY.IUCN_ID]
			if iucnIdClaim then
				local iucnTaxonId = iucnIdClaim[1].mainsnak.datavalue.value
				if iucnTaxonId then
					local taxonName = LOCALLATINNAME .. (LOCALAUTHORNAME and string.format('(%s, %s)', LOCALAUTHORNAME, LOCALAUTHORDATE) or '')
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

					taxobox.status.iucn = taxobox.status.iucn .. mw.getCurrentFrame():extensionTag('ref', ref)
				end
			end
		end
	end

	-- GET DISTRIBUTION MAP
	if entity.claims[PROPERTY.RANGE_MAP] then
		local map = entity:getBestStatements(PROPERTY.RANGE_MAP)
		if map[1].mainsnak.datavalue then
			taxobox.distribution.title = to.bold('Разпространение')
			taxobox.distribution.name = map[1].mainsnak.datavalue.value
			if map[1].qualifiers then
				local mediaLegend = map[1].qualifiers[PROPERTY.MEDIA_LEGEND]
				if mediaLegend then
					for j, lang in pairs(mediaLegend) do
						local language = lang.datavalue.value.language
						if language == 'bg' then
							taxobox.distribution.description = lang.datavalue.value.text
							break
						end
					end
				end
			end
		end
	end
	
	-- GET CLASSIFICATION
	taxobox.classification.title = to.bold('Класификация')
	taxobox.classification.list =  getClassification(itemId, true)

	-- GET AUTHORITY
	taxobox.authority.name = getAuthority(entity, kingdom)
	taxobox.authority.link = entity:getSitelink('specieswiki') or LOCALLATINNAME
	
	-- GET SYNONYMS
	local taxonSynonymClaim = entity.claims[PROPERTY.TAXON_SYNONYM]
	if taxonSynonymClaim then
		taxobox.synonyms.title = to.bold('Синоними')
		local synonyms = ''
		for i=1, #taxonSynonymClaim do
			local synonymId = taxonSynonymClaim[i].mainsnak.datavalue.value.id
			if synonymId then
				synonyms = synonyms .. getSynonym(synonymId, kingdom)
			end
		end
		
		taxobox.synonyms.list = synonyms
	end

	-- GET COMMONS CATEGORY
	local commonsCategoryClaim = entity.claims[PROPERTY.COMMONS_CATEGORY]
	if commonsCategoryClaim then
		local commons = commonsCategoryClaim[1].mainsnak.datavalue.value
		if commons then
			local commonsLink = tostring(mw.uri.canonicalUrl('Commons:Category:' .. commons))
			taxobox.commons.text = to.bold('[' .. commonsLink .. '?uselang=bg ' .. taxobox.title .. ']') .. ' в ' .. to.link('Общомедия')
		end
	end
	
	-- GET COLOR
	taxobox.color = getColor(kingdom:lower())

	return taxobox
end

function p.get(frame)
	local itemId = frame.args[1] or mw.wikibase.getEntityIdForCurrentPage()
	local taxobox = getTaxobox(itemId)
	
	return renderTaxobox(taxobox)
end

return p
