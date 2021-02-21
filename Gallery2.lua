local p = {}

function p.get(frame)
	local args = frame.args
	local list = ''
	local i = 1
	while(args[i+1] ~= nil) do 
		list = list .. frame:preprocess('<gallery mode="packed-hover" heights=1000px>' .. args[i] .. '|' .. args[i+1] .. '</gallery>')
		i = i + 2
	end
	local root = mw.html.create('div')
		:css('width', '250px'):css('float', 'right'):css('clear', 'right')
		:wikitext(list)
		:done()
	
	return tostring(root)
end

return p
