local p = {}

local THEMES = {
	{ 'биология|биология2|биология3', 'Butterfly template.png' },
	{ '...', '...' }
}

function p.get(frame)
	local themes = frame.args
	--for i=1, 10 do
	--	themes[i]
	--end
	local theme = 'биология'
	local pic = 'Butterfly template.png'
		
	local image = '[[File:' .. pic .. '|30x60п]]'
	local text = '\'\'Тази статия, свързана с [[' .. theme .. ']] все още е [[Уикипедия:Мъниче|мъниче]].  Помогнете на Уикипедия, като я [{{fullurl:{{FULLPAGENAME}}|action=edit}} редактирате] и разширите.\'\''
	local category = '[[Категория:Мъничета за ' .. theme .. ']]'
	
	local stub = mw.html.create()
		:tag('div')
			:addClass('boilerplate metadata plainlinks noprint')
			:css('margin-top', '1em')
			:css('display', 'table')
			:tag('div')
				:css('float', 'left')
				:css('width', '32px')
				:css('overflow', 'hidden')
				:wikitext(image)
				:done()
			:tag('div')
				:css('margin-left', '37px')
				:wikitext(text)
				:done()
			:done()
		:wikitext(category)
		:allDone()

	return tostring(stub)	
end

return p
