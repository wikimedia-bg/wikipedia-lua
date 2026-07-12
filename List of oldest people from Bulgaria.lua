require('strict')
local getArgs = require('Module:Arguments').getArgs

local ageUtil = require('Module:Age utilities')
local ageInYearsMonthsAndDays = ageUtil.ageInYearsMonthsAndDays
local ageInYearsMonthsAndDaysFormat = ageUtil.ageInYearsMonthsAndDaysFormat
local compareAges = ageUtil.compareAges
local equalAges = ageUtil.equalAges
local displayMax = 100 -- Display max 100 entries

--local language = mw.language
--local language = mw.getLanguage('no')
local language = mw.getContentLanguage()

local p = {}

-- Returns true if personA is older than personB
local function comparePersons(personA, personB)
	local diffAge = compareAges(personA.age, personB.age)
	if diffAge == 0 then -- Same age, let the person who is born first "win"
		if personA.dateBirth ~= personB.dateBirth then return personA.dateBirth < personB.dateBirth end
	end
	return diffAge > 0
end

local function formatDateIso8061(year, month, day)
	return tostring(year) .. '-' .. string.format('%02d', month) .. '-' .. string.format('%02d', day)
end

local function formatDateSortable(dateN)
	local date = os.date('!*t', dateN)
	local dateIso = formatDateIso8061(date.year, date.month, date.day)
	local result = '<span style="display:none">' .. dateIso .. '</span>'
	-- https://en.wikipedia.org/wiki/Wikipedia:Comparable_Lua_functions_to_wikitext#Date_and_time
	result = result .. '<span style="white-space:nowrap">' .. language:formatDate('j F Y', dateIso) .. '</span>'
	return result
end

-- Expects a table of persons as input.
-- Returns a string with sorted and formatted output (as a sortable table)
function p.displaySortedTable(persons, frame)
	if #persons == 0 then return '' end

	table.sort(persons, comparePersons) -- Sort according to age and birth date

	local aliveColor = '#99FF99'
	local deadColor = '#F9F9F9'
	local result = ''
	local lastAge = nil
	local rank, keyLast = 0, 0
	local numberOfLiving = 0
	local row, rankCell = nil, nil
	local root = mw.html.create()
	for key, person in ipairs(persons) do
		if lastAge == nil or not equalAges(lastAge, person.age) then -- New age: increment rank
			if rankCell ~= nil and key > rank then
				rankCell:attr('rowspan', tostring(key - rank))
			end
			rankCell = nil
			if key > displayMax then break end -- Display max 100 entries
			rank = key
			lastAge = person.age
			row = root:tag('tr')
			rankCell = row:tag('th'):wikitext(tostring(rank) .. '.')
		else
			row = root:tag('tr')
		end
		keyLast = key

		row:tag('td'):wikitext(person.name)
		if not person.dateDeath then -- Not dead
			row:attr('bgcolor', aliveColor)
			numberOfLiving = numberOfLiving + 1
		end
--		row:tag('td'):wikitext(person.sex)
		row:tag('td'):wikitext(formatDateSortable(person.dateBirth))
		if person.dateDeath ~= nil then -- Dead
			row:tag('td'):wikitext(formatDateSortable(person.dateDeath))
		else
			row:tag('td'):wikitext(person.sex == 'F' and 'жива' or 'жив')
		end
		row:tag('td'):wikitext(ageInYearsMonthsAndDaysFormat(person.age))
		row:tag('td'):wikitext(person.nation or '')
	end
	if rankCell ~= nil and keyLast > rank then
		rankCell:attr('rowspan', tostring(keyLast - rank + 1))
	end
	root:allDone()

	local header = frame:preprocess(
		'{{legend2|' .. aliveColor .. "|Живи: '''"
		.. tostring(numberOfLiving)
		.. "'''||border=1px solid #AAAAAA}}"
		.. '<br/>' ..
		'{{legend2|' .. deadColor .. "|Починали: '''"
		.. tostring(keyLast - numberOfLiving) 
		.. "'''||border=1px solid #AAAAAA}}")
		.. '\n' .. [[
{|class="wikitable sortable"
!#
!Име
!Дата на раждане
!Дата на смъртта
!Възраст
!Страна
]]
	return header .. '\n' .. result .. tostring(root) .. '\n|}'
end


-- Input string dateStr is expected on the format "YYYY-MM-DD"
-- Returns a numeric representation of the date or nil
local function decodeDate(dateStr)
	if dateStr == nil or #dateStr < 8 then return nil end
	
	local strings = mw.text.split(dateStr, '-', true)
	if strings == nil or #strings ~= 3 then return nil end
	
	local date = {}
	date.year = tonumber(strings[1]) or 0
	date.month = tonumber(strings[2]) or 1
	date.day = tonumber(strings[3]) or 1
	return os.time(date);
end

--[[ Input is expected as a table of arguments.
	Expects a semi colon seperated entry for each person on the format:
		"Name etc ; Sex ; Date of birth ; Date of death ; References etc"
			Name and DoB are mandatory, DoD and reference are optional.
			Dates should be in the format "YYYY-MM-DD". ]]
-- Returns a table with the persons
local function decodeArgs(args)
	local dateNow = os.time()
	local persons = {}
	
	for name, value in pairs(args) do
		local strings = mw.text.split(value, ';', true)
		if strings ~= nil and #strings >= 2 then -- Need at least name and birth date
			local person = {}
			person.name = strings[1] or ''
			person.sex = strings[2] or 'F'
			person.dateBirth = decodeDate(strings[3]) -- Date of birth
			if person.dateBirth ~= nil then
				person.dateDeath = decodeDate(strings[4]) -- Date of death
				person.age = ageInYearsMonthsAndDays(person.dateDeath or dateNow, person.dateBirth)
				person.nation = strings[5] or ''
				-- For templates and/or html codes with semicolon
				for k = 6, #strings do person.nation = person.nation .. ';' .. strings[k] or '' end
				table.insert(persons, person)
			end
		end
	end
	return persons
end

-- Decodes args from a frame and displas list
local function displaySorted_(frameArgs, frame)
	local args = getArgs(frameArgs)
	local persons = decodeArgs(args)
	return p.displaySortedTable(persons, frame) -- Display as a sortable table
end

-- To be used from a template. Uses args from parent to template
function p.displaySorted(frame)
	return displaySorted_(frame:getParent().args, frame)
end

-- To be used directly with #invoke
function p.displaySorted0(frame)
	return displaySorted_(frame.args, frame)
end

return p
