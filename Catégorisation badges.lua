local p = { }

local badgesList = {
	Q6540291 = 'избрани портали',
	Q6540326 = 'избрани теми',
	Q17437796 = 'избрани статии',
	Q17437798 = 'добри статии',
	Q17506997 = 'избрани списъци',
	Q17507019 = 'Проект:Знаете ли',
	Q17559452 = 'препоръчана статия',
	Q17580674 = 'избрани портали',
	Q17580678 = 'Статии А-клас',
	Q17580679 = 'Статии Б-клас',
	Q17580680 = 'Статии В-клас',
	Q17580682 = 'Статии с важно значение',
}

local badgesCategory = {
	Q17437796 = 'Избрани статии',
	Q17437798 = 'Добри статии',
	Q17506997 = 'Избрани списъци'  -- 'избрани списъци',
}

local linkCategoryPrefix = { 
	default = '',
}

local linkCategorySuffix = { 
	default = ' на друг език',
	afwiki = ' на африкански',
	alswiki = ' на елзаски',
	amwiki = ' на амхарски',
	anwiki = ' на арагонски',
	arwiki = ' на арабски',
	arzwiki = ' на египетски арабски',
	astwiki = ' на астурски',
	azwiki = ' на азербайджански',
	bawiki = ' на башкирски',
	barwiki = ' на австро-баварски',
	bat_smgwiki = ' на джамайски',
	bewiki = ' на беларуски',
	be_x_oldwiki = ' на беларуски',
	bgwiki = ' на български',
	bnwiki = ' на бенгалски',
	bpywiki = ' на бишнуприйски',
	brwiki = ' на бретонски',
	bswiki = ' на бошняшки',
	cawiki = ' на каталонски',
	cebwiki = ' на себуански',
	cswiki = ' на чешки',
	cvwiki = ' на чувашки',
	cywiki = ' на уелски',
	dawiki = ' на датски',
	dewiki = ' на немски',
	diqwiki = ' на зазаки',
	dvwiki = ' на дивехи',
	elwiki = ' на гръцки ',
	simplewiki = ' на английски',
	enwiki = ' на английски',
	eowiki = ' на есперанто',
	eswiki = ' на испански',
	etwiki = ' на естонски',
	euwiki = ' на баски',
	extwiki = ' на естремадурски',
	fawiki = ' на персийски',
	fiwiki = ' на фински',
	fowiki = ' на фарьорски',
	frwiki = '',
	frrwiki = ' на севернофризски',
	fywiki = ' на западнофризски',
	gawiki = ' на ирландски',
	gdwiki = ' на шотландски келтски',
	glwiki = ' на галисийски',
	guwiki = ' на гуджаратски',
	gvwiki = ' на менски',
	hewiki = ' на иврит',
	hiwiki = ' на хинди',
	hrwiki = ' на хърватски',
	htwiki = ' на хаитянски креолски',
	huwiki = ' на унгарски',
	hywiki = ' на арменски',
	iawiki = ' на интерлингуа',
	idwiki = ' на индонезийски',
	iswiki = ' на исландски',
	itwiki = ' на италиански',
	jawiki = ' на японски',
	jvwiki = ' на явански',
	kawiki = ' на грузински',
	klwiki = ' на гренландски',
	kkwiki = ' на казахски',
	kmwiki = ' на кхмерски',
	knwiki = ' на канадски',
	kowiki = ' на корейски',
	krcwiki = ' на карачаево-балкарски',
	kuwiki = ' на кюрдски',
	kvwiki = ' на коми',
	lawiki = ' на латински',
	lbwiki = ' на люксембургски',
	liwiki = ' на лимбургски',
	lmowiki = ' на ломбардски',
	lowiki = ' на лаоски',
	ltwiki = ' на литовски',
	lvwiki = ' на латвийски',
	map_bmswiki = ' на баньюмасански',
	mgwiki = ' на малгашки',
	mkwiki = ' на македонски',
	mlwiki = ' на малаялам',
	mrwiki = ' на маратхи',
	mswiki = ' на малайски',
	mtwiki = ' на малтийски',
	mywiki = ' на бирмански',
	nahwiki = ' на науатъл',
	nds_nlwiki = ' на долносаксонски',
	nlwiki = ' на нидерландски',
	nnwiki = ' на нюношк',
	nowiki = ' на норвежки',
	ocwiki = ' на окситански',
	piwiki = ' на пали',
	plwiki = ' на полски',
	ptwiki = ' на португалски',
	quwiki = ' на кечуа',
	rowiki = ' на румънски',
	ruwiki = ' на руски',
	sawiki = ' на санскрит',
	scowiki = ' на шотландски',
	shwiki = ' на сърбохърватски',
	skwiki = ' на словашки',
	slwiki = ' на словенски',
	sqwiki = ' на албански',
	srwiki = ' на сръбски',
	svwiki = ' на шведски',
	swwiki = ' на суахили',
	szlwiki = ' на силезийски',
	uzwiki = ' на узбекски',
	tawiki = ' на тамилски',
	tewiki = ' на телугу',
	thwiki = ' на тайски',
	tlwiki = ' на тагалог',
	tnwiki = ' на тсвана',
	trwiki = ' на турски',
	ttwiki = ' на татарски',
	ukwiki = ' на украински',
	urwiki = ' на урду',
	uzwiki = ' на узбекски',
	vecwiki = ' на венециански',
	viwiki = ' на виетнамски',
	vowiki = ' на волапюк',
	wawiki = ' на валонски',
	warwiki = ' на варайски',
	yiwiki = ' на идиш',
	yowiki = ' на йоруба',
	zhwiki = ' на китайски',
	zh_classicalwiki = ' на ласически китайски',
	zh_min_nanwiki = ' на южномински',
	zh_yuewiki = ' на кантонски',
}

function p.badgesCategory( frame )
	local entity = mw.wikibase.getEntity()
	local wikitext = {}
	local categoryNs = mw.site.namespaces[14].name
	if not entity then
		return ''
	end

	for siteid, linkTable in pairs( entity.sitelinks ) do
		if siteid ~= 'bgwiki' then
			for i, badgeId in ipairs( linkTable.badges ) do
				if badgesCategory[ badgeId ] then
					local main = badgesCategory[ badgeId ]
					local suffix = linkCategorySuffix[ siteid ] or linkCategorySuffix.default
					local category = string.format('[[%s:%s]]', categoryNs, main .. suffix )
					table.insert( wikitext, category )
				end
			end
		end
	end
	return table.concat( wikitext )
end

return p