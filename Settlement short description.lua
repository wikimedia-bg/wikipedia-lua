--generates auto short description for use in infobox settlement
local p = {}
p.categories = ""
local plain = require('Module:Plain text')._main
local getArgs = require('Module:Arguments').getArgs
local tableTools = require ('Module:TableTools')

function p.reverseTable (init)
	init[1], init[3] = init[3], init[1]
	return init
end

function p.assign (args, argname, num)
	local val
	local var = {}
	for i = 0,num do
		--handle initial "subdivision_foo" without number
		if i == 0 then
			val = ""
		else
			val = tostring(i)
		end
		var[i+1] = p.validate(plain(args[argname..val]))
	end
	return var
end

--Display short description using {{short description}}
function p.shortdesc(text, frame)
	return frame:expandTemplate{title = 'Кратко описание', args = {text, 'noreplace'}}
end

function p.category (cattype)
	local category = string.format('[[Категория:Страници ползващи шаблон `Селище инфо` с лоши %s]]', cattype)
	if category then p.categories = p.categories..category end --categorize
end

--sanity and other checks
function p.validate (parameter, cat)
	if not parameter then return nil end
	parameter = parameter:gsub('%b()', '') --remove things in brackets as extraneous information
			   :gsub('%s+', ' ') --fix possible extra spaces from previous cleanup
			   :gsub('^%s+', '') --trim spaces from beginning
			   :gsub('%s+$', '') --trim spaces from end
	if parameter:match("[,;]") or not parameter:match("%a") then --must have some letters, ignore if multiple types/subdivisions
		if cat then p.category (cat) end
		return nil
	end
	if (parameter == "") then return nil end
	return parameter
end

--removes redundancy like "England, United Kingdom" and fixes issues like "Foo in United States" (to "Foo in the United States")
--also used in Module:Type in location
function p.cleanupLoc (location)
	if location == "" then return nil end
	local replacements = {
		["England, United Kingdom"] =  "England",
		["Scotland, United Kingdom"] =  "Scotland",
		["Wales, United Kingdom"] =  "Wales",
		["New York City, New York, United States"] =  "New York City",
		["^United States$"] = "the United States",
		["London, United Kingdom"] = "London",
		["London, England"] = "London",
		-- Шаблон:BUL (BGR)
		[" на България"] = ""
	}
	for i, v in pairs(replacements) do 
		location = location:gsub(i, v) --series of replacements
	end
	return location
end

function p.main(frame)
	local categories = ""
	local subdivision_types = {}
	local subdivision_names = {}
	local args = getArgs (frame, {parentOnly = true})
	local settlement_type = p.validate(plain(args.settlement_type or args.type), "settlement type") or "Място"
	local short_description = plain(args.short_description)
	subdivision_types = p.assign(args, "единица-1-вид", 2)
	subdivision_names = p.assign(args, "единица-1-име", 2)
	
	if short_description then
		if (short_description == 'no') then
			return
		else
			return p.shortdesc(short_description, frame)
		end
	end
	
	if not(subdivision_names[3] and
		(string.find(settlement_type, '[nN]eighbo[u]?rhood') or string.find(settlement_type, '[sS]uburb'))) then
		subdivision_names[3] = nil --display the third subdivision_type only if suburb or neighborhood
	end
	
	--if say "Voivodeship" is found within the subdivision_type, then specially handle
	--by adding Voivodeship to the end if not already present
	for x, y in ipairs (subdivision_types) do
		local special_types = {
			"Voivodeship"
		}
		for i, j in ipairs(special_types) do
			if subdivision_names[x] and string.find(y, j, 1, true)
				and not string.find(subdivision_names[x], j, 1, true) then
				subdivision_names[x] = subdivision_names[x].." "..j
			end
		end
	end
	
	for x, y in ipairs (subdivision_names) do
		if y then
			if string.find(settlement_type, y, 1, true) then --if the subdivision is found within the settlement type
				subdivision_names[x] = nil --don't display redundancy
				p.category ("settlement type")
			end
			if y == mw.title.getCurrentTitle().text then --if the title is the same as one of the subdivision_names
				subdivision_names[x] = nil --don't display redundancy
			end
		end
	end

	local location = table.concat(tableTools.compressSparseArray(p.reverseTable(subdivision_names)), ', ')
	
	location = p.cleanupLoc (location)
	
	if location then location =  " в " .. location else location = "" end

	return p.shortdesc(settlement_type..location, frame)..p.categories
end

return p
