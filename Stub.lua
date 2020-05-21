local p = {}

local THEMES = {
	{ 'биология|биология2|биология3', 'Butterfly template.png' },
	{ '...', '...' }
}

local function printStub(theme, image)
	local imageLink = string.format('[[File:%s|30x60п]]', image)
	local link = tostring(mw.uri.canonicalUrl(mw.title.getCurrentTitle().fullText, 'action=edit'))
	local stubLink = '[[Уикипедия:Мъниче|мъниче]]'
	local text = string.format("''Тази статия, свързана с [[%s]] все още е %s. Помогнете на Уикипедия, като я [%s редактирате] и разширите.''", theme, stubLink, link)
	local stub = mw.html.create()
		:tag('div')
			:addClass('plainlinks')
			:css('margin-top', '1em')
			:css('display', 'table')
			:tag('div')
				:css('float', 'left')
				:css('width', '32px')
				:css('overflow', 'hidden')
				:wikitext(imageLink)
				:done()
			:tag('div')
				:css('margin-left', '37px')
				:wikitext(text)
				:allDone()
	
	return tostring(stub)
end

function p.get(frame)
	local themes = frame.args
	--for i=1, 10 do
	--	themes[i]
	--end
	local theme = 'биология'
	local image = 'Butterfly template.png'
	
	local stub = printStub(theme, image)
	
	if mw.title.getCurrentTitle().namespace == 0 then
		stub = stub .. '[[Категория:Мъничета за ' .. theme .. ']]'
	end
	
	return stub
end

return p
