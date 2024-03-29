--
-- This module implements {{Sidebar}}
--
require('Module:No globals')

local p = {}

local getArgs = require('Module:Arguments').getArgs
local navbar = require('Module:Navbar')._navbar

local function trimAndAddAutomaticNewline(s)
	-- For compatibility with the original {{sidebar with collapsible lists}}
	-- implementation, which passed some parameters through {{#if}} to trim
	-- their whitespace. This also triggered the automatic newline behavior.
	-- ([[meta:Help:Newlines and spaces#Automatic newline]])
	s = mw.ustring.gsub(s, "^%s*(.-)%s*$", "%1")
	if mw.ustring.find(s, '^[#*:;]') or mw.ustring.find(s, '^{|') then
		return '\n' .. s
	else
		return s
	end
end

local function hasSubgroup(s)
	if mw.ustring.find(s, 'vertical%-navbox%-subgroup') then
		return true
	else
		return false
	end
end

function p.sidebar(frame, args)
	if not args then
		args = getArgs(frame)
	end
	local root = mw.html.create()
	local child = args.child and mw.text.trim(args.child) == 'yes'

	root = root:tag('table')
	if not child then
		root 
			:addClass('vertical-navbox')
			:addClass(args.wraplinks ~= 'true' and 'nowraplinks' or nil)
			:addClass(args.bodyclass or args.class)
			:css('float', args.float or 'right')
			:css('clear', (args.float == 'none' and 'both') or args.float or 'right')
			:css('width', args.width or '22.0em')
			:css('margin', args.float == 'left' and '0 1.0em 1.0em 0' or '0 0 1.0em 1.0em')
			:css('background', '#f9f9f9')
			:css('border', '1px solid #aaa')
			:css('padding', '0.2em')
			:css('border-spacing', '0.4em 0')
			:css('text-align', 'center')
			:css('line-height', '1.4em')
			:css('font-size', '88%')
			:cssText(args.bodystyle or args.style)

		if args.outertitle then
			root
				:tag('caption')
					:addClass(args.outertitleclass)
					:css('padding-bottom', '0.2em')
					:css('font-size', '125%')
					:css('line-height', '1.2em')
					:css('font-weight', 'bold')
					:cssText(args.outertitlestyle)
					:wikitext(args.outertitle)
		end

		if args.topimage then
			local imageCell = root:tag('tr'):tag('td')

			imageCell
				:addClass(args.topimageclass)
				:css('padding', '0.4em 0')
				:cssText(args.topimagestyle)
				:wikitext(args.topimage)

			if args.topcaption then
				imageCell
					:tag('div')
						:css('padding-top', '0.2em')
						:css('line-height', '1.2em')
						:cssText(args.topcaptionstyle)
						:wikitext(args.topcaption)
			end
		end

		if args.pretitle then
			root
				:tag('tr')
					:tag('td')
						:addClass(args.pretitleclass)
						:cssText(args.basestyle)
						:css('padding-top', args.topimage and '0.2em' or '0.4em')
						:css('line-height', '1.2em')
						:cssText(args.pretitlestyle)
						:wikitext(args.pretitle)
		end
	else
		root
			:addClass('vertical-navbox-subgroup')
			:css('width', '100%')
			:css('margin', '0px')
			:css('border-spacing', '0px')
			:addClass(args.bodyclass or args.class)
			:cssText(args.bodystyle or args.style)
	end

	if args.title then
		if child then
			root
				:wikitext(args.title)
		else
			root
				:tag('tr')
					:tag('th')
						:addClass(args.titleclass)
						:cssText(args.basestyle)
						:css('padding', '0.2em 0.4em 0.2em')
						:css('padding-top', args.pretitle and 0)
						:css('font-size', '145%')
						:css('line-height', '1.2em')
						:cssText(args.titlestyle)
						:wikitext(args.title)
		end
	end

	if args.image then
		local imageCell = root:tag('tr'):tag('td')

		imageCell
			:addClass(args.imageclass)
			:css('padding', '0.2em 0 0.4em')
			:cssText(args.imagestyle)
			:wikitext(args.image)

		if args.caption then
			imageCell
				:tag('div')
					:css('padding-top', '0.2em')
					:css('line-height', '1.2em')
					:cssText(args.captionstyle)
					:wikitext(args.caption)
		end
	end

	if args.above then
		root
			:tag('tr')
				:tag('td')
					:addClass(args.aboveclass)
					:css('padding', '0.3em 0.4em 0.3em')
					:css('font-weight', 'bold')
					:cssText(args.abovestyle)
					:newline() -- newline required for bullet-points to work
					:wikitext(args.above)
	end

	local rowNums = {}
	for k, v in pairs(args) do
		k = '' .. k
		local num = k:match('^heading(%d+)$') or k:match('^content(%d+)$')
		if num then table.insert(rowNums, tonumber(num)) end
	end
	table.sort(rowNums)
	-- remove duplicates from the list (e.g. 3 will be duplicated if both heading3 and content3 are specified)
	for i = #rowNums, 1, -1 do
		if rowNums[i] == rowNums[i - 1] then
			table.remove(rowNums, i)
		end
	end

	for i, num in ipairs(rowNums) do
		local heading = args['heading' .. num]
		if heading then
			root
				:tag('tr')
					:tag('th')
						:addClass(args.headingclass)
						:css('padding', '0.1em')
						:cssText(args.basestyle)
						:cssText(args.headingstyle)
						:cssText(args['heading' .. num .. 'style'])
						:newline()
						:wikitext(heading)
		end

		local content = args['content' .. num]
		if content then
			root
				:tag('tr')
					:tag('td')
						:addClass(args.contentclass)
						:css('padding', hasSubgroup(content) and '0.1em 0 0.2em' or '0 0.1em 0.4em')
						:cssText(args.contentstyle)
						:cssText(args['content' .. num .. 'style'])
						:newline()
						:wikitext(content)
						:done()
					:newline() -- Without a linebreak after the </td>, a nested list like "* {{hlist| ...}}" doesn't parse correctly.
		end
	end

	if args.below then
		root
			:tag('tr')
				:tag('td')
					:addClass(args.belowclass)
					:css('padding', '0.3em 0.4em 0.3em')
					:css('font-weight', 'bold')
					:cssText(args.belowstyle)
					:newline()
					:wikitext(args.below)
	end

	if not child then
		local navbarArg = args.navbar or args.tnavbar
		if navbarArg ~= 'none' and navbarArg ~= 'off' and (args.name or mw.title.new( frame:getParent():getTitle() ).rootText ~= 'Sidebar') then
			root
				:tag('tr')
					:tag('td')
						:css('text-align', 'right')
						:css('font-size', '115%')
						:cssText(args.navbarstyle or args.tnavbarstyle)
						:wikitext(navbar{
							args.name,
							mini = 1,
							fontstyle = args.navbarfontstyle or args.tnavbarfontstyle
						})
		end
	end

	return tostring(root)
end

function p.collapsible(frame)
	local args = getArgs(frame)

	args.abovestyle = 'border-top: 1px solid #aaa; border-bottom: 1px solid #aaa;' .. (args.abovestyle or '')
	args.belowstyle = 'border-top: 1px solid #aaa; border-bottom: 1px solid #aaa;' .. (args.belowstyle or '')
	args.navbarstyle = 'padding-top: 0.6em;' .. (args.navbarstyle or args.tnavbarstyle or '')
	if not args.name and mw.title.new( frame:getParent():getTitle() ).rootText == 'Sidebar with collapsible lists' then
		args.navbar = 'none'
	end

	local contentArgs = {}

	for k, v in pairs(args) do
		local num = string.match(k, '^list(%d+)$')
		if num then
			local expand = args.expanded and (args.expanded == 'all' or args.expanded == args['list' .. num .. 'name'])

			local row = mw.html.create('div')
			row
				:addClass('mw-collapsible')
				:addClass((not expand) and 'mw-collapsed' or nil)
				:css('border', 'none')
				:css('padding', 0)
				:cssText(args.listframestyle)
				:cssText(args['list' .. num .. 'framestyle'])
				:tag('div')
					:addClass(args.listtitleclass)
					:css('font-size', '105%')
					:css('background', 'transparent')
					:css('text-align', 'left')
					:cssText(args.basestyle)
					:cssText(args.listtitlestyle)
					:cssText(args['list' .. num .. 'titlestyle'])
					:wikitext(trimAndAddAutomaticNewline(args['list' .. num .. 'title'] or 'List'))
					:done()
				:tag('div')
					:addClass('mw-collapsible-content')
					:addClass(args.listclass)
					:addClass(args['list' .. num .. 'class'])
					:css('font-size', '105%')
					:css('padding', '0.2em 0 0.4em')
					:css('text-align', 'center')
					:cssText(args.liststyle)
					:cssText(args['list' .. num .. 'style'])
					:wikitext(trimAndAddAutomaticNewline(args['list' .. num]))

			contentArgs['content' .. num] = tostring(row)
		end
	end

	for k, v in pairs(contentArgs) do
		args[k] = v
	end

	return p.sidebar(frame, args)
end

return p
