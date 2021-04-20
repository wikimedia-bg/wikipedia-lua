local p = {}

p.trim = function(frame)
	local s = mw.text.trim(frame.args[1] or "")
	return s
end

p.upper = function(frame)
	local s = mw.text.trim(frame.args[1] or "")
	return string.upper(s)
end

p.lower = function(frame)
	local s = mw.text.trim(frame.args[1] or "")
	return string.lower(s)
end

p.sentence = function (frame )
	frame.args[1] = string.lower(frame.args[1])
	return p.ucfirst(frame)
end

p.ucfirst = function (frame )
	local s =  mw.text.trim( frame.args[1] or "" )
	local s1 = ""
	-- if it's a list chop off and (store as s1) everything up to the first <li>
	local lipos = mw.ustring.find(s, "<li>" )
	if lipos then
		s1 = mw.ustring.sub(s, 1, lipos + 3)
		s = mw.ustring.sub(s, lipos + 4)
	end
	-- s1 is either "" or the first part of the list markup, so we can continue
	-- and prepend s1 to the returned string
	local letterpos
	if mw.ustring.find(s, "^%[%[[^|]+|[^%]]+%]%]") then
		-- this is a piped wikilink, so we capitalise the text, not the pipe
		local _
		_, letterpos = mw.ustring.find(s, "|%A*%a") -- find the first letter after the pipe
	else
		letterpos = mw.ustring.find(s, '%a')
	end
	if letterpos then
		local first = mw.ustring.sub(s, 1, letterpos - 1)
		local letter = mw.ustring.sub(s, letterpos, letterpos)
		local rest = mw.ustring.sub(s, letterpos + 1)
		return s1 .. first .. mw.ustring.upper(letter) .. rest
	else
		return s1 .. s
	end
end

p.title = function (frame )
	-- http://grammar.yourdictionary.com/capitalization/rules-for-capitalization-in-titles.html
	-- recommended by The U.S. Government Printing Office Style Manual:
	-- "Capitalize all words in titles of publications and documents,
	-- except a, an, the, at, by, for, in, of, on, to, up, and, as, but, or, and nor."
	local alwayslower = {['a'] = 1, ['an'] = 1, ['the'] = 1,
		['and'] = 1, ['but'] = 1, ['or'] = 1, ['for'] = 1,
		['nor'] = 1, ['on'] = 1, ['in'] = 1, ['at'] = 1, ['to'] = 1,
		['from'] = 1, ['by'] = 1, ['of'] = 1, ['up'] = 1 }
	local res = ''
	local s =  mw.text.trim( frame.args[1] or "" )
	local words = mw.text.split( s, " ")
	for i, s in ipairs(words) do
		s = string.lower( s )
		if( i > 1 and alwayslower[s] == 1) then
			-- leave in lowercase
		else
			s = mw.getContentLanguage():ucfirst(s)
		end
		words[i] = s
	end
	return table.concat(words, " ")
end

-- findlast finds the last item in a list
-- the first unnamed parameter is the list
-- the second, optional unnamed parameter is the list separator (default = comma space)
-- returns the whole list if separator not found
p.findlast = function(frame)
	local s =  mw.text.trim( frame.args[1] or "" )
	local sep = frame.args[2] or ""
	if sep == "" then sep = ", " end
	local pattern = ".*" .. sep .. "(.*)"
	local a, b, last = s:find(pattern)
	if a then
		return last
	else
		return s
	end
end

-- stripZeros finds the first number and strips leading zeros (apart from units)
-- e.g "0940" -> "940"; "Year: 0023" -> "Year: 23"; "00.12" -> "0.12"
p.stripZeros = function(frame)
	local s = mw.text.trim(frame.args[1] or "")
	local n = tonumber( string.match( s, "%d+" ) ) or ""
	s = string.gsub( s, "%d+", n, 1 )
	return s
end

-- nowiki ensures that a string of text is treated by the MediaWiki software as just a string
-- it takes an unnamed parameter and trims whitespace, then removes any wikicode
p.nowiki = function(frame)
	local str = mw.text.trim(frame.args[1] or "")
	return mw.text.nowiki(str)
end

-- posnq (position, no quotes) returns the numerical start position of the first occurrence
-- of one piece of text ("match") inside another ("str").
-- It returns nil if no match is found, or if either parameter is blank.
-- It takes the text to be searched in as the first unnamed parameter, which is trimmed.
-- It takes the text to match as the second unnamed parameter, which is trimmed and
-- any double quotes " are stripped out.
p.posnq = function(frame)
	local args = frame.args
	local pargs = frame:getParent().args
	for k, v in pairs(pargs) do
		args[k] = v
	end
	local str = mw.text.trim(args[1] or args.source or "")
	local match = mw.text.trim(args[2] or args.target or ""):gsub('"', '')
	if str == "" or match == "" then return nil end
	local plain = mw.text.trim(args[3] or args.plain or "")
	if plain == "false" then plain = false else plain = true end
	local nomatch = mw.text.trim(args[4] or args.nomatch or "")
	-- just take the start position
	local pos = mw.ustring.find(str, match, 1, plain) or nomatch
	return pos
end

-- split splits text at boundaries specified by separator
-- and returns the chunk for the index idx (starting at 1)
-- #invoke:String2 |split |text |separator |index |true/false
-- #invoke:String2 |split |txt=text |sep=separator |idx=index |plain=true/false
-- if plain is false/no/0 then separator is treated as a Lua pattern - defaults to plain=true
p.split = function(frame)
	local args = frame.args
	if not(args[1] or args.txt) then args = frame:getParent().args end
	local txt = args[1] or args.txt or ""
	if txt == "" then return nil end
	local sep = (args[2] or args.sep or ""):gsub('"', '')
	local idx = tonumber(args[3] or args.idx) or 1
	local plain = (args[4] or args.plain or "true"):sub(1,1)
	plain = (plain ~= "f" and plain ~= "n" and plain ~= "0")
	local splittbl = mw.text.split( txt, sep, plain )
	if idx < 0 then idx = #splittbl + idx + 1 end
	return splittbl[idx]
end

-- val2percent scans through a string, passed as either the first unnamed parameter or |txt=
-- it converts each number it finds into a percentage and returns the resultant string.
p.val2percent = function(frame)
	local args = frame.args
	if not(args[1] or args.txt) then args = frame:getParent().args end
	local txt = mw.text.trim(args[1] or args.txt or "")
	if txt == "" then return nil end
	local function v2p (x)
		x = (tonumber(x) or 0) * 100
		if x == math.floor(x) then x = math.floor(x) end
		return x .. "%"
	end
	txt = txt:gsub("%d[%d%.]*", v2p) -- store just the string
	return txt
end

-- one2a scans through a string, passed as either the first unnamed parameter or |txt=
-- it converts each occurrence of 'one ' into either 'a ' or 'an ' and returns the resultant string.
p.one2a = function(frame)
	local args = frame.args
	if not(args[1] or args.txt) then args = frame:getParent().args end
	local txt = mw.text.trim(args[1] or args.txt or "")
	if txt == "" then return nil end
	txt = txt:gsub(" one ", " a "):gsub("^one", "a"):gsub("One ", "A "):gsub("a ([aeiou])", "an %1"):gsub("A ([aeiou])", "An %1")
	return txt
end

-- findpagetext returns the position of a piece of text in a page
-- First positional parameter or |text is the search text
-- Optional parameter |title is the page title, defaults to current page
-- Optional parameter |plain is either true for plain search (default) or false for Lua pattern search
-- Optional parameter |nomatch is the return value when no match is found; default is nil
p._findpagetext = function(args)
	-- process parameters
	local nomatch = args.nomatch or ""
	if nomatch == "" then nomatch = nil end
	--
	local text = mw.text.trim(args[1] or args.text or "")
	if text == "" then return nil end
	--
	local title = args.title or ""
	local titleobj
	if title == "" then
		titleobj = mw.title.getCurrentTitle()
	else
		titleobj = mw.title.new(title)
	end
	--
	local plain = args.plain or ""
	if plain:sub(1, 1) == "f" then plain = false else plain = true end
	-- get the page content and look for 'text' - return position or nomatch
	local content = titleobj:getContent()
	return mw.ustring.find(content, text, 1, plain) or nomatch	-- returns multiple values
end
p.findpagetext = function(frame)
	local args = frame.args
	local pargs = frame:getParent().args
	for k, v in pairs(pargs) do
		args[k] = v
	end
	if not (args[1] or args.text) then return nil end
	-- just the first value
	return (p._findpagetext(args))
end

-- returns the decoded url. Inverse of parser function {{urlencode:val|TYPE}}
-- Type is:
-- QUERY decodes + to space (default)
-- PATH does no extra decoding
-- WIKI decodes _ to space
p._urldecode = function(url, type)
	url = url or ""
	type = (type == "PATH" or type == "WIKI") and type
	return mw.uri.decode( url, type )
end
-- {{#invoke:String2|urldecode|url=url|type=type}}
p.urldecode = function(frame)
	return mw.uri.decode( frame.args.url, frame.args.type )
end

-- what follows was merged from Module:StringFunc

-- helper functions
p._GetParameters = require('Модул:GetParameters')

-- Argument list helper function, as per Module:String
p._getParameters = p._GetParameters.getParameters

-- Escape Pattern helper function so that all characters are treated as plain text, as per Module:String
function p._escapePattern( pattern_str)
	return mw.ustring.gsub( pattern_str, "([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1" );
end

-- Helper Function to interpret boolean strings, as per Module:String
p._getBoolean = p._GetParameters.getBoolean

--[[
Strip

This function Strips characters from string

Usage:
{{#invoke:String2|strip|source_string|characters_to_strip|plain_flag}}

Parameters
	source: The string to strip
	chars:  The pattern or list of characters to strip from string, replaced with ''
	plain:  A flag indicating that the chars should be understood as plain text. defaults to true.

Leading and trailing whitespace is also automatically stripped from the string.
]]
function p.strip( frame )
	local new_args = p._getParameters( frame.args,  {'source', 'chars', 'plain'} )
	local source_str = new_args['source'] or '';
	local chars = new_args['chars'] or '' or 'characters';
	source_str = mw.text.trim(source_str);
	if source_str == '' or chars == '' then
		return source_str;
	end
	local l_plain = p._getBoolean( new_args['plain'] or true );
	if l_plain then
		chars = p._escapePattern( chars );
	end
	local result;
	result = mw.ustring.gsub(source_str, "["..chars.."]", '')
	return result;
end

--[[
Match any
Returns the index of the first given pattern to match the input. Patterns must be consecutively numbered.
Returns the empty string if nothing matches for use in {{#if:}}

Usage:
	{{#invoke:String2|matchAll|source=123 abc|456|abc}} returns '2'.

Parameters:
	source: the string to search
	plain:  A flag indicating that the patterns should be understood as plain text. defaults to true.
	1, 2, 3, ...: the patterns to search for
]]
function p.matchAny(frame)
	local source_str = frame.args['source'] or error('The source parameter is mandatory.')
	local l_plain = p._getBoolean( frame.args['plain'] or true )
	for i = 1, math.huge do
		local pattern = frame.args[i]
		if not pattern then return '' end
		if mw.ustring.find(source_str, pattern, 1, l_plain) then
			return tostring(i)
		end
	end
end

return p
