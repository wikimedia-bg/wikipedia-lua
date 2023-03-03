-- This module implements [[Template:Random portal component]]

local p = {}

local mRandom = require('Module:Random')
local currentTitle = mw.title.getCurrentTitle()

-- tracking function added by BHG 29/04/2019
-- called as subPageTrackingCategories(pages, args.max)
local function subPageTrackingCategories(pages, max, header)
	local retval = "";
	local thispagetitle = mw.title.getCurrentTitle().text

	-- don't track DYK etc, only selected/featured articles, biogs etc
	if ((string.find(header, "/[sS]elected") == -1) and (string.find(header, "/[fF]eatured") == -1)) then
		return retval
	end
	-- no tracking unless we are in Portal namespace
	if (mw.title.getCurrentTitle().nsText ~= "Portal") then
		return ""
	end

	-- no tracking if this is a subpage
	if ((mw.ustring.match(thispagetitle, "/") ~= nil) and (thispagetitle ~= "AC/DC")) then
		return retval
	end

	local maxNum = tonumber(max)
	local availableSubPageCount = maxNum

	-- Check for missing subpages at end of alleged number range
	while availableSubPageCount > 0 and not mw.title.new(pages.subpage .. '/' .. tostring(availableSubPageCount)).exists do
		availableSubPageCount = availableSubPageCount - 1
	end
	if availableSubPageCount < maxNum then 
		retval = retval .. "[[Категория:Произволен портален компонент с по-малко налични подстраници от зададения максимум]]"
	else
		-- Check for spurious subpages beyond end of alleged number range
		while mw.title.new(pages.subpage .. '/' .. tostring(availableSubPageCount + 1)).exists do
			availableSubPageCount = availableSubPageCount + 1
		end
		if availableSubPageCount > maxNum then 
			retval = retval .. "[[Категория:Произволен портален компонент с повече налични подстраници от зададения максимум]]"
		end
	end

	-- before categorising, check what type of subpage we are categorising, and if detected, categorise images separately
	local subpageType = "subpages" -- generic type
	local subpageName = pages.subpage
	subpageName = mw.ustring.gsub(subpageName, "^[^/]*/", "")
	subpageName = mw.ustring.lower(subpageName)
	if ((mw.ustring.find(subpageName, "picture", 1, true) ~= nil) or
		(mw.ustring.find(subpageName, "image", 1, true) ~= nil) or
		(mw.ustring.find(subpageName, "panorama", 1, true) ~= nil)) then
		subpageType = "image subpages"
	end
	if (availableSubPageCount < 2) then
		retval = retval .. "[[Категория:Произволен портален компонент с по-малко от 2 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 5) then
		retval = retval .. "[[Категория:Произволен портален компонент с 2-5 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 10) then
		retval = retval .. "[[Категория:Произволен портален компонент с 6-10 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 15) then
		retval = retval .. "[[Категория:Произволен портален компонент с 11-15 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 20) then
		retval = retval .. "[[Категория:Произволен портален компонент с 16-20 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 25) then
		retval = retval .. "[[Категория:Произволен портален компонент с 21-25 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 30) then
		retval = retval .. "[[Категория:Произволен портален компонент с 26-30 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 40) then
		retval = retval .. "[[Категория:Произволен портален компонент с 31-40 налични " .. subpageType .. "]]"
	elseif (availableSubPageCount <= 50) then
		retval = retval .. "[[Категория:Произволен портален компонент с 41-50 налични " .. subpageType .. "]]"
	else
		retval = retval .. "[[Категория:Произволен портален компонент с повече от 50 налични " .. subpageType .. "]]"
	end
	return retval;
end
local function getRandomNumber(max)
	-- gets a random integer between 1 and max; max defaults to 1
	return mRandom.number{max or 1}
end

local function expandArg(args, key)
	-- Emulate how unspecified template parameters appear in wikitext. If the
	-- specified argument exists, its value is returned, and if not the argument
	-- name is returned inside triple curly braces.
	local val = args[key]
	if val then
		return val
	else
		return string.format('{{{%s}}}', key)
	end
end

local function getPages(args)
	local pages = {}
	pages.root = args.rootpage or currentTitle.prefixedText
	pages.subpage = pages.root .. '/' .. expandArg(args, 'subpage')
	local tries = 10
	repeat
		pages.random = pages.subpage .. '/' .. getRandomNumber(args.max)
		tries = tries - 1
	until tries < 1 or mw.title.new(pages.random).exists
	pages.footer = 'Шаблон:Портал:Кутия-Край'
	return pages
end

local function tryExpandTemplate(frame, title, args)
	local success, result = pcall(frame.expandTemplate, frame, {title = title, args = args})
	if success then
		return result
	else
		local msg = string.format(
			'<strong class="error">The page "[[%s]]" does not exist.</strong>',
			title
		)
		if mw.title.getCurrentTitle().namespace == 100 then -- is in the portal namespace
			msg = msg .. '[[Категория:Портали, изискващи внимание]]'
		end
		return msg
	end
end

local function getHeader(frame, pages, header, template)
	return tryExpandTemplate(
		frame,
		template or pages.root .. '/Кутия-Заглавка',
		{header, pages.random}
	)
end

local function getRandomSubpageContent(frame, pages)
	return tryExpandTemplate(
		frame,
		pages.random
	)
end

local function getFooter(frame, pages, link)
	return tryExpandTemplate(
		frame,
		pages.footer,
		{link}
	)
end

function p._main(args, frame)
	frame = frame or mw.getCurrentFrame()
	local pages = getPages(args)

	local ret = {}
	ret[#ret + 1] = getHeader(frame, pages, args.header or 'subpage', args.headertemplate)
	ret[#ret + 1] = getRandomSubpageContent(frame, pages)
	if not args.footer or not args.footer:find('%S') then
		ret[#ret + 1] = '<div style="clear:both;"></div></div>'
	else
		ret[#ret + 1] = getFooter(frame, pages, string.format(
			'[[%s|%s]]',
			pages.subpage,
			expandArg(args, 'footer')
		))
	end

	return table.concat(ret, '\n') .. subPageTrackingCategories(pages, args.max, args.header)
end

function p._nominate(args, frame)
	frame = frame or mw.getCurrentFrame()
	local pages = getPages(args)
	
	local ret = {}
	ret[#ret + 1] = getHeader(frame, pages, expandArg(args, 'header'), args.headertemplate)
	ret[#ret + 1] = getRandomSubpageContent(frame, pages)
	ret[#ret + 1] = getFooter(frame, pages, string.format(
		'[[/Nominate/%s|Предложи]] • [[%s|%s]] ',
		expandArg(args, 'subpage'),
		pages.subpage,
		args.footer or 'Архив'
	))

	return table.concat(ret, '\n') .. subPageTrackingCategories(pages, args.max, args.header)
end

local function makeInvokeFunction(func)
	return function (frame)
		local args = require('Module:Arguments').getArgs(frame, {
			trim = false,
			removeBlanks = false,
			wrappers = {
				'Template:Random portal component',
				'Template:Random portal component/BHG-test',
				'Template:Random portal component with nominate'
			}
		})
		return func(args, frame)
	end
end

p.main = makeInvokeFunction(p._main)
p.nominate = makeInvokeFunction(p._nominate)

return p
