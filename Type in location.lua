local p = {}
local plaintext = require("Module:Plain text")._main

--Cleanup/format location for use in short descriptions
function p.prepareLoc (frame)
	return p._prepareLoc (frame.args[1])
end

function p._prepareLoc (text)
	text = plaintext(text)
	text = text..',' --comma at the end makes things convenient
	text = text:gsub('%b()', ', ') --remove things in brackets as extraneous information
			   :gsub('[^%s,]*%d[^%s,]*', '') --remove things with digits as generally being unnecessary postal codes/road numbers etc
			   :gsub('(,%s-),', '%1') --fix possible blank separated commas from previous cleanup
			   :gsub('%s%s', ' ') --fix possible extra spaces from previous cleanup
			   :gsub('^[%s,]*', '') --trim commas and spaces from beginning
			   :gsub('[%s,]*$', '') --trim commas and spaces from end
	return text
end

--Gets general location from more specific one for short descriptions
--i.e if a location is specified to be "P. Sherman 42 Wallaby Way Sydney, Australia", return "Sydney, Australia"
--splits by commas and returns last two entries

function p.generalLoc (frame)
	return p._generalLoc (frame.args[1])
end

function p._generalLoc (loc)
	loc = p._prepareLoc(loc)
	split = {}
	num = 0
	loc = loc..',' --comma at the end for convenient splitting with gmatch
	for k in loc:gmatch('([^,]*),') do --split by commas
		table.insert(split, k)
		num = num + 1
	end
	if num == 1 then --if only comma was the one at the end return the whole thing
		return split[1]
	else
		return split[num-1]..','..split[num] --return last two entries separated by commas
	end
end

--validate type parameter
function p.validateTyp (typ, args)
	checkpatterns = args['check-patterns']
	invalidadd = args.invalidadd
	if checkpatterns then
		for k in (checkpatterns..';'):gmatch('([^;]*);') do --split checkpatterns by ;, check if one of the patterns is in type
			if typ:match(k) then return typ end
		end
		if invalidadd then --if invalid, add to make it valid
			return typ..' '..invalidadd
		end
	else
		return typ
	end
end

--generates type in location
function p.main(frame)
	args = require('Module:Arguments').getArgs (frame, {frameOnly = true})
	return p._main(args, frame)
end

function p._main (args, frame)
	cleanupLoc = require('Module:Settlement short description').cleanupLoc
	typ = args[1]
	if typ then typ = plaintext(args[1]) end
	if not typ then return end --check after plaintexting if typ exists
	sep = ((args.sep == 'no') and '') or args.sep or ' in ' --if args.sep set to no, nothing between typ and loc, if it has other value put that
	local loc = args[2]
	if args['full-loc'] then func = '_prepareLoc' else func =  '_generalLoc' end
	if loc then
		loc = p[func](loc)
		loc = cleanupLoc (loc)
		if loc then loc =  sep..loc else loc = "" end
	else
		loc = ""
	end
	typ = p.validateTyp (typ, args)
	if typ then return frame:expandTemplate {title = 'Кратко описание', args = {typ..loc, 'noreplace'}} end
end

return p
