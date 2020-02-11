-- TODO:
-- вируси
-- 'sect.', 'subg.', 'subsp.'
-- Общоприето наименование
-- Хибрид

local p = {}

local RANK
local KINGDOM
local LATINNAME
local AUTHORITY

local MONTHS = { 'януари', 'февруари', 'март', 'април', 'май', 'юни', 'юли', 'август', 'септември', 'октомври', 'ноември', 'декември' }

local ITEM = {
	EXTINCT_SPECIES = 'Q237350',
	FEMALE_ORGANISM = 'Q43445',
	FOSSIL_TAXON = 'Q23038290',
	MALE_ORGANISM = 'Q44148',
	MONOTYPIC_FOSSIL_TAXON = 'Q47487597',
	MONOTYPIC_TAXON = 'Q310890',
	POLYPHYLETIC_COMMON_NAME = 'Q55983715',
	RECOMBINATION = 'Q14594740'
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
	START_TIME = 'P580',
	END_TIME = 'P582',
	IUCN_ID = 'P627',
	FAMILY_NAME = 'P734',
	DISAPPEARED_DATE = 'P746',
	-- SUBJECT_OF = 'P805', -- image qualifier
	RETRIEVED = 'P813',
	ZOOLOGY_NAME = 'P835',
	EARLIEST_DATE = 'P1319',
	LATEST_DATE = 'P1326',
	TAXON_SYNONYM = 'P1420',
	MEDIA_LEGEND = 'P2096',
	COLLAGE_IMAGE = 'P2716'
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

local FOSSILSTAGES = {
	{ age = 0, name = 'настояще' },
	{ age = 0.00245, name = 'субатлантик' },
	{ age = 0.00566, name = 'суборий' },
	{ age = 0.00922, name = 'атлантик' },
	{ age = 0.01064, name = 'борий (период)|борий' },
	{ age = 0.01143, name = 'преборий' },
	{ age = 0.116, name = 'weichselian' },
	{ age = 0.126, name = 'eemian', grade = 1, link = 'Тарантий|Т', color = '#FEFFD1' },
	{ age = 0.24, name = 'ранхолабрий' },
	{ age = 0.352, name = 'wolstonian' },
	{ age = 0.424, name = 'hoxnian' },
	{ age = 0.73, name = 'kansan' },
	{ age = 0.781, name = 'cromerien', grade = 1, link = 'Йоний', color = '#FFFD6A' },
	{ age = 1.07, name = 'бавелий', grade = 1, link = 'Бавелий|Б', color = '#EDEB5D' },
	{ age = 1.2, name = 'менапий', grade = 1, link = 'Менапий|М', color = '#DCD179' },
	{ age = 1.45, name = 'валий', grade = 1, link = 'Валий|В', color = '#A8CB00' },
	{ age = 1.806, name = 'ебуроний', grade = 1, link = 'Ебуроний|Ебу', color = '#76BA33' },
	{ age = 2.4, name = 'тиглий', grade = 1, link = 'Тиглий', color = '#00B003' },
	{ age = 2.588, name = 'претиглий', grade = 1, link = 'Претиглий|Пт', color = '#0FD236' },
	{ age = 3.6, name = 'пияцензий', grade = 1, link = 'Плиоцен|Плц', color = '#00ED01' },
	{ age = 5.332, name = 'занклий' },
	{ age = 7.246, name = 'месиний' },
	{ age = 11.608, name = 'тортоний' },
	{ age = 13.65, name = 'серавалий' },
	{ age = 15.97, name = 'лангий' },
	{ age = 20.43, name = 'бурдигалий' },
	{ age = 23.03, name = 'аквитаний', grade = 2, link = 'Неоген|Н', color = '#FEDD2D' },
	{ age = 28.1, name = 'хатий' },
	{ age = 33.9, name = 'орелий' },
	{ age = 37.8, name = 'приабоний' },
	{ age = 41.2, name = 'бартоний' },
	{ age = 47.8, name = 'лутеций (период)|лутеций' },
	{ age = 56, name = 'ипресий' },
	{ age = 59.2, name = 'танетий' },
	{ age = 61.6, name = 'зеландий' },
	{ age = 66, name = 'даний', grade = 2, link = 'Палеоген|Пг', color = '#FEA163' },
	{ age = 70.6, name = 'маастрихтий' },
	{ age = 83.5, name = 'кампаний' },
	{ age = 85.8, name = 'сантоний' },
	{ age = 89.3, name = 'конякий' },
	{ age = 93.5, name = 'туроний' },
	{ age = 99.6, name = 'ценоманий' },
	{ age = 112, name = 'албий' },
	{ age = 125, name = 'аптий' },
	{ age = 130, name = 'баремий' },
	{ age = 136.4, name = 'хотривий' },
	{ age = 140.2, name = 'валангиний' },
	{ age = 145.5, name = 'бериасий', grade = 2, link = 'Креда|К', color = '#6FC86B' },
	{ age = 152.1, name = 'титоний' },
	{ age = 157.3, name = 'кимеридгий' },
	{ age = 163.5, name = 'оксфордий' },
	{ age = 166.1, name = 'каловий' },
	{ age = 168.3, name = 'батоний' },
	{ age = 170.3, name = 'байосий' },
	{ age = 174.1, name = 'аалений' },
	{ age = 182.7, name = 'тоархий' },
	{ age = 190.8, name = 'плиенсбахий' },
	{ age = 199.3, name = 'синемурий' },
	{ age = 201.3, name = 'хетангий', grade = 2, link = 'Юра|Ю', color = '#00BBE7' },
	{ age = 208.5, name = 'ретий' },
	{ age = 228, name = 'норий' },
	{ age = 235, name = 'карний' },
	{ age = 242, name = 'ладиний' },
	{ age = 247.2, name = 'анисий' },
	{ age = 251.2, name = 'спатий' },
	{ age = 252.2, name = 'индий', grade = 2, link = 'Триас|Т', color = '#994E96' },
	{ age = 254.1, name = 'чангсингий' },
	{ age = 259.8, name = 'лонгтаний' },
	{ age = 265.1, name = 'капитаний' },
	{ age = 268.8, name = 'уордий' },
	{ age = 272.3, name = 'роадий' },
	{ age = 283.5, name = 'кунгурий' },
	{ age = 290.1, name = 'артинский' },
	{ age = 295, name = 'сакмарий' },
	{ age = 298.9, name = 'аселий', grade = 2, link = 'Перм (период)|П', color = '#F7583C' },
	{ age = 303.7, name = 'гжелий' },
	{ age = 307, name = 'казимовий' },
	{ age = 315.2, name = 'московий (период)|московий' },
	{ age = 323.2, name = 'башкирий' },
	{ age = 330.9, name = 'серпуковий' },
	{ age = 346.7, name = 'визий' },
	{ age = 358.9, name = 'турний', grade = 2, link = 'Карбон|К', color = '#3FAEAD' },
	{ age = 372.2, name = 'фамений' },
	{ age = 382.7, name = 'франий' },
	{ age = 387.7, name = 'живетий' },
	{ age = 393.3, name = 'айфелий' },
	{ age = 407.6, name = 'емсий' },
	{ age = 410.8, name = 'прагий' },
	{ age = 419.2, name = 'локовий', grade = 2, link = 'Девон|Д', color = '#DD9651' },
	{ age = 423, name = 'придолий' },
	{ age = 425.6, name = 'лудфордий' },
	{ age = 427.4, name = 'горстий' },
	{ age = 430.5, name = 'хомерий' },
	{ age = 433.4, name = 'шайнуудий' },
	{ age = 438.5, name = 'телихий' },
	{ age = 440.8, name = 'аероний' },
	{ age = 443.4, name = 'руданий', grade = 2, link = 'Силур|С', color = '#A6DFC5' },
	{ age = 445.2, name = 'хирнантий' },
	{ age = 453, name = 'катий' },
	{ age = 458.4, name = 'сандбий' },
	{ age = 467.3, name = 'дариуилий' },
	{ age = 470, name = 'дапингий' },
	{ age = 477.7, name = 'флоий' },
	{ age = 485.4, name = 'тремадокий', grade = 2, link = 'Ордовик|О', color = '#00A98A' },
	{ age = 489.5, name = 'мансий' },
	{ age = 494, name = 'джиангшаний' },
	{ age = 497, name = 'пейбий' },
	{ age = 500.5, name = 'гужангий' },
	{ age = 504.5, name = 'друмий' },
	{ age = 509, name = 'тойоний' },
	{ age = 514, name = 'ботомий' },
	{ age = 521, name = 'ченгжианг' },
	{ age = 529, name = 'томотий' },
	{ age = 541, name = 'фортуний', grade = 2, link = 'Камбрий|К', color = '#81AA72' },
	{ age = 635, name = 'едиакарий', grade = 2, link = 'Прекамбрий|ПреК', color = '#FED67B' },
	{ age = 850, name = 'байкалий' },
	{ age = 1000, name = 'тоний', grade = 3, link = 'Неопротерозой|Нп', color = '#FFB86C' },
	{ age = 1050, name = 'синий' },
	{ age = 1100, name = 'маяний' },
	{ age = 1200, name = 'стений' },
	{ age = 1400, name = 'ектасий' },
	{ age = 1600, name = 'калимий', grade = 3, link = 'Мезопротерозой|Мп', color = '#FF8773' },
	{ age = 1800, name = 'статерий' },
	{ age = 2050, name = 'орозирий' },
	{ age = 2300, name = 'рясий' },
	{ age = 2500, name = 'сидерий', grade = 3, link = 'Палеопротерозой|Пп', color = '#FF6333' },
	{ age = 2800, name = 'неоархай', grade = 3, link = 'Неоархай|На', color = '#FA62FF' },
	{ age = 3200, name = 'мезоархай', grade = 3, link = 'Мезоархай|Ма', color = '#C867FF' },
	{ age = 3600, name = 'палеоархай', grade = 3, link = 'Палеоархай|Па', color = '#96ABFF' },
	{ age = 3800, name = 'еоархай', grade = 3, link = 'Еоархай|Е', color = '#85DBFC' },
	{ age = 4567.17, name = 'хадей', grade = 3, link = 'Хадей', color = '#96F5FF' }
}

local COLORMAP = {
	{ { 'animalia' }, '#D3D3A4' },
	{ { 'plantae' }, '#90EE90' },
	{ { 'fungi' }, '#ADD8E6' },
	{ { 'bacteria' }, '#E0D3E0' },
	{ { 'chromista' }, '#ADFF2F' },	--'chromalveolata'
--	{ { 'virus', 'i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'i-vii' }, '#EE82EE' },
--	{ { 'archaea', 'euryarchaeota', 'crenarchaeota', 'korarchaeota', 'nanoarchaeota', 'thaumarchaeota' }, '#E2B7B7' },
--	{ { 'protista' }, '#F0E68C' },
--	{ { 'amoebozoa' }, '#FFC8A0' },
--	{ { 'rhizaria', 'excavata' }, '#EEE9E9' },
--	{ { 'eukaryota', 'bikonta', 'unikonta', 'opisthokonta', 'choanomonada', 'prokaryota' }, '#CDC9C9' }
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

local function createSectionNode(section, color)
	local node = mw.html.create('tr')
		:tag('td')
			:css('text-align', 'center')
			:css('border', '1px solid #aaa')
			:css('background', color)
			:wikitext(section)
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
			:css('padding', '5px')
			:css('text-align', 'center')
			:tag('div')
				:css('display', 'inline-block')
				:wikitext(to.link(string.format('File:%s|frameless%s|240px', file.name, title)) .. caption)
				:allDone()
		
	return node
end

local function createFossilStageBlockNode(left, width, color, link, isFirst)
	if isFirst then
		local gradient = string.format('linear-gradient(left,#FFF 0%%,%s 100%%)', color)
		color = string.format('#FFF;background:-moz-%s;background:-webkit-%s;background:-o-%s', gradient, gradient, gradient)
	end
	
	local node = mw.html.create('div')
		:css('position', 'absolute')
		:css('height', '100%')
		:css('left', left .. 'px')
		:css('width', width .. 'px')
		:css('background-color', color)
		:wikitext(to.link(link))
		:allDone()
			
	return node
end

local function createFossilScaleNode(text, startTime, endTime, earliestTime, latestTime)
	local INFOBOXWIDTH = 250

	-- GET GRADE
	local grade
	local firstTime = earliestTime and earliestTime > startTime and earliestTime or startTime
	if 0 <= firstTime and firstTime < 3.5 then
		grade = 1
	elseif 3.5 <= firstTime and firstTime < 630 then
		grade = 2
	elseif 630 <= firstTime and firstTime < 4700 then
		grade = 3
	end
	
	-- GET SCALE
	local scale = ''
	local index = 0
	local stages = {}
	for i=#FOSSILSTAGES, 1, -1 do
		local stage = FOSSILSTAGES[i]
		if stage.grade == grade then
			index = index + 1
			stages[index] = {}
			stages[index].age = stage.age
			stages[index].link = stage.link
			stages[index].color = stage.color
		end
	end

	if grade and #stages > 0 then
		local coefficient = INFOBOXWIDTH / (stages[1].age)
		for i=1, #stages do
			local left = INFOBOXWIDTH - coefficient * (stages[i].age)
			local width = INFOBOXWIDTH - left
			if i < #stages then
				width = width - coefficient * (stages[i + 1].age)
			end
			
			scale = scale .. tostring(createFossilStageBlockNode(left, width, stages[i].color, stages[i].link, i == 1))
		end
		
		-- GET LIGHT BAR
		local lightBarWidth = (startTime == earliestTime and endTime == latestTime) and 0 or coefficient * (earliestTime - latestTime)
		local lightBarLeft = lightBarWidth ~= 0 and INFOBOXWIDTH - lightBarWidth - coefficient * latestTime or 0
		
		-- GET SOLID BAR
		local solidBarWidth = coefficient * (startTime - endTime)
		local solidBarLeft = INFOBOXWIDTH - solidBarWidth - coefficient * endTime - 1
		
		local fossilRange = mw.html.create('div')
			:tag('div')
				-- text
				:css('text-align', 'center')
				:wikitext(text)
				:done()
			:tag('div')
				-- geologic time scale
				:css('margin', '4px auto 0')
				:css('clear', 'both')
				:css('width', INFOBOXWIDTH .. 'px')
				:css('height', '18px')
				:css('line-height', '170%')
				:css('font-size', '80%')
				:css('overflow', 'visible')
				:css('border', '1px #666')
				:css('border-style', 'solid none')
				:css('padding', '0')
				:css('position', 'relative')
				:css('z-index', '0')
				:wikitext(scale)
				:tag('div')
					-- right border
					:css('position', 'absolute')
					:css('height', '100%')
					:css('background-color', '#666')
					:css('width', '1px')
					:css('left', INFOBOXWIDTH .. 'px')
					:done()
				:done()
			:tag('div')
				-- light and solid bars
				:css('margin', '0 auto')
				:css('line-height', '0')
				:css('clear', 'both')
				:css('width', INFOBOXWIDTH .. 'px')
				:css('height', '8px')
				:css('overflow', 'visible')
				:css('padding', '0')
				:css('position', 'relative')
				:css('top', '-4px')
				:css('background-color', 'transparent')
				:css('z-index', '100')
				:tag('div')
					-- light bar
					:css('background-color', '#360')
					:css('position', 'absolute')
					:css('height', '8px')
					:css('left', lightBarLeft .. 'px')
					:css('width', lightBarWidth .. 'px')
					:css('opacity', '0.42')
					:done()
				:tag('div')
					-- solid bar
					:css('background-color', '#6c3')
					:css('position', 'absolute')
					:css('height', '6px')
					:css('left', solidBarLeft .. 'px')
					:css('width', solidBarWidth .. 'px')
					:css('border', '1px solid #360')
					:css('top', '1px')
					:allDone()

		return tostring(fossilRange)
	end
end

local function getFossilStageName(age)
	for i=1, #FOSSILSTAGES do
		local stage = FOSSILSTAGES[i]
		if age <= stage.age then
			return to.link(stage.name)
		end
	end

	return '?'
end

local function getAuthority(taxonNameClaim, isCurrentTaxon)
	local qualifiers = taxonNameClaim[1].qualifiers
	if qualifiers then
		local authorityName
		local localAuthorityName
		local taxonAuthors = qualifiers[PROPERTY.TAXON_AUTHOR]
		if taxonAuthors then
			for i = 1, #taxonAuthors do
				local authorAbbreviation
				local authorItemId = taxonAuthors[i].datavalue.value.id
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
						end
					end
					-- last attempt to get authorAbbreviation if nil
					if not authorAbbreviation then
						local authorLabel = authorEntity:getLabel('en')
						if authorLabel then
							local splittedEnName = mw.text.split(authorLabel, ' ')
							authorAbbreviation = splittedEnName[#splittedEnName]
						else
							authorAbbreviation = '?'
						end
					end
				end
				
				local authorNameLink = authorEntity:getSitelink('bgwiki')
				local currentName = authorNameLink and to.link(authorNameLink .. '|' .. authorAbbreviation) or authorAbbreviation
				
				if #taxonAuthors == 1 or i == 1 then
					authorityName = currentName
					localAuthorityName = authorAbbreviation
				elseif #taxonAuthors == 2 then
					authorityName = authorityName .. ' & ' .. currentName
					localAuthorityName = localAuthorityName .. ' & ' .. authorAbbreviation
				else
					authorityName = authorityName .. ' et al.'
					localAuthorityName = localAuthorityName .. ' et al.'
					break
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
			result = result .. to.link(string.format('Категория:%s видове', category))
		end
		
		return result
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

local function getDate(value, getBCE)
	-- '+2020-01-22T11:06:23Z'
	local datetime = value.time
	if datetime then
		-- { 2020, 1, 22, 11, 6, 23 }
		local datetimeTable = {}
		for m in string.gmatch(datetime, '[^%d]*0?(%d+)[^%d]*') do
			table.insert(datetimeTable, m)
		end
		local year = datetimeTable[1]
		if year then
			if getBCE then
				-- million years BCE
				if datetime:sub(1, 1) == '-' then
					if mw.ustring.match(year, '^%d+$') then
						return tonumber(year) / 1000000
					end
				end
			else
				if value.precision == 7 then
					-- 16 век
					return (year / 100) .. ' век'
				elseif value.precision == 8 then
					-- 1700-те г.
					return year .. '-те г.'
				elseif value.precision == 9 then
					-- 2020 г.
					return year .. ' г.'
				elseif value.precision == 11 then
					-- 22 януари 2020 г.
					if datetimeTable[3] and datetimeTable[2] then
						return string.format('%s %s %s г.', datetimeTable[3], MONTHS[tonumber(datetimeTable[2])], year)
					end
				end
			end
		end
	end
end

local function getColor(kingdom)
	if kingdom then
		kingdom = kingdom:lower()
		for i, color in pairs(COLORMAP) do
			for j, name in pairs(color[1]) do
				if name == kingdom then
					return color[2]
				end
			end
		end
	end
	
	return '#FFF'
end

local function getbgLabel(entity)
	if entity.labels.bg and entity.labels.bg.language == 'bg' then
		return mw.language.getContentLanguage():ucfirst(entity.labels.bg.value)
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
		if not LATINNAME and RANK.name == rank.name then
			LATINNAME = latinName
		end
	end
	
	local bgLabel = getbgLabel(entity)
	local bgSiteLink = entity:getSitelink('bgwiki')
	
	if not KINGDOM and rank.name == 'царство' then
		KINGDOM = latinName
	end
	
	local instanceOf = getClaim(entity, PROPERTY.INSTANCE_OF)
	local isMonotypic = instanceOf and (string.match(instanceOf, ITEM.MONOTYPIC_TAXON) or string.match(instanceOf, ITEM.MONOTYPIC_FOSSIL_TAXON))
	local isFossil = instanceOf and (string.match(instanceOf, ITEM.FOSSIL_TAXON) or string.match(instanceOf, ITEM.MONOTYPIC_FOSSIL_TAXON))
	isHighlighted = isHighlighted and (not next(taxons) or isMonotypic)
	
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
	local taxobox = { id = itemId, image1 = {}, image2 = {}, audio = {}, map = {} }

	-- GET TITLE
	taxobox.title = mw.title.getCurrentTitle().text
	local entity = mw.wikibase.getEntity(itemId)
	if entity and entity.claims then
		local instanceOf = getClaim(entity, PROPERTY.INSTANCE_OF)
		taxobox.title = getbgLabel(entity) or entity:getSitelink('bgwiki') or taxobox.title
		if instanceOf and string.match(instanceOf, ITEM.POLYPHYLETIC_COMMON_NAME) then
			taxobox.common = {}
		elseif not entity.claims[PROPERTY.TAXON_NAME] then
			return taxobox
		end
	else
		return taxobox
	end
	
	-- GET RANK
	local localRankItem = getClaim(entity, PROPERTY.TAXON_RANK, 1)
	RANK = localRankItem and TAXONOMICRANK[localRankItem] or TAXONOMICRANK.Q0
	taxobox.title = toItalicIfUnderGenus(taxobox.title, RANK)
	
	-- GET IMAGES
	if RANK.id < TAXONOMICRANK.Q7432.id and entity.claims[PROPERTY.COLLAGE_IMAGE] then
		local collage = entity:getBestStatements(PROPERTY.COLLAGE_IMAGE)
		if collage[1].mainsnak.datavalue then
			taxobox.image1.name = collage[1].mainsnak.datavalue.value
			taxobox.image1.description = getFileDescription(collage[1])
		end
	else
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
	if not taxobox.common then	
		local taxons = getClassification(itemId, true, {})
		local classification = nil
		local authority = nil
		for i=#taxons, 1, -1 do
			local taxon = taxons[i]
			if taxon.isHighlighted or isAllowedRank(taxon.rank) then
				classification = (classification or '') .. '<tr><td style="text-align:right; padding-right:5px">' .. taxon.rank.name .. ':</td><td style="text-align:left">'
				local latinName = mw.ustring.gsub(taxon.latinName, '(.)%w+%s', '%1.&nbsp;')
				local dead = taxon.isFossil and '†' or ''
				if taxon.isHighlighted then
					latinName = toItalicIfUnderGenus(to.bold(latinName), taxon.rank)
					if taxon.bgLabel and mw.ustring.match(taxon.bgLabel, '[А-я]') then
						classification = classification .. to.bold(taxon.bgLabel) .. ' <small>(' .. dead .. latinName ..  ')</small>'
					else
						classification = classification .. dead .. latinName
					end
					
					local spanLink = string.format("<span class='plainlinks'>[%s %s]</span>", tostring(mw.uri.canonicalUrl('Species:' .. taxon.authority.link, 'uselang=bg')), taxon.latinName)
					local authorityLink = string.format("<div>%s %s</div>", to.link('File:Wikispecies-logo.svg|16px|Уикивидове'), to.italic(to.bold(spanLink)))
					authority = (authority or '') .. authorityLink
					if taxon.authority.name then
						authority = authority .. '<div style="text-align:center; font-size:smaller">' .. taxon.authority.name .. '</div>'
					end
				else
					if taxon.bgLabel and mw.ustring.match(taxon.bgLabel, '[А-я]') then
						local bgLink = taxon.bgLabel
						if taxon.bgSiteLink then
							bgLink = taxon.bgSiteLink
						elseif mw.title.new(taxon.bgLabel).exists and not mw.title.new(taxon.bgLabel).isRedirect then
							bgLink = bgLink .. ' (' .. taxon.rank.name .. ')'
						end
						latinName = toItalicIfUnderGenus(latinName, taxon.rank)
						classification = classification .. to.link(bgLink .. '|' .. taxon.bgLabel) .. ' <small>(' .. dead .. latinName ..  ')</small>'
					else
						if taxon.bgSiteLink then
							latinName = taxon.bgSiteLink .. '|' .. latinName
						elseif mw.title.new(taxon.latinName).exists and not mw.title.new(taxon.latinName).isRedirect then
							latinName = taxon.latinName .. ' (' .. taxon.rank.name .. ')|' .. latinName
						elseif taxon.latinName ~= latinName then
							latinName = taxon.latinName .. '|' .. latinName
						end
						classification = classification .. dead .. toItalicIfUnderGenus(to.link(latinName), taxon.rank)
					end
				end
				classification = classification .. '</td></tr>'
			end
		end
		taxobox.classification = classification
		taxobox.authority = authority
	end
	
	-- GET IUCN STATUS
	local iucnClaim = entity.claims[PROPERTY.IUCN]
	if iucnClaim then
		local status = iucnClaim[1].mainsnak.datavalue.value.id
		if status and status ~= '' then
			taxobox.status = getStatus(IUCNSTATUS[status])
			if status == ITEM.EXTINCT_SPECIES and iucnClaim[1].qualifiers then
				local disappearedDate = iucnClaim[1].qualifiers[PROPERTY.DISAPPEARED_DATE]
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
	
	-- GET FOSSIL RANGE
	local startTimeClaim = entity.claims[PROPERTY.START_TIME]
	if startTimeClaim then
		local startTime = getDate(startTimeClaim[1].mainsnak.datavalue.value, true)
		local earliestTime = startTime
		local qualifiers = startTimeClaim[1].qualifiers
		if qualifiers and qualifiers[PROPERTY.EARLIEST_DATE] then
			earliestTime = getDate(qualifiers[PROPERTY.EARLIEST_DATE][1].datavalue.value, true)
		end
		
		local endTime = 0
		local latestTime = 0
		local endTimeClaim = entity.claims[PROPERTY.END_TIME]
		if endTimeClaim then
			endTime = getDate(endTimeClaim[1].mainsnak.datavalue.value, true)
			latestTime = endTime
			local qualifiers = endTimeClaim[1].qualifiers
			if qualifiers and qualifiers[PROPERTY.LATEST_DATE] then
				latestTime = getDate(qualifiers[PROPERTY.LATEST_DATE][1].datavalue.value, true)
			end
		end
		
		local startTimeStage = getFossilStageName(startTime)
		local endTimeStage = getFossilStageName(endTime)
		local timeStage = startTimeStage .. (startTimeStage ~= endTimeStage and ' – ' .. endTimeStage or '')
		local text = string.format('%s, %s Ma', timeStage, startTime .. '–' .. endTime)
		
		taxobox.fossilRange = createFossilScaleNode(text, startTime, endTime, earliestTime, latestTime)
	end

	-- GET COMMONS CATEGORY
	local commonsCategoryClaim = entity.claims[PROPERTY.COMMONS_CATEGORY]
	if commonsCategoryClaim then
		local commons = commonsCategoryClaim[1].mainsnak.datavalue.value
		if commons then
			local commonsLink = tostring(mw.uri.canonicalUrl('Commons:Category:' .. commons, 'uselang=bg'))
			taxobox.commons = to.bold('[' .. commonsLink .. ' ' .. taxobox.title .. ']') .. ' в ' .. to.link('Общомедия')
		end
	end
	
	-- GET COLOR
	taxobox.color = taxobox.common and '#DDD' or getColor(KINGDOM)

	return taxobox
end

local function renderTaxobox(taxobox)
	-- TITLE
	titleNode = mw.html.create('tr')
		:tag('td')
			:css('text-align', 'center')
			:css('border', '1px solid #aaa')
			:css('background', taxobox.color)
			:css('font-size', '125%')
			:css('font-weight', 'bold')
			:css('border-spacing', '6px')
			:wikitext(taxobox.title)
			:allDone()
	
	-- COMMON NAME
	if taxobox.common then
		commonNode = mw.html.create('tr')
			:tag('td')
				:css('text-align', 'center')
				:tag('div')
					:css('font-size', 'larger')
					:wikitext('Общоприето наименование')
					:done()
				:wikitext(string.format("Терминът '''„%s“''' се използва на български за няколко отделни таксона.", taxobox.title))
				:allDone()
	end
	
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
					:css('text-align', 'left')
					:tag('ul')
						:wikitext(taxobox.synonyms)
						:allDone()
	end
	
	-- FOSSIL RANGE
	if taxobox.fossilRange then
		fossilRangeNode = mw.html.create()
			:node(createSectionNode(to.bold('Обхват на вкаменелости'), taxobox.color))
			:tag('tr')
				:tag('td')
					:css('text-align', 'center')
					:wikitext(taxobox.fossilRange)
					:allDone()
	end
	
	-- COMMONS CATEGORY
	if taxobox.commons then
		commonsNode = mw.html.create()
			:node(createSectionNode(taxobox.commons, taxobox.color))
	end
	
	-- EDIT LINK
	if taxobox.id then
		editNode = mw.html.create('tr')
			:tag('td')
				:css('text-align', 'right')
				:tag('small')
					:tag('span')
						:addClass('plainlinks')
						:wikitext(string.format('[%s редактиране]', tostring(mw.uri.canonicalUrl('Wikidata:' .. taxobox.id, 'uselang=bg'))))
						:allDone()
	end
	
	local root = mw.html.create('table')
		:addClass('infobox infobox-lua')
		:css('width', '22em')
		:css('background', '#F2F2F2')
		:css('border', '1px solid #CCD2D9')
		:css('border-spacing', '6px')
		:css('infobox_v2 vcard')
		:node(titleNode)
		:node(commonNode)
		:node(image1Node)
		:node(image2Node)
		:node(audioNode)
		:node(statusNode)
		:node(classificationNode)
		:node(authorityNode)
		:node(distributionNode)
		:node(synonymsNode)
		:node(fossilRangeNode)
		:node(commonsNode)
		:node(editNode)
		:allDone()

	return tostring(root)
end

function p.get(frame)
	local itemId = frame.args[1]
	if not itemId or itemId == '' then
		itemId = mw.wikibase.getEntityIdForCurrentPage()
	end
	
	local taxobox = getTaxobox(itemId)

	local pageTitle = mw.title.getCurrentTitle()
	if pageTitle.namespace == 0 then
		mw.getCurrentFrame():callParserFunction('DISPLAYTITLE', toItalicIfUnderGenus(pageTitle.text, RANK))
	end
	
	return renderTaxobox(taxobox)
end

return p
