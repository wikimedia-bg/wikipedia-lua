local p = {}
local wd = require('Модул:Wd')

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
	-- julian = nil, -- is the date in Julian calendar
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

function Date:fromWikidata(eid, property)
	local dateString = wd._property({eid, property})

	d = { _ = dateString, q = eid, p = property }
	setmetatable(d, self)
	self.__index = self
	if isEmpty(dateString) or (dateString == 'няма') then
		return d
	end
	if (dateString == 'неизвестна') then
		d.unknown = true
		return d
	end

	if string.match(dateString, 'пр.н.е.') then
		d.bce = true
	end
	if string.match(dateString, 'стар стил') then
		d.julian = true
	end

	local day, monthName, year = mw.ustring.match(dateString, "^(%d+) (%a+) (%d+)")
	if day and monthName and year then
		return d:set(year, monthName, day)
	end
	monthName, year = mw.ustring.match(dateString, "^(%a+) (%d+)")
	if monthName and year then
		return d:set(year, monthName)
	end

	millennium = mw.ustring.match(dateString, "^(%d+).* хилядолетие")
	if millennium then
		d.millennium = millennium
		return d
	end
	century = mw.ustring.match(dateString, "^(%d+).* век")
	if century then
		d.century = century
		return d
	end
	decade = mw.ustring.match(dateString, "^(%d+)-те")
	if decade then
		d.decade = decade
		return d
	end
	year = mw.ustring.match(dateString, "^(%d+)")
	if year then
		return d:set(year)
	end

	return d
end

function age(dateOfBirth, dateOfDeath)
	if not dateOfBirth.year then
		return nil
	end
	if isEmpty(dateOfDeath) or dateOfDeath:isEmpty() then
		dateOfDeath = Date.currentDate()
	elseif dateOfDeath.unknown then
		return nil
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

function bceSuffix(isBce)
	if isBce then return " пр.н.е." else return "" end
end

function birthCategories(date)
	local cats = {}
	if date.millennium then
		table.insert(cats, "Родени през " .. date.millennium .. " хилядолетие" .. bceSuffix(date.bce))
	end
	if date.century then
		table.insert(cats, "Родени през " .. date.century .. " век" .. bceSuffix(date.bce))
	end
	if date.decade then
		table.insert(cats, "Родени през " .. date.decade .. "-те години" .. bceSuffix(date.bce))
	end
	if date.year then
		table.insert(cats, "Родени през " .. date.year .. " година" .. bceSuffix(date.bce))
	end
	if date.day and date.monthName then
		table.insert(cats, "Родени на " ..  date.day .. " " .. date.monthName)
	end
	if date.unknown then
		table.insert(cats, "Статии за личности с неизвестна година на раждане")
	end
	if date.julian and isAfterGregorianIntroduced(date) then
		table.insert(cats, "Статии с дати на раждане или смърт по стар стил")
	end
	return cats
end

function deathCategories(date)
	local cats = {}
	if date.millennium then
		table.insert(cats, "Починали през " ..  date.millennium .. " хилядолетие" .. bceSuffix(date.bce))
	end
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
	if date.julian and isAfterGregorianIntroduced(date) then
		table.insert(cats, "Статии с дати на раждане или смърт по стар стил")
	end
	return cats
end

function prepareBirthDateVarsWikidata(eid)
	local vars = {}
	vars.date = Date:fromWikidata(eid, 'P569')

	if isEmpty(wd._property({eid, 'P570'})) then 
		vars.age = age(vars.date)
	end
	vars.cats = birthCategories(vars.date)

	return vars
end

function prepareDeathDateVarsWikidata(eid)
	local vars = {}
	vars.date = Date:fromWikidata(eid, 'P570')
	if isEmpty(vars.date._) then
		return nil
	end

	local birthDate = Date:fromWikidata(eid, 'P569')
	if not isEmpty(birthDate._) then
		vars.age = age(birthDate, vars.date)
	end
	vars.cats = deathCategories(vars.date)

	return vars
end

function formatAgeSuffix(age)
	return '<span class="noprint"> <small>('.. age .. ' г.)</small></span>'
end

function isJulian(calendar)
	-- The "Q" things are calendarmodels as returned by Wikidata queries.
	-- For more information, see [[:wikidata:Help:Dates]].
	local julian_items = {
		["Q11184"] = true,
		["Q1985786"] = true,
		["юлиански"] = true,
	}
	-- Equivalent to Python's "if calendar in julian_items".
	return julian_items[calendar]
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
	if date.year and tonumber(date.year) < 1583 then
		return false
	end
	if date.decade and tonumber(date.decade) < 1580 then
		return false
	end
	if date.century and tonumber(date.century) < 16 then
		return false
	end
	-- The calendar makes very little sense with millennium level accuracy.
	if date.millennium then
		return false
	end
	
	-- After or in 1583, the 1580s, or the 16th century.
	return true
end

function formatDate(vars, calendar)
	if vars == nil then
		return ""
	end

	local output = wd._property({'linked', vars.date.q, vars.date.p})
	if output == 'неизвестна' then
		local earliest = wd._property({'qualifier', vars.date.q, vars.date.p, 'P1319', format='%q'})
		local latest = wd._property({'qualifier', vars.date.q, vars.date.p, 'P1326', format='%q'})
		if (earliest ~= '') and (latest ~= '') then
			output = 'между ' .. earliest .. ' и ' .. latest
		elseif (earliest ~= '') then
			output = 'не по-рано от ' .. earliest
		elseif (latest ~= '') then
			output = 'не по-късно от ' .. latest
		else
			output = 'неизв.'
		end
	else
		local sourcing = wd._qualifier({vars.date.q, vars.date.p, 'P1480'})
		if sourcing ~= '' then
			output = sourcing .. " " .. output
		end
	end

	if vars.age then
		output = output .. formatAgeSuffix(vars.age)
	end
	output = '<span class="oneline">' .. output .. '</span>'
	for k, category in pairs(vars.cats) do
		output = output .. '[[Категория:' .. category .. ']]'
	end
	return output
end

function inArray (array, value)
    for index, v in ipairs(array) do
        if v == value then
            return true
        end
    end

    return false
end

function isCountry(qid)
        local countries = {'Q6256', 'Q3624078', 'Q1151405', 'Q161243', 'Q15239622', 'Q2577883', 'Q3024240', 'Q6726158', 'Q15634554'}
        local s = wd._properties ({ 'raw', qid, 'P31', sep='', ["sep%s"]='\t' })

        for token in string.gmatch(s, "[^\t]+") do
                if inArray(countries, token) then
                        return true
                end
        end
        return false
end

function isSettlement(qid, iterate)
        local settlements = {'Q486972', 'Q3957', 'Q7930989', 'Q10354598', 'Q498162', 'Q17343829', 'Q22674925', 'Q1529096', 'Q515'}
        local s = wd._properties ({ 'raw', qid, 'P31', sep='', ["sep%s"]='\t' })
        local t = false

        for token in string.gmatch(s, "[^\t]+") do
                if inArray(settlements, token) then
                        return true
                end
                if iterate > 0 then
                        t = isSettlement(token, iterate - 1)
                        if t then
                                return true
                        end
                end
        end
        return false
end

function findSettlement(qid, date, iterate)
        local s = wd._properties ({ 'raw', qid, 'P131', sep='', ["sep%s"]='\t' , ["date"]=date })
        local t = ''
        for token in string.gmatch(s, "[^\t]+") do
                if isSettlement(token, 1) then
                        return token
                end
                if iterate > 0 then
                        t = findSettlement(qid, date, iterate - 1)
                        if t ~= '' then
                                return t
                        end
                end
        end
        return ''
end

function joinStrings(strings, separator)
        local res = ''
        for i, s in ipairs(strings) do
                if (s ~= '') and (s ~= nil) then
                        res = res .. s .. separator
                end
        end
        if res ~= '' then
                res = string.sub (res, 1, string.len(res) - string.len(separator))
        end
        return res
end

function p.lsc(frame)
	local location = frame.args[1]

	if location == '' or location == ' ' then
		return ''
	end

	local settlement = ''
	local lstr = wd._label({ 'linked', location })
	local sstr = ''
	local cstr = frame.args[3] or ''

	if isCountry(location) then
		return lstr
	end
	if isSettlement(location, 1) then
		if cstr == '' then
			cstr = wd._property({'linked', 'normal+', location, 'P17', date=frame.args[2]})
		end
	else
		settlement = findSettlement(location, frame.args[2], 3)
		if settlement ~= '' then
			if cstr == '' then
				cstr = wd._property({'linked', 'normal+', settlement, 'P17', date=frame.args[2]})
			end
			sstr = wd._label({ 'linked', settlement})
		else
			if cstr == '' then
				cstr = wd._property({'linked', 'normal+', location, 'P17',  date=frame.args[2]})
			end
		end
	end
	return joinStrings({lstr, sstr, cstr}, ', ')
end

function p.birth_date(frame)
	local eid = frame.args[1] or ''
	return formatDate(prepareBirthDateVarsWikidata(eid))
end

function p.death_date(frame)
	local eid = frame.args[1] or ''
	return formatDate(prepareDeathDateVarsWikidata(eid))
end

return p
