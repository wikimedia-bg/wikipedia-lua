local p = {}

function isEmpty(var)
	return var == nil or var == ""
end

Date = {
	-- _ = nil, -- save here the original date string, e.g. "31 май 2000"
	-- day = nil,
	-- month = nil,
	-- monthName = nil,
	-- year = nil,
	-- bce = nil, -- is it in the BCE epoch
}
function Date.currentDate()
	return os.date("*t")
end

function Date:isEmpty()
	return isEmpty(self._)
end
function Date:monthNameToNumber(monthName)
	local map = {
		["януари"] = 1,
		["февруари"] = 2,
		["март"]  = 3,
		["април"] = 4,
		["май"] = 5,
		["юни"] = 6,
		["юли"] = 7,
		["август"] = 8,
		["септември"] = 9,
		["октомври"] = 10,
		["ноември"] = 11,
		["декември"] = 12
	}
	return map[monthName] or nil
end
function Date:set(year, monthName, day)
	self.year = year
	self.monthName = monthName
	self.month = self:monthNameToNumber(monthName)
	self.day = day
	return self
end

function Date:fromString(dateString)
	d = { _ = dateString }
	setmetatable(d, self)
	self.__index = self
	if isEmpty(dateString) then
		return d
	end
	if string.match(dateString, 'BCE$') then
		d.bce = true
	end
	local day, monthName, year = mw.ustring.match(dateString, "^(%d+) (%a+) (%d+)")
	if day and monthName and year then
		return d:set(year, monthName, day)
	end
	monthName, year = mw.ustring.match(dateString, "^(%a+) (%d+)")
	if monthName and year then
		return d:set(year, monthName)
	end
	century = mw.ustring.match(dateString, "^(%d+)\. century")
	if century then
		d.century = century
		return d
	end
	decade = mw.ustring.match(dateString, "^(%d+)s")
	if decade then
		d.decade = decade
		return d
	end
	year = mw.ustring.match(dateString, "^(%d+)")
	if year then
		return d:set(year)
	end
	if string.match(dateString, "неизвестна стойност") then
		d.unknown = true
	end
	-- old value
	if string.match(dateString, "неразпозната стойност") then
		d.unknown = true
	end

	return d
end


function age(dateOfBirth, dateOfDeath)
	if not dateOfBirth.year then
		return nil
	end
	if isEmpty(dateOfDeath) or dateOfDeath:isEmpty() then
		dateOfDeath = Date.currentDate()
	end
	local startDate = dateForCalc(dateOfBirth)
	local endDate = dateForCalc(dateOfDeath)
	if dateOfBirth.bce and not dateOfDeath.bce then
		-- reverse the sign and subtract one year
		startDate = startDate * -1 + 10000
	end
	local age = math.abs(math.floor((endDate - startDate) / 10000))
	if age > 125 then -- put a max age
		return nil
	end
	return age
end

function dateForCalc(date)
	return string.format("%d%02d%02d", date.year or 0, date.month or 0, date.day or 0)
end

function birthCategories(date)
	local cats = {}
	if date.century then
		table.insert(cats, "Родени през " ..  date.century .. " век" .. bceSuffix(date.bce))
	end
	if date.decade then
		table.insert(cats, "Родени през " ..  date.decade.. "-те години" .. bceSuffix(date.bce))
	end
	if date.year then
		table.insert(cats, "Родени през " ..  date.year .. " година" .. bceSuffix(date.bce))
	end
	if date.day and date.monthName then
		table.insert(cats, "Родени на " ..  date.day .. " " .. date.monthName)
	end
	if date.unknown then
		table.insert(cats, "Статии за личности с неизвестна година на раждане")
	end
	return cats
end

function deathCategories(date)
	local cats = {}
	if date.century then
		table.insert(cats, "Починали през " ..  date.century .. " век" .. bceSuffix(date.bce))
	end
	if date.decade then
		table.insert(cats, "Починали през " ..  date.decade .. "-те години" .. bceSuffix(date.bce))
	end
	if date.year then
		table.insert(cats, "Починали през " ..  date.year .. " година" .. bceSuffix(date.bce))
	end
	if date.day and date.monthName then
		table.insert(cats, "Починали на " ..  date.day .. " " .. date.monthName)
	end
	if date.unknown then
		table.insert(cats, "Статии за личности с неизвестна година на смърт")
	end
	return cats
end

function prepareBirthDateVars(dateOfBirthString, dateOfDeathString)
	if isEmpty(dateOfBirthString) then
		return nil
	end
	local vars = {}
	vars.date = Date:fromString(dateOfBirthString)
	if isEmpty(dateOfDeathString) then
		vars.age = age(vars.date)
	end
	vars.cats = birthCategories(vars.date)
	return vars
end

function prepareDeathDateVars(dateOfBirthString, dateOfDeathString)
	if isEmpty(dateOfDeathString) then
		return nil
	end
	local vars = {}
	vars.date = Date:fromString(dateOfDeathString)
	if not isEmpty(dateOfBirthString) then
		vars.age = age(Date:fromString(dateOfBirthString), vars.date)
	end
	vars.cats = deathCategories(vars.date)
	return vars
end

function wikifyDate(date)
	if date.century then
		return "[[" .. date.century .. " век" .. bceSuffix(date.bce) .. "]]"
	end
	if date.decade then
		return "[[" .. date.decade .. "-те" .. (date.bce and " пр.н.е.]]" or "]] години")
	end
	if date.unknown then
		return "неизв."
	end
	local output = ""
	if date.day and date.monthName then
		output = output .. "[[" .. date.day .. " " .. date.monthName .. "]] "
	elseif date.monthName then
		output = output .. date.monthName .. " "
	end
	if date.year then
		output = output .. "[[" .. date.year .. (date.bce and " г. пр.н.е.]]" or "]] г.")
	end
	return output
end

function bceSuffix(isBce)
	if isBce then return " пр.н.е." else return "" end
end

function formatAgeSuffix(age)
	return '<span class="noprint"> <small>('.. age .. ' г.)</small></span>'
end

function isAfterGregorianIntroduced(date)
	-- Shouldn't be possible if calendarmodel is defined, but best be safe.
	if date.unknown then
		return false
	end
	-- All dates BC are definitely before Gregorian has been introduced.
	if date.bce then
		return false
	end
	-- Not sure what comparison with nil would return so check if defined first.
	-- Feel free to simplify if you know it's an overkill.
	if date.year and tonumber(date.year) < 1582 then
		return false
	end
	if date.decade and tonumber(date.decade) < 1580 then
		return false
	end
	if date.century and tonumber(date.century) < 16 then
		return false
	end
	
	-- After or in 1582, the 1580s, or the 16th century.
	return true
end

function formatDate(vars, calendar)
	if vars == nil then
		return ""
	end
	local output = wikifyDate(vars.date)
	if calendar == "Q11184" or calendar == "Q1985786" then
		if isAfterGregorianIntroduced(vars.date) then
			output = output .. '<sup>[[Приемане на григорианския календар|стар стил]]</sup>'
			output = output .. '[[Категория:Статии с дати на раждане или смърт по стар стил]]'
		end
	end
	if vars.age then
		output = output .. formatAgeSuffix(vars.age)
	end
	output = '<span class="oneline">' .. output .. '</span>'
	for k, category in pairs(vars.cats) do
		output = output .. '[[Category:' .. category .. ']]'
	end
	return output
end

function p.birth_date(frame)
	return formatDate(prepareBirthDateVars(frame.args[1], frame.args[2]), frame.args[3])
end

function p.death_date(frame)
	return formatDate(prepareDeathDateVars(frame.args[1], frame.args[2]), frame.args[3])
end

return p
