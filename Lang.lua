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
	local qid = mw.wikibase.getEntityIdForTitle(name .. ' език')
	if qid then -- страницата следва традиционен формат на името "... език", съществува и е свързана с Уикиданни
		return name .. ' език'
	else 
		qid = mw.wikibase.getEntityIdForTitle(name .. ' (език)')
		if qid then -- страницата следва традиционен формат на името "... (език)", съществува и е свързана с Уикиданни
			return name .. ' (език)'
		else -- страницата не следва традиционен формат на името
			qid = mw.wikibase.getEntityIdForTitle(name) -- друга проверка за съществуващо име
			if qid then -- страницата съществува и е свързана с Уикиданни
				local instance = mw.wikibase.getAllStatements(qid, 'P31')
				for i = 1, #instance do
					local id = instance[i].mainsnak and instance[i].mainsnak.datavalue and instance[i].mainsnak.datavalue.value and instance[i].mainsnak.datavalue.value.id
					if id then
						local label = mw.ustring.lower(mw.wikibase.getLabel(id) or '')
						if mw.ustring.match(label, '%f[%a]език%f[%A]') or mw.ustring.match(label, '%f[%a]language%f[%A]') then
							return name -- страницата е екземпляр на език
						end
					end
				end

				local iso_1 = mw.wikibase.getAllStatements(qid, 'P218')
				local iso_2 = mw.wikibase.getAllStatements(qid, 'P219')
				local iso_3 = mw.wikibase.getAllStatements(qid, 'P220')
				local ietf = mw.wikibase.getAllStatements(qid, 'P305')
				if (#iso_1 + #iso_2 + #iso_3 + #ietf) > 0 then
					-- страницата съдържа свойства, идентифициращи обекта като език
					return name
				end
			end
		end
	end

	-- страницата не свързана с Уикиданни или е свързана, но не е екземпляр на език и не съдържа свойства, идентифициращи обекта като език
	return name .. (mw.ustring.match(name, '[жзсчцш]ки$') and ' език' or ' (език)')
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
	return "&#123;&#123;lang&#124;'''" .. val .. "'''&#125;&#125;"
end

function p.docTable(frame)
	local ttype = mw.ustring.lower(frame.args[1] or '')

	if ttype ~= 'преведени' and ttype ~= 'непреведени' and ttype ~= 'липсващи' then return '' end

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
		:node(tableRow('th', '50%', nil, 'Език', 'Шаблон <small>(езиковият код е отбелязан в получер)</small>'))
		:newline()
	local translated = mw.html.create()
	local not_translated = mw.html.create()
	local missing = mw.html.create()
	local background, link, name
	local all_langs = {}

	if ttype == 'преведени' or ttype == 'непреведени' then
		for k, v in pairs(mw.language.fetchLanguageNames('bg', 'all')) do
			if type(k) == 'string' and type(v) == 'string' then
				table.insert(all_langs, {k, v})
			end
		end

		table.sort(all_langs, function(a, b) return a[1] < b[1] end)

		for i = 1, #all_langs do
			name = data['renamed'][all_langs[i][1]] or all_langs[i][2]
			if mw.ustring.match(mw.ustring.lower(name), '^[а-ъьюя%s%p]+$') then
				if ttype == 'преведени' then
					background = data['renamed'][all_langs[i][1]] and '#dff9f9' or nil
					if data['renamed'][all_langs[i][1]] and data['renamed'][all_langs[i][1]] == all_langs[i][2] then
						background = '#ffdbd4' 
					end
					link = data['link_exception'][all_langs[i][1]] or linkCheck(name)
					if data['link_exception'][all_langs[i][1]] then
						name = "''" .. name .. "''"
					end
					translated
						:node(tableRow('td', nil, background, createLink(link, name), tempExample(all_langs[i][1])))
						:newline()
				end
			else
				if ttype == 'непреведени' then
					not_translated
						:node(tableRow('td', nil, nil, name, tempExample(all_langs[i][1])))
						:newline()
				end
			end
		end
	end

	if ttype == 'липсващи' then
		for k, v in pairs(data.missing) do
		link = data['link_exception'][k] or linkCheck(v)
		missing
			:node(tableRow('td', nil, nil, createLink(link, v), tempExample(k)))
			:newline()
		end
	end

	if ttype == 'преведени' then
		return tostring(div:node(tab:node(translated)))
	elseif ttype == 'непреведени' then
		return tostring(div:node(tab:node(not_translated)))
	elseif ttype == 'липсващи' then
		return tostring(div:node(tab:node(missing)))
	end
end

function p.cite(frame)		-- Опросена версия за {{cite-lang}}
	local code =  mw.ustring.lower(mw.text.trim(frame:getParent().args[1] or ''))
	if code == '' then return '' end

	local name = data['renamed'][code] or data['missing'][code] or mw.language.fetchLanguageName(code, 'bg')
	if not name or name == '' then
		return errorMessage('Неразпознат езиков код „<samp>' .. code ..'</samp>“')
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
		return errorMessage('Неразпознат езиков код „<samp>' .. code ..'</samp>“', '[[Категория:Страници с грешки]]')
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
