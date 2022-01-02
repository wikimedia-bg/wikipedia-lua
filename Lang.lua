local p = {}

local data = mw.loadData('Модул:Lang/data')
local ns = mw.title.getCurrentTitle().namespace

local locale_names = data['локално_дефинирани']
local link_exceptions = data['изключения_препратки']

--[=[===========================================================================
========================= ОСНОВНИ СПОМАГАТЕЛНИ ФУНКЦИИ =========================
=============================================================================]=]

local function errorMessage(msg, cat)
	local root = mw.html.create('strong')

	root:addClass('error')
	root:wikitext('Грешка в записа: ' .. msg)
	root:done()

	return tostring(root) .. (cat or '')
end

local function linkCheck(name)
	 -- проверка дали страницата съществува/е свързана с Уикиданни, за да се спести проверката с реурсоемката анализираща функция ifexist
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
						if mw.ustring.match(label, '%f[%a][а-ъьюя]-език%f[%A]') or mw.ustring.match(label, '%f[%a][a-z]-language%f[%A]') then
							return name -- обектът е екземпляр на език
						end
					end
				end

				local lang_properties = {
					'P218', -- ISO 639-1
					'P219', -- ISO 639-2
					'P220', -- ISO 639-3
					'P305', -- IETF
					'P506', -- ISO 15924 aлфа-4
					'P2620', -- ISO 15924 цифров
				}
				for i = 1, #lang_properties do
					local value = mw.wikibase.getAllStatements(qid, lang_properties[i])
					if #value > 0 then
						-- обектът съдържа свойство, което го идентифицира като език
						return name
					end
				end
			end
		end
	end

	-- страницата не е свързана с Уикиданни или е свързана, но обектът в УД не е екземпляр на език и/или не съдържа свойства, които да го идентифицират като език
	return name .. (mw.ustring.match(name, '[жзсчцш]ки$') and ' език' or ' (език)')
end

local function createLink(pagelink, linktext)
	if pagelink == linktext then
		return '[[' .. pagelink .. ']]'
	else
		return '[[' .. pagelink .. '|' .. linktext .. ']]'
	end
end

local function trimText(txt)
	txt = txt or ''
	txt = mw.ustring.gsub(txt, '^%s+', '')
	txt = mw.ustring.gsub(txt, '%s+$', '')
	return txt
end

local function charSet(...)
	local result = ''
	for i, v in pairs(arg) do
		if type(v) == 'string' then
			v = mw.ustring.gsub(v, '([^-]+)' , function(s)
				if mw.ustring.match(s, '^%x+$') then
					s = mw.ustring.char(tonumber('0x' .. s))
				end
				return s
			end)
			if mw.ustring.match(v, '^[^-]%-[^-]$') then
				result = result .. v
			end
		end
	end
	return result
end

local function textWrap(code, dir, text)
	local mark = dir ~= 'ltr' and '&lrm;' or ''
	local root = mw.html.create('span')
	local regex = '^[%A'
		.. charSet('0000-007F', '0080-00FF', '0100-017F', '0180-024F', '2C60-2C7F', 'A720-A7FF', 'AB30-AB6F', '10780-107BF', '1DF00-1DFFF', '1E00-1EFF', '0250-02AF' , '1D00-1D7F', '1D80-1DBF') -- латиница (без Latin Ligatures и Fullwidth Latin Letters)
		.. charSet('0400-04FF', '0500-052F', '2DE0-2DFF', 'A640-A69F', '1C80-1C8F') -- кирилица
		.. charSet('0370-03FF', '1F00-1FFF', '10140-1018F') -- гръцка азбука и числа
		.. charSet('0300-036F', '1AB0-1AFF', '1DC0-1DFF') -- Combining Diacritical Marks, CDM Extended, CDM Supplement
		.. ']+$' -- край на променливата regex; обхватите на символите са взети от https://unicode.org/charts/

	root:attr('lang', code)
	root:attr('dir', dir)
	root:css('font-style', mw.ustring.match(text, regex) and 'italic' or 'normal') -- добавя курсив, само ако текстът е изцяло от горепосочените писмени системи или други неазбучни символи
	root:wikitext(text)
	root:done()

	return tostring(root) .. mark
end

--[=[===========================================================================
====================== ФУНКЦИИ ЗА ТАБЛИЧНАТА ДОКУМЕНТАЦИЯ ======================
=============================================================================]=]

local function tableRow(celltag, width, background, str1, str2)
	local row = mw.html.create('tr')

	row:css('background-color', background)
	row:tag(celltag):css('width', width):wikitext(str1):done()
	row:tag(celltag):css('width', width):wikitext(str2):done()
	row:done()

	return row
end

local function tempExample(val, background, oname)
	local root = mw.html.create('code')
	val = "&#123;&#123;lang&#124;'''" .. val .. "'''&#125;&#125;"

	root:css('background-color', background)
	root:wikitext(val)
	root:done()

	return tostring(root) .. (oname and ' <small>(' .. oname .. ')</small>' or '')
end

function p.docTable(frame)
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
		:node(tableRow('th', '50%', nil, 'Език', 'Шаблон'))
		:newline()
	local translated = mw.html.create()
	local not_translated = mw.html.create()
	local link, background, original_name
	local mediawiki_names = mw.language.fetchLanguageNames('bg', 'all')
	local all_langs = {}
	local repeated_names = {}
	local already_added = {}

	for k, v in pairs(mediawiki_names) do
		if type(k) == 'string' and type(v) == 'string' then
			background = nil
			original_name = nil
			if locale_names[k] then
				if locale_names[k] == v then
					background = '#ffdbd4'
				else
					background = '#dff9f9'
					original_name = v
				end
			end
			v = locale_names[k] or v
			table.insert(all_langs, {k, v, background, original_name})

			if not repeated_names[v] then
				repeated_names[v] = {k}
			else
				if type(repeated_names[v]) == 'table' then
					table.insert(repeated_names[v], k)
				end
			end
		end
	end

	for k, v in pairs(locale_names) do
		if type(k) == 'string' and type(v) == 'string' and not mediawiki_names[k] then
			table.insert(all_langs, {k, v, '#daf7a6'})
			if not repeated_names[v] then
				repeated_names[v] = {k}
			else
				if type(repeated_names[v]) == 'table' then
					table.insert(repeated_names[v], k)
				end
			end
		end
	end

	table.sort(all_langs, function(a, b) return a[1] < b[1] end)

	for i = 1, #all_langs do
		local code = all_langs[i][1]
		local name = all_langs[i][2]
		local temp = tempExample(code, all_langs[i][3], all_langs[i][4])

		if not already_added[code] then
			if type(repeated_names[name]) == 'table' and #repeated_names[name] > 1 then
				table.sort(repeated_names[name], function(a, b) return a < b end)
				for j = 1, #repeated_names[name] do
					if repeated_names[name][j] ~= code then
						background = nil
						original_name = nil
						for k = 1, #all_langs do
							if all_langs[k][1] == repeated_names[name][j] then
								background = all_langs[k][3]
								original_name = all_langs[k][4]
							end
						end
						temp = temp .. '<hr>' .. tempExample(repeated_names[name][j], background, original_name)
						already_added[repeated_names[name][j]] = true
					end
				end
			end

			if mw.ustring.match(mw.ustring.lower(name), '^[а-ъьюя%s%p]+$') then
				link = link_exceptions[code] or linkCheck(name)
				if link_exceptions[code] then
					name = "''" .. name .. "''"
				end
				translated
					:node(tableRow('td', nil, nil, createLink(link, name), temp))
					:newline()
			else
				not_translated
					:node(tableRow('td', nil, nil, name, temp))
					:newline()
			end
		end
	end

	return '<h3>Преведени</h3>\n'
	.. tostring(div:node(tab:node(translated)))
	.. '\n<h3>Непреведени</h3>\n'
	.. tostring(div:node(tab:node(not_translated)))
end

--[=[===========================================================================
================================ {{CITE-LANG}} =================================
=============================================================================]=]

function p.cite(frame)
	local code =  mw.ustring.lower(trimText(frame:getParent().args[1]))
	if code == '' then return '' end

	local name = locale_names[code] or mw.language.fetchLanguageName(code, 'bg')
	if not name or name == '' then
		return errorMessage('Неразпознат езиков код „<samp>' .. code ..'</samp>“')
	end

	return 'на ' .. name
end

--[=[===========================================================================
================================== {{LANG}} ====================================
=============================================================================]=]

function p.main(frame)
	local args = frame:getParent().args
	local code = mw.ustring.lower(trimText(args[1]))
	local words = {}

	if code == '' then
		return ns == 0 and errorMessage('Празен първи позиционен параметър', '[[Категория:Страници с грешки]]') or ''
	end

	local name = locale_names[code] or mw.language.fetchLanguageName(code, 'bg')

	if not name or name == '' then
		return errorMessage('Неразпознат езиков код „<samp>' .. code ..'</samp>“', ns == 0 and '[[Категория:Страници с грешки]]')
	end

	local success, dir = pcall(function()
		return mw.language.new(code):getDir() -- ресурсоемка анализираща функция
	end)
	if not success then
		dir = 'auto' -- при прехвърляне на лимита на ресурсоемките анализиращи функции
	end

	local link = link_exceptions[code] or linkCheck(name)

	for k, v in pairs(args) do
		k = tonumber(k)
		if type(k) == 'number' and k > 1 then
			v = trimText(v)
			if v ~= '' then
				table.insert(words, textWrap(code, dir, v))
			end
		end
	end

	local str = trimText((args['на'] or 'на') .. ' '  .. createLink(link, name))
	if #words > 0 then
		str = str .. ': ' .. mw.text.listToText(words, ', ', ' или ')
	end

	return str
end

return p
