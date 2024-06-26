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
	dateString = mw.ustring.gsub(dateString, '<!%-%-%s*', '')
	dateString = mw.ustring.gsub(dateString, '%-%->', '')

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

	local day, monthName, year = mw.ustring.match(dateString, "^(%d+)%s+(%a+)%s+(%d+)")
	if day and monthName and year then
		return d:set(year, monthName, day)
	end
	monthName, year = mw.ustring.match(dateString, "^(%a+)%s+(%d+)")
	if monthName and year then
		return d:set(year, monthName)
	end

	millennium = mw.ustring.match(dateString, "^(%d+)%s+хилядолетие")
	if millennium then
		d.millennium = millennium
		return d
	end
	century = mw.ustring.match(dateString, "^(%d+)%s+век")
	if century then
		d.century = century
		return d
	end
	decade = mw.ustring.match(dateString, "^(%d+)%-те")
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
	if vars == nil then return '' end

	local output = ''
	local earliest = ''
	local latest = ''
	local sourcing = ''
	local str = wd._property({'linked', 'qualifier', 'qualifier', 'qualifier', vars.date.q, vars.date.p, 'P1319', 'P1326', 'P1480', format='o=%p[\ne=%q1][\nl=%q2][\ns=%q3]'})
	for m in mw.ustring.gmatch(str, '[^\n]+') do
		m = mw.text.trim(m)
		output = mw.ustring.match(m, '^o=(.+)$') or output
		earliest = mw.ustring.match(m, '^e=(.+)$') or earliest
		latest = mw.ustring.match(m, '^l=(.+)$') or latest
		sourcing = mw.ustring.match(m, '^s=(.+)$') or sourcing
	end
	if output == '' then return '' end

	if output == 'неизв.' then
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
		if sourcing ~= '' then
			output = sourcing .. ' ' .. output
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
        if isSettlement(qid, 0) then
                return false
        end

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
        local notsettlements = {'Q123705'}
        local settlements = {'Q486972', 'Q3957', 'Q7930989', 'Q10354598', 'Q498162', 'Q17343829', 'Q22674925', 'Q1529096', 'Q515', 'Q484170', 'Q15630849', 'Q89487741', 'Q562061', 'Q667509', 'Q2039348', 'Q5084', 'Q1802801', 'Q494721', 'Q493522', 'Q51049922'}
        local s = wd._properties ({ 'raw', qid, 'P31', sep='', ["sep%s"]='\t' })
        if s == '' then
                s = wd._properties ({ 'raw', qid, 'P279', sep='', ["sep%s"]='\t' })
        end
        local t = false

        for token in string.gmatch(s, "[^\t]+") do
                if inArray(notsettlements, token) then
                        return false
                end
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
                        t = findSettlement(token, date, iterate - 1)
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

function relabel(link, newlabel)
	if newlabel ~= '' then
		if link:find("]]") ~= nil then
			if link:find("|") ~= nil then
				link = link:gsub("|.*]]", "|" .. newlabel .. "]]")
			else
				link = link:gsub("]]", "|" .. newlabel .. "]]")
			end
		else
			link = newlabel
		end
	end
	return link
end

function lsc(location, defcountry, date, earliestdate, latestdate)
	local s = ''
	local d = ''

	if location == '' or location == ' ' then
		return ''
	end

	local settlement = ''
	local lstr = wd._label({ 'linked', location })
	local sstr = ''
	local cstr = defcountry or ''

	if isCountry(location) then
		return lstr
	end

    d = mw.text.trim(date or '')

    if d == '' then
      d = mw.text.trim(latestdate or '')   -- tries with latest date
    end
    if d == '' then
      d = mw.text.trim(earliestdate or '')   -- tries with earliest date
    end
	if isSettlement(location, 1) then
		if cstr == '' then
			country = wd._property({'raw', 'deprecated+', location, 'P17', date=d})
			if country ~= '' then
				cstr = wd._label({ 'linked', country})
				cstr = relabel(cstr, wd._property({'linked', 'deprecated+', country, 'P1448', date=d}))
			end
		end
		lstr = relabel(lstr, wd._property({'linked', 'deprecated+', location, 'P1448', date=d}))
	else
		settlement = findSettlement(location, date, 3)
		if settlement ~= '' then
			if cstr == '' then
				country = wd._property({'raw', 'deprecated+', settlement, 'P17', date=d})
				if country ~= '' then
					cstr = wd._label({ 'linked', country})
					cstr = relabel(cstr, wd._property({'linked', 'deprecated+', country, 'P1448', date=d}))
				end
			end
			sstr = wd._label({ 'linked', settlement})
			sstr = relabel(sstr, wd._property({'linked', 'deprecated+', settlement, 'P1448', date=d}))
		else
			if cstr == '' then
				country = wd._property({'raw', 'deprecated+', location, 'P17', date=d})
				if country ~= '' then
					cstr = wd._label({ 'linked', country})
					cstr = relabel(cstr, wd._property({'linked', 'deprecated+', country, 'P1448', date=d}))
				end
			end
		end
	end
	if lstr == sstr then sstr = '' end
	if lstr == cstr then cstr = '' end
	if sstr == cstr then cstr = '' end
	return joinStrings({lstr, sstr, cstr}, ', ')
end

function p.lsc(frame)
    return lsc(frame.args[1], frame.args[3], frame.args[2], frame.args[4], frame.args[5])
end

function p.birth_date(frame)
	local eid = frame.args[1] or ''
	return formatDate(prepareBirthDateVarsWikidata(eid))
end

function p.death_date(frame)
	local eid = frame.args[1] or ''
	return formatDate(prepareDeathDateVarsWikidata(eid))
end

function p.service_years(frame)
	local eid = frame.args[1] or ''
	local occupation = 'P106'
	local militaryPersonnel = 'Q47064'
	local startTime = 'P580'
	local endTime = 'P582'
	local serviceStart = wd._qualifier({'raw', eid, occupation, militaryPersonnel, startTime}) or ''
	local serviceEnd = wd._qualifier({'raw', eid, occupation, militaryPersonnel,  endTime}) or ''

	if serviceStart == '' and serviceEnd == '' then
		return ''
	end

	local yearStart = string.match(serviceStart, "%d+") or ''
	local yearEnd = string.match(serviceEnd, "%d+") or ''

	if yearStart == '' then
		serviceYears = 'до ' .. yearEnd
	elseif yearEnd == '' then
		serviceYears = 'от ' .. yearStart
	else
		serviceYears = yearStart .. ' – ' .. yearEnd
	end

	return serviceYears .. ' г.'
end

return p
