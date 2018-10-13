--[[ ----------------------------------

Lua module implementing the {{webarchive}} template. 

A merger of the functionality of three templates: {{wayback}}, {{webcite}} and {{cite archives}}
	
]]


--[[--------------------------< D E P E N D E N C I E S >------------------------------------------------------
]]

require('Module:No globals');
local getArgs = require ('Module:Arguments').getArgs;


--[[--------------------------< F O R W A R D   D E C L A R A T I O N S >--------------------------------------
]]

local categories = {};															-- category names
local config = {};																-- global configuration settings
local digits = {};																-- for i18n; table that translates local-wiki digits to western digits
local err_warn_msgs = {};														-- error and warning messages
local excepted_pages = {};
local month_num = {};															-- for i18n; table that translates local-wiki month names to western digits
local prefixes = {};															-- service provider tail string prefixes
local services = {};															-- archive service provider data from
local s_text = {};																-- table of static text strings used to build final rendering
local uncategorized_namespaces = {};											-- list of namespaces that we should not categorize
local uncategorized_subpages = {};												-- list of subpages that should not be categorized


--[[--------------------------< P A G E   S C O P E   I D E N T I F I E R S >----------------------------------
]]

local non_western_digits;														-- boolean flag set true when data.digits.enable is true
local this_page = mw.title.getCurrentTitle();

local track = {};																-- Associative array to hold tracking categories
local ulx = {};																	-- Associative array to hold template data 


--[[--------------------------< S U B S T I T U T E >----------------------------------------------------------

Populates numbered arguments in a message string using an argument table.

]]

local function substitute (msg, args)
	return args and mw.message.newRawMessage (msg, args):plain() or msg;
end


--[[--------------------------< tableLength >-----------------------

Given a 1-D table, return number of elements

]]

local function tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end


--[=[-------------------------< M A K E _ W I K I L I N K >----------------------------------------------------

Makes a wikilink; when both link and display text is provided, returns a wikilink in the form [[L|D]]; if only
link is provided, returns a wikilink in the form [[L]]; if neither are provided or link is omitted, returns an
empty string.

]=]

local function make_wikilink (link, display, no_link)
	if nil == no_link then
		if link and ('' ~= link) then
			if display and ('' ~= display) then
				return table.concat ({'[[', link, '|', display, ']]'});
			else
				return table.concat ({'[[', link, ']]'});
			end
		end
		return display or '';													-- link not set so return the display text

	else																		-- no_link
		if display and ('' ~= display) then										-- if there is display text
			return display;														-- return that
		else
			return link or '';													-- return the target article name or empty string
		end
	end
end


--[[--------------------------< createTracking >-----------------------

Return data in track[] ie. tracking categories

]]

local function createTracking()
	if not excepted_pages[this_page.fullText] then								-- namespace:title/fragment is allowed to be categorized (typically this module's / template's testcases page(s))
		if uncategorized_namespaces[this_page.nsText] then
			return '';															-- this page not to be categorized so return empty string
		end
		for _,v in ipairs (uncategorized_subpages) do							-- cycle through page name patterns
			if this_page.text:match (v) then									-- test page name against each pattern
				return '';														-- this subpage type not to be categorized so return empty string
			end
		end
	end

	local out = {};
	if tableLength(track) > 0 then
		for key, _ in pairs(track) do											-- loop through table
			table.insert (out, make_wikilink (key));							-- and convert category names to links
		end
	end
	return table.concat (out);													-- concat into one big string; empty string if table is empty

end


--[[--------------------------< inlineError >-----------------------

Critical error. Render output completely in red. Add to tracking category.

This function called as the last thing before abandoning this module

]]

local function inlineError (msg, args)
	track[categories.error] = 1
	return table.concat ({
		'<span style="font-size:100%" class="error citation-comment">Error in ',	-- open the error message span
		config.tname,															-- insert the local language template name
		' template: ',
		substitute (msg, args),													-- insert the formatted error message
		'.</span>',																-- close the span
		createTracking()														-- add the category
		})
end


--[[--------------------------< inlineRed >-----------------------

Render a text fragment in red, such as a warning as part of the final output.
Add tracking category.

 ]]

local function inlineRed(msg, trackmsg)
	if trackmsg == "warning" then
		track[categories.warning] = 1;
	elseif trackmsg == "error" then
		track[categories.error] = 1;
	end

	return '<span style="font-size:100%" class="error citation-comment">' .. msg .. '</span>'
end


--[[--------------------------< base62 >-----------------------

Convert base-62 to base-10
Credit: https://de.wikipedia.org/wiki/Modul:Expr 

]]

local function base62( value )
	local r = 1																	-- default return value is input value is malformed

	if value:match ('%W') then													-- value must only be in the set [0-9a-zA-Z]
		return;																	-- nil return when value contains extraneous characters
	end

	local n = #value															-- number of characters in value
	local k = 1
	local c
	r = 0
	for i = n, 1, -1 do															-- loop through all characters in value from ls digit to ms digit
		c = value:byte( i, i )
		if c >= 48 and c <= 57 then												-- character is digit 0-9
			c = c - 48
		elseif c >= 65 and c <= 90 then											-- character is ascii a-z
			c = c - 55
		else																	-- must be ascii A-Z
			c = c - 61
		end
		r = r + c * k															-- accumulate this base62 character's value
		k = k * 62																-- bump for next
	end -- for i

	return r
end 


--[[--------------------------< D E C O D E _ D A T E >--------------------------------------------------------

Given a date string, return it in iso format along with an indicator of the date's format.  Except that month names
must be recognizable as legitimate month names with proper capitalization, and that the date string must match one
of the recognized date formats, no error checking is done here; return nil else

]]

local function decode_date (date_str)
	local patterns = {
		['dmy'] = {'^(%d%d?) +([^%s%d]+) +(%d%d%d%d)$', 'd', 'm', 'y'},			-- %a does not recognize unicode combining characters used by some languages
		['mdy'] = {'^([^%s%d]+) (%d%d?), +(%d%d%d%d)$', 'm', 'd', 'y'},
		['ymd'] = {'^(%d%d%d%d) +([^%s%d]+) (%d%d?)$', 'y', 'm', 'd'},			-- not mos compliant at en.wiki but may be acceptible at other wikis
		};
	
	local t = {};

	if non_western_digits then													-- this wiki uses non-western digits?
		date_str = mw.ustring.gsub (date_str, '%d', digits);					-- convert this wiki's non-western digits to western digits
	end

	if date_str:match ('^%d%d%d%d%-%d%d%-%d%d$') then							-- already an iso format date, return western digits form
		return date_str, 'iso';
	end
	
	for k, v in pairs (patterns) do
		local c1, c2, c3 = mw.ustring.match (date_str, patterns[k][1]);			-- c1 .. c3 are captured but we don't know what they hold
		
		if c1 then																-- set on match
			t = {																-- translate unspecified captures to y, m, and d
				[patterns[k][2]] = c1,											-- fill the table of captures with the captures
				[patterns[k][3]] = c2,											-- take index names from src_pattern table and assign sequential captures
				[patterns[k][4]] = c3,
				};
			if month_num[t.m] then												-- when month not already a number
				t.m = month_num[t.m];											-- replace valid month name with a number
			else
				return nil, 'iso';												-- not a valid date form because month not valid
			end

			return mw.ustring.format ('%.4d-%.2d-%.2d', t.y, t.m, t.d), k;		-- return date in iso format
		end
	end
	return nil, 'iso';															-- date could not be decoded; return nil and default iso date
end

	
--[[--------------------------< makeDate >-----------------------

Given year, month, day numbers, (zero-padded or not) return a full date in df format
where df may be one of:
	mdy, dmy, iso, ymd

on entry, year, month, day are presumed to be correct for the date that they represent; all are required

in this module, makeDate() is sometimes given an iso-format date in year:
	makeDate (2018-09-20, nil, nil, df)
this works because table.concat() sees only one table member

]]

local function makeDate (year, month, day, df)
	local format = {
		['dmy'] = 'j F Y',
		['mdy'] = 'F j, Y',
		['ymd'] = 'Y F j',
		['iso'] = 'Y-m-d',
		};

	local date = table.concat ({year, month, day}, '-');						-- assemble year-initial numeric-format date (zero padding not required here)

	if non_western_digits then													--this wiki uses non-western digits?
		date = mw.ustring.gsub (date, '%d', digits);							-- convert this wiki's non-western digits to western digits
	end

	return mw.getContentLanguage():formatDate (format[df], date);
end


--[[--------------------------< I S _ V A L I D _ D A T E >----------------------------------------------------

Returns true if date is after 31 December 1899 (why is 1900 the min year? shouldn't the internet's date-of-birth
be min year?), not after today's date, and represents a valid date (29 February 2017 is not a valid date).  Applies
Gregorian leapyear rules.

all arguments are required

]]

local function is_valid_date (year, month, day)
	local days_in_month = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
	local month_length;
	local y, m, d;
	local today = os.date ('*t');												-- fetch a table of current date parts

	if not year or '' == year or not month or '' == month or not day or '' == day then
		return false;															-- something missing
	end
	
	y = tonumber (year);
	m = tonumber (month);
	d = tonumber (day);

	if 1900 > y or today.year < y or 1 > m or 12 < m then						-- year and month are within bounds	TODO: 1900?
		return false;
	end

	if (2==m) then																-- if February
		month_length = 28;														-- then 28 days unless
		if (0==(y%4) and (0~=(y%100) or 0==(y%400))) then						-- is a leap year?
			month_length = 29;													-- if leap year then 29 days in February
		end
	else
		month_length=days_in_month[m];
	end

	if 1 > d or month_length < d then											-- day is within bounds
		return false;
	end
																					-- here when date parts represent a valid date
	return os.time({['year']=y, ['month']=m, ['day']=d, ['hour']=0}) <= os.time();	-- date at midnight must be less than or equal to current date/time
end


--[[--------------------------< decodeWebciteDate >-----------------------

Given a URI-path to Webcite (eg. /67xHmVFWP) return the encoded date in df format

returns date string in df format - webcite date is a unix timestamp encoded as bae62
or the string 'query'

]]

local function decodeWebciteDate(path, df)

	local dt = {};
	local decode;

	dt = mw.text.split(path, "/")

	-- valid URL formats that are not base62

	-- http://www.webcitation.org/query?id=1138911916587475
	-- http://www.webcitation.org/query?url=http..&date=2012-06-01+21:40:03
	-- http://www.webcitation.org/1138911916587475
	-- http://www.webcitation.org/cache/73e53dd1f16cf8c5da298418d2a6e452870cf50e
	-- http://www.webcitation.org/getfile.php?fileid=1c46e791d68e89e12d0c2532cc3cf629b8bc8c8e

	if dt[2]:find ('query', 1, true) or 
		dt[2]:find ('cache', 1, true) or
		dt[2]:find ('getfile', 1, true) or
		tonumber(dt[2]) then
			return 'query';
	end

	decode = base62(dt[2]);														-- base62 string -> exponential number
	if not decode then
		return nil;																-- nil return when dt[2] contains characters not in %w
	end
	dt = os.date('*t', string.format("%d", decode):sub(1,10))					-- exponential number -> text -> first 10 characters (a unix timestamp) -> a table of date parts

	decode = makeDate (dt.year, dt.month, dt.day, 'iso');						-- date comparisons are all done in iso format with western digits
	if non_western_digits then													--this wiki uses non-western digits?
		decode = mw.ustring.gsub (decode, '%d', digits);						-- convert this wiki's non-western digits to western digits
	end

	return decode;
end


--[[--------------------------< decodeWaybackDate >-----------------------

Given a URI-path to Wayback (eg. /web/20160901010101/http://example.com )
or Library of Congress Web Archives (/all/20160901010101/http://example.com)
return the formatted date eg. "September 1, 2016" in df format 
Handle non-digits in snapshot ID such as "re_" and "-" and "*"

returns two values:
	first value is one of these:
		valid date string in df format - wayback date is valid (including the text string 'index' when date is '/*/')
		empty string - wayback date is malformed (less than 8 digits, not a valid date)
		nil - wayback date is '/save/' or otherwise not a number
	
	second return value is an appropriate 'message' may or may not be formatted

]]

local function decodeWaybackDate(path, df)

	local msg, snapdate;

	snapdate = path:gsub ('^/all/', ''):gsub ('^/web/', ''):gsub ('^/', '');	-- remove leading '/all/', leading '/web/' or leading '/'
	snapdate = snapdate:match ('^[^/]+');										-- get timestamp
	if snapdate == "*" then														-- eg. /web/*/http.. or /all/*/http..
		return 'index';															-- return indicator that this url has an index date
	end

	snapdate = snapdate:gsub ('%a%a_%d?$', ''):gsub ('%-', '');					-- from date, remove any trailing "re_", dashes

	msg = '';
	if snapdate:match ('%*$') then												-- a trailing '*' causes calendar display at archive .org
		snapdate = snapdate:gsub ('%*$', '');									-- remove so not part of length calc later
		msg = inlineRed (err_warn_msgs.ts_cal, 'warning');						-- make a message
	end

	if not tonumber(snapdate) then
		return nil, 'ts_nan';													-- return nil (fatal error flag) and message selector
	end

	local dlen = snapdate:len();
	if dlen < 8 then															-- we need 8 digits TODO: but shouldn't this be testing for 14 digits?
		return '', inlineRed (err_warn_msgs.ts_short, 'error');					-- return empty string and error message
	end

	local year, month, day = snapdate:match ('(%d%d%d%d)(%d%d)(%d%d)');			-- no need for snapdatelong here

	if not is_valid_date (year, month, day) then
		return '', inlineRed (err_warn_msgs.ts_date, 'error');					-- return empty string and error message
	end

	snapdate = table.concat ({year, month, day}, '-');							-- date comparisons are all done in iso format
	if 14 == dlen then
		return snapdate, msg;													-- return date with message if any
	else
		return snapdate, msg .. inlineRed (err_warn_msgs.ts_len, 'warning');	-- return date with warning message(s)
	end
end


--[[--------------------------< decodeArchiveisDate >-----------------------

Given an Archive.is "long link" URI-path (e.g. /2016.08.28-144552/http://example.com)
return the date in df format (e.g. if df = dmy, return 28 August 2016)
Handles "." and "-" in snapshot date, so 2016.08.28-144552 is same as 20160828144552

returns two values:
	first value is one of these:
		valid date string in df format - archive.is date is valid (including the text string 'short link' when url is the short form)
		empty string - wayback date is malformed (not a number, less than 8 digits, not a valid date)
		nil - wayback date is '/save/'
	
	second return value is an appropriate 'message' may or may not be formatted

]]

local function decodeArchiveisDate(path, df)
	local snapdate

	if path:match ('^/%w+$') then												-- short form url path is '/' followed by some number of base 62 digits and nothing else
		return "short link"														-- e.g. http://archive.is/hD1qz
	end

	snapdate = mw.text.split (path, '/')[2]:gsub('[%.%-]', '');					-- get snapshot date, e.g. 2016.08.28-144552; remove periods and hyphens

	local dlen = string.len(snapdate)
	if dlen < 8 then															-- we need 8 digits TODO: but shouldn't this be testing for 14 digits?
		return '', inlineRed (err_warn_msgs.ts_short, 'error');					-- return empty string and error message
	end

	local year, month, day = snapdate:match ('(%d%d%d%d)(%d%d)(%d%d)');			-- no need for snapdatelong here

	if not is_valid_date (year, month, day) then
		return '', inlineRed (err_warn_msgs.ts_date, 'error');					-- return empty string and error message
	end

	snapdate = table.concat ({year, month, day}, '-');							-- date comparisons are all done in iso format
	if 14 == dlen then
		return snapdate;														-- return date
	else
		return snapdate, inlineRed (err_warn_msgs.ts_len, 'warning');			-- return date with warning message
	end
 end


--[[--------------------------< serviceName >-----------------------

Given a domain extracted by mw.uri.new() (eg. web.archive.org) set tail string and service ID

]]

local function serviceName(host, no_link)
	local tracking;
	local index;
	
	host = host:lower():gsub ('^web%.(.+)', '%1'):gsub ('^www%.(.+)', '%1');	-- lowercase, remove web. and www. subdomains

	if services[host] then
		index = host;
	else
		for k, _ in pairs (services) do
			if host:find ('%f[%a]'..k:gsub ('([%.%-])', '%%%1')) then
				index = k;
				break;
			end
		end
	end
	
	if index then
		local out = {''};														-- empty string in [1] so that concatenated result has leading single space
		ulx.url1.service = services[index][4] or 'other';
		tracking = services[index][5] or categories.other;
																				-- build tail string
		if false == services[index][1] then										-- select prefix
			table.insert (out, prefixes.at);
		elseif true == services[index][1] then
			table.insert (out, prefixes.atthe);
		else
			table.insert (out, services[index][1]);
		end
		
		table.insert (out, make_wikilink (services[index][2], services[index][3], no_link));	-- add article wikilink
		if services[index][6] then												-- add tail postfix if it exists
			table.insert (out, services[index][6]);
		end
		
		ulx.url1.tail = table.concat (out, ' ');								-- put it all together; result has leading space character

	else																		-- here when unknown archive
		ulx.url1.service = 'other';
		tracking = categories.unknown;
		ulx.url1.tail = table.concat ({'', prefixes.at, host, inlineRed (err_warn_msgs.unknown_url, error)}, ' ');
	end
	
	track[tracking] = 1
end


--[[--------------------------< parseExtraArgs >-----------------------

Parse numbered arguments starting at 2, such as url2..url10, date2..date10, title2..title10
	For example: {{webarchive |url=.. |url4=.. |url7=..}}
		Three url arguments not in numeric sequence (1..4..7). 
			Function only processes arguments numbered 2 or greater (in this case 4 and 7)
				It creates numeric sequenced table entries like:
				urlx.url2.url = <argument value for url4>
				urlx.url3.url = <argument value for url7>
			Returns the number of URL arguments found numbered 2 or greater (in this case returns "2")

 ]]

local function parseExtraArgs(args)

	local i, j, argurl, argurl2, argdate, argtitle

	j = 2
	for i = 2, config.maxurls do
		argurl = "url" .. i
		if args[argurl] then
			argurl2 = "url" .. j
			ulx[argurl2] = {}
			ulx[argurl2]["url"] = args[argurl]
			argdate = "date" .. j
			if args[argdate] then
				ulx[argurl2]["date"] = args[argdate]
			else
				ulx[argurl2]["date"] = inlineRed (err_warn_msgs.date_miss, 'warning');
			end
	
			argtitle = "title" .. j
			if args[argtitle] then
				ulx[argurl2]["title"] = args[argtitle]
			else
				ulx[argurl2]["title"] = nil
			end
			j = j + 1
		end
	end

	if j == 2 then
		return 0
	else
		return j - 2
	end
end


--[[--------------------------< comma >-----------------------

Given a date string, return "," if it's MDY 

]]

local function comma(date)
	return (date and date:match ('%a+ +%d%d?(,) +%d%d%d%d')) or '';
end


--[[--------------------------< createRendering >-----------------------

Return a rendering of the data in ulx[][]

]]

local function createRendering()

	local displayfield
	local out = {};
	
	local period1 = '';															-- For backwards compat with {{wayback}}
	local period2 = '.';															

	local index_date, msg = ulx.url1.date:match ('(index)(.*)');				-- when ulx.url1.date extract 'index' text and message text (if there is a message)
	ulx.url1.date = ulx.url1.date:gsub ('index.*', 'index');					-- remove message

	if 'none' == ulx.url1.format then											-- For {{wayback}}, {{webcite}}
		table.insert (out, '[');												-- open extlink markup
		table.insert (out, ulx.url1.url);										-- add url

		if ulx.url1.title then
			table.insert (out, ' ')												-- the required space
			table.insert (out, ulx.url1.title)									-- the title
			table.insert (out, ']');											-- close extlink markup
			table.insert (out, ulx.url1.tail);									-- tail text
			if ulx.url1.date then
				table.insert (out, '&#32;(');									-- open date text; TODO: why the html entity? replace with regular space?
				table.insert (out, 'index' == ulx.url1.date and s_text.archive or s_text.archived);	-- add text
				table.insert (out, ' ');										-- insert a space
				table.insert (out, ulx.url1.date);								-- add date
				table.insert (out, ')');										-- close date text
			end
		else																	-- no title
			if index_date then													-- when url date is 'index' 
				table.insert (out, table.concat ({' ', s_text.Archive_index, ']'}));	-- add the index link label
				table.insert (out, msg or '');									-- add date mismatch message when url date is /*/ and |date= has valid date
			else
				table.insert (out, table.concat ({' ', s_text.Archived, '] '}));	-- add link label for url has timestamp date (will include mismatch message if there is one)
			end
			if ulx.url1.date then
				if 'wayback' == ulx.url1.service then 
					period1 = '.';
					period2 = '';
				end
				if 'index' ~= ulx.url1.date then
					table.insert (out, ulx.url1.date);							-- add date when data is not 'index'
				end
				table.insert (out, comma(ulx.url1.date));						-- add ',' if date format is mdy
				table.insert (out, ulx.url1.tail);								-- add tail text
				table.insert (out, period1);									-- terminate
			else																-- no date
				table.insert (out, ulx.url1.tail);								-- add tail text
			end
		end

		if 0 < ulx.url1.extraurls then											-- For multiple archive URLs
			local tot = ulx.url1.extraurls + 1
			table.insert (out, period2);										-- terminate first url
			table.insert (out, table.concat ({' ', s_text.addlarchives, ': '}));	-- add header text

			for i=2, tot do														-- loop through the additionals
				local index = table.concat ({'url', i});						-- make an index
				displayfield = ulx[index]['title'] and 'title' or 'date';		-- choose display text
				table.insert (out, '[');										-- open extlink markup
				table.insert (out, ulx[index]['url']);							-- add the url
				table.insert (out, ' ');										-- the required space
				table.insert (out, ulx[index][displayfield]);					-- add the label
				table.insert (out, ']');										-- close extlink markup
				table.insert (out, i==tot and '.' or ', ');						-- add terminator
			end
		end
		return table.concat (out);												-- make a big string and done

	else																		-- For {{cite archives}}																	
		if 'addlarchives' == ulx.url1.format then								-- Multiple archive services 
			table.insert (out, table.concat ({s_text.addlarchives, ': '}));		-- add header text
		else																	-- Multiple pages from the same archive 
			table.insert (out, table.concat ({s_text.addlpages, ' '}));			-- add header text
			table.insert (out, ulx.url1.date);									-- add date to header text
			table.insert (out, ': ');											-- close header text
		end

		local tot = ulx.url1.extraurls + 1;
		for i=1, tot do															-- loop through the additionals
			local index = table.concat ({'url', i});							-- make an index
			table.insert (out, '[');											-- open extlink markup
			table.insert (out, ulx[index]['url']);								-- add url
			table.insert (out, ' ');											-- add required space

			displayfield = ulx[index]['title'];
			if 'addlarchives' == ulx.url1.format then
				if not displayfield then 
					displayfield = ulx[index]['date']
				end
			else																-- must be addlpages
				if not displayfield then 
					displayfield = table.concat ({s_text.Page, ' ', i});
				end
			end
			table.insert (out, displayfield);									-- add title, date, page label text
			table.insert (out, ']');											-- close extlink markup
			table.insert (out, (i==tot and '.' or ', '));							-- add terminator
		end
		return table.concat (out);												-- make a big string and done
	end
end


--[[--------------------------< P A R A M E T E R _ N A M E _ X L A T E >--------------------------------------

for internaltionalization, translate local-language parameter names to their English equivalents

TODO: return error message if multiple aliases of the same canonical parameter name are found?

returns two tables:
	new_args - holds canonical form parameters and their values either from translation or because the parameter was already in canonical form
	origin - maps canonical-form parameter names to their untranslated (local language) form for error messaging in the local language

unrecognized parameters are ignored

]]

local function parameter_name_xlate (args, params, enum_params)
	local name;																	-- holds modifiable name of the parameter name during evaluation
	local enum;																	-- for enumerated parameters, holds the enumerator during evaluation
	local found = false;														-- flag used to break out of nested for loops
	local new_args = {};														-- a table that holds canonical and translated parameter k/v pairs
	local origin = {};															-- a table that maps original (local language) parameter names to their canonical name for local language error messaging
	local unnamed_params;														-- set true when unsupported positional parameters are detected
	
	for k, v in pairs (args) do													-- loop through all of the arguments in the args table
		name = k;																-- copy of original parameter name

		if 'string' == type (k) then
			if non_western_digits then											-- true when non-western digits supported at this wiki
				name = mw.ustring.gsub (name, '%d', digits);					-- convert this wiki's non-western digits to western digits
			end
			
			enum = name:match ('%d+$');											-- get parameter enumerator if it exists; nil else
			
			if not enum then													-- no enumerator so looking for non-enumnerated parameters
				-- TODO: insert shortcut here? if params[name] then name holds the canonical parameter name; no need to search further
				for pname, aliases in pairs (params) do							-- loop through each parameter the params table
					for _, alias in ipairs (aliases) do							-- loop through each alias in the parameter's aliases table
						if name == alias then
							new_args[pname] = v;								-- create a new entry in the new_args table
							origin [pname] = k;									-- create an entry to make canonical parameter name to original local language parameter name
							found = true;										-- flag so that we can break out of these nested for loops
							break;												-- no need to search the rest of the aliases table for name so go on to the next k, v pair
						end
					end
	
					if found then												-- true when we found an alias that matched name
						found = false;											-- reset the flag
						break;													-- go do next args k/v pair
					end
				end
			else																-- enumerated parameters
				name = name:gsub ('%d$', '#');									-- replace enumeration digits with place holder for table search
				-- TODO: insert shortcut here? if num_params[name] then name holds the canonical parameter name; no need to search further
				for pname, aliases in pairs (enum_params) do					-- loop through each parameter the num_params table
					for _, alias in ipairs (aliases) do							-- loop through each alias in the parameter's aliases table
						if name == alias then
							pname = pname:gsub ('#$', enum);					-- replace the '#' place holder with the actual enumerator
							new_args[pname] = v;								-- create a new entry in the new_args table
							origin [pname] = k;									-- create an entry to make canonical parameter name to original local language parameter name
							found = true;										-- flag so that we can break out of these nested for loops
							break;												-- no need to search the rest of the aliases table for name so go on to the next k, v pair
						end
					end
	
					if found then												-- true when we found an alias that matched name
						found = false;											-- reset the flag
						break;													-- go do next args k/v pair
					end
				end
			end
		else
			unnamed_params = true;												-- flag for unsupported positional parameters
		end
	end																			-- for k, v
	return new_args, origin, unnamed_params;
end


--[[--------------------------< W E B A R C H I V E >----------------------------------------------------------

template entry point

]]

local function webarchive(frame)
	local args = getArgs (frame);

	local data = mw.loadData (table.concat ({									-- make a data module name; sandbox or live
		'Module:Webarchive/data',
		frame:getTitle():find('sandbox', 1, true) and '/sandbox' or ''			-- this instance is ./sandbox then append /sandbox
		}));
	categories = data.categories;												-- fill in the forward declarations
	config = data.config;
	if data.digits.enable then
		digits = data.digits;													-- for i18n; table of digits in the local wiki's language
		non_western_digits = true;												-- use_non_western_digits
	end
	err_warn_msgs = data.err_warn_msgs;
	excepted_pages = data.excepted_pages;
	month_num = data.month_num;													-- for i18n; table of month names in the local wiki's language
	prefixes = data.prefixes;
	services = data.services;
	s_text = data.s_text;
	uncategorized_namespaces = data.uncategorized_namespaces;
	uncategorized_subpages = data.uncategorized_subpages;

	local origin = {};															-- holds a map of English to local language parameter names used in the current template; not currently used
	local unnamed_params;														-- boolean set to true when template call has unnamed parameters
	args, origin, unnamed_params = parameter_name_xlate (args, data.params, data.enum_params);	-- translate parameter names in args to English

	local date, format, msg, udate, uri, url;
	local ldf = 'iso';															-- when there is no |date= parameter, render url dates in iso format
	
	if args.url and args.url1 then												-- URL argument (first)
		return inlineError (data.crit_err_msgs.conflicting, {origin.url, origin.url1});
	end
	
	url = args.url or args.url1;
	
	if not url then
		return inlineError (data.crit_err_msgs.empty);
	end
																				-- these iabot bugs perportedly fixed; removing these causes lua script error
--[[																				-- at Template:Webarchive/testcases/Production; resolve that before deleting these tests
	if mw.ustring.find( url, "https://web.http", 1, true ) then					-- track bug - TODO: IAbot bug; not known if the bug has been fixed; deferred
		track[categories.error] = 1;
		return inlineError (data.crit_err_msgs.iabot1);
	end 
	if url == "https://web.archive.org/http:/" then								 -- track bug - TODO: IAbot bug; not known if the bug has been fixed; deferred
		track[categories.error] = 1;
		return inlineError (data.crit_err_msgs.iabot2);
	end
]]

	if not (url:lower():find ('^http') or url:find ('^//')) then
		return inlineError (data.crit_err_msgs.invalid_url );
	end

	ulx.url1 = {}
	ulx.url1.url = url

	ulx.url1.extraurls = parseExtraArgs(args)

	local good = false;
	good, uri = pcall (mw.uri.new, ulx.url1.url);								-- get a table of uri parts from this url; protected mode to prevent lua error when ulx.url1.url is malformed
	
	if not good or nil == uri.host then											-- abandon when ulx.url1.url is malformed
		return inlineError (data.crit_err_msgs.invalid_url);
	end
	
	serviceName(uri.host, args.nolink)

	if args.date and args.date1 then											-- Date argument
		return inlineError (data.crit_err_msgs.conflicting, {origin.date, origin.date1});
	end
	
	date = args.date or args.date1;
	date = date and date:gsub (' +', ' ');										-- replace multiple spaces with a single space

	if date and config.verifydates then
		if '*' == date then
			date = 'index';
			ldf = 'iso';														-- set to default format
		else
			date, ldf = decode_date (date);										-- get an iso format date from date and get date's original format
		end
	end

	if 'wayback' == ulx.url1.service or 'locwebarchives' == ulx.url1.service then
		if date then
			if config.verifydates then
				if ldf then
					udate, msg = decodeWaybackDate (uri.path);					-- get the url date in iso format and format of date in |date=; 'index' when wayback url date is *
					if not udate then											-- this is the only 'fatal' error return
						return inlineError (data.crit_err_msgs[msg]);
					end

					if udate ~= date then										-- date comparison using iso format dates
						date = udate;
						msg = table.concat ({
							inlineRed (err_warn_msgs.mismatch, 'warning'),		-- add warning message
							msg,												-- add message if there is one
						});
					end
				end
			end
		else																	-- no |date=
			udate, msg = decodeWaybackDate (uri.path);

			if not udate then													-- this is the only 'fatal' error return
				return inlineError (data.crit_err_msgs[msg]);
			end

			if '' == udate then 
				date = nil;														-- unset
			else
				date = udate;
			end
		end

	elseif 'webcite' == ulx.url1.service then
		if date then
			if config.verifydates then
				if ldf then
					udate = decodeWebciteDate (uri.path);						-- get the url date in iso format
					if 'query' ~= udate then									-- skip if query
						if udate ~= date then									-- date comparison using iso format dates
							date = udate;
							msg = table.concat ({
								inlineRed (err_warn_msgs.mismatch, 'warning'),
								});
						end
					end
				end
			end
		else
			date = decodeWebciteDate( uri.path, "iso" )
			if date == "query" then
				date = nil;														-- unset
				msg = inlineRed (err_warn_msgs.date_miss, 'warning');
			elseif not date then												-- invalid base62 string
				date = inlineRed (err_warn_msgs.date1, 'error');
			end
		end

	elseif 'archiveis' == ulx.url1.service then
		if date then
			if config.verifydates then
				if ldf then
					udate, msg = decodeArchiveisDate (uri.path)					-- get the url date in iso format
					if 'short link' ~= udate then								-- skip if short link
						if udate ~= date then									-- date comparison using iso format dates
							date = udate;
							msg = table.concat ({
								inlineRed (err_warn_msgs.mismatch, 'warning'),	-- add warning message
								msg,											-- add message if there is one
							});
						end
					end
				end
			end
		else																	-- no |date=
			udate, msg = decodeArchiveisDate( uri.path, "iso" )
			if udate == "short link" then
				date = nil;														-- unset
				msg = inlineRed (err_warn_msgs.date_miss, 'warning');
			elseif '' == udate then
				date = nil;														-- unset
			else
				date = udate;
			end
		end
		
	else																		-- some other service
		if not date then
			msg = inlineRed (err_warn_msgs.date_miss, 'warning');
		end
	end

	if 'index' == date then
		ulx.url1.date = date .. (msg or '');									-- create index + message (if there is one)
	elseif date then
		ulx.url1.date = makeDate (date, nil, nil, ldf) .. (msg or '');			-- create a date in the wiki's local language + message (if there is one)
	else
		ulx.url1.date = msg;
	end

	format = args.format;														-- Format argument 

	if not format then
		format = "none"
	else
		for k, v in pairs (data.format_vals) do									-- |format= accepts two specific values loop through a table of those values
			local found;														-- declare a nil flag
			for _, p in ipairs (v) do											-- loop through local language variants
				if format == p then												-- when |format= value matches 
					format = k;													-- use name from table key
					found = true;												-- declare found so that we can break out of outer for loop
					break;														-- break out of inner for loop
				end
			end
			
			if found then
				break;
			end
		end

		if format == "addlpages" then
			if not ulx.url1.date then
				format = "none"
			end
		elseif format == "addlarchives" then
			format = "addlarchives"
		else
			format = "none"
		end
	end
	ulx.url1.format = format

	if args.title and args.title1 then											-- Title argument
		return inlineError (data.crit_err_msgs.conflicting, {origin.title, origin.title1});
	end

	ulx.url1.title = args.title or args.title1;

	local rend = createRendering()
	if not rend then
		return inlineError (data.crit_err_msgs.unknown);
	end

	return rend .. ((unnamed_params and inlineRed (err_warn_msgs.unnamed_params, 'warning')) or '') .. createTracking();

end


--[[--------------------------< E X P O R T E D 	 F U N C T I O N S >------------------------------------------
]]

return {webarchive = webarchive};