local yesno = require('Module:Yesno')
local lang = mw.language.getContentLanguage()
local N_YEAR_DIGITS = 12
local MAX_YEAR = 10^N_YEAR_DIGITS - 1

--------------------------------------------------------------------------------
-- Dts class
--------------------------------------------------------------------------------

local Dts = {}
Dts.__index = Dts

Dts.months = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}

Dts.monthsAbbr = {
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec"
}

function Dts._makeMonthSearch(t)
	local ret = {}
	for i, month in ipairs(t) do
		ret[month:lower()] = i
	end
	return ret
end
Dts.monthSearch = Dts._makeMonthSearch(Dts.months)
Dts.monthSearchAbbr = Dts._makeMonthSearch(Dts.monthsAbbr)
Dts.monthSearchAbbr['sept'] = 9 -- Allow "Sept" to match September

Dts.formats = {
	dmy = true,
	mdy = true,
	dm = true,
	md = true,
	my = true,
	y = true,
	m = true,
	d = true,
	hide = true
}

function Dts.new(args)
	local self = setmetatable({}, Dts)

	-- Parse date parameters.
	-- In this step we also record whether the date was in DMY or YMD format,
	-- and whether the month name was abbreviated.
	if args[2] or args[3] or args[4] then
		self:parseDateParts(args[1], args[2], args[3], args[4])
	elseif args[1] then
		self:parseDate(args[1])
	end

	-- Raise an error on invalid values
	if self.year then
		if self.year == 0 then
			error('years cannot be zero', 0)
		elseif self.year < -MAX_YEAR then
			error(string.format(
				'years cannot be less than %s',
				lang:formatNum(-MAX_YEAR)
			), 0)
		elseif self.year > MAX_YEAR then
			error(string.format(
				'years cannot be greater than %s',
				lang:formatNum(MAX_YEAR)
			), 0)
		elseif math.floor(self.year) ~= self.year then
			error('years must be an integer', 0)
		end
	end
	if self.month and (
		self.month < 1
		or self.month > 12
		or math.floor(self.month) ~= self.month
	) then
		error('months must be an integer between 1 and 12', 0)
	end
	if self.day and (
		self.day < 1
		or self.day > 31
		or math.floor(self.day) ~= self.day
	) then
		error('days must be an integer between 1 and 31', 0)
	end

	-- Set month abbreviation behaviour, i.e. whether we are outputting
	-- "January" or "Jan".
	if args.abbr then
		self.isAbbreviated = args.abbr == 'on' or yesno(args.abbr) or false
	else
		self.isAbbreviated = self.isAbbreviated or false
	end

	-- Set the format string
	if args.format then
		self.format = args.format
	else
		self.format = self.format or 'mdy'
	end
	if not Dts.formats[self.format] then
		error(string.format(
			"'%s' is not a valid format",
			tostring(self.format)
		), 0)
	end

	-- Set addkey. This adds a value at the end of the sort key, allowing users
	-- to manually distinguish between identical dates.
	if args.addkey then
		self.addkey = tonumber(args.addkey)
		if not self.addkey or
			self.addkey < 0 or
			self.addkey > 9999 or
			math.floor(self.addkey) ~= self.addkey
		then
			error("the 'addkey' parameter must be an integer between 0 and 9999", 0)
		end
	end

	-- Set whether the displayed date is allowed to wrap or not.
	self.isWrapping = args.nowrap == 'off' or yesno(args.nowrap) == false

	return self
end

function Dts:hasDate()
	return (self.year or self.month or self.day) ~= nil
end

-- Find the month number for a month name, and set the isAbbreviated flag as
-- appropriate.
function Dts:parseMonthName(s)
	s = s:lower()
	local month = Dts.monthSearch[s]
	if month then
		return month
	else
		month = Dts.monthSearchAbbr[s]
		if month then
			self.isAbbreviated = true
			return month
		end
	end
	return nil
end

-- Parses separate parameters for year, month, day, and era.
function Dts:parseDateParts(year, month, day, bc)
	if year then
		self.year = tonumber(year)
		if not self.year then
			error(string.format(
				"'%s' is not a valid year",
				tostring(year)
			), 0)
		end
	end
	if month then
		if tonumber(month) then
			self.month = tonumber(month)
		elseif type(month) == 'string' then
			self.month = self:parseMonthName(month)
		end
		if not self.month then
			error(string.format(
				"'%s' is not a valid month",
				tostring(month)
			), 0)
		end
	end
	if day then
		self.day = tonumber(day)
		if not self.day then
			error(string.format(
				"'%s' is not a valid day",
				tostring(day)
			), 0)
		end
	end
	if bc then
		local bcLower = type(bc) == 'string' and bc:lower()
		if bcLower == 'bc' or bcLower == 'bce' then
			if self.year and self.year > 0 then
				self.year = -self.year
			end
		elseif bcLower ~= 'ad' and bcLower ~= 'ce' then
			error(string.format(
				"'%s' is not a valid era code (expected 'BC', 'BCE', 'AD' or 'CE')",
				tostring(bc)
			), 0)
		end
	end
end

-- This method parses date strings. This is a poor man's alternative to
-- mw.language:formatDate, but it ends up being easier for us to parse the date
-- here than to use mw.language:formatDate and then try to figure out after the
-- fact whether the month was abbreviated and whether we were DMY or MDY.
function Dts:parseDate(date)
	-- Generic error message.
	local function dateError()
		error(string.format(
			"'%s' is an invalid date",
			date
		), 0)
	end

	local function parseDayOrMonth(s)
		if s:find('^%d%d?$') then
			return tonumber(s)
		end
	end

	local function parseYear(s)
		if s:find('^%d%d%d%d?$') then
			return tonumber(s)
		end
	end

	-- Deal with year-only dates first, as they can have hyphens in, and later
	-- we need to split the string by all non-word characters, including
	-- hyphens. Also, we don't need to restrict years to 3 or 4 digits, as on
	-- their own they can't be confused as a day or a month number.
	self.year = tonumber(date)
	if self.year then
		return
	end

	-- Split the string using non-word characters as boundaries.
	date = tostring(date)
	local parts = mw.text.split(date, '%W+')
	local nParts = #parts
	if parts[1] == '' or parts[nParts] == '' or nParts > 3 then
		-- We are parsing a maximum of three elements, so raise an error if we
		-- have more. If the first or last elements were blank, then the start
		-- or end of the string was a non-word character, which we will also
		-- treat as an error.
		dateError()
	elseif nParts < 1 then
	 	-- If we have less than one element, then something has gone horribly
	 	-- wrong.
		error(string.format(
			"an unknown error occurred while parsing the date '%s'",
			date
		), 0)
	end

	if nParts == 1 then
		-- This can be either a month name or a year.
		self.month = self:parseMonthName(parts[1])
		if not self.month then
			self.year = parseYear(parts[1])
			if not self.year then
				dateError()
			end
		end
	elseif nParts == 2 then
		-- This can be any of the following formats:
		-- DD Month
		-- Month DD
		-- Month YYYY
		-- YYYY-MM
		self.month = self:parseMonthName(parts[1])
		if self.month then
			-- This is either Month DD or Month YYYY.
			self.year = parseYear(parts[2])
			if not self.year then
				-- This is Month DD.
				self.format = 'mdy'
				self.day = parseDayOrMonth(parts[2])
				if not self.day then
					dateError()
				end
			end
		else
			self.month = self:parseMonthName(parts[2])
			if self.month then
				-- This is DD Month.
				self.format = 'dmy'
				self.day = parseDayOrMonth(parts[1])
				if not self.day then
					dateError()
				end
			else
				-- This is YYYY-MM.
				self.year = parseYear(parts[1])
				self.month = parseDayOrMonth(parts[2])
				if not self.year or not self.month then
					dateError()
				end
			end
		end
	elseif nParts == 3 then
		-- This can be any of the following formats:
		-- DD Month YYYY
		-- Month DD, YYYY
		-- YYYY-MM-DD
		-- DD-MM-YYYY
		self.month = self:parseMonthName(parts[1])
		if self.month then
			-- This is Month DD, YYYY.
			self.format = 'mdy'
			self.day = parseDayOrMonth(parts[2])
			self.year = parseYear(parts[3])
			if not self.day or not self.year then
				dateError()
			end
		else
			self.day = parseDayOrMonth(parts[1])
			if self.day then
				self.month = self:parseMonthName(parts[2])
				if self.month then
					-- This is DD Month YYYY.
					self.format = 'dmy'
					self.year = parseYear(parts[3])
					if not self.year then
						dateError()
					end
				else
					-- This is DD-MM-YYYY.
					self.format = 'dmy'
					self.month = parseDayOrMonth(parts[2])
					self.year = parseYear(parts[3])
					if not self.month or not self.year then
						dateError()
					end
				end
			else
				-- This is YYYY-MM-DD
				self.year = parseYear(parts[1])
				self.month = parseDayOrMonth(parts[2])
				self.day = parseDayOrMonth(parts[3])
				if not self.year or not self.month or not self.day then
					dateError()
				end
			end
		end
	end
end

function Dts:makeSortKey()
	local year, month, day
	local nYearDigits = N_YEAR_DIGITS
	if self:hasDate() then
		year = self.year or os.date("*t").year
		if year < 0 then
			year = -MAX_YEAR - 1 - year
			nYearDigits = nYearDigits + 1 -- For the minus sign
		end
		month = self.month or 1
		day = self.day or 1
	else
		-- Blank {{dts}} transclusions should sort last.
		year = MAX_YEAR
		month = 99
		day = 99
	end
	return string.format(
		'%0' .. nYearDigits .. 'd-%02d-%02d-%04d',
		year, month, day, self.addkey or 0
	)
end

function Dts:getMonthName()
	if not self.month then
		return ''
	end
	if self.isAbbreviated then
		return self.monthsAbbr[self.month]
	else
		return self.months[self.month]
	end
end

function Dts:makeDisplay()
	if self.format == 'hide' then
		return ''
	end
	local hasYear = self.year and self.format:find('y')
	local hasMonth = self.month and self.format:find('m')
	local hasDay = self.day and self.format:find('d')
	local isMonthFirst = self.format:find('md')
	local ret = {}
	if hasDay and hasMonth and isMonthFirst then
		ret[#ret + 1] = self:getMonthName()
		ret[#ret + 1] = ' '
		ret[#ret + 1] = self.day
		if hasYear then
			ret[#ret + 1] = ','
		end
	elseif hasDay and hasMonth then
		ret[#ret + 1] = self.day
		ret[#ret + 1] = ' '
		ret[#ret + 1] = self:getMonthName()
	elseif hasDay then
		ret[#ret + 1] = self.day
	elseif hasMonth then
		ret[#ret + 1] = self:getMonthName()
	end
	if hasYear then
		if hasDay or hasMonth then
			ret[#ret + 1] = ' '
		end
		local displayYear = math.abs(self.year)
		if displayYear > 9999 then
			displayYear = lang:formatNum(displayYear)
		else
			displayYear = tostring(displayYear)
		end
		ret[#ret + 1] = displayYear
		if self.year < 0 then
			ret[#ret + 1] = '&nbsp;BC'
		end
	end
	return table.concat(ret)
end

function Dts:__tostring()
	local root = mw.html.create()
	local span = root:tag('span')
		:attr('data-sort-value', self:makeSortKey())

	-- Display
	if self:hasDate() and self.format ~= 'hide' then
		span:wikitext(self:makeDisplay())
		if not self.isWrapping then
			span:css('white-space', 'nowrap')
		end
	end

	return tostring(root)
end

--------------------------------------------------------------------------------
-- Exports
--------------------------------------------------------------------------------

local p = {}

function p._exportClasses()
	return {
		Dts = Dts
	}
end

function p._main(args)
	local success, ret = pcall(function ()
		local dts = Dts.new(args)
		return tostring(dts)
	end)
	if success then
		return ret
	else
		ret = string.format(
			'<strong class="error">Error in [[Template:Date table sorting]]: %s</strong>',
			ret
		)
		if mw.title.getCurrentTitle().namespace == 0 then
			-- Only categorise in the main namespace
			ret = ret .. '[[Category:Date table sorting templates with errors]]'
		end
		return ret
	end
end

function p.main(frame)
	local args = require('Module:Arguments').getArgs(frame, {
		wrappers = 'Template:Date table sorting',
	})
	return p._main(args)
end

return p
