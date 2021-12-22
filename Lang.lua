local p = {}

local data = mw.loadData('Модул:Lang/data')

local function errorMessage(msg, cat)
	local root = mw.html.create('strong')

	root:addClass('error')
	root:wikitext('Грешка в записа: ' .. msg)
	root:done()

	return tostring(root) .. (cat or '')
end

local function linkCheck(name)
	 -- проверка дали страницата съществува/е свързана с Уикиданни, за да се спести проверката с реурсоемката анализираща функция
	local extra = mw.ustring.match(name, '[сзжшчц]ки$') and ' език' or ' (език)'
	local qid = mw.wikibase.getEntityIdForTitle(name .. extra)
	if qid then -- страницата следва традиционен формат на името, съществува и е свързана с Уикиданни
		return name .. extra
	else -- страницата не следва традиционен формат на името
		qid = mw.wikibase.getEntityIdForTitle(name) -- друга проверка за съществуващо име
		if qid then -- страницата съществува и е свързана с Уикиданни
			local instance = mw.ustring.lower(mw.getCurrentFrame():callParserFunction{name = '#property', args = {'P31', from = qid }}) -- евтин начин за извикване на всички стойности на свойството; избягва се цикленето през отделните стойности и последващото допълнително анализиране
			local iso_1 = mw.wikibase.getAllStatements(qid, 'P218')
			local iso_2 = mw.wikibase.getAllStatements(qid, 'P219')
			local iso_3 = mw.wikibase.getAllStatements(qid, 'P220')
			local ietf = mw.wikibase.getAllStatements(qid, 'P305')
			if mw.ustring.match(instance, '%f[%a]език%f[%A]') or mw.ustring.match(instance, '%f[%a]language%f[%A]') or ((#iso_1 + #iso_2 + #iso_3 + #ietf) > 0) then
				-- страницата е екземпляр на език или съдържа свойства, идентифициращи обекта като език
				return name
			else
				return name .. ' (език)'
			end
		end
	end

	return name .. extra
end

local function createLink(pagelink, linktext)
	if pagelink == linktext then
		return '[[' .. pagelink .. ']]'
	else
		return '[[' .. pagelink .. '|' .. linktext .. ']]'
	end
end

local function textWrap(code, dir, text)
	local mark = dir ~= 'ltr' and '&lrm;' or ''
	local root = mw.html.create('i')

	root:attr('lang', code)
	root:attr('dir', dir)
	root:wikitext(text)
	root:done()

	return tostring(root) .. mark
end

local function tableRow(celltag, width, background, str1, str2)
	local row = mw.html.create('tr')

	row:css('background-color', background)
	row:tag(celltag):css('width', width):wikitext(str1):done()
	row:tag(celltag):css('width', width):wikitext(str2):done()
	row:done()

	return row
end

local function tempExample(val)
	return mw.text.nowiki('{{lang|' .. val .. '}}')
end

function p.docTable(frame)
	local ttype = mw.ustring.lower(frame.args[1] or '')

	if ttype == '' then return '' end

	local div = mw.html.create('div')
		:css('height', '400px')
		:css('overflow', 'auto')
		:css('border', '1px solid black')
		:css('padding', '0')
	local tab = mw.html.create('table')
		:addClass('wikitable sortable')
		:css('width', '100%')
		:css('margin', '0')
		:newline()
		:node(tableRow('th', '50%', nil, 'Шаблон', 'Език'))
		:newline()
	local translated = mw.html.create()
	local not_translated = mw.html.create()
	local missing = mw.html.create()
	local result = ''
	local background, link, name
	local all_langs = {}

	for k, v in pairs(mw.language.fetchLanguageNames('bg', 'all')) do
		if type(k) == 'string' and type(v) == 'string' then
			table.insert(all_langs, {k, v})
		end
	end

	table.sort(all_langs, function(a, b) return a[1] < b[1] end)

	for i = 1, #all_langs do
		name = data['renamed'][all_langs[i][1]] or all_langs[i][2]
		local norm = mw.ustring.toNFC(mw.ustring.lower(name))
		if norm then norm = mw.ustring.toNFD(norm) end
		if norm and mw.ustring.match(norm, '[а-я]') then
			background = data['renamed'][all_langs[i][1]] and '#dff9f9' or nil
			link = data['link_exception'][all_langs[i][1]] or linkCheck(name)
			if data['link_exception'][all_langs[i][1]] then
				name = "''" .. name .. "''"
			end
			translated
				:node(tableRow('td', nil, background, tempExample(all_langs[i][1]), createLink(link, name)))
				:newline()
		else
			not_translated
				:node(tableRow('td', nil, nil, tempExample(all_langs[i][1]), name))
				:newline()
		end
	end

	for k, v in pairs(data.missing) do
		link = data['link_exception'][k] or linkCheck(v)
		missing
			:node(tableRow('td', nil, nil, tempExample(k), createLink(link, v)))
			:newline()
	end

	if ttype == 'преведени' then
		div:node(tab:node(translated))
		result = tostring(div)
	elseif ttype == 'непреведени' then
		div:node(tab:node(not_translated))
		result = tostring(div)
	elseif ttype == 'липсващи' then
		div:node(tab:node(missing))
		result = tostring(div)
	end

	return result
end

function p.cite(frame)		-- Опросена версия за {{cite-lang}}
	local code =  mw.ustring.lower(mw.text.trim(frame:getParent().args[1] or ''))
	if code == '' then return '' end

	local name = data['renamed'][code] or data['missing'][code] or mw.language.fetchLanguageName(code, 'bg')
	if not name or name == '' then
		return errorMessage('Неразпознат езиков код „' .. code ..'“')
	end

	return 'на ' .. name
end

function p.main(frame)
	local args = frame:getParent().args
	local words = {}
	local code = mw.ustring.lower(mw.text.trim(args[1] or ''))

	if code == '' then
		return errorMessage('Празен първи позиционен параметър', '[[Категория:Страници с грешки]]')
	end

	local name = data['renamed'][code] or data['missing'][code] or mw.language.fetchLanguageName(code, 'bg')

	if not name or name == '' then
		return errorMessage('Неразпознат езиков код „' .. code ..'“', '[[Категория:Страници с грешки]]')
	end

	local success, dir = pcall(function()
		return mw.language.new(code):getDir() -- ресурсоемка анализираща функция
	end)
	if not success then
		dir = 'auto' -- при прехвърляне на лимита на ресурсоемките анализиращи функции
	end

	local link = data['link_exception'][code] or linkCheck(name)

	for k, v in pairs(args) do
		k = tonumber(k)
		if type(k) == 'number' and k > 1 then
			v = mw.text.trim(v)
			if v ~= '' then
				table.insert(words, textWrap(code, dir, v))
			end
		end
	end

	local str = mw.text.trim((args['на'] or 'на') .. ' '  .. createLink(link, name))
	if #words > 0 then
		str = str .. ': ' .. mw.text.listToText(words, ', ', ' или ')
	end

	return str
end

return p
