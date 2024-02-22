local p = {}
local args = {}
local origArgs
local root
local colspan = 2
local cat = { present = {}, ins = {} }

local function formatInput(str)
	-- Remove categories from data cells
	-- Add them in a separate table to be concatenated outside of the infobox
	str = mw.ustring.gsub(str, '(%[%[([^%[%]]-):[^%[%]]+%]%])', function (m, subm)
		subm = mw.text.trim(mw.ustring.lower(subm))
		if subm == 'категория' or subm == 'category' then
			if not cat.present[m] then
				cat.present[m] = true
				table.insert(cat.ins, m)
			end
			return ''
		end
		return m
	end)
	-- Remove an empty table or subbox
	str = mw.ustring.gsub(str, '<[Tt][Aa][Bb][Ll][Ee][^<>]*>%s*</[Tt][Aa][Bb][Ll][Ee]%s*>', '')

	if mw.ustring.match(str, '^%s*$') then
		-- Input is empty or contains only whitespace characters;
		-- no point to continue, so return nothing
		return nil
	end

	-- Add newline when a string begins and ends with
	-- wikilists
	str = mw.ustring.gsub(str, '^%s*([*#;:])', '\n%1')
	str = mw.ustring.gsub(str, '(\n[*#;:][^\n]*)%s*$', '%1\n')
	-- wikitables
	str = mw.ustring.gsub(str, '^%s*({|)', '\n%1')
	str = mw.ustring.gsub(str, '(\n|})%s*$', '%1\n')
	-- wikihorizontal rules
	str = mw.ustring.gsub(str, '^%s*(%-%-%-%-+)', '\n%1')
	str = mw.ustring.gsub(str, '(\n%-%-%-%-+)%s*$', '%1\n')

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
	until last == str
	return str
end

local function noMobileHRRow(str)
	-- Add class 'nomobile' when a row contains only horizontal rule
	if mw.ustring.match(str or '', '^%s*%-%-%-%-+%s*$') or mw.ustring.match(str or '', '^%s*<[Hh][Rr][^<>]*>%s*$') then
		return 'nomobile'
	end
	return nil
end

local function addSubboxClass(str)
	-- Add class 'has-subbox' when string
	if mw.ustring.match(str or '', '^%s*<[Tt][Aa][Bb][Ll][Ee][^<>]-["%s]infobox%-subbox["%s][^<>]*>.*</[Tt][Aa][Bb][Ll][Ee]%s*>%s*$') then
		return 'onlysubbox'
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

local function renderTitle()
	if not args.title then return end

	root:tag('caption')
		:addClass('infobox-title')
		:addClass(addSubboxClass(args.title))
		:addClass(args.titleclass)
		:cssText(args.titlestyle)
		:wikitext(args.title)
		:done()
end

local function renderAboveRow()
	if not args.above then return end

	root:tag('tr')
		:tag('td')
			:attr('colspan', colspan)
			:addClass('infobox-above')
			:addClass(addSubboxClass(args.above))
			:addClass(args.aboveclass)
			:cssText(args.abovestyle)
			:wikitext(args.above)
			:done()
end

local function addSubheaderRow(subheaderArgs)
	if not subheaderArgs.data then return end

	root:tag('tr')
		:addClass(subheaderArgs.rowclass)
		:tag('td')
			:attr('colspan', colspan)
			:addClass('infobox-subheader')
			:addClass(addSubboxClass(subheaderArgs.data))
			:addClass(subheaderArgs.class)
			:cssText(subheaderArgs.datastyle)
			:cssText(subheaderArgs.datastylenum)
			:wikitext(subheaderArgs.data)
			:done()
end

local function renderSubheaders()
	if args.subheader and not args.subheader1 then
		args.subheader1 = args.subheader
		args.subheaderrowclass1 = args.subheaderrowclass
	end
	local subheadernums = getArgNums('subheader')
	for k, num in ipairs(subheadernums) do
		addSubheaderRow({
			rowclass = args['subheaderrowclass' .. num],
			data = args['subheader' .. num],
			datastyle = args.subheaderstyle,
			datastylenum = args['subheaderstyle' .. num],
			class = args.subheaderclass,
		})
	end
end

local function addImageRow(imageArgs)
	if not imageArgs.data then return end

	root:tag('tr')
		:addClass(imageArgs.rowclass)
		:tag('td')
			:attr('colspan', colspan)
			:addClass('infobox-image')
			:addClass(addSubboxClass(imageArgs.data))
			:addClass(imageArgs.class)
			:cssText(imageArgs.datastyle)
			:cssText(imageArgs.datastylenum)
			:wikitext(imageArgs.data)
			:done()
end

local function renderImages()
	if args.image and not args.image1 then
		args.image1 = args.image
	end
	if args.caption and not args.caption1 then
		args.caption1 = args.caption
	end
	local imagenums = getArgNums('image')
	for k, num in ipairs(imagenums) do
		local caption = args['caption' .. num]
		local data = mw.html.create():wikitext(args['image' .. num])
		if caption then
			data:tag('div')
				:cssText(args.captionstyle)
				:wikitext(caption)
				:done()
		end
		addImageRow({
			rowclass = args['imagerowclass' .. num],
			data = tostring(data),
			datastyle = args.imagestyle,
			datastylenum = args['imagestyle' .. num],
			class = args.imageclass,
		})
	end
end

local function preprocessRows()
	if not args.autoheaders then return end

	local rownums = union(getArgNums('header'), getArgNums('data', '[abc]?'))
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

local function addRow(rowArgs)
	-- Adds a row to the infobox, with either a header cell
	-- or a label/data cell combination.
	if rowArgs.header
	and mw.ustring.lower(rowArgs.header) ~= '_blank_'
	and mw.ustring.lower(rowArgs.header) ~= '_empty_'
	and mw.ustring.lower(rowArgs.header) ~= '_none_' then
		root:tag('tr')
			:addClass(noMobileHRRow(rowArgs.header))
			:addClass(rowArgs.rowclass)
			:cssText(rowArgs.rowstyle)
			:tag('th')
				:attr('colspan', colspan)
				:attr('scope', 'colgroup')
				:addClass('infobox-header')
				:addClass(addSubboxClass(rowArgs.header))
				:addClass(rowArgs.class)
				:addClass(args.headerclass)
				:cssText(args.headerstyle)
				:cssText(rowArgs.headerstyle)
				:wikitext(rowArgs.header)
				:done()
	elseif rowArgs.data then
		local row = root:tag('tr')
		if not rowArgs.label or noMobileHRRow(rowArgs.label) then
			row:addClass(noMobileHRRow(rowArgs.data))
		end
		row:addClass(rowArgs.rowclass)
		row:cssText(rowArgs.rowstyle)
		local span = colspan
		if rowArgs.label then
			span = span - 1
			row:tag('th')
				:attr('scope', 'row')
				:addClass('infobox-label')
				:addClass(addSubboxClass(rowArgs.label))
				:cssText(args.labelstyle)
				:cssText(rowArgs.labelstyle)
				:wikitext(rowArgs.label)
				:done()
		end
		row:tag('td')
			:attr('colspan', span > 1 and span or nil)
			:addClass(rowArgs.label and 'infobox-data' or 'infobox-data-only')
			:addClass(addSubboxClass(rowArgs.data))
			:addClass(rowArgs.class)
			:cssText(rowArgs.datastyle)
			:cssText(rowArgs.datastylenum)
			:wikitext(rowArgs.data)
			:done()
	elseif rowArgs.data_a then
		local row = root:tag('tr')
		row:addClass(rowArgs.rowclass)
		row:cssText(rowArgs.rowstyle)
		row:tag('th')
			:attr('scope', 'row')
			:addClass('infobox-label')
			:addClass(addSubboxClass(rowArgs.label))
			:cssText(args.labelstyle)
			:cssText(rowArgs.labelstyle)
			:wikitext(rowArgs.label)
			:done()
		row:tag('td')
				:addClass('infobox-data')
				:addClass(addSubboxClass(rowArgs.data_a))
				:addClass(rowArgs.class_a)
				:cssText(rowArgs.datastyle_a or rowArgs.datastyle)
				:cssText(rowArgs.datastylenum_a)
				:wikitext(rowArgs.data_a)
				:done()
		if args.render_b then
			row:tag('td')
				:addClass('infobox-data')
				:addClass(addSubboxClass(rowArgs.data_b))
				:addClass(rowArgs.class_b)
				:cssText(rowArgs.datastyle_b or rowArgs.datastyle)
				:cssText(rowArgs.datastylenum_b)
				:wikitext(rowArgs.data_b)
				:done()
		end
		if args.render_c then
			row:tag('td')
				:addClass('infobox-data')
				:addClass(addSubboxClass(rowArgs.data_c))
				:addClass(rowArgs.class_c)
				:cssText(rowArgs.datastyle_c or rowArgs.datastyle)
				:cssText(rowArgs.datastylenum_c)
				:wikitext(rowArgs.data_c)
				:done()
		end
	end
end

local function renderRows()
	-- Gets the union of the header and data argument numbers,
	-- and renders them all in order using addRow.
	local rownums = union(getArgNums('header'), getArgNums('data', '[abc]?'))
	table.sort(rownums)
	local title = mw.title.getCurrentTitle()
	for k, num in ipairs(rownums) do
		if title.namespace == 10 and args['header' .. num] and (args['data' .. num] or args['data' .. num .. 'a'] or args['data' .. num .. 'b'] or args['data' .. num .. 'c']) then
			mw.addWarning("<span style='color:red'>Едновременна употреба на ''header'' и ''data'' с числова наставка '''" .. num .. "'''.</span>")
		end
		addRow({
			rowclass = args['rowclass' .. num],
			rowstyle = args['rowstyle' .. num],
			header = args['header' .. num],
			headerstyle = args['headerstyle' .. num],
			label = args['label' .. num],
			labelstyle = args['labelstyle' .. num],
			data = args['data' .. num],
			datastyle = args.datastyle,
			datastylenum = args['datastyle' .. num],
			class = args['class' .. num],
			data_a = args['data' .. num .. 'a'],
			datastyle_a = args.datastylea,
			datastylenum_a = args['datastyle' .. num .. 'a'] or args['datastyle' .. num],
			class_a = args['class' .. num .. 'a'],
			data_b = args['data' .. num .. 'b'],
			datastyle_b = args.datastyleb,
			datastylenum_b = args['datastyle' .. num .. 'b'] or args['datastyle' .. num],
			class_b = args['class' .. num .. 'b'],
			data_c = args['data' .. num .. 'c'],
			datastyle_c = args.datastylec,
			datastylenum_c = args['datastyle' .. num .. 'c'] or args['datastyle' .. num],
			class_c = args['class' .. num .. 'c']
		})
	end
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
		if not args.below and not args.belowstyle then
			args.belowstyle = args.headerstyle or args.abovestyle
		end
		args.below = args.below or commonsBelow() -- Get commons only when an infobox doesn't have subbox/child params
	end
	if not args.below then return end

	root:tag('tr')
		:tag('td')
			:attr('colspan', colspan)
			:addClass('infobox-below')
			:addClass(addSubboxClass(args.below))
			:addClass(args.belowclass)
			:cssText(args.belowstyle)
			:wikitext(args.below)
			:done()
end

local function renderNavBar()
	if not args.name then return end

	root:tag('tr')
		:tag('td')
			:attr('colspan', colspan)
			:addClass('infobox-navbar')
			:wikitext(mw.getCurrentFrame():expandTemplate{ title = 'navbar', args = {args.name, mini = 1}})
			:done()
end

local function renderItalicTitle()
	if args.child == 'yes' or args.subbox == 'yes' then return end

	local italicTitle = args['italic title'] and mw.ustring.lower(args['italic title'])
	if italicTitle == '' or italicTitle == 'force' or italicTitle == 'yes' then
		root:tag('tr')
			:addClass('infobox-italic-title')
			:tag('td')
				:attr('colspan', colspan)
				:wikitext(mw.getCurrentFrame():expandTemplate{title = 'italic title'})
				:done()
	end
end

local function loadTemplateStyles()
	if args.child == 'yes' or args.subbox == 'yes' then return '' end

	return mw.getCurrentFrame():extensionTag{
		name = 'templatestyles',
		args = { src = 'Модул:Infobox/styles.css' }
	}
end

local function _infobox()
	-- Specify the overall layout of the infobox, with special settings
	-- if the infobox is used as a 'child' inside another infobox.'
	if args.child ~= 'yes' then
		root = mw.html.create('table')
		root:addClass('infobox')
		if args.subbox == 'yes' then
			root:addClass('infobox-subbox')
		else
			root:addClass('infobox-lua')
		end
		root:addClass(args.bodyclass)
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
	renderItalicTitle()

	return loadTemplateStyles() .. cleanInfobox(tostring(root)) .. table.concat(cat.ins)
end

local function preprocessSingleArg(argName, prefix)
	-- If the argument exists and isn't blank, add it to the argument table.
	-- Blank arguments are treated as nil to match the behaviour of ParserFunctions.
	if origArgs[argName] and origArgs[argName] ~= '' then
		prefix = prefix or argName
		if prefix == 'title' or prefix == 'above' or prefix == 'subheader'
		or prefix == 'image' or prefix == 'caption' or prefix == 'header'
		or prefix == 'label' or prefix == 'data' or prefix == 'below' then
			args[argName] = formatInput(origArgs[argName])
		else
			args[argName] = origArgs[argName]
		end
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
		if type(v) ~= 'table' or type(v.prefix) ~= "string" or (v.depend and type(v.depend) ~= 'table') or (v.suffix and type(v.suffix) ~= 'table') then
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
	local moreArgumentsExist
	local a = 1 -- Counter variable.
	repeat
		moreArgumentsExist = false
		for i = a, a + step - 1 do
			for j, v in ipairs(prefixTable) do
				v.suffix = v.suffix or {''}
				for k = 1, #v.suffix do
					local prefixArgName = v.prefix .. i .. v.suffix[k]
					if origArgs[prefixArgName] then
						moreArgumentsExist = true -- Do another loop if any arguments are found, even blank ones.
						preprocessSingleArg(prefixArgName, v.prefix)
						if v.prefix == 'data' and args[prefixArgName] then
							if not args.render_b and v.suffix[k] == 'b' then
								args.render_b = true
							elseif not args.render_c and v.suffix[k] == 'c' then
								args.render_c = true
							end
						end
					end
					-- Process the depend table if the prefix argument is present and not blank, or
					-- we are processing "prefix1" and "prefix" is present and not blank, and
					-- if the depend table is present.
					if v.depend and (args[prefixArgName] or (i == 1 and args[v.prefix])) then
						for l, dependValue in ipairs(v.depend) do
							local dependArgName = dependValue .. i .. v.suffix[k]
							preprocessSingleArg(dependArgName, dependValue)
						end
					end
				end
			end
		end
		a = a + step
	until not moreArgumentsExist
end

local function parseArgs(frame, version)
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
		{prefix = 'image', depend = {'caption', 'imagestyle', 'imagerowclass'}}
	}, 10)
	preprocessSingleArg('captionstyle')
	preprocessSingleArg('imagestyle')
	preprocessSingleArg('imageclass')
	if version == 'infobox' then
		preprocessArgs({
			{prefix = 'header', depend = {'headerstyle'}},
			{prefix = 'label', depend = {'labelstyle'}},
			{prefix = 'data', depend = {'datastyle', 'class'}},
			{prefix = 'rowclass'},
			{prefix = 'rowstyle'}
		}, 50)
	elseif version == 'infobox3cols' then
		preprocessArgs({
			{prefix = 'header', depend = {'headerstyle'}},
			{prefix = 'label', depend = {'labelstyle'}},
			{prefix = 'data', depend = {'datastyle', 'class'}, suffix = {'', 'a', 'b', 'c'}},
			{prefix = 'rowclass'},
			{prefix = 'rowstyle'},
		}, 50)
	end
	preprocessSingleArg('headerclass')
	preprocessSingleArg('headerstyle')
	preprocessSingleArg('labelstyle')
	preprocessSingleArg('datastyle')
	if version == 'infobox3cols' then
		preprocessSingleArg('datastylea')
		preprocessSingleArg('datastyleb')
		preprocessSingleArg('datastylec')
	end
	preprocessSingleArg('below')
	preprocessSingleArg('belowclass')
	preprocessSingleArg('belowstyle')
	preprocessSingleArg('name')
end

function p.infobox(frame)
	parseArgs(frame, 'infobox')
	return _infobox()
end

function p.infobox3cols(frame)
	parseArgs(frame, 'infobox3cols')
	if args.child == 'yes' then
		args.subbox = 'yes'
		args.child = nil
	end
	colspan = colspan + (args.render_b and 1 or 0) + (args.render_c and 1 or 0)
	return _infobox()
end

return p
