local makeUrl = require('Модул:URL')._url

local p = {}

-- Wrapper for pcall which returns nil on failure.
local function quickPcall(func)
	local success, result = pcall(func)
	if success then
		return result
	end
end

-- Взима ранга на свойството от Wikidata. Връща 1, 0 или -1
local function getRank(prop)
	local rank = prop.rank
	if rank == 'preferred' then
		return 1
	elseif rank == 'normal' then
		return 0
	elseif rank == 'deprecated' then
		return -1
	else
		-- No rank or undefined rank is treated as "normal".
		return 0
	end
end

-- Проверява дали Wikidata свойството е обозначено като написано на български език
-- Тук е единствената разлика с английската версия на модула (Q1860 -> Q7918
local function isBulgarian(prop)
	local ret = quickPcall(function ()
		for i, lang in ipairs(prop.qualifiers.P407) do
			if lang.datavalue.value['numeric-id'] == 7918 then
				return true
			end
		end
		return false
	end)
	return ret == true
end

-- Взема официалният сайт от Уикиданни.
local fetchWikidataUrl
fetchWikidataUrl = function()
	-- Get objects for all official sites on Wikidata.
	local websites = quickPcall(function ()
		return mw.wikibase.getAllStatements(mw.wikibase.getEntityIdForCurrentPage(), 'P856')
	end)

	-- Clone the objects in case other code needs them in their original order.
	websites = websites and mw.clone(websites) or {}

	-- Add the table index to the objects in case it is needed in the sort.
	for i, website in ipairs(websites) do
		website._index = i
	end

	-- Сортиране на сайтовете, първо по най-висок ранг, после по език - български
	table.sort(websites, function(ws1, ws2)
		local r1 = getRank(ws1)
		local r2 = getRank(ws2)
		if r1 ~= r2 then
			return r1 > r2
		end
		local e1 = isBulgarian(ws1)
		local e2 = isBulgarian(ws2)
		if e1 ~= e2 then
			return e1
		end
		return ws1._index < ws2._index
	end)
	local url = quickPcall(function ()
		return websites[1].mainsnak.datavalue.value
	end)

	-- Кеширане на резултата с цел по-малко операции за #invoke.
	fetchWikidataUrl = function ()
		return url
	end

	return url
end

-- Извеждане на URL и други елементи.
local function renderUrl(options)
	if not options.url and not options.wikidataurl then
		local qid = mw.wikibase.getEntityIdForCurrentPage()
		local result = '<strong class="error">' ..
			'Няма открит URL. Моля, укажете URL тук или го добавете в Уикиданни.' ..
			'</strong>'
		if qid then
			result = result.. ' [[File:OOjs UI icon edit-ltr-progressive.svg |frameless |text-top |10px |alt=Редактирайте в Уикиданни |link=https://www.wikidata.org/wiki/' .. qid .. '#P856|Редактирайте в Уикиданни]]'
		end
		return result
	end
	local ret = {}
	ret[#ret + 1] = string.format(
		'<span class="official-website">%s</span>',
		makeUrl(options.url or options.wikidataurl, options.display)
	)
	if options.wikidataurl and not options.url then
		local qid = mw.wikibase.getEntityIdForCurrentPage()
		if qid then
			ret[#ret + 1] = '[[File:OOjs UI icon edit-ltr-progressive.svg |frameless |text-top |10px |alt=Редактирайте в Уикиданни |link=https://www.wikidata.org/wiki/' .. qid .. '#P856|Редактирайте в Уикиданни]]'
		end
	end
	if options.format == 'flash' then
		ret[#ret + 1] = mw.getCurrentFrame():expandTemplate{
			title = 'Color',
			args = {'#505050', '(Изисква [[Adobe Flash Player]])'}
		}
	end
	if options.mobile then
		ret[#ret + 1] = '(' .. makeUrl(options.mobile, 'Мобилен сайт') .. ')'
	end
	return table.concat(ret, ' ')
end

-- Render the tracking category.
local function renderTrackingCategory(url, wikidataurl)
	if mw.title.getCurrentTitle().namespace ~= 0 then
		return ''
	end
	local category
	if not url and not wikidataurl then
		category = 'Без официален сайт'
	elseif not url and wikidataurl then
		return ''
	elseif url and wikidataurl then
		if url:gsub('/%s*$', '') ~= wikidataurl:gsub('/%s*$', '') then
			category = 'Различни официални сайтове в Уикиданни и Уикипедия'
		end
	else
		category = 'Без официален сайт в Уикиданни'
	end
	return category and string.format('[[Категория:%s]]', category) or ''
end

function p._main(args)
	local url = args[1] or args.URL or args.url
	local wikidataurl = fetchWikidataUrl()
	local formattedUrl = renderUrl{
		url = url,
		wikidataurl = wikidataurl,
		display = args[2] or args.name or 'Официален сайт',
		format = args.format,
		mobile = args.mobile
	}
	return formattedUrl .. renderTrackingCategory(url, wikidataurl)
end

function p.main(frame)
	local args = require('Модул:Arguments').getArgs(frame, {
		wrappers = 'Шаблон:Официален сайт'
	})
	return p._main(args)
end

return p
