-- This module implements {{userbox}}.

local getArgs = require('Module:Arguments').getArgs
local categoryHandler = require('Module:Category handler').main

local p = {}

--------------------------------------------------------------------------------
-- Helper functions
--------------------------------------------------------------------------------

local function checkNum(val, default)
	-- Checks whether a value is a number greater than or equal to zero. If so,
	-- returns it as a number. If not, returns a default value.
	val = tonumber(val)
	if val and val >= 0 then
		return val
	else
		return default
	end
end

local function addSuffix(num, suffix)
	-- Turns a number into a string and adds a suffix.
	if num then
		return tostring(num) .. suffix
	else
		return nil
	end
end

local function checkNumAndAddSuffix(num, default, suffix)
	-- Checks a value with checkNum and adds a suffix.
	num = checkNum(num, default)
	return addSuffix(num, suffix)
end

local function makeCat(cat, sort)
	-- Makes a category link.
	if sort then
		return mw.ustring.format('[[Category:%s|%s]]', cat, sort)
	else
		return mw.ustring.format('[[Category:%s]]', cat)
	end
end

local function checkImageExists(image)
	-- Checks if some image file exists in Wikipedia and return it like text or image template
	if (image ~= null and string.sub(image,1,5) == 'File:') then
		return '[[' .. image .. '|40п]]'
	else
		return image
	end
end

--------------------------------------------------------------------------------
-- Argument processing
--------------------------------------------------------------------------------

local function makeInvokeFunc(funcName)
	return function (frame)
		local args = getArgs(frame)
		return p.main(funcName, args)
	end
end

p.userbox = makeInvokeFunc('_userbox')
p['userbox-2'] = makeInvokeFunc('_userbox-2')
p['userbox-r'] = makeInvokeFunc('_userbox-r')

--------------------------------------------------------------------------------
-- Main functions
--------------------------------------------------------------------------------

function p.main(funcName, args)
	local userboxData = p[funcName](args)
	local userbox = p.render(userboxData)
	local cats = p.categories(args)
	return userbox .. (cats or '')
end

function p._userbox(args)
	-- Does argument processing for {{userbox}}.
	local data = {}

	-- Get div tag values.
	data.float = args.float or 'right'
	local borderWidthNum = checkNum(args['border-w'], 1) -- Used to calculate width.
	data.borderWidth = addSuffix(borderWidthNum, 'px')
	data.borderColor = args['border-c'] or args[3] or '#999'
	data.width = addSuffix(240 - 2 * borderWidthNum, 'px') -- Also used in the table tag.
	data.bodyClass = args.bodyclass

	-- Get id values.
	local id = args.logo or args.id or checkImageExists(args[1])
	data.id = id
	data.showId = id and true or false
	data.idWidth = checkNumAndAddSuffix(args['id-w'], 45, 'px')
	data.idHeight = checkNumAndAddSuffix(args['id-h'], 45, 'px')
	data.idBackgroundColor = args['id-c'] or args[4] or '#ddd'
	data.idTextAlign = args['id-a'] or 'center'
	data.idFontSize = checkNumAndAddSuffix(args['id-s'], 14, 'pt')
	data.idColor = args['id-fc'] or args[6] or 'black'
	data.idPadding = args['id-p'] or '1px'
	data.idLineHeight = args['id-lh'] or '1.25em'
	data.idOtherParams = args['id-other']
	data.idClass = args['id-class']

	-- Get info values.
	data.info = args.info or args[2]
	data.infoTextAlign = args['info-a'] or 'center'
	data.infoFontSize = checkNumAndAddSuffix(args['info-s'], 8, 'pt')
	data.infoHeight = checkNumAndAddSuffix(args['id-h'], 45, 'px')
	data.infoBackgroundColor = args['info-c'] or args[5] or '#eee'
	data.infoPadding = args['info-p'] or '0 4px 0 4px'
	data.infoLineHeight = args['info-lh'] or '1.25em'
	data.infoColor = args['info-fc'] or args[7] or 'black'
	data.infoOtherParams = args['info-other']
	data.infoClass = args['info-class']

	return data
end

p['_userbox-2'] = function (args)
	-- Does argument processing for {{userbox-2}}.
	local data = {}

	-- Get div tag values.
	data.float = args.float or 'right'
	local borderWidthNum = checkNum(args['border-w'], 1) -- Used to calculate width.
	data.borderWidth = addSuffix(borderWidthNum, 'px')
	data.borderColor = args['border-c'] or args[3] or '#999'
	data.width = addSuffix(240 - 2 * borderWidthNum, 'px') -- Also used in the table tag.
	data.bodyClass = args.bodyclass

	-- Get id values.
	data.showId = true
	data.id = args.logo or args.id1 or checkImageExists(args[1])
	data.idWidth = checkNumAndAddSuffix(args['id1-w'], 45, 'px')
	data.idHeight = checkNumAndAddSuffix(args['id-h'], 45, 'px')
	data.idBackgroundColor = args['id1-c'] or args[4] or '#ddd'
	data.idTextAlign = 'center'
	data.idFontSize = checkNumAndAddSuffix(args['id1-s'], 14, 'pt')
	data.idLineHeight = args['id1-lh'] or '1.25em'
	data.idColor = args['id1-fc'] or 'black'
	data.idPadding = args['id1-p'] or '1px'
	data.idOtherParams = args['id1-other']

	-- Get info values.
	data.info = args.info or args[2]
	data.infoTextAlign = args['info-a'] or 'center'
	data.infoFontSize = checkNumAndAddSuffix(args['info-s'], 8, 'pt')
	data.infoColor = args['info-fc'] or args[7] or 'black'
	data.infoBackgroundColor = args['info-c'] or args[5] or '#eee'
	data.infoPadding = args['info-p'] or '0 4px 0 4px'
	data.infoLineHeight = args['info-lh'] or '1.25em'
	data.infoOtherParams = args['info-other']

	-- Get id2 values.
	data.showId2 = true
	data.id2 = args.logo or checkImageExists(args.id2)
	data.id2Width = checkNumAndAddSuffix(args['id2-w'], 45, 'px')
	data.id2Height = data.idHeight
	data.id2BackgroundColor = args['id2-c'] or args[4] or '#ddd'
	data.id2TextAlign = 'center'
	data.id2FontSize = checkNumAndAddSuffix(args['id2-s'], 14, 'pt')
	data.id2LineHeight = args['id2-lh'] or '1.25em'
	data.id2Color = args['id2-fc'] or 'black'
	data.id2Padding = args['id2-p'] or '0 0 0 1px'
	data.id2OtherParams = args['id2-other']

	return data
end

p['_userbox-r'] = function (args)
	-- Does argument processing for {{userbox-r}}.
	local data = {}

	-- Get div tag values.
	data.float = args.float or 'right'
	local borderWidthNum = checkNum(args['border-w'], 1) -- Used to calculate width.
	data.borderWidth = addSuffix(borderWidthNum, 'px')
	data.borderColor = args['border-c'] or args[3] or '#999'
	data.width = addSuffix(240 - 2 * borderWidthNum, 'px') -- Also used in the table tag.
	data.bodyClass = args.bodyclass
	
	-- Get id values.
	data.showId = false -- We only show id2 in userbox-r.

	-- Get info values.
	data.info = args.info or args[2]
	data.infoTextAlign = args['info-a'] or 'center'
	data.infoFontSize = checkNumAndAddSuffix(args['info-s'], 8, 'pt')
	data.infoPadding = args['info-p'] or '0 4px 0 4px'
	data.infoLineHeight = args['info-lh'] or '1.25em'
	data.infoBackgroundColor = args['info-c'] or args[5] or '#eee'
	data.infoColor = args['info-fc'] or args[7] or 'black'
	data.infoOtherParams = args['info-other']
	
	-- Get id2 values.
	data.showId2 = true
	data.id2 = args.logo or args.id or checkImageExists(args[1]) or 'id'
	data.id2Width = checkNumAndAddSuffix(args['id-w'], 45, 'px')
	data.id2Height = checkNumAndAddSuffix(args['id-h'], 45, 'px')
	data.id2BackgroundColor = args['id-c'] or args[4] or '#ddd'
	data.id2TextAlign = args['id-a'] or 'center'
	data.id2FontSize = checkNumAndAddSuffix(args['id-s'], 14, 'pt')
	data.id2Color = args['id-fc'] or args[6] or 'black'
	data.id2Padding = args['id-p'] or '0 0 0 1px'
	data.id2LineHeight = args['id-lh'] or '1.25em'
	data.id2OtherParams = args['id-other']

	return data
end

function p.render(data)
	-- Renders the userbox html using the content of the data table.
	-- Render the div tag html.
	local root = mw.html.create('div')
	root
		:css('float', data.float)
		:css('border', (data.borderWidth or '') .. ' solid ' .. (data.borderColor or ''))
		:css('margin', '1px')
		:css('width', data.width)
		:addClass('wikipediauserbox')
		:addClass(data.bodyClass)

	-- Render the table tag html.
	local tableroot = root:tag('table')
	tableroot
		:css('width', data.width)
		:css('margin-bottom', '0')
		:css('border-collapse', 'collapse')
	
	-- Render the id html.
	local tablerow = tableroot:tag('tr')
	if data.showId then
		tablerow:tag('th')
			:css('border', '0')
			:css('width', data.idWidth)
			:css('height', data.idHeight)
			:css('background', data.idBackgroundColor)
			:css('text-align', data.idTextAlign)
			:css('font-size', data.idFontSize)
			:css('color', data.idColor)
			:css('padding', data.idPadding)
			:css('line-height', data.idLineHeight)
			:css('vertical-align', 'middle')
			:cssText(data.idOtherParams)
			:addClass(data.idClass)
			:wikitext(data.id)
	end

	-- Render the info html.
	tablerow:tag('td')
		:css('border', '0')
		:css('text-align', data.infoTextAlign)
		:css('font-size', data.infoFontSize)
		:css('font-weight', 'bold')
		:css('padding', data.infoPadding)
		:css('height', data.infoHeight)
		:css('line-height', data.infoLineHeight)
		:css('color', data.infoColor)
		:css('vertical-align', 'middle')
		:css('background-color', data.infoBackgroundColor)
		:cssText(data.infoOtherParams)
		:addClass(data.infoClass)
		:wikitext(data.info)
	
	-- Render the second id html.
	if data.showId2 then
		tablerow:tag('th')
			:css('border', '0')
			:css('width', data.id2Width)
			:css('height', data.id2Height)
			:css('background', data.id2BackgroundColor)
			:css('text-align', data.id2TextAlign)
			:css('font-size', data.id2FontSize)
			:css('color', data.id2Color)
			:css('padding', data.id2Padding)
			:css('line-height', data.id2LineHeight)
			:css('vertical-align', 'middle')
			:cssText(data.id2OtherParams)
			:wikitext(data.id2)
	end

	return tostring(root)
end

function p.categories(args, page)
	-- Gets categories from [[Module:Category handler]].
	-- The page parameter makes the function act as though the module was being called from that page.
	-- It is included for testing purposes.
	local cats = {}
	cats[#cats + 1] = args.category or args[8]
	cats[#cats + 1] = args.category2
	cats[#cats + 1] = args.category3
	if #cats > 0 and mw.title.getCurrentTitle().nsText ~= 'Шаблон' then
		-- Get the title object
		local title
		if page then
			title = mw.title.new(page)
		else
			title = mw.title.getCurrentTitle()
		end
		-- Build category handler arguments.
		local chargs = {}
		chargs.page = page
		chargs.nocat = args.nocat
		if args.notcatsubpages then
			chargs.subpage = 'no'
		end
		-- User namespace.
		local user = ''
		for i, cat in ipairs(cats) do
			user = user .. makeCat(cat)
		end
		chargs.user = user
		-- Template namespace.
		local basepage = title.baseText
		local template = ''
		for i, cat in ipairs(cats) do
			template = template .. makeCat(cat, ' ' .. basepage)
		end
		chargs.template = template
		return categoryHandler(chargs)
	else
		return nil
	end
end

return p