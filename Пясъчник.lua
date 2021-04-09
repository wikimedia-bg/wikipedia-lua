local p = {}

local function toBgNum(n)
	n = tostring(n)
	n = n:gsub('^%d+', function(cap)
		if #cap > 4 then
			cap = string.reverse(string.gsub(string.reverse(cap), '(%d%d%d)', '%1 '))
		end
		return cap
	end):gsub('%.', ',')
	return n
end

local function renderTimeline(t)
	local mval = 1
	local bardata = ''
	local plotdata1 = ''
	local plotdata2 = ''

	local y, v
	for i = 1, #t do
		y = t[i].year
		v = t[i].val
		mval = math.max(mval, v)
		bardata = bardata .. 'bar:' .. y .. ' text:' .. y .. '\n'
		plotdata1 = plotdata1 .. 'bar:' .. y .. ' from:0 till:' .. v .. '\n'
		plotdata2 = plotdata2 .. 'bar:' .. y .. ' at:' .. v .. ' fontsize:S text:"' .. toBgNum(v) .. '" shift:(-10,5)\n'
	end

	-- some ugly code ahead :)
	local result = '\n'
			-- timeline color options
			.. 'Colors=' .. '\n'
			.. 'id:a value:gray(0.9)' .. '\n'
			.. 'id:b value:gray(0.7)' .. '\n'
			.. 'id:c value:rgb(1,1,1)' .. '\n'
			.. 'id:d value:rgb(0.6,0.7,1)' .. '\n\n'
			-- variuos other timeline options
			.. 'ImageSize = width:auto barincrement:35 height:250' .. '\n'
			.. 'PlotArea = left:50 bottom:30 top:30 right:30' .. '\n'
			.. 'DateFormat = x.y' .. '\n'
			.. 'Period = from:0 till:' .. mval .. '\n'
			.. 'TimeAxis = orientation:vertical' .. '\n'
			.. 'AlignBars = justify' .. '\n\n'
			-- bar data
			.. 'BarData=' .. '\n'
			.. bardata .. '\n'
			-- first plot data
			.. 'PlotData=' .. '\n'
			.. 'color:d width:20 align:left' .. '\n'
			.. plotdata1 .. '\n'
			-- second plot data
			.. 'PlotData=' .. '\n'
			.. plotdata2
	-- end of result

	return result
end

local function renderTable(t, order, link, notimeline, align, timeline)
	if notimeline == '1' or notimeline == 'да' or notimeline == 'y' or notimeline == 'yes' or notimeline == 'true' then
		notimeline = true
	else
		notimeline = false
	end

	if order ~= '' then order = '<br><small>(в ' .. order .. ')</small>' end

	local position = {
		['left'] = 'floatleft',
		['вляво'] = 'floatleft',
		['л'] = 'floatleft',
		['ляво'] = 'floatleft',
		['right'] = 'floatright',
		['вдясно'] = 'floatright',
		['д'] = 'floatright',
		['дясно'] = 'floatright',
		['center'] = 'centered',
		['ц'] = 'centered',
		['център'] = 'centered',
	}

	local class
	if align ~= '' and position[align] then
		class = 'wikitable ' .. position[align]
	else
		class = 'wikitable'
	end

	local wikitablebegin, wikitableend, style
	local wikitablecontent = ''

	-- some ugly code ahead :)
	if notimeline then -- notimeline option is true, so plain sortable table
		wikitablebegin = '{| class="' .. class .. ' sortable" style="text-align:right; white-space:nowrap"\n'
			.. '|-\n'
			.. '! Година на<br>преброяване !! Численост' .. order.. '\n'
		-- end of wikitablebegin
		wikitableend = '|}'
	else -- here a timeline have to be added, so there has to be 2 tables - the sortable one and the outter table which holds both the inner table and the timeline
		style = 'style="border-right:1px #aaa solid" | ' -- explicitly add a style because the inner table has no border
		wikitablebegin = '{| class="' .. class .. '"\n' -- outer table
			.. '|-\n' -- row
			.. '| style="padding:0" |\n' -- cell that will hold the inner table; no padding for the inner table
			.. '{| class="wikitable sortable" style="margin:0; border:0; text-align:right; white-space:nowrap"\n' -- sortable inner table with removed margins and border
			.. '|-\n' -- row
			..'! ' .. style .. 'Година на<br>преброяване !! Численост' .. order.. '\n'
		-- end of wikitablebegin
		wikitableend = '|}\n' -- closing of the inner table
			.. '| style="text-align:center" | ' .. timeline .. '\n' -- timeline cell
			.. '|}' -- closing of the outer table
		-- end of wikitableend
	end

	local y, v, attryear, attrnum
	for i = 1, #t do
		y = t[i].year
		v = t[i].val
		attryear = 'data-sort-value="' .. y .. '" ' .. (style or '| ')
		attrnum = 'data-sort-value="' .. v .. '" | '
		if link ~= '' then
			if not (link == '0' or link == 'не' or link == 'без' or link == 'no') then
				link = mw.ustring.gsub(link, '%%година%%', tostring(y))
				y = '[[' .. link .. '|' .. y .. ']]'
			end
		else
			y = '[[' .. y .. ']]'
		end
		wikitablecontent = wikitablecontent .. '|-\n| ' .. attryear .. y .. ' || ' .. attrnum .. toBgNum(v) .. t[i].refs .. '\n'
	end

	return wikitablebegin .. wikitablecontent .. wikitableend
end

function p.main(frame)
	local args = frame.args
	local pargs = frame:getParent().args

	local order = args['численост-порядък'] or pargs['численост-порядък'] or ''
	local link = args['препратка'] or pargs['препратка'] or ''
	local notimeline = args['без-графика'] or pargs['без-графика'] or ''
	local align = args['подравняване'] or pargs['подравняване'] or ''
	local stats = {}
	local ref
	local result = ''

	for k, v in pairs(pargs) do
		k = tonumber(k)
		if mw.ustring.match(tostring(k), '^%d%d%d%d$') and (k >= 1650 and k <= os.date('*t').year) then
			-- remove all the refs and keep them in a separate var
			ref = ''
			v = mw.ustring.gsub(v, '(<%f[%w]ref%f[%W][^>]*/>)', function(cap)
				ref = ref + cap
				return ''
			end) -- self-closing refs
			v = mw.ustring.gsub(v, '(<%f[%w]ref%f[%W][^>]*>.-</%f[%w]ref%f[%W][^>]*>)', function(cap)
				ref = ref + cap
				return ''
			end) -- normal refs
			v = mw.ustring.gsub(v, '&.-;', '') -- remove any HTML entities
			v = mw.ustring.gsub(v, '%s', '') -- remove any whitespace characters
			v = mw.ustring.gsub(v, ',', '.') -- replace commas with dots
			v = mw.ustring.gsub(v, '[^.%d]', '') -- remove any character that isn't a dot or a digit
			local _, count = mw.ustring.gsub(v, '%.', '')
			if count > 1 then v = mw.ustring.gsub(v, '%.', '', count - 1) end
			v = tonumber(v) -- if unsuccessful then it will be nil; the next "if" will be skipped
			if v then
				table.insert(stats, {year = k, val = v, refs = ref})
			end
		end
	end

	if #stats > 0 then
		table.sort(stats, function(a, b) return a.year < b.year end) -- sort in ascending order (years)
		local timeline
		if mw.isSubsting() then
			timeline = '<timeline>' .. renderTimeline(stats) .. '</timeline>'
		else
			timeline = frame:extensionTag('timeline', renderTimeline(stats))
		end
		result = renderTable(stats, order, link, notimeline, align, timeline)
	end

	return result
end

return p
