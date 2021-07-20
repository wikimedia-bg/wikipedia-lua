-- Implement various "age of" and other date-related templates.

local mtext = {
	-- Message and other text that should be localized.
	-- Also need to localize text in table names in function dateDifference.
	['mt-bad-param1'] =             'Invalid parameter $1',
	['mt-bad-param2'] =             'Parameter $1=$2 is invalid',
	['mt-bad-show'] =               'Parameter show=$1 is not supported here',
	['mt-cannot-add'] =             'Cannot add "$1"',
	['mt-conflicting-show'] =       'Parameter show=$1 conflicts with round=$2',
	['mt-date-wrong-order'] =       'The second date must be later in time than the first date',
	['mt-dd-future'] =              'Death date (first date) must not be in the future',
	['mt-dd-wrong-order'] =         'Death date (first date) must be later in time than the birth date (second date)',
	['mt-invalid-bd-age'] =         'Invalid birth date for calculating age',
	['mt-invalid-dates-age'] =      'Invalid dates for calculating age',
	['mt-invalid-end'] =            'Invalid end date in second parameter',
	['mt-invalid-start'] =          'Invalid start date in first parameter',
	['mt-need-jdn'] =               'Need valid Julian date number',
	['mt-need-valid-bd'] =          'Need valid birth date: year, month, day',
	['mt-need-valid-bd2'] =         'Need valid birth date (second date): year, month, day',
	['mt-need-valid-date'] =        'Need valid date',
	['mt-need-valid-dd'] =          'Need valid death date (first date): year, month, day',
	['mt-need-valid-ymd'] =         'Need valid year, month, day',
	['mt-need-valid-ymd-current'] = 'Need valid year|month|day or "currentdate"',
	['mt-need-valid-ymd2'] =        'Second date should be year, month, day',
	['mt-template-bad-name'] =      'The specified template name is not valid',
	['mt-template-x'] =             'The template invoking this must have "|template=x" where x is the wanted operation',
	['txt-and'] =                   ' and ',
	['txt-or'] =                    '&nbsp;or ',
	['txt-category'] =              'Category:Age error',
	['txt-comma-and'] =             ', and ',
	['txt-error'] =                 'Error: ',
	['txt-format-default'] =        'mf',  -- 'df' (day first = dmy) or 'mf' (month first = mdy)
	['txt-module-convertnumeric'] = 'Module:ConvertNumeric',
	['txt-module-date'] =           'Module:Date',
	['txt-sandbox'] =               'sandbox',
	['txt-bda'] = '<span style="display:none"> (<span class="bday">$1</span>) </span>$2<span class="noprint ForceAgeToShow"> (age&nbsp;$3)</span>',
	['txt-dda'] = '$2<span style="display:none">($1)</span> (aged&nbsp;$3)',
	['txt-bda-disp'] = 'disp_raw',  -- disp_raw → age is a number only; disp_age → age is a number and unit (normally years but months or days if very young)
	['txt-dda-disp'] = 'disp_raw',
	['txt-dmy'] = '%-d %B %-Y',
	['txt-mdy'] = '%B %-d, %-Y',
}

local isWarning = {
	['mt-bad-param1'] = true,
}

local translate, from_en, to_en, isZero
if translate then
	-- Functions to translate from en to local language and reverse go here.
	-- See example at [[:bn:Module:বয়স]].
else
	from_en = function (text)
		return text
	end
	isZero = function (text)
		return tonumber(text) == 0
	end
end

local _Date, _currentDate
local function getExports(frame)
	-- Return objects exported from the date module or its sandbox.
	if not _Date then
		local sandbox = frame:getTitle():find(mtext['txt-sandbox'], 1, true) and ('/' .. mtext['txt-sandbox']) or ''
		local datemod = require(mtext['txt-module-date'] .. sandbox)
		local realDate = datemod._Date
		_currentDate = datemod._current
		if to_en then
			_Date = function (...)
				local args = {}
				for i, v in ipairs({...}) do
					args[i] = to_en(v)
				end
				return realDate(unpack(args))
			end
		else
			_Date = realDate
		end
	end
	return _Date, _currentDate
end

local Collection  -- a table to hold items
Collection = {
	add = function (self, item)
		if item ~= nil then
			self.n = self.n + 1
			self[self.n] = item
		end
	end,
	join = function (self, sep)
		return table.concat(self, sep)
	end,
	remove = function (self, pos)
		if self.n > 0 and (pos == nil or (0 < pos and pos <= self.n)) then
			self.n = self.n - 1
			return table.remove(self, pos)
		end
	end,
	sort = function (self, comp)
		table.sort(self, comp)
	end,
	new = function ()
		return setmetatable({n = 0}, Collection)
	end
}
Collection.__index = Collection

local function stripToNil(text)
	-- If text is a string, return its trimmed content, or nil if empty.
	-- Otherwise return text (which may, for example, be nil).
	if type(text) == 'string' then
		text = text:match('(%S.-)%s*$')
	end
	return text
end

local function dateFormat(args)
	-- Return string for wanted date format.
	local default = mtext['txt-format-default']
	local other = default == 'df' and 'mf' or 'df'
	local wanted = stripToNil(args[other]) and other or default
	return wanted == 'df' and mtext['txt-dmy'] or mtext['txt-mdy']
end

local function substituteParameters(text, ...)
	-- Return text after substituting any given parameters for $1, $2, etc.
	return mw.message.newRawMessage(text, ...):plain()
end

local function yes(parameter)
	-- Return true if parameter should be interpreted as "yes".
	-- Do not want to accept mixed upper/lowercase unless done by current templates.
	-- Need to accept "on" because "round=on" is wanted.
	return ({ y = true, yes = true, on = true })[parameter]
end

local function message(msg, ...)
	-- Return formatted message text for an error or warning.
	local function getText(msg)
		return mtext[msg] or error('Bug: message "' .. tostring(msg) .. '" not defined')
	end
	local categories = {
		error = mtext['txt-category'],
		warning = mtext['txt-category'],
	}
	local a, b, k, category
	local text = substituteParameters(getText(msg), ...)
	if isWarning[msg] then
		a = '<sup>[<i>'
		b = '</i>]</sup>'
		k = 'warning'
	else
		a = '<strong class="error">' .. getText('txt-error')
		b = '</strong>'
		k = 'error'
	end
	if mw.title.getCurrentTitle():inNamespaces(0) then
		-- Category only in namespaces: 0=article.
		category = '[[' .. categories[k] .. ']]'
	end
	return
		a ..
		mw.text.nowiki(text) ..
		b ..
		(category or '')
end

local function formatNumber(number)
	-- Return the given number formatted with commas as group separators,
	-- given that the number is an integer.
	local numstr = tostring(number)
	local length = #numstr
	local places = Collection.new()
	local pos = 0
	repeat
		places:add(pos)
		pos = pos + 3
	until pos >= length
	places:add(length)
	local groups = Collection.new()
	for i = places.n, 2, -1 do
		local p1 = length - places[i] + 1
		local p2 = length - places[i - 1]
		groups:add(numstr:sub(p1, p2))
	end
	return groups:join(',')
end

local function spellNumber(number, options, i)
	-- Return result of spelling number, or
	-- return number (as a string) if cannot spell it.
	-- i == 1 for the first number which can optionally start with an uppercase letter.
	number = tostring(number)
	return require(mtext['txt-module-convertnumeric']).spell_number(
		number,
		nil,                       -- fraction numerator
		nil,                       -- fraction denominator
		i == 1 and options.upper,  -- true: 'One' instead of 'one'
		not options.us,            -- true: use 'and' between tens/ones etc
		options.adj,               -- true: hyphenated
		options.ordinal            -- true: 'first' instead of 'one'
	) or number
end

local function makeExtra(args, flagCurrent)
	-- Return extra text that will be inserted before the visible result
	-- but after any sort key.
	local extra = args.prefix or ''
	if mw.ustring.len(extra) > 1 then
		-- Parameter "~" gives "~3" whereas "over" gives "over 3".
		if extra:sub(-6, -1) ~= '&nbsp;' then
			extra = extra .. ' '
		end
	end
	if flagCurrent then
		extra = '<span class="currentage"></span>' .. extra
	end
	return extra
end

local function makeSort(value, sortable)
	-- Return a sort key if requested.
	-- Assume value is a valid number which has not overflowed.
	if sortable == 'sortable_table' or sortable == 'sortable_on' or sortable == 'sortable_debug' then
		local sortKey
		if value == 0 then
			sortKey = '5000000000000000000'
		else
			local mag = math.floor(math.log10(math.abs(value)) + 1e-14)
			if value > 0 then
				sortKey = 7000 + mag
			else
				sortKey = 2999 - mag
				value = value + 10^(mag+1)
			end
			sortKey = string.format('%d', sortKey) .. string.format('%015.0f', math.floor(value * 10^(14-mag)))
		end
		local result
		if sortable == 'sortable_table' then
			result = 'data-sort-value="_SORTKEY_"|'
		elseif sortable == 'sortable_debug' then
			result = '<span data-sort-value="_SORTKEY_♠"><span style="border:1px solid">_SORTKEY_♠</span></span>'
		else
			result = '<span data-sort-value="_SORTKEY_♠"></span>'
		end
		return (result:gsub('_SORTKEY_', sortKey))
	end
end

local translateParameters = {
	abbr = {
		off = 'abbr_off',
		on = 'abbr_on',
	},
	disp = {
		age = 'disp_age',
		raw = 'disp_raw',
	},
	format = {
		raw = 'format_raw',
		commas = 'format_commas',
	},
	round = {
		on = 'on',
		yes = 'on',
		months = 'ym',
		weeks = 'ymw',
		days = 'ymd',
		hours = 'ymdh',
	},
	sep = {
		comma = 'sep_comma',
		[','] = 'sep_comma',
		serialcomma = 'sep_serialcomma',
		space = 'sep_space',
	},
	show = {
		hide = { id = 'hide' },
		y = { 'y', id = 'y' },
		ym = { 'y', 'm', id = 'ym' },
		ymd = { 'y', 'm', 'd', id = 'ymd' },
		ymw = { 'y', 'm', 'w', id = 'ymw' },
		ymwd = { 'y', 'm', 'w', 'd', id = 'ymwd' },
		yd = { 'y', 'd', id = 'yd', keepZero = true },
		m = { 'm', id = 'm' },
		md = { 'm', 'd', id = 'md' },
		w = { 'w', id = 'w' },
		wd = { 'w', 'd', id = 'wd' },
		h = { 'H', id = 'h' },
		hm = { 'H', 'M', id = 'hm' },
		hms = { 'H', 'M', 'S', id = 'hms' },
		M = { 'M', id = 'M' },
		s = { 'S', id = 's' },
		d = { 'd', id = 'd' },
		dh = { 'd', 'H', id = 'dh' },
		dhm = { 'd', 'H', 'M', id = 'dhm' },
		dhms = { 'd', 'H', 'M', 'S', id = 'dhms' },
		ymdh = { 'y', 'm', 'd', 'H', id = 'ymdh' },
		ymdhm = { 'y', 'm', 'd', 'H', 'M', id = 'ymdhm' },
		ymwdh = { 'y', 'm', 'w', 'd', 'H', id = 'ymwdh' },
		ymwdhm = { 'y', 'm', 'w', 'd', 'H', 'M', id = 'ymwdhm' },
	},
	sortable = {
		off = false,
		on = 'sortable_on',
		table = 'sortable_table',
		debug = 'sortable_debug',
	},
}

local spellOptions = {
	cardinal = {},
	Cardinal = { upper = true },
	cardinal_us = { us = true },
	Cardinal_us = { us = true, upper = true },
	ordinal = { ordinal = true },
	Ordinal = { ordinal = true, upper = true },
	ordinal_us = { ordinal = true, us = true },
	Ordinal_us = { ordinal = true, us = true, upper = true },
}

local function dateExtract(frame)
	-- Return part of a date after performing an optional operation.
	local Date = getExports(frame)
	local args = frame:getParent().args
	local parms = {}
	for i, v in ipairs(args) do
		parms[i] = v
	end
	if yes(args.fix) then
		table.insert(parms, 'fix')
	end
	if yes(args.partial) then
		table.insert(parms, 'partial')
	end
	local show = stripToNil(args.show) or 'dmy'
	local date = Date(unpack(parms))
	if not date then
		if show == 'format' then
			return 'error'
		end
		return message('mt-need-valid-date')
	end
	local add = stripToNil(args.add)
	if add then
		for item in add:gmatch('%S+') do
			date = date + item
			if not date then
				return message('mt-cannot-add', item)
			end
		end
	end
	local sortKey, result
	local sortable = translateParameters.sortable[args.sortable]
	if sortable then
		local value = (date.partial and date.partial.first or date).jdz
		sortKey = makeSort(value, sortable)
	end
	if show ~= 'hide' then
		result = date[show]
		if result == nil then
			result = from_en(date:text(show))
		elseif type(result) == 'boolean' then
			result = result and '1' or '0'
		else
			result = from_en(tostring(result))
		end
	end
	return (sortKey or '') .. makeExtra(args) .. (result or '')
end

local function rangeJoin(range)
	-- Return text to be used between a range of ages.
	return range == 'dash' and '–' or mtext['txt-or']
end

local function makeText(values, components, names, options, noUpper)
	-- Return wikitext representing an age or duration.
	local text = Collection.new()
	local count = #values
	local sep = names.sep or ''
	for i, v in ipairs(values) do
		-- v is a number (say 4 for 4 years), or a table ({4,5} for 4 or 5 years).
		local islist = type(v) == 'table'
		if (islist or v > 0) or (text.n == 0 and i == count) or (text.n > 0 and components.keepZero) then
			local fmt, vstr
			if options.spell then
				fmt = function(number)
					return spellNumber(number, options.spell, noUpper or i)
				end
			elseif i == 1 and options.format == 'format_commas' then
				-- Numbers after the first should be small and not need formatting.
				fmt = formatNumber
			else
				fmt = tostring
			end
			if islist then
				vstr = fmt(v[1]) .. rangeJoin(options.range)
				noUpper = true
				vstr = vstr .. fmt(v[2])
			else
				vstr = fmt(v)
			end
			local name = names[components[i]]
			if name then
				if type(name) == 'table' then
					name = mw.getContentLanguage():plural(islist and v[2] or v, name)
				end
				text:add(vstr .. sep .. name)
			else
				text:add(vstr)
			end
		end
	end
	local first, last
	if options.join == 'sep_space' then
		first = ' '
		last = ' '
	elseif options.join == 'sep_comma' then
		first = ', '
		last = ', '
	elseif options.join == 'sep_serialcomma' and text.n > 2 then
		first = ', '
		last = mtext['txt-comma-and']
	else
		first = ', '
		last = mtext['txt-and']
	end
	for i, v in ipairs(text) do
		if i < text.n then
			text[i] = v .. (i + 1 < text.n and first or last)
		end
	end
	local sign = ''
	if options.isnegative then
		-- Do not display negative zero.
		if text.n > 1 or (text.n == 1 and text[1]:sub(1, 1) ~= '0' ) then
			if options.format == 'format_raw' then
				sign = '-'  -- plain hyphen so result can be used in a calculation
			else
				sign = '−'  -- Unicode U+2212 MINUS SIGN
			end
		end
	end
	return
		(options.sortKey or '') ..
		(options.extra or '') ..
		sign ..
		text:join() ..
		(options.suffix or '')
end

local function dateDifference(parms)
	-- Return a formatted date difference using the given parameters
	-- which have been validated.
	local names = {
		-- Each name is:
		-- * a string if no plural form of the name is used; or
		-- * a table of strings, one of which is selected using the rules at
		--   https://translatewiki.net/wiki/Plural/Mediawiki_plural_rules
		abbr_off = {
			sep = '&nbsp;',
			y = {'year', 'years'},
			m = {'month', 'months'},
			w = {'week', 'weeks'},
			d = {'day', 'days'},
			H = {'hour', 'hours'},
			M = {'minute', 'minutes'},
			S = {'second', 'seconds'},
		},
		abbr_on = {
			y = 'y',
			m = 'm',
			w = 'w',
			d = 'd',
			H = 'h',
			M = 'm',
			S = 's',
		},
		abbr_infant = {      -- for {{age for infant}}
			sep = '&nbsp;',
			y = {'yr', 'yrs'},
			m = {'mo', 'mos'},
			w = {'wk', 'wks'},
			d = {'day', 'days'},
			H = {'hr', 'hrs'},
			M = {'min', 'mins'},
			S = {'sec', 'secs'},
		},
		abbr_raw = {},
	}
	local diff = parms.diff  -- must be a valid date difference
	local show = parms.show  -- may be nil; default is set below
	local abbr = parms.abbr or 'abbr_off'
	local defaultJoin
	if abbr ~= 'abbr_off' then
		defaultJoin = 'sep_space'
	end
	if not show then
		show = 'ymd'
		if parms.disp == 'disp_age' then
			if diff.years < 3 then
				defaultJoin = 'sep_space'
				if diff.years >= 1 then
					show = 'ym'
				else
					show = 'md'
				end
			else
				show = 'y'
			end
		end
	end
	if type(show) ~= 'table' then
		show = translateParameters.show[show]
	end
	if parms.disp == 'disp_raw' then
		defaultJoin = 'sep_space'
		abbr = 'abbr_raw'
	elseif parms.wantSc then
		defaultJoin = 'sep_serialcomma'
	end
	local diffOptions = {
		round = parms.round,
		duration = parms.wantDuration,
		range = parms.range and true or nil,
	}
	local sortKey
	if parms.sortable then
		local value = diff.age_days + (parms.wantDuration and 1 or 0)  -- days and fraction of a day
		if diff.isnegative then
			value = -value
		end
		sortKey = makeSort(value, parms.sortable)
	end
	local textOptions = {
		extra = parms.extra,
		format = parms.format,
		join = parms.sep or defaultJoin,
		isnegative = diff.isnegative,
		range = parms.range,
		sortKey = sortKey,
		spell = parms.spell,
		suffix = parms.suffix,  -- not currently used
	}
	if show.id == 'hide' then
		return sortKey or ''
	end
	local values = { diff:age(show.id, diffOptions) }
	if values[1] then
		return makeText(values, show, names[abbr], textOptions)
	end
	if diff.partial then
		-- Handle a more complex range such as
		-- {{age_yd|20 Dec 2001|2003|range=yes}} → 1 year, 12 days or 2 years, 11 days
		local opt = {
			format = textOptions.format,
			join = textOptions.join,
			isnegative = textOptions.isnegative,
			spell = textOptions.spell,
		}
		return
			(textOptions.sortKey or '') ..
			makeText({ diff.partial.mindiff:age(show.id, diffOptions) }, show, names[abbr], opt) ..
			rangeJoin(textOptions.range) ..
			makeText({ diff.partial.maxdiff:age(show.id, diffOptions) }, show, names[abbr], opt, true) ..
			(textOptions.suffix or '')
	end
	return message('mt-bad-show', show.id)
end

local function getDates(frame, getopt)
	-- Parse template parameters and return one of:
	-- * date         (a date table, if single)
	-- * date1, date2 (two date tables, if not single)
	-- * text         (a string error message)
	-- A missing date is optionally replaced with the current date.
	-- If wantMixture is true, a missing date component is replaced
	-- from the current date, so can get a bizarre mixture of
	-- specified/current y/m/d as has been done by some "age" templates.
	-- Some results may be placed in table getopt.
	local Date, currentDate = getExports(frame)
	getopt = getopt or {}
	local function flagCurrent(text)
		-- This allows the calling template to detect if the current date has been used,
		-- that is, whether both dates have been entered in a template expecting two.
		-- For example, an infobox may want the age when an event occurred, not the current age.
		-- Don't bother detecting if wantMixture is used because not needed and it is a poor option.
		if not text then
			if getopt.noMissing then
				return nil  -- this gives a nil date which gives an error
			end
			text = 'currentdate'
			if getopt.flag == 'usesCurrent' then
				getopt.usesCurrent = true
			end
		end
		return text
	end
	local args = frame:getParent().args
	local fields = {}
	local isNamed = args.year or args.year1 or args.year2 or
		args.month or args.month1 or args.month2 or
		args.day or args.day1 or args.day2
	if isNamed then
		fields[1] = args.year1 or args.year
		fields[2] = args.month1 or args.month
		fields[3] = args.day1 or args.day
		fields[4] = args.year2
		fields[5] = args.month2
		fields[6] = args.day2
	else
		for i = 1, 6 do
			fields[i] = args[i]
		end
	end
	local imax = 0
	for i = 1, 6 do
		fields[i] = stripToNil(fields[i])
		if fields[i] then
			imax = i
		end
		if getopt.omitZero and i % 3 ~= 1 then  -- omit zero months and days as unknown values but keep year 0 which is 1 BCE
			if isZero(fields[i]) then
				fields[i] = nil
				getopt.partial = true
			end
		end
	end
	local fix = getopt.fix and 'fix' or ''
	local partialText = getopt.partial and 'partial' or ''
	local dates = {}
	if isNamed or imax >= 3 then
		local nrDates = getopt.single and 1 or 2
		if getopt.wantMixture then
			-- Cannot be partial since empty fields are set from current.
			local components = { 'year', 'month', 'day' }
			for i = 1, nrDates * 3 do
				fields[i] = fields[i] or currentDate[components[i > 3 and i - 3 or i]]
			end
			for i = 1, nrDates do
				local index = i == 1 and 1 or 4
				local y, m, d = fields[index], fields[index+1], fields[index+2]
				if (m == 2 or m == '2') and (d == 29 or d == '29') then
					-- Workaround error with following which attempt to use invalid date 2001-02-29.
					-- {{age_ymwd|year1=2001|year2=2004|month2=2|day2=29}}
					-- {{age_ymwd|year1=2001|month1=2|year2=2004|month2=1|day2=29}}
					-- TODO Get rid of wantMixture because even this ugly code does not handle
					-- 'Feb' or 'February' or 'feb' or 'february'.
					if not ((y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0) then
						d = 28
					end
				end
				dates[i] = Date(y, m, d)
			end
		else
			-- If partial dates are allowed, accept
			--     year only, or
			--     year and month only
			-- Do not accept year and day without a month because that makes no sense
			-- (and because, for example, Date('partial', 2001, nil, 12) sets day = nil, not 12).
			for i = 1, nrDates do
				local index = i == 1 and 1 or 4
				local y, m, d = fields[index], fields[index+1], fields[index+2]
				if (getopt.partial and y and (m or not d)) or (y and m and d) then
					dates[i] = Date(fix, partialText, y, m, d)
				elseif not y and not m and not d then
					dates[i] = Date(flagCurrent())
				end
			end
		end
	else
		getopt.textdates = true  -- have parsed each date from a single text field
		dates[1] = Date(fix, partialText, flagCurrent(fields[1]))
		if not getopt.single then
			dates[2] = Date(fix, partialText, flagCurrent(fields[2]))
		end
	end
	if not dates[1] then
		return message(getopt.missing1 or 'mt-need-valid-ymd')
	end
	if getopt.single then
		return dates[1]
	end
	if not dates[2] then
		return message(getopt.missing2 or 'mt-need-valid-ymd2')
	end
	return dates[1], dates[2]
end

local function ageGeneric(frame)
	-- Return the result required by the specified template.
	-- Can use sortable=x where x = on/table/off/debug in any supported template.
	-- Some templates default to sortable=on but can be overridden.
	local name = frame.args.template
	if not name then
		return message('mt-template-x')
	end
	local args = frame:getParent().args
	local specs = {
		age_days = {                -- {{age in days}}
			show = 'd',
			disp = 'disp_raw',
		},
		age_days_nts = {            -- {{age in days nts}}
			show = 'd',
			disp = 'disp_raw',
			format = 'format_commas',
			sortable = 'on',
		},
		duration_days = {           -- {{duration in days}}
			show = 'd',
			disp = 'disp_raw',
			duration = true,
		},
		duration_days_nts = {       -- {{duration in days nts}}
			show = 'd',
			disp = 'disp_raw',
			format = 'format_commas',
			sortable = 'on',
			duration = true,
		},
		age_full_years = {          -- {{age}}
			show = 'y',
			abbr = 'abbr_raw',
			flag = 'usesCurrent',
			omitZero = true,
			range = 'no',
		},
		age_full_years_nts = {      -- {{age nts}}
			show = 'y',
			abbr = 'abbr_raw',
			format = 'format_commas',
			sortable = 'on',
		},
		age_in_years = {            -- {{age in years}}
			show = 'y',
			abbr = 'abbr_raw',
			negative = 'error',
			range = 'dash',
		},
		age_in_years_nts = {        -- {{age in years nts}}
			show = 'y',
			abbr = 'abbr_raw',
			negative = 'error',
			range = 'dash',
			format = 'format_commas',
			sortable = 'on',
		},
		age_infant = {              -- {{age for infant}}
			-- Do not set show because special processing is done later.
			abbr = yes(args.abbr) and 'abbr_infant' or 'abbr_off',
			disp = 'disp_age',
			sep = 'sep_space',
			sortable = 'on',
		},
		age_m = {                   -- {{age in months}}
			show = 'm',
			disp = 'disp_raw',
		},
		age_w = {                   -- {{age in weeks}}
			show = 'w',
			disp = 'disp_raw',
		},
		age_wd = {                  -- {{age in weeks and days}}
			show = 'wd',
		},
		age_yd = {                  -- {{age in years and days}}
			show = 'yd',
			format = 'format_commas',
			sep = args.sep ~= 'and' and 'sep_comma' or nil,
		},
		age_yd_nts = {              -- {{age in years and days nts}}
			show = 'yd',
			format = 'format_commas',
			sep = args.sep ~= 'and' and 'sep_comma' or nil,
			sortable = 'on',
		},
		age_ym = {                  -- {{age in years and months}}
			show = 'ym',
			sep = 'sep_comma',
		},
		age_ymd = {                 -- {{age in years, months and days}}
			show = 'ymd',
			range = true,
		},
		age_ymwd = {                -- {{age in years, months, weeks and days}}
			show = 'ymwd',
			wantMixture = true,
		},
	}
	local spec = specs[name]
	if not spec then
		return message('mt-template-bad-name')
	end
	if name == 'age_days' then
		local su = stripToNil(args['show unit'])
		if su then
			if su == 'abbr' or su == 'full' then
				spec.disp = nil
				spec.abbr = su == 'abbr' and 'abbr_on' or nil
			end
		end
	end
	local partial, autofill
	local range = stripToNil(args.range) or spec.range
	if range then
		-- Suppose partial dates are used and age could be 11 or 12 years.
		-- "|range=" (empty value) has no effect (spec is used).
		-- "|range=yes" or spec.range == true sets range = true (gives "11 or 12")
		-- "|range=dash" or spec.range == 'dash' sets range = 'dash' (gives "11–12").
		-- "|range=no" or spec.range == 'no' sets range = nil and fills each date in the diff (gives "12").
		--     ("on" is equivalent to "yes", and "off" is equivalent to "no").
		-- "|range=OTHER" sets range = nil and rejects partial dates.
		range = ({ dash = 'dash', off = 'no', no = 'no', [true] = true })[range] or yes(range)
		if range then
			partial = true  -- accept partial dates with a possible age range for the result
			if range == 'no' then
				autofill = true  -- missing month/day in first or second date are filled from other date or 1
				range = nil
			end
		end
	end
	local getopt = {
		fix = yes(args.fix),
		flag = stripToNil(args.flag) or spec.flag,
		omitZero = spec.omitZero,
		partial = partial,
		wantMixture = spec.wantMixture,
	}
	local date1, date2 = getDates(frame, getopt)
	if type(date1) == 'string' then
		return date1
	end
	local format = stripToNil(args.format)
	local spell = spellOptions[format]
	if format then
		format = 'format_' .. format
	elseif name == 'age_days' and getopt.textdates then
		format = 'format_commas'
	end
	local parms = {
		diff = date2:subtract(date1, { fill = autofill }),
		wantDuration = spec.duration or yes(args.duration),
		range = range,
		wantSc = yes(args.sc),
		show = args.show == 'hide' and 'hide' or spec.show,
		abbr = spec.abbr,
		disp = spec.disp,
		extra = makeExtra(args, getopt.usesCurrent and format ~= 'format_raw'),
		format = format or spec.format,
		round = yes(args.round),
		sep = spec.sep,
		sortable = translateParameters.sortable[args.sortable or spec.sortable],
		spell = spell,
	}
	if (spec.negative or frame.args.negative) == 'error' and parms.diff.isnegative then
		return message('mt-date-wrong-order')
	end
	return from_en(dateDifference(parms))
end

local function bda(frame)
	-- Implement [[Template:Birth date and age]].
	local args = frame:getParent().args
	local options = {
		missing1 = 'mt-need-valid-bd',
		noMissing = true,
		single = true,
	}
	local date = getDates(frame, options)
	if type(date) == 'string' then
		return date  -- error text
	end
	local Date = getExports(frame)
	local diff = Date('currentdate') - date
	if diff.isnegative or diff.years > 150 then
		return message('mt-invalid-bd-age')
	end
	local disp = mtext['txt-bda-disp']
	local show = 'y'
	if diff.years < 2 then
		disp = 'disp_age'
		if diff.years == 0 and diff.months == 0 then
			show = 'd'
		else
			show = 'm'
		end
	end
	local result = substituteParameters(
		mtext['txt-bda'],
		date:text('%-Y-%m-%d'),
		from_en(date:text(dateFormat(args))),
		from_en(dateDifference({
			diff = diff,
			show = show,
			abbr = 'abbr_off',
			disp = disp,
			sep = 'sep_space',
		}))
	)
	local warnings = tonumber(frame.args.warnings)
	if warnings and warnings > 0 then
		local good = {
			df = true,
			mf = true,
			day = true,
			day1 = true,
			month = true,
			month1 = true,
			year = true,
			year1 = true,
		}
		local invalid
		local imax = options.textdates and 1 or 3
		for k, _ in pairs(args) do
			if type(k) == 'number' then
				if k > imax then
					invalid = tostring(k)
					break
				end
			else
				if not good[k] then
					invalid = k
					break
				end
			end
		end
		if invalid then
			result = result .. message('mt-bad-param1', invalid)
		end
	end
	return result
end

local function dda(frame)
	-- Implement [[Template:Death date and age]].
	local args = frame:getParent().args
	local options = {
		missing1 = 'mt-need-valid-dd',
		missing2 = 'mt-need-valid-bd2',
		noMissing = true,
		partial = true,
	}
	local date1, date2 = getDates(frame, options)
	if type(date1) == 'string' then
		return date1
	end
	local diff = date1 - date2
	if diff.isnegative then
		return message('mt-dd-wrong-order')
	end
	local Date = getExports(frame)
	local today = Date('currentdate') + 1  -- one day in future allows for timezones
	if date1 > today then
		return message('mt-dd-future')
	end
	local years
	if diff.partial then
		years = diff.partial.years
		years = type(years) == 'table' and years[2] or years
	else
		years = diff.years
	end
	if years > 150 then
		return message('mt-invalid-dates-age')
	end
	local fmt_date, fmt_ymd
	if date1.day then  -- y, m, d known
		fmt_date = dateFormat(args)
		fmt_ymd = '%-Y-%m-%d'
	elseif date1.month then  -- y, m known; d unknown
		fmt_date = '%B %-Y'
		fmt_ymd = '%-Y-%m-00'
	else  -- y known; m, d unknown
		fmt_date = '%-Y'
		fmt_ymd = '%-Y-00-00'
	end
	local result = substituteParameters(
		mtext['txt-dda'],
		date1:text(fmt_ymd),
		from_en(date1:text(fmt_date)),
		from_en(dateDifference({
			diff = diff,
			show = 'y',
			abbr = 'abbr_off',
			disp = mtext['txt-dda-disp'],
			range = 'dash',
			sep = 'sep_space',
		}))
	)
	local warnings = tonumber(frame.args.warnings)
	if warnings and warnings > 0 then
		local good = {
			df = true,
			mf = true,
		}
		local invalid
		local imax = options.textdates and 2 or 6
		for k, _ in pairs(args) do
			if type(k) == 'number' then
				if k > imax then
					invalid = tostring(k)
					break
				end
			else
				if not good[k] then
					invalid = k
					break
				end
			end
		end
		if invalid then
			result = result .. message('mt-bad-param1', invalid)
		end
	end
	return result
end

local function dateToGsd(frame)
	-- Implement [[Template:Gregorian serial date]].
	-- Return Gregorian serial date of the given date, or the current date.
	-- The returned value is negative for dates before 1 January 1 AD
	-- despite the fact that GSD is not defined for such dates.
	local date = getDates(frame, { wantMixture=true, single=true })
	if type(date) == 'string' then
		return date
	end
	return tostring(date.gsd)
end

local function jdToDate(frame)
	-- Return formatted date from a Julian date.
	-- The result includes a time if the input includes a fraction.
	-- The word 'Julian' is accepted for the Julian calendar.
	local Date = getExports(frame)
	local args = frame:getParent().args
	local date = Date('juliandate', args[1], args[2])
	if date then
		return from_en(date:text())
	end
	return message('mt-need-jdn')
end

local function dateToJd(frame)
	-- Return Julian date (a number) from a date which may include a time,
	-- or the current date ('currentdate') or current date and time ('currentdatetime').
	-- The word 'Julian' is accepted for the Julian calendar.
	local Date = getExports(frame)
	local args = frame:getParent().args
	local date = Date(args[1], args[2], args[3], args[4], args[5], args[6], args[7])
	if date then
		return tostring(date.jd)
	end
	return message('mt-need-valid-ymd-current')
end

local function timeInterval(frame)
	-- Implement [[Template:Time interval]].
	-- There are two positional arguments: date1, date2.
	-- The default for each is the current date and time.
	-- Result is date2 - date1 formatted.
	local Date = getExports(frame)
	local args = frame:getParent().args
	local parms = {
		extra = makeExtra(args),
		wantDuration = yes(args.duration),
		range = yes(args.range) or (args.range == 'dash' and 'dash' or nil),
		wantSc = yes(args.sc),
	}
	local fix = yes(args.fix) and 'fix' or ''
	local date1 = Date(fix, 'partial', stripToNil(args[1]) or 'currentdatetime')
	if not date1 then
		return message('mt-invalid-start')
	end
	local date2 = Date(fix, 'partial', stripToNil(args[2]) or 'currentdatetime')
	if not date2 then
		return message('mt-invalid-end')
	end
	parms.diff = date2 - date1
	for argname, translate in pairs(translateParameters) do
		local parm = stripToNil(args[argname])
		if parm then
			parm = translate[parm]
			if parm == nil then  -- test for nil because false is a valid setting
				return message('mt-bad-param2', argname, args[argname])
			end
			parms[argname] = parm
		end
	end
	if parms.round then
		local round = parms.round
		local show = parms.show
		if round ~= 'on' then
			if show then
				if show.id ~= round then
					return message('mt-conflicting-show', args.show, args.round)
				end
			else
				parms.show = translateParameters.show[round]
			end
		end
		parms.round = true
	end
	return from_en(dateDifference(parms))
end

return {
	age_generic = ageGeneric,           -- can emulate several age templates
	birth_date_and_age = bda,           -- Template:Birth_date_and_age
	death_date_and_age = dda,           -- Template:Death_date_and_age
	gsd = dateToGsd,                    -- Template:Gregorian_serial_date
	extract = dateExtract,              -- Template:Extract
	jd_to_date = jdToDate,              -- Template:?
	JULIANDAY = dateToJd,               -- Template:JULIANDAY
	time_interval = timeInterval,       -- Template:Time_interval
}
