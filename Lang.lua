local p = {}

local data = mw.loadData('Модул:Lang/data')
local ns = mw.title.getCurrentTitle().namespace

local renamed_codes = data['преименувани']
local missing_codes = data['липсващи']
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

local function tempExample(val, background)
	local root = mw.html.create('code')
	val = "&#123;&#123;lang&#124;'''" .. val .. "'''&#125;&#125;"

	root:css('background-color', background)
	root:wikitext(val)
	root:done()

	return tostring(root)
end

function p.docTable(frame)
	local ttype = mw.ustring.lower(trimText(frame.args[1]))

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
		:node(tableRow('th', '50%', nil, 'Език', 'Шаблон'))
		:newline()
	local translated = mw.html.create()
	local not_translated = mw.html.create()
	local missing = mw.html.create()
	local link, background
	local all_langs = {}
	local all_existing_names = {}
	local duplicated_names = {}
	local already_added = {}

	for k, v in pairs(mw.language.fetchLanguageNames('bg', 'all')) do
		if type(k) == 'string' and type(v) == 'string' then
			background = nil
			if renamed_codes[k] then
				if renamed_codes[k] == v then
					background = '#ffdbd4'
				else
					background = '#dff9f9'
				end
			end
			v = renamed_codes[k] or v
			table.insert(all_langs, {k, v, background})

			if not all_existing_names[v] then
				all_existing_names[v] = {k}
			else
				if type(all_existing_names[v]) == 'table' then
					table.insert(all_existing_names[v], k)
				end
			end
		end
	end

	if ttype == 'преведени' or ttype == 'непреведени' then
		table.sort(all_langs, function(a, b) return a[1] < b[1] end)
		duplicated_names = all_existing_names

		for i = 1, #all_langs do
			local code = all_langs[i][1]
			local name = all_langs[i][2]
			local temp = tempExample(code, all_langs[i][3])

			if not already_added[code] then
				if type(duplicated_names[name]) == 'table' and #duplicated_names[name] > 1 then
					table.sort(duplicated_names[name], function(a, b) return a < b end)
					for j = 1, #duplicated_names[name] do
						if duplicated_names[name][j] ~= code then
							background = nil
							for k = 1, #all_langs do
								if all_langs[k][1] == duplicated_names[name][j] then
									background = all_langs[k][3]
								end
							end
							temp = temp .. '<hr>' .. tempExample(duplicated_names[name][j], background)
							already_added[duplicated_names[name][j]] = true
						end
					end
				end

				if mw.ustring.match(mw.ustring.lower(name), '^[а-ъьюя%s%p]+$') then
						if ttype == 'преведени' then
							link = link_exceptions[code] or linkCheck(name)
							if link_exceptions[code] then
								name = "''" .. name .. "''"
							end
							translated
								:node(tableRow('td', nil, nil, createLink(link, name), temp))
								:newline()
						end
				else
					if ttype == 'непреведени' then
						not_translated
							:node(tableRow('td', nil, nil, name, temp))
							:newline()
					end
				end
			end
		end
	end

	if ttype == 'липсващи' then
		local m_codes = {}

		for k, v in pairs(missing_codes) do
			if type(k) == 'string' and type(v) == 'string' then
				table.insert(m_codes, {k, v})
			end

			if not duplicated_names[v] then
				duplicated_names[v] = {k}
			else
				if type(duplicated_names[v]) == 'table' then
					table.insert(duplicated_names[v], k)
				end
			end
		end
		table.sort(m_codes, function(a, b) return a[1] < b[1] end)

		for i = 1, #m_codes do
			local code = m_codes[i][1]
			local name = m_codes[i][2]
			local existing_codename = renamed_codes[code] or mw.language.fetchLanguageName(code, 'bg')
			local background = existing_codename ~= '' and '#fff88e' or nil
			local temp = tempExample(code, background)

			if not already_added[code] then
				if type(duplicated_names[name]) == 'table' and #duplicated_names[name] > 1 then
						table.sort(duplicated_names[name], function(a, b) return a < b end)
						for j = 1, #duplicated_names[name] do
							if duplicated_names[name][j] ~= code then
								existing_codename = renamed_codes[duplicated_names[name][j]] or mw.language.fetchLanguageName(duplicated_names[name][j], 'bg')
								background = existing_codename ~= '' and '#fff88e' or nil
								temp = temp .. '<hr>' .. tempExample(duplicated_names[name][j], background)
								already_added[duplicated_names[name][j]] = true
							end
						end
				end

				link = link_exceptions[code] or linkCheck(name)
				if link_exceptions[code] then
					name = "''" .. name .. "''"
				end
				background = all_existing_names[name] and '#daf7a6' or nil
				missing
					:node(tableRow('td', nil, background, createLink(link, name), temp))
					:newline()

			end
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

--[=[===========================================================================
================================ {{CITE-LANG}} =================================
=============================================================================]=]

function p.cite(frame)
	local code =  mw.ustring.lower(trimText(frame:getParent().args[1]))
	if code == '' then return '' end

	local name = renamed_codes[code] or missing_codes[code] or mw.language.fetchLanguageName(code, 'bg')
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

	local name = renamed_codes[code] or missing_codes[code] or mw.language.fetchLanguageName(code, 'bg')

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
