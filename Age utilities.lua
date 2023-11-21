local p = {}

--------------------------------------------------------------------------------
-- Local helper functions
--------------------------------------------------------------------------------

-- Returns true if year is/was a leap year
local function isLeapYear(year)
	return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

-- Copied from [[en:Module:Age]]
local function gsd(year, month, day)
	-- Return the Gregorian serial day (an integer >= 1) for the given date,
	-- or return nil if the date is invalid (only check that year >= 1).
	-- This is the number of days from the start of 1 AD (there is no year 0).
	-- This code implements the logic in [[Template:Gregorian serial date]].
	if year < 1 then
		return nil
	end
	local floor = math.floor
	local days_this_year = (month - 1) * 30.5 + day
	if month > 2 then
		if isLeapYear(year) then
			days_this_year = days_this_year - 1
		else
			days_this_year = days_this_year - 2
		end
		if month > 8 then
			days_this_year = days_this_year + 0.9
		end
	end
	days_this_year = floor(days_this_year + 0.5)
	year = year - 1
	local days_from_past_years = year * 365
		+ floor(year / 4)
		- floor(year / 100)
		+ floor(year / 400)
	return days_from_past_years + days_this_year
end


--------------------------------------------------------------------------------
-- Functions for calculating age
--------------------------------------------------------------------------------

-- Returns age in years and days. Input is two dates in numeric form as returned from os.time
function p.ageInYearsAndDays(date2N, date1N)
	local date1 = os.date('!*t', date1N)
	local date2 = os.date('!*t', date2N)
	local age = {}

	age.years = date2.year - date1.year;
	if date2.month < date1.month or date2.month == date1.month and date2.day < date1.day then
		age.years = age.years - 1
	end

	local year = date2.year
	if date2.month < date1.month or date2.month == date1.month and date2.day < date1.day then
		year = year - 1
	end
	age.days = gsd(date2.year, date2.month, date2.day) - gsd(year, date1.month, date1.day)

	return age
end

local Date = require('Module:Date')._Date
-- Returns age in years, months and days. Input is two dates in numeric form as returned from os.time
function p.ageInYearsMonthsAndDays(date2N, date1N)
	local date1 = os.date('!*t', date1N)
	local date2 = os.date('!*t', date2N)
	local Date1 = Date(date1.year, date1.month, date1.day)
	local Date2 = Date(date2.year, date2.month, date2.day)
    local diff = Date2 - Date1
    local age = {}

    age.years, age.months, age.days = diff:age('ymd')
	age.d = diff:duration('d')

	return age
end

--------------------------------------------------------------------------------
-- Functions for comparing ages
--------------------------------------------------------------------------------

-- Returns < 0 if ageA < ageB, 0 if ageA == ageB, > 0 if ageA > ageB
function p.compareAges(ageA, ageB)
	if ageA.d ~= nil then
		if ageA.d < ageB.d then return -1 end
		return (ageA.d > ageB.d and 1 or 0)
	end
	if ageA.years ~= ageB.years then
		if ageA.years < ageB.years then return -1 end
		return 1
	end
	if ageA.days ~= ageB.days then
		if ageA.days < ageB.days then return -1 end
		return 1
	end
	return 0 -- equal
end

-- Returns true if ageA == ageB
function p.equalAges(ageA, ageB)
	return p.compareAges(ageA, ageB) == 0
end


--------------------------------------------------------------------------------
-- Functions for displaying age
--------------------------------------------------------------------------------

-- Returns a date as a sortable string with age in years and days ("x години и y дни")
function p.ageInYearsAndDaysFormat(age)
	local result = tostring(age.years) .. ' ' .. (age.years == 1 and 'година' or 'година')
		.. ', ' .. tostring(age.days) .. ' и ' .. (age.days == 1 and 'ден' or 'дни')
	return '<span data-sort-value="' .. tostring(1000 * age.years + age.days) .. '">' .. result .. '</span>'
end

-- Returns a date as a sortable string with age in years, months and days ("x години, y месеца и z години")
function p.ageInYearsMonthsAndDaysFormat(age)
	local result = ''
	if (age.years > 0) then
		result = tostring(age.years) .. ' ' .. (age.years == 1 and 'година' or 'година')
	end
	if (age.months > 0) then 
		result = result .. (age.years == 0 and '' or ', ') .. tostring(age.months) .. ' ' .. (age.months == 1 and 'месец' or 'месеца')
	end
	result = result .. ((age.years > 0 or age.months > 0) and ' и ' or '') .. tostring(age.days) .. ' ' .. (age.days == 1 and 'ден' or 'дни')

	return '<span data-sort-value="' .. tostring(100000 * age.years + 1000 * age.months + age.days) .. '">' .. result .. '</span>'
end

return p
