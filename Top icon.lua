local p = {}

function p.main(frame)
	local args = {}
	local argsRelative = frame:getRelative().args

	--Empty parameters performed by Lua
	for cle, val in pairs(argsRelative) do
		if val ~= '' then
			args[cle] = mw.text.trim(val)
		end
	end

	return p._main(args)
end

function p._main(args)
	local res = mw.html.create()
	local iconeTitle = mw.html.create()
	local frame = mw.getCurrentFrame()
	local fileWiki = '[[File:%s|%spx|link=%s|%s|%s|alt=%s]]'
	local argsId = args.id
	local nowiki = frame:extensionTag{name = 'nowiki'}

	iconeTitre
 		:wikitext(mw.ustring.format(fichierWiki,
			args.image or 'Fairytale bookmark.png',
			args.size or 20,
			args.link or 'Модул:Top icon',
			args['parameter'] or '',
			args.text or 'Примерен текст',
			args.text or 'Примерен текст'))

	if not args.id then
		local nsPage = mw.title.getCurrentTitle().namespace
		if nsPage == 2 or nsPage == 3 then
			argsId = args.image or 'Fairytale bookmark.png'
		end
	end

	res:wikitext(frame:extensionTag('indicator', tostring(iconeTitre), {name = argsId}))

	if not args.id then
		res:wikitext('[[Категория:Страници без идентични икони]]')
	end

	return nowiki .. tostring(res)
end

return p