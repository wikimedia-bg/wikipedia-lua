--[[
Този модул има за цел да замени функционалността на {{Coord}} и свързаните 
шаблони.  Той предоставя няколко метода, включително:

{{#Invoke:Координати | coord }} : Функция, която форматира и показва стойности
на координати.

{{#Invoke:Координати | dec2dms }} : Функция, която превръща градуси записани 
като десетична стойност във формат DMS.

{{#Invoke:Координати | dms2dec }} : Превръща стойност от DMS в градуси 
записани като десетична стойност.

{{#Invoke:Coordinates | link }} : Експортира връзката, която се ползва.

]]

local math_mod = require("Модул:Math")
local coordinates = {};

local current_page = mw.title.getCurrentTitle()
local page_name = mw.uri.encode( current_page.prefixedText, 'WIKI' );
local coord_link = '//tools.wmflabs.org/geohack/geohack.php?pagename=' .. page_name .. '&language=bg&params='

--[[ Помощна функция, замества {{coord/display/title}} ]]
local function displaytitle(s, notes)
	return '<div id="coordinates" class="nomobile noprint">'
		.. '[[Географска координатна система|Координати]]: ' .. s .. notes
		.. '</div>'
end

--[[ Помощна функция, замества {{coord/display/inline}} ]]
local function displayinline(s, notes)
	return s .. notes	
end

--[[ Помощна функция, used in detecting DMS formatting ]]
local function dmsTest(first, second)
	if type(first) ~= 'string' or type(second) ~= 'string' then
		return nil
	end
	local s = (first .. second):upper()
	return s:find('^[NS][EW]$') or s:find('^[EW][NS]$')
end


--[[ Wrapper function to grab args, see Module:Arguments for this function's documentation. ]]
local function makeInvokeFunc(funcName)
	return function (frame)
		local args = require('Модул:Arguments').getArgs(frame, {
			wrappers = 'Шаблон:Координати'
		})
		return coordinates[funcName](args)
	end
end

--[[ Помощна функция, handle optional args. ]]
local function optionalArg(arg, supplement)
	return arg and arg .. supplement or ''
end

--[[
Formats any error messages generated for display
]]
local function errorPrinter(errors)
	local result = ""
	for i,v in ipairs(errors) do
		local errorHTML = '<strong class="error">Координати: ' .. v[2] .. '</strong>'
		result = result .. errorHTML .. "<br />"
	end
	return result
end

--[[
Determine the required CSS class to display coordinates

Usually geo-nondefault is hidden by CSS, unless a user has overridden this for himself
default is the mode as specificied by the user when calling the {{coord}} template
mode is the display mode (dec or dms) that we will need to determine the css class for 
]]
local function displayDefault(default, mode)
	if default == "" then
		default = "dec"
	end
	
	if default == mode then
		return "geo-default"
	else
		return "geo-nondefault"
	end
end

--[[
specPrinter

Output formatter.  Takes the structure generated by either parseDec
or parseDMS and formats it for inclusion on Wikipedia.
]]
local function specPrinter(args, coordinateSpec)
	local uriComponents = coordinateSpec["param"]
	if uriComponents == "" then
		-- RETURN error, should never be empty or nil
		return "ГРЕШКА - липсва параметър"
	end
	if args["name"] then
		uriComponents = uriComponents .. "&title=" .. mw.uri.encode(coordinateSpec["name"])
	end
	
	local geodmshtml = '<span class="geo-dms" title="Карти, снимки от въздуха и други данни за това място">'
			 .. '<span class="latitude">' .. coordinateSpec["dms-lat"] .. '</span> '
			 .. '<span class="longitude">' ..coordinateSpec["dms-long"] .. '</span>'
			 .. '</span>'

	local lat = tonumber( coordinateSpec["dec-lat"] ) or 0
	local geodeclat
	if lat < 0 then
		-- FIXME this breaks the pre-existing precision
		geodeclat = tostring(coordinateSpec["dec-lat"]):sub(2) .. "° ю.ш."
	else
		geodeclat = (coordinateSpec["dec-lat"] or 0) .. "° с.ш."
	end

	local long = tonumber( coordinateSpec["dec-long"] ) or 0
	local geodeclong
	if long < 0 then
		-- FIXME does not handle unicode minus
		geodeclong = tostring(coordinateSpec["dec-long"]):sub(2) .. "° з.д." 
	else
		geodeclong = (coordinateSpec["dec-long"] or 0) .. "° и.д."
	end
	
	local geodechtml = '<span class="geo-dec" title="Карти, снимки от въздуха и други данни за това място">'
			 .. geodeclat .. ' '
			 .. geodeclong
			 .. '</span>'

	local geonumhtml = '<span class="geo">'
			 .. coordinateSpec["dec-lat"] .. '; '
			 .. coordinateSpec["dec-long"]
			 .. '</span>'

	local inner = '<span class="' .. displayDefault(coordinateSpec["default"], "dms" ) .. '">' .. geodmshtml .. '</span>'
				.. '<span class="geo-multi-punct">&#xfeff; / &#xfeff;</span>'
				.. '<span class="' .. displayDefault(coordinateSpec["default"], "dec" ) .. '">';

	if not args["name"] then
		inner = inner .. geodechtml 
				.. '<span style="display:none">&#xfeff; / ' .. geonumhtml .. '</span></span>'
	else
		inner = inner .. '<span class="vcard">' .. geodechtml 
				.. '<span style="display:none">&#xfeff; / ' .. geonumhtml .. '</span>'
				.. '<span style="display:none">&#xfeff; (<span class="fn org">'
				.. args["name"] .. '</span>)</span></span></span>'
	end

	return '<span class="plainlinks nourlexpansion">' .. 
		'[' .. coord_link .. uriComponents .. ' ' .. inner .. ']' .. '</span>'
end

--[[ Помощна функция, convert decimal to degrees ]]
local function convert_dec2dms_d(coordinate)
	local d = math_mod._round( coordinate, 0 ) .. "°"
	return d .. ""
end

--[[ Помощна функция, convert decimal to degrees and minutes ]]
local function convert_dec2dms_dm(coordinate)	
	coordinate = math_mod._round( coordinate * 60, 0 );
	local m = coordinate % 60;
	coordinate = math.floor( (coordinate - m) / 60 );
	local d = coordinate % 360 .."°"
	
	return d .. string.format( "%02d′", m )
end

--[[ Помощна функция, convert decimal to degrees, minutes, and seconds ]]
local function convert_dec2dms_dms(coordinate)
	coordinate = math_mod._round( coordinate * 60 * 60, 0 );
	local s = coordinate % 60
	coordinate = math.floor( (coordinate - s) / 60 );
	local m = coordinate % 60
	coordinate = math.floor( (coordinate - m) / 60 );
	local d = coordinate % 360 .."°"

	return d .. string.format( "%02d′", m ) .. string.format( "%02d″", s )
end

--[[ 
Помощна функция, convert decimal latitude or longitude to 
degrees, minutes, and seconds format based on the specified precision.  
]]
local function convert_dec2dms(coordinate, firstPostfix, secondPostfix, precision)
	local coord = tonumber(coordinate)
	local postfix
	if coord >= 0 then
		postfix = firstPostfix
	else
		postfix = secondPostfix
	end

	precision = precision:lower();
	if precision == "dms" then
		return convert_dec2dms_dms( math.abs( coord ) ) .. postfix;
	elseif precision == "dm" then
		return convert_dec2dms_dm( math.abs( coord ) ) .. postfix;
	elseif precision == "d" then
		return convert_dec2dms_d( math.abs( coord ) ) .. postfix;
	end
end

--[[
Convert DMS format into a N or E decimal coordinate
]]
local function convert_dms2dec(direction, degrees_str, minutes_str, seconds_str)
	local degrees = tonumber(degrees_str)
	local minutes = tonumber(minutes_str) or 0
	local seconds = tonumber(seconds_str) or 0
	
	local factor = 1
	if direction == "S" or direction == "W" then
		factor = -1
	end
	
	local precision = 0
	if seconds_str then
		precision = 5 + math.max( math_mod._precision(seconds_str), 0 );
	elseif minutes_str and minutes_str ~= '' then
		precision = 3 + math.max( math_mod._precision(minutes_str), 0 );
	else
		precision = math.max( math_mod._precision(degrees_str), 0 );
	end
	
	local decimal = factor * (degrees+(minutes+seconds/60)/60) 
	return string.format( "%." .. precision .. "f", decimal ) -- not tonumber since this whole thing is string based.
end

--[[ 
Checks input values to for out of range errors.
]]
local function validate( lat_d, lat_m, lat_s, long_d, long_m, long_s, source, strong )
	local errors = {};
	lat_d = tonumber( lat_d ) or 0;
	lat_m = tonumber( lat_m ) or 0;
	lat_s = tonumber( lat_s ) or 0;
	long_d = tonumber( long_d ) or 0;
	long_m = tonumber( long_m ) or 0;
	long_s = tonumber( long_s ) or 0;

	if strong then
		if lat_d < 0 then
			table.insert(errors, {source, "latitude degrees < 0 with hemisphere flag"})
		end
		if long_d < 0 then
			table.insert(errors, {source, "longitude degrees < 0 with hemisphere flag"})
		end
		--[[ 
		#coordinates is inconsistent about whether this is an error.  If globe: is
		specified, it won't error on this condition, but otherwise it will.
		
		For not simply disable this check.
		
		if long_d > 180 then
			table.insert(errors, {source, "longitude degrees > 180 with hemisphere flag"})
		end
		]]
	end	
		
	if lat_d > 90 then
		table.insert(errors, {source, "latitude degrees > 90"})
	end
	if lat_d < -90 then
		table.insert(errors, {source, "latitude degrees < -90"})
	end
	if lat_m >= 60 then
		table.insert(errors, {source, "latitude minutes >= 60"})
	end
	if lat_m < 0 then
		table.insert(errors, {source, "latitude minutes < 0"})
	end
	if lat_s >= 60 then
		table.insert(errors, {source, "latitude seconds >= 60"})
	end
	if lat_s < 0 then
		table.insert(errors, {source, "latitude seconds < 0"})
	end
	if long_d >= 360 then
		table.insert(errors, {source, "longitude degrees >= 360"})
	end
	if long_d <= -360 then
		table.insert(errors, {source, "longitude degrees <= -360"})
	end
	if long_m >= 60 then
		table.insert(errors, {source, "longitude minutes >= 60"})
	end
	if long_m < 0 then
		table.insert(errors, {source, "longitude minutes < 0"})
	end
	if long_s >= 60 then
		table.insert(errors, {source, "longitude seconds >= 60"})
	end
	if long_s < 0 then
		table.insert(errors, {source, "longitude seconds < 0"})
	end
	
	return errors;
end

--[[
parseDec

Transforms decimal format latitude and longitude into the a
structure to be used in displaying coordinates
]]
local function parseDec( lat, long, format )
	local coordinateSpec = {}
	local errors = {}
	
	if not long then
		return nil, {{"parseDec", "Липсва геогр. дължина"}}
	elseif not tonumber(long) then
		return nil, {{"parseDec", "Longitude could not be parsed as a number: " .. long}}
	end
	
	errors = validate( lat, nil, nil, long, nil, nil, 'parseDec', false );	
	coordinateSpec["dec-lat"]  = lat;
	coordinateSpec["dec-long"] = long;

	local mode = coordinates.determineMode( lat, long );
	coordinateSpec["dms-lat"]  = convert_dec2dms( lat, "с.ш.", "ю.ш.", mode)  -- {{coord/dec2dms|{{{1}}}|N|S|{{coord/prec dec|{{{1}}}|{{{2}}}}}}}
	coordinateSpec["dms-long"] = convert_dec2dms( long, "и.д.", "з.д.", mode)  -- {{coord/dec2dms|{{{2}}}|E|W|{{coord/prec dec|{{{1}}}|{{{2}}}}}}}	
	
	if format then
		coordinateSpec.default = format
	else
		coordinateSpec.default = "dec"
	end

	return coordinateSpec, errors
end

--[[
parseDMS

Transforms degrees, minutes, seconds format latitude and longitude 
into the a structure to be used in displaying coordinates
]]
local function parseDMS( lat_d, lat_m, lat_s, lat_f, long_d, long_m, long_s, long_f, format )
	local coordinateSpec = {}
	local errors = {}
	
	lat_f = lat_f:upper();
	long_f = long_f:upper();
	
	-- Check if specified backward
	if lat_f == 'E' or lat_f == 'W' then
		local t_d, t_m, t_s, t_f;
		t_d = lat_d;
		t_m = lat_m;
		t_s = lat_s;
		t_f = lat_f;
		lat_d = long_d;
		lat_m = long_m;
		lat_s = long_s;
		lat_f = long_f;
		long_d = t_d;
		long_m = t_m;
		long_s = t_s;
		long_f = t_f;
	end	
	
	errors = validate( lat_d, lat_m, lat_s, long_d, long_m, long_s, 'parseDMS', true );
	if not long_d then
		return nil, {{"parseDMS", "Липсва геогр. дължина" }}
	elseif not tonumber(long_d) then
		return nil, {{"parseDMS", "Longitude could not be parsed as a number:" .. long_d }}
	end
	
	if not lat_m and not lat_s and not long_m and not long_s and #errors == 0 then 
		if math_mod._precision( lat_d ) > 0 or math_mod._precision( long_d ) > 0 then
			if lat_f:upper() == 'S' then 
				lat_d = '-' .. lat_d;
			end
			if long_f:upper() == 'W' then 
				long_d = '-' .. long_d;
			end	 
			
			return parseDec( lat_d, long_d, format );
		end		
	end   
	
	coordinateSpec["dms-lat"]  = lat_d.."°"..optionalArg(lat_m,"′") .. optionalArg(lat_s,"″") .. lat_f
	coordinateSpec["dms-long"] = long_d.."°"..optionalArg(long_m,"′") .. optionalArg(long_s,"″") .. long_f
	coordinateSpec["dec-lat"]  = convert_dms2dec(lat_f, lat_d, lat_m, lat_s) -- {{coord/dms2dec|{{{4}}}|{{{1}}}|0{{{2}}}|0{{{3}}}}}
	coordinateSpec["dec-long"] = convert_dms2dec(long_f, long_d, long_m, long_s) -- {{coord/dms2dec|{{{8}}}|{{{5}}}|0{{{6}}}|0{{{7}}}}}

	if format then
		coordinateSpec.default = format
	else
		coordinateSpec.default = "dms"
	end   

	return coordinateSpec, errors
end

--[[ 
Check the input arguments for coord to determine the kind of data being provided
and then make the necessary processing.
]]
local function formatTest(args)
	local result, errors
	local primary = false

	local function getParam(args, lim)
		local ret = {}
		for i = 1, lim do
			ret[i] = args[i] or ''
		end
		return table.concat(ret, '_')
	end
	
	if not args[1] then
		-- no lat logic
		return errorPrinter( {{"formatTest", "Missing latitude"}} )
	elseif not tonumber(args[1]) then
		-- bad lat logic
		return errorPrinter( {{"formatTest", "Unable to parse latitude as a number:" .. args[1]}} )
	elseif not args[4] and not args[5] and not args[6] then
		-- dec logic
		result, errors = parseDec(args[1], args[2], args.format)
		if not result then
			return errorPrinter(errors);
		end			  
		result.param = table.concat({args[1], 'N', args[2] or '', 'E', args[3] or ''}, '_')
	elseif dmsTest(args[4], args[8]) then
		-- dms logic
		result, errors = parseDMS(args[1], args[2], args[3], args[4], 
			args[5], args[6], args[7], args[8], args.format)
		if args[10] then
			table.insert(errors, {'formatTest', 'Extra unexpected parameters'})
		end
		if not result then
			return errorPrinter(errors)
		end
		result.param = getParam(args, 9)
	elseif dmsTest(args[3], args[6]) then
		-- dm logic
		result, errors = parseDMS(args[1], args[2], nil, args[3], 
			args[4], args[5], nil, args[6], args['format'])
		if args[8] then
			table.insert(errors, {'formatTest', 'Допълнителни неочаквани параметри'})
		end
		if not result then
			return errorPrinter(errors)
		end
		result.param = getParam(args, 7)
	elseif dmsTest(args[2], args[4]) then
		-- d logic
		result, errors = parseDMS(args[1], nil, nil, args[2], 
			args[3], nil, nil, args[4], args.format)
		if args[6] then
			table.insert(errors, {'formatTest', 'Допълнителен неочакван параметър'})
		end	
		if not result then
			return errorPrinter(errors)
		end
		result.param = getParam(args, 5)
	else
		-- Error
		return errorPrinter({{"formatTest", "Unknown argument format"}})
	end
	result.name = args.name
	
	local extra_param = {'dim', 'globe', 'scale', 'region', 'source', 'type'}
	for _, v in ipairs(extra_param) do
		if args[v] then 
			table.insert(errors, {'formatTest', 'Parameter: "' .. v .. '=" should be "' .. v .. ':"' })
		end
	end
	
	local ret = specPrinter(args, result)
	if #errors > 0 then
		ret = ret .. ' ' .. errorPrinter(errors) .. '[[Category:Pages with malformed coordinate tags]]'
	end
	return ret
end

--[[
Generate Wikidata tracking categories.
]]
local function makeWikidataCategories()
	local ret
	if mw.wikibase and current_page.namespace == 0 then
		local entity = mw.wikibase.getEntityObject()
		if entity and entity.claims and entity.claims.P625 and entity.claims.P625[1] then
			local snaktype = entity.claims.P625[1].mainsnak.snaktype
			if snaktype == 'value' then
				-- coordinates exist both here and on Wikidata, and can be compared.
				ret = 'Coordinates on Wikidata'
			elseif snaktype == 'somevalue' then
				ret = 'Coordinates on Wikidata set to unknown value'
			elseif snaktype == 'novalue' then
				ret = 'Coordinates on Wikidata set to no value'
			end
		else
			-- We have to either import the coordinates to Wikidata or remove them here.
			ret = 'Coordinates not on Wikidata'
		end
	end
	if ret then
		return string.format('[[Category:%s]]', ret)
	else
		return ''
	end
end

--[[
link

Simple function to export the coordinates link for other uses.

Usage:
	{{ Invoke:Coordinates | link }}
	
]]
function coordinates.link(frame)
	return coord_link;
end

--[[
dec2dms

Wrapper to allow templates to call dec2dms directly.

Usage:
	{{ Invoke:Coordinates | dec2dms | decimal_coordinate | positive_suffix | 
		negative_suffix | precision }}
	
decimal_coordinate is converted to DMS format.  If positive, the positive_suffix
is appended (typical N or E), if negative, the negative suffix is appended.  The
specified precision is one of 'D', 'DM', or 'DMS' to specify the level of detail
to use.
]]
coordinates.dec2dms = makeInvokeFunc('_dec2dms')
function coordinates._dec2dms(args)
	local coordinate = args[1]
	local firstPostfix = args[2] or ''
	local secondPostfix = args[3] or ''
	local precision = args[4] or ''

	return convert_dec2dms(coordinate, firstPostfix, secondPostfix, precision)
end

--[[
Helper function to determine whether to use D, DM, or DMS
format depending on the precision of the decimal input.
]]
function coordinates.determineMode( value1, value2 )
	local precision = math.max( math_mod._precision( value1 ), math_mod._precision( value2 ) );
	if precision <= 0 then
		return 'd'
	elseif precision <= 2 then
		return 'dm';
	else
		return 'dms';
	end
end		

--[[
dms2dec

Wrapper to allow templates to call dms2dec directly.

Usage:
	{{ Invoke:Coordinates | dms2dec | direction_flag | degrees | 
		minutes | seconds }}
	
Converts DMS values specified as degrees, minutes, seconds too decimal format.
direction_flag is one of N, S, E, W, and determines whether the output is 
positive (i.e. N and E) or negative (i.e. S and W).
]]
coordinates.dms2dec = makeInvokeFunc('_dms2dec')
function coordinates._dms2dec(args)
	local direction = args[1]
	local degrees = args[2]
	local minutes = args[3]
	local seconds = args[4]

	return convert_dms2dec(direction, degrees, minutes, seconds)
end

--[[
coord

Main entry point for Lua function to replace {{coord}}

Usage:
	{{ Invoke:Coordinates | coord }}
	{{ Invoke:Coordinates | coord | lat | long }}
	{{ Invoke:Coordinates | coord | lat | lat_flag | long | long_flag }}
	...
	
	Refer to {{coord}} documentation page for many additional parameters and 
	configuration options.
	
Note: This function provides the visual display elements of {{coord}}.  In
order to load coordinates into the database, the {{#coordinates:}} parser 
function must also be called, this is done automatically in the Lua
version of {{coord}}.
]]
coordinates.coord = makeInvokeFunc('_coord')
function coordinates._coord(args)
	if not args[1] and not args[2] and mw.wikibase.getEntityObject() then
		local entity = mw.wikibase.getEntityObject()
		if entity 
			and entity.claims
			and entity.claims.P625
			and entity.claims.P625[1].mainsnak.snaktype == 'value'
		then
			local precision = entity.claims.P625[1].mainsnak.datavalue.value.precision
			args[1]=entity.claims.P625[1].mainsnak.datavalue.value.latitude
			args[2]=entity.claims.P625[1].mainsnak.datavalue.value.longitude
			if precision then
				precision=-math_mod._round(math.log(precision)/math.log(10),0)
				args[1]=math_mod._round(args[1],precision)
				args[2]=math_mod._round(args[2],precision)
			end
		end
	end
	
	local contents = formatTest(args)
	local Notes = args.notes or ''
	local Display = args.display and args.display:lower() or 'inline'

	local function isInline(s)
		-- Finds whether coordinates are displayed inline.
		return s:find('inline') ~= nil or s == 'i' or s == 'it' or s == 'ti'
	end
	local function isInTitle(s)
		-- Finds whether coordinates are displayed in the title.
		return s:find('title') ~= nil or s == 't' or s == 'it' or s == 'ti'
	end
	
	local text = ''
	if isInline(Display) then
		text = text .. displayinline(contents, Notes)
	end
	if isInTitle(Display) then
		text = text
			.. displaytitle(contents, Notes)
			.. makeWikidataCategories()
	end
	return text
end

return coordinates
