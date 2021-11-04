local p = {}

local CATEGORY = ''
local STUBCAT = 'Категория:Мъничета'
local THEMES = require("Модул:Stub/themes")

local function toLower(str)
	return mw.language.getContentLanguage():lc(str)
end

local function printStub(theme, image, plural, pagelink)
	local editLink = tostring(mw.uri.canonicalUrl(mw.title.getCurrentTitle().fullText, 'action=edit'))
	
	local themeText = ''
	if theme then
		if pagelink then theme = pagelink .. '|' .. theme end
		if plural then
			themeText = ' за [[' .. theme .. ']]'
		else
			themeText = ', свързана ' .. (mw.ustring.match(toLower(theme), '^[сз]') and 'със' or 'с') .. ' [[' .. theme .. ']],'
		end
	end
	
	local text = string.format("''Тази статия%s все още е [[Уикипедия:Мъниче|мъниче]]. Помогнете на Уикипедия, като я [%s редактирате] и разширите.''", themeText, editLink)
	local stub = mw.html.create()
		:tag('div')
			:addClass('plainlinks')
			:css('margin-top', '1em')
			:css('display', 'table')
			:tag('div')
				:css('float', 'left')
				:css('width', '32px')
				:css('overflow', 'hidden')
				:wikitext(string.format('[[File:%s|30x60п]]', image))
				:done()
			:tag('div')
				:css('margin-left', '37px')
				:wikitext(text)
				:allDone()
	
	return tostring(stub)
end

local function checkStubSize()
	local content = mw.title.getCurrentTitle():getContent()
	if content then
		local size = content:len()
		local temp
		content = mw.ustring.lower(content)

		-- без шаблони и уикитаблици
		content = mw.ustring.gsub(content, '%b{}', function(cap)
			if mw.ustring.match(cap, '^{[{|]') and mw.ustring.match(cap, '[|}]}$') then
				cap = ''
			end
			return cap
		end)
		
		-- без източници
		content = mw.ustring.gsub(content, '<%f[%w]ref%f[%W][^>]*/>', '') -- премахване на самозатварящи се ref тагове
		content = mw.ustring.gsub(content, '<%f[%w]ref%f[%W][^>]*>.-</%f[%w]ref%f[%W][^>]*>', '')
		
		-- без галерии
		content = mw.ustring.gsub(content, '<%f[%w]gallery%f[%W][^>]*>.-</%f[%w]gallery%f[%W][^>]*>', '')
		
		-- без файлове и категории; обикновен текст вместо препратки
		content = mw.ustring.gsub(content, '%b[]', function(cap)
			local prefix = mw.ustring.match(cap, '^%[%[%s*([a-zа-я]+):')
			
			if prefix and (prefix == 'файл' or prefix == 'картинка' or prefix == 'категория' or
							prefix == 'file' or prefix == 'image' or prefix == 'category') then
				return ''
			end
			
			-- [B A] => A
			cap = mw.ustring.gsub(cap, '%[https?://[^%s%[%]]+([^%[%]]*)%]', '%1')
			cap = mw.ustring.gsub(cap, '%[//[^%s%[%]]+([^%[%]]*)%]', '%1')
			
			-- [[A]] => A
			cap = mw.ustring.gsub(cap, '%[%[([^%|%[%]]+)%]%]', '%1')
			
			-- [[B|A]] => A
			cap = mw.ustring.gsub(cap, '%[%[[^%|%[%]]+%|([^%[%]]*)%]%]', '%1')
			
			return cap
		end)
		
		-- без съдържание в клетки на неуикифицирани таблици
		repeat
			temp = content
			content = mw.ustring.gsub(content, '<%f[%w]t[dh]%f[%W][^>]*>.-(</?%f[%w]t[dhr]%f[%W][^>]*>)', '%1')
			content = mw.ustring.gsub(content, '<%f[%w]t[dh]%f[%W][^>]*>.-(</?%f[%w]table%f[%W][^>]*>)', '%1')
		until content == temp
		
		-- без тагове
		content = mw.ustring.gsub(content, '</?%f[%w][a-z]+%f[%W][^>]*>', '')
		
		-- без коментари
		content = mw.ustring.gsub(content, '<!%-%-.-%-%->', '')
		
		-- без раздели
		repeat
			temp = content
			content = mw.ustring.gsub(content, '\n(=+)[^\n]+%1%s*\n', '\n')
		until content == temp
		
		-- поне 4 букви в дума на кирилица
		local _, words = mw.ustring.gsub(content, '[а-я][а-я][а-я][а-я]+', '')
		if words >= 500 then
			-- мъниче с над 500 думи
			CATEGORY = CATEGORY .. '[[Категория:Мъничета с над 500 думи]]'
		elseif size >= 10000 then
			-- мъниче с размер над 10kb
			CATEGORY = CATEGORY .. '[[Категория:Мъничета над 10kb]]'
		end
	end
end

function p.get(frame)
	local stub = ''
	if frame.args[1] and frame.args[1] ~= '' then
		for i, theme in pairs(frame.args) do
			if theme ~= '' then
				local found = false
				for i=1, #THEMES do
					local themes = mw.text.split(THEMES[i][1], '|')
					for j=1, #themes do
						if toLower(theme) == toLower(themes[j]) then
							local plural = THEMES[i][3]
							stub = stub .. printStub(themes[1], THEMES[i][2], plural, THEMES[i]['link'])
							CATEGORY = string.format('%s[[%s за %s]]', CATEGORY, STUBCAT, plural and plural or themes[1])
							found = true
							break
						end
					end
				end
				
				if not found then
					stub = stub .. '<div><strong class="error">Грешка в записа: Неразпозната тема "' .. frame.args[i] .. '"</strong></div>'
					CATEGORY = CATEGORY .. '[[Категория:Страници с грешки]]'
				end
			end
		end
	else
		stub = printStub(nil, 'M Puzzle.png')
		CATEGORY = string.format('[[%s]]', STUBCAT)
	end
	
	if mw.title.getCurrentTitle().namespace == 0 then
		checkStubSize()
		stub = stub .. CATEGORY
	end
	
	return stub
end

return p
