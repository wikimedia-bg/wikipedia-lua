-- This module implements {{Infobox}}
local p = {}
local args = {}
local origArgs
local root
local cats = {}
local colspan = 12

local function fixInput(str)
	if str then
		-- Add newline when a string begins and ends with
		-- wikilists
		str = mw.ustring.gsub(str, '^([%*#;:])', '\n%1')
		str = mw.ustring.gsub(str, '(\n[%*#;:][^\r\n]*)$', '%1\n')
		-- wikitables
		str = mw.ustring.gsub(str, '^(%{%|)', '\n%1')
		str = mw.ustring.gsub(str, '(\n%|%})$', '%1\n')
		-- wikihorizontal rules
		str = mw.ustring.gsub(str, '^(%-%-%-%-+)', '\n%1')
		str = mw.ustring.gsub(str, '(\n%-%-%-%-+)$', '%1\n')
		-- remove categories from cells
		-- add them in a separate table
		str = mw.ustring.gsub(str, '(%[%[([^%[%]]-):[^%[%]]+%]%])', function (m, subm)
			subm = mw.text.trim(mw.ustring.lower(subm))
			if subm ~= 'категория' and subm ~= 'category' then return m end
			table.insert(cats, m)
			return ''
		end)
		if mw.ustring.match(str, '^%s*$') then str = nil end
	end
	return str
end

local function cleanInfobox(str)
	local last
	repeat
		last = str
		-- Remove empty row with other nested rows in it
		-- This occurs when an infobox with 'child' parameter is placed
		-- immediately inside a data, label or header cell
		-- and no other content precedes it/follows it
		str = mw.ustring.gsub(str, '<[Tt][Rr][^<>]*>%s*<[Tt][DdHh][^<>]*>%s*(<[Tt][Rr][^<>]*>%s*<[Tt][DdHh][^<>]*>)', '%1')
		str = mw.ustring.gsub(str, '(</[Tt][DdHh]%s*>%s*</[Tt][Rr]%s*>)%s*</[Tt][DdHh]%s*>%s*</[Tt][Rr]%s*>', '%1')
		-- Remove an empty table/infobox
		str = mw.ustring.gsub(str, '<[Tt][Aa][Bb][Ll][Ee][^<>]*>%s*</[Tt][Aa][Bb][Ll][Ee]%s*>', '')
		-- Remove empty cell rows
		str = mw.ustring.gsub(str, '<[Tt][Rr][^<>]*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*</[Tt][Rr]%s*>', '')
		str = mw.ustring.gsub(str, '<[Tt][Rr][^<>]*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*</[Tt][Rr]%s*>', '')
		str = mw.ustring.gsub(str, '<[Tt][Rr][^<>]*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*</[Tt][Rr]%s*>', '')
		str = mw.ustring.gsub(str, '<[Tt][Rr][^<>]*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*<[Tt][DdHh][^<>]*>%s*</[Tt][DdHh]%s*>%s*</[Tt][Rr]%s*>', '')
	until str == last
	return str
end

local function noMobileHRRow(str)
	-- Add class 'nomobile' when a row contains only horizontal rule
	if str and (mw.ustring.match(str, '^%s*%-%-%-%-+%s*$') or mw.ustring.match(str, '^%s*<[Hh][Rr][^<>]*>%s*$')) then
		return 'nomobile'
	end
	return nil
end

local function union(t1, t2)
	-- Returns the union of the values of two tables, as a sequence.
	local vals = {}
	for k, v in pairs(t1) do
		vals[v] = true
	end
	for k, v in pairs(t2) do
		vals[v] = true
	end
	local ret = {}
	for k, v in pairs(vals) do
		table.insert(ret, k)
	end
	return ret
end

local function getArgNums(prefix, suffix)
	-- Returns a table containing the numbers of the arguments that exist
	-- for the specified prefix. For example, if the prefix was 'data', and
	-- 'data1', 'data2', and 'data5' exist, it would return {1, 2, 5}.
	local nums = {}
	for k, v in pairs(args) do
		local num = tostring(k):match('^' .. prefix .. '([1-9]%d*)' .. (suffix or '') .. '$')
		if num then table.insert(nums, tonumber(num)) end
	end
	table.sort(nums)
	return nums
end

local function addRow(rowArgs)
	-- Adds a row to the infobox, with either a header cell
	-- or a label/data cell combination.
	rowArgs.header = fixInput(rowArgs.header)
	rowArgs.label = fixInput(rowArgs.label)
	rowArgs.data_a = fixInput(rowArgs.data_a)
	rowArgs.data_b = fixInput(rowArgs.data_b)
	rowArgs.data_c = fixInput(rowArgs.data_c)
	if rowArgs.header and mw.ustring.lower(rowArgs.header) ~= '_blank_' and mw.ustring.lower(rowArgs.header) ~= '_empty_' and mw.ustring.lower(rowArgs.header) ~= '_none_' then
		root
			:tag('tr')
				:addClass(noMobileHRRow(rowArgs.header))
				:addClass(rowArgs.rowclass)
				:cssText(rowArgs.rowstyle)
				:tag('th')
					:attr('colspan', colspan)
					:attr('scope', 'colgroup')
					:addClass(rowArgs.class)
					:addClass(args.headerclass)
					:css('text-align', 'center')
					:cssText(args.headerstyle)
					:cssText(rowArgs.headerstyle)
					:wikitext(rowArgs.header)
					:done()
	elseif rowArgs.data_a or rowArgs.data_b or rowArgs.data_c then
		local cells = 4
		if not rowArgs.label then cells = cells - 1 end
		if not rowArgs.data_a then cells = cells - 1 end
		if not rowArgs.data_b then cells = cells - 1 end
		if not rowArgs.data_c then cells = cells - 1 end
		local row = root:tag('tr')
		if cells == 1 then
			row:addClass(noMobileHRRow(rowArgs.data_a or rowArgs.data_b or rowArgs.data_c))
		end
		row
			:addClass(rowArgs.rowclass)
			:cssText(rowArgs.rowstyle)
		if rowArgs.label then
			row
				:tag('th')
					:attr('colspan', colspan/cells)
					:attr('scope', 'row')
					:css('text-align', 'left')
					:cssText(args.labelstyle)
					:cssText(rowArgs.labelstyle)
					:wikitext(rowArgs.label)
					:done()
		end
		if rowArgs.data_a then
			row
				:tag('td')
					:attr('colspan', colspan/cells)
					:addClass(rowArgs.class_a)
					:css('text-align', not (rowArgs.label or rowArgs.data_b or rowArgs.data_c) and 'center' or nil)
					:cssText(rowArgs.datastyle_a)
					:cssText(rowArgs.datastylenum_a)
					:wikitext(rowArgs.data_a)
					:done()
		end
		if rowArgs.data_b then
			row
				:tag('td')
					:attr('colspan', colspan/cells)
					:addClass(rowArgs.class_b)
					:css('text-align', not (rowArgs.label or rowArgs.data_a or rowArgs.data_c) and 'center' or nil)
					:cssText(rowArgs.datastyle_b)
					:cssText(rowArgs.datastylenum_b)
					:wikitext(rowArgs.data_b)
					:done()
		end
		if rowArgs.data_c then
			row
				:tag('td')
					:attr('colspan', colspan/cells)
					:addClass(rowArgs.class_c)
					:css('text-align', not (rowArgs.label or rowArgs.data_a or rowArgs.data_b) and 'center' or nil)
					:cssText(rowArgs.datastyle_c)
					:cssText(rowArgs.datastylenum_c)
					:wikitext(rowArgs.data_c)
					:done()
		end
	end
end

local function renderTitle()
	args.title = fixInput(args.title)
	if not args.title then return end

	root
		:tag('caption')
			:addClass(args.titleclass)
			:cssText(args.titlestyle)
			:wikitext(args.title)
end

local function renderAboveRow()
	args.above = fixInput(args.above)
	if not args.above then return end

	root
		:tag('tr')
			:tag('th')
				:attr('colspan', colspan)
				:addClass(args.aboveclass)
				:css('text-align', 'center')
				:css('font-size', '125%')
				:css('font-weight', 'bold')
				:cssText(args.abovestyle)
				:wikitext(args.above)
				:done()
end

local function commonsBelow()
	local commons
	local entity = mw.wikibase.getEntity()
	local success, val = pcall(function() return entity['claims']['P373'][1]['mainsnak']['datavalue']['value'] end) -- Commons category property value

	if success then
		commons = 'Category:' .. val
	else
		success, val = pcall(function() return entity['claims']['P935'][1]['mainsnak']['datavalue']['value'] end) -- Commons gallery property value
		if success then
			commons = val
		else
			success, val = pcall(function() return entity['sitelinks']['commonswiki']['title'] end) -- Commons link value from multilanguage sites links menu
			if success then commons = val end
		end
	end

	if commons then
		return '<b class="plainlinks">[' .. tostring(mw.uri.fullUrl(':c:' .. commons, 'uselang=bg')) .. ' ' .. mw.ustring.gsub(mw.title.getCurrentTitle().text, '%s+%b()$', '') .. ']</b> в [[Общомедия]]'
	end

	return nil
end

local function renderBelowRow()
	if not (args.child or args.subbox) then
		args.below = args.below or commonsBelow() -- Get commons only when an infobox doesn't have subbox/child params
	end
	args.below = fixInput(args.below)
	if not args.below then return end

	root
		:tag('tr')
			:tag('td')
				:attr('colspan', colspan)
				:addClass(args.belowclass)
				:css('text-align', 'center')
				:cssText(args.belowstyle)
				:wikitext(args.below)
				:done()
end

local function renderSubheaders()
	if args.subheader then
		args.subheader1 = args.subheader
	end
	if args.subheaderrowclass then
		args.subheaderrowclass1 = args.subheaderrowclass
	end
	local subheadernums = getArgNums('subheader')
	for k, num in ipairs(subheadernums) do
		addRow({
			rowclass = args['subheaderrowclass' .. num],
			data_a = args['subheader' .. num],
			datastyle_a = args.subheaderstyle,
			datastylenum_a = args['subheaderstyle' .. num],
			class_a = args.subheaderclass,
		})
	end
end

local function renderImages()
	if args.image then
		args.image1 = args.image
	end
	if args.caption then
		args.caption1 = args.caption
	end
	local imagenums = getArgNums('image')
	for k, num in ipairs(imagenums) do
		local caption = fixInput(args['caption' .. num])
		local data = mw.html.create():wikitext(args['image' .. num])
		if caption then
			data
				:tag('div')
					:cssText(args.captionstyle)
					:wikitext(caption)
		end
		addRow({
			rowclass = args['imagerowclass' .. num],
			data_a = tostring(data),
			datastyle_a = args.imagestyle,
		})
	end
end

local function preprocessRows()
	if not args.autoheaders then return end

	local rownums = union(getArgNums('header'), getArgNums('data'))
	table.sort(rownums)
	local lastheader
	for k, num in ipairs(rownums) do
		if args['header' .. num] then
			if lastheader then
				args['header' .. lastheader] = nil
			end
			lastheader = num
		elseif args['data' .. num] or args['data' .. num .. 'a'] or args['data' .. num .. 'b'] or args['data' .. num .. 'c'] then
			lastheader = nil
		end
	end
	if lastheader then
		args['header' .. lastheader] = nil
	end
end

local function renderRows()
	-- Gets the union of the header and data argument numbers,
	-- and renders them all in order using addRow.
	local rownums = union(getArgNums('header'), getArgNums('data', '[abc]?'))
	table.sort(rownums)
	for k, num in ipairs(rownums) do
		addRow({
			rowclass = args['rowclass' .. num],
			rowstyle = args['rowstyle' .. num],
			header = args['header' .. num],
			headerstyle = args['headerstyle' .. num],
			label = args['label' .. num],
			labelstyle = args['labelstyle' .. num],
			data_a = args['data' .. num] or args['data' .. num .. 'a'],
			data_b = args['data' .. num .. 'b'],
			data_c = args['data' .. num .. 'c'],
			datastyle_a = args.datastyle or args.datastylea,
			datastyle_b = args.datastyle or args.datastyleb,
			datastyle_c = args.datastyle or args.datastylec,
			datastylenum_a = args['datastyle' .. num] or args['datastyle' .. num .. 'a'],
			datastylenum_b = args['datastyle' .. num .. 'b'],
			datastylenum_c = args['datastyle' .. num .. 'c'],
			class_a = args['class' .. num] or args['class' .. num .. 'a'],
			class_b = args['class' .. num .. 'b'],
			class_c = args['class' .. num .. 'c']
		})
	end
end

local function renderNavBar()
	if not args.name then return end

	root
		:tag('tr')
			:tag('td')
				:attr('colspan', colspan)
				:css('text-align', 'right')
				:wikitext(mw.getCurrentFrame():expandTemplate({
					title = 'navbar',
					args = { args.name, mini = 1 }
				}))
end

local function renderItalicTitle()
	local italicTitle = args['italic title'] and mw.ustring.lower(args['italic title'])
	if italicTitle == '' or italicTitle == 'force' or italicTitle == 'yes' then
		return mw.getCurrentFrame():expandTemplate({title = 'italic title'})
	end
	return ''
end

local function _infobox()
	-- Specify the overall layout of the infobox, with special settings
	-- if the infobox is used as a 'child' inside another infobox.
	if args.child ~= 'yes' then
		root = mw.html.create('table')

		root
			:addClass('infobox infobox-lua')
			:addClass(args.bodyclass)

			if args.subbox == 'yes' then
				root
					:css('padding', '0')
					:css('border', 'none')
					:css('margin', '-3px')
					:css('width', 'auto')
					:css('min-width', '100%')
					:css('font-size', '100%')
					:css('clear', 'none')
					:css('float', 'none')
					:css('background-color', 'transparent')
			else
				root:css('width', '22em')
			end
		root:cssText(args.bodystyle)

		renderTitle()
		renderAboveRow()
	else
		root = mw.html.create()
		
		root:wikitext(args.title)
	end

	renderSubheaders()
	renderImages()
	preprocessRows()
	renderRows()
	renderBelowRow()
	renderNavBar()

	return cleanInfobox(tostring(root)) .. renderItalicTitle() .. table.concat(cats)
end

local function preprocessSingleArg(argName)
	-- If the argument exists and isn't blank, add it to the argument table.
	-- Blank arguments are treated as nil to match the behaviour of ParserFunctions.
	if origArgs[argName] and origArgs[argName] ~= '' then
		args[argName] = origArgs[argName]
	end
end

local function preprocessArgs(prefixTable, step)
	-- Assign the parameters with the given prefixes to the args table, in order, in batches
	-- of the step size specified. This is to prevent references etc. from appearing in the
	-- wrong order. The prefixTable should be an array containing tables, each of which has
	-- two possible fields, a "prefix" string and a "depend" table. The function always parses
	-- parameters containing the "prefix" string, but only parses parameters in the "depend"
	-- table if the prefix parameter is present and non-blank.
	if type(prefixTable) ~= 'table' then
		error("Non-table value detected for the prefix table", 2)
	end
	if type(step) ~= 'number' then
		error("Invalid step value detected", 2)
	end

	-- Get arguments without a number suffix, and check for bad input.
	for i, v in ipairs(prefixTable) do
		if type(v) ~= 'table' or type(v.prefix) ~= "string" or (v.depend and type(v.depend) ~= 'table') then
			error('Invalid input detected to preprocessArgs prefix table', 2)
		end
		preprocessSingleArg(v.prefix)
		-- Only parse the depend parameter if the prefix parameter is present and not blank.
		if args[v.prefix] and v.depend then
			for j, dependValue in ipairs(v.depend) do
				if type(dependValue) ~= 'string' then
					error('Invalid "depend" parameter value detected in preprocessArgs')
				end
				preprocessSingleArg(dependValue)
			end
		end
	end

	-- Get arguments with number suffixes.
	local a = 1 -- Counter variable.
	local moreArgumentsExist = true
	while moreArgumentsExist do
		moreArgumentsExist = false
		for i = a, a + step - 1 do
			for j, v in ipairs(prefixTable) do
				v.suffix = v.suffix or {''}
				for k = 1, #v.suffix do
					local prefixArgName = v.prefix .. i .. v.suffix[k]
					if origArgs[prefixArgName] then
						moreArgumentsExist = true -- Do another loop if any arguments are found, even blank ones.
						preprocessSingleArg(prefixArgName)
					end
					-- Process the depend table if the prefix argument is present and not blank, or
					-- we are processing "prefix1" and "prefix" is present and not blank, and
					-- if the depend table is present.
					if v.depend and (args[prefixArgName] or (i == 1 and args[v.prefix])) then
						for l, dependValue in ipairs(v.depend) do
							local dependArgName = dependValue .. i
							preprocessSingleArg(dependArgName)
						end
					end
				end
			end
		end
		a = a + step
	end
end

function p.infobox(frame)
	-- If called via #invoke, use the args passed into the invoking template.
	-- Otherwise, for testing purposes, assume args are being passed directly in.
	if frame == mw.getCurrentFrame() then
		origArgs = frame:getParent().args
	else
		origArgs = frame
	end

	-- Parse the data parameters in the same order that the old {{infobox}} did, so that
	-- references etc. will display in the expected places. Parameters that depend on
	-- another parameter are only processed if that parameter is present, to avoid
	-- phantom references appearing in article reference lists.
	args['child'] = origArgs['child'] -- could be blank or absent; different behaviour because of renderBelowRow()
	args['subbox'] = origArgs['subbox'] -- could be blank or absent; different behaviour because of renderBelowRow()
	args['italic title'] = origArgs['italic title'] -- different behaviour if blank or absent
	preprocessSingleArg('autoheaders')
	preprocessSingleArg('bodyclass')
	preprocessSingleArg('bodystyle')
	preprocessSingleArg('title')
	preprocessSingleArg('titleclass')
	preprocessSingleArg('titlestyle')
	preprocessSingleArg('above')
	preprocessSingleArg('aboveclass')
	preprocessSingleArg('abovestyle')
	preprocessArgs({
		{prefix = 'subheader', depend = {'subheaderstyle', 'subheaderrowclass'}}
	}, 10)
	preprocessSingleArg('subheaderstyle')
	preprocessSingleArg('subheaderclass')
	preprocessSingleArg('image')
	preprocessSingleArg('caption')
	preprocessArgs({
		{prefix = 'image', depend = {'caption', 'imagerowclass'}}
	}, 10)
	preprocessSingleArg('captionstyle')
	preprocessSingleArg('imagestyle')
	preprocessSingleArg('imageclass')
	preprocessArgs({
		{prefix = 'rowclass'},
		{prefix = 'rowstyle'},
		{prefix = 'header'},
		{prefix = 'headerstyle'},
		{prefix = 'labelstyle'},
		{prefix = 'data', suffix = {'', 'a', 'b', 'c'}, depend = {'label'}},
		{prefix = 'datastyle', suffix = {'', 'a', 'b', 'c'}},
		{prefix = 'class', suffix = {'', 'a', 'b', 'c'}},
	}, 100)
	preprocessSingleArg('headerclass')
	preprocessSingleArg('headerstyle')
	preprocessSingleArg('labelstyle')
	preprocessSingleArg('datastyle')
	preprocessSingleArg('below')
	preprocessSingleArg('belowclass')
	preprocessSingleArg('belowstyle')
	preprocessSingleArg('name')
	preprocessSingleArg('decat')

	return _infobox()
end

return p
