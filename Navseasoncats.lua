require[[strict]]
local p = {}
local horizontal = require('Module:List').horizontal

--[[==========================================================================]]
--[[                                Globals                                   ]]
--[[==========================================================================]]

local currtitle = mw.title.getCurrentTitle()
local nexistingcats = 0
local errors = ''
local testcasecolon = ''
local testcases = string.match(currtitle.subpageText, '^testcases')
if    testcases then testcasecolon = ':' end
local navborder = true
local followRs = true
local skipgaps = false
local listall = false
local tlistall = {}
local tlistallbwd = {}
local tlistallfwd = {}
local ttrackingcats = { --when reindexing, Ctrl+H 'trackcat(13,' & 'ttrackingcats[16]'
	'', -- [1] placeholder for [[Category:Navseasoncats using cat parameter]]
	'', -- [2] placeholder for [[Category:Navseasoncats using testcase parameter]]
	'', -- [3] placeholder for [[Category:Navseasoncats using unknown parameter]]
	'', -- [4] placeholder for [[Category:Navseasoncats range not using en dash]]
	'', -- [5] placeholder for [[Category:Navseasoncats range abbreviated (MOS)]]
	'', -- [6] placeholder for [[Category:Navseasoncats range redirected (base change)]]
	'', -- [7] placeholder for [[Category:Navseasoncats range redirected (var change)]] --new
	'', -- [8] placeholder for [[Category:Navseasoncats range redirected (end)]]
	'', -- [9] placeholder for [[Category:Navseasoncats range redirected (MOS)]]
	'', --[10] placeholder for [[Category:Navseasoncats range redirected (other)]]
	'', --[11] placeholder for [[Category:Navseasoncats range gaps]]
	'', --[12] placeholder for [[Category:Navseasoncats range irregular]]
	'', --[13] placeholder for [[Category:Navseasoncats range irregular, 0-length]]
	'', --[14] placeholder for [[Category:Navseasoncats range ends (present)]]
	'', --[15] placeholder for [[Category:Navseasoncats range ends (blank, MOS)]]
	'', --[16] placeholder for [[Category:Navseasoncats isolated]]
	'', --[17] placeholder for [[Category:Navseasoncats default season gap size]]
	'', --[18] placeholder for [[Category:Navseasoncats decade redirected]]
	'', --[19] placeholder for [[Category:Navseasoncats year redirected (base change)]]
	'', --[20] placeholder for [[Category:Navseasoncats year redirected (var change)]]
	'', --[21] placeholder for [[Category:Navseasoncats year redirected (other)]]
	'', --[22] placeholder for [[Category:Navseasoncats roman numeral redirected]]
	'', --[23] placeholder for [[Category:Navseasoncats nordinal redirected]]
	'', --[24] placeholder for [[Category:Navseasoncats wordinal redirected]]
	'', --[25] placeholder for [[Category:Navseasoncats TV season redirected]]
	'', --[26] placeholder for [[Category:Navseasoncats using skip-gaps parameter]]
	'', --[27] placeholder for [[Category:Navseasoncats year and range]]
	'', --[28] placeholder for [[Category:Navseasoncats year and decade]]
	'', --[29] placeholder for [[Category:Navseasoncats decade and century]]
	'', --[30] placeholder for [[Category:Navseasoncats in mainspace]]
	'', --[31] placeholder for [[Category:Navseasoncats redirection error]]
}
local avoidself =  (not string.match(currtitle.text, 'Navseasoncats with') and
					not string.match(currtitle.text, 'Navseasoncats.*/doc') and
					not string.match(currtitle.text, 'Navseasoncats.*/sandbox') and
					currtitle.text ~= 'Navseasoncats' and
					currtitle.nsText ~= 'User_talk' and
					currtitle.nsText ~= 'Template_talk' and
					(currtitle.nsText ~= 'Template' or testcases)) --avoid nested transclusion errors (i.e. {{Infilmdecade}})


--[[==========================================================================]]
--[[                      Utility & category functions                        ]]
--[[==========================================================================]]

--Determine if a category exists (in a function for easier localization).
local function catexists( title )
	return mw.title.new( title, 'Category' ).exists
end

--Error message handling.
function p.errorclass( msg )
	return mw.text.tag( 'span', {class='error mw-ext-cite-error'}, '<b>Error!</b> '..string.gsub(msg, '&#', '&amp;#') )
end

--Failure handling.
function p.failedcat( errors, sortkey )
	if avoidself then
		return (errors or '')..'&#42;&#42;&#42;Navseasoncats failed to generate navbox***'..
			   '[['..testcasecolon..'Category:Navseasoncats failed to generate navbox|'..(sortkey or 'O')..']]\n'
	end
	return ''
end

--Tracking cat handling.
--	key: 15 (when reindexing ttrackingcats{}, Ctrl+H 'trackcat(13,' & 'ttrackingcats[16]')
--	cat: 'Navseasoncats isolated'; '' to remove
--Used by main, all nav_*(), & several utility functions.
local function trackcat( key, cat )
	if avoidself and key and cat then
		if cat ~= '' then
			ttrackingcats[key] = '[['..testcasecolon..'Category:'..cat..']]'
		else
			ttrackingcats[key] = ''
		end
	end
	return
end

--Check for unknown parameters.
--Used by main only.
local function checkforunknownparams( tbl )
	local knownparams = {
		['min'] = 'min',
		['max'] = 'max',
		['cat'] = 'cat',
		['testcase'] = 'testcase',
		['testcasegap'] = 'testcasegap',
		['skip-gaps'] = 'skip-gaps',
		['list-all-links'] = 'list-all-links',
		['follow-redirects'] = 'follow-redirects',
	}
	for k, _ in pairs (tbl) do
		if knownparams[k] == nil then
			trackcat(3, 'Navseasoncats using unknown parameter')
			break
		end
	end
end

--Check for nav_*() navigational isolation (not necessarily an error).
--Used by all nav_*().
local function isolatedcat()
	if nexistingcats == 0 then
		trackcat(16, 'Navseasoncats isolated')
	end
end

--Returns the target of {{Category redirect}}, if it exists, else returns the original cat.
--{{Title year}}, etc., if found, are evaluated.
--Used by catlinkfollowr(), and so indirectly by all nav_*().
local function rtarget( frame, cat )
	local catcontent = mw.title.new( cat or '', 'Category' ):getContent()
	if string.match( catcontent or '', '{{ *[Cc]at' ) then --prelim test
		local tregex = {
			--the following 11 pages (6 condensed) redirect to [[Template:Category redirect]], in descending order, as of 9/2022:
			'{{ *[Cc]ate?g?o?r?y?[ _]*[rR]edirect',	--505+312+243+1 transclusions
			'{{ *[Cc]atr',							--21
			'{{ *[Cc]at[ _]*[rR]edir',				--5+3
			'{{ *[Cc]at[ _]*[rR]ed',				--3+2
			'{{ *[Cc]at[ _]*[mM]ove',				--1
			'{{ *[Cc]ategory[ _]*[mM]ove',			--0
		}
		for _, v in pairs (tregex) do
			local rtarget = mw.ustring.match( catcontent, v..'%s*|%s*([^|}]+)' )
			if rtarget then
				if string.match(rtarget, '{{') then --{{Title year}}, etc., exists; evaluate
					local regex_ty = '%s*|%s*([^{}]*{{([^{|}]+)}}[^{}]-)%s*}}' --eval null-param templates only; expanded if/as needed
					local rtarget_orig, ty = mw.ustring.match( catcontent, v..regex_ty )
					if rtarget_orig then
						local ty_eval = frame:expandTemplate{ title = ty, args = { page = cat } } --frame:newChild doesn't work, use 'page' param instead
						local rtarget_eval = mw.ustring.gsub(rtarget_orig, '{{%s*'..ty..'%s*}}', ty_eval )
						return rtarget_eval
					else --sub-parameters present; track & return default
						trackcat(31, 'Navseasoncats redirection error')
					end
				end
				rtarget = mw.ustring.gsub(rtarget, '^1%s*=%s*', '')
				rtarget = string.gsub(rtarget, '^[Cc]ategory:', '')
				return rtarget
			end
		end --for
	end --if
	return cat
end

--Similar to {{LinkCatIfExists2}}: make a piped link to a category, if it exists;
--if it doesn't exist, just display the greyed link title without linking.
--Follows {{Category redirect}}s.
--Returns {
--			['cat'] = cat,
--			['catexists'] = true,
--			['rtarget'] = <#R target>,
--			['navelement'] = <#R target navelement>,
--			['displaytext'] = displaytext,
--		  } if #R followed;
--returns {
--			['cat'] = cat,
--			['catexists'] = <true|false>,
--			['rtarget'] = nil,
--			['navelement'] = <cat navelement>,
--			['displaytext'] = displaytext,
--		  } otherwise.
--Used by all nav_*().
local function catlinkfollowr( frame, cat, displaytext, displayend )
	cat         = mw.text.trim(cat or '')
	displaytext = mw.text.trim(displaytext or '')
	displayend  = displayend or false --bool flag to override displaytext IIF the cat/target is terminal (e.g. "2021–present" or "2021–")
	
	local grey = '#888'
	local disp = cat
	if displaytext ~= '' then --use 'displaytext' parameter if present
		disp = mw.ustring.gsub(displaytext, '%s+%(.+$', ''); --strip any trailing disambiguator
	end
	
	local link, nilorR
	local exists = catexists(cat)
	if exists then
		nexistingcats = nexistingcats + 1
		if followRs then
			local R = rtarget(frame, cat) --find & follow #R
			if R ~= cat then --#R followed
				nilorR = R
			end
			
			if displayend then
				local y, hyph, ending = mw.ustring.match(R, '^.-(%d+)([–-])(.*)$')
				if ending == 'present' then
					disp = y..hyph..ending
				elseif ending == '' then
					disp = y..hyph..'<span style="visibility:hidden">'..y..'</span>' --hidden y to match spacing
				end
			end
			
			link = '[[:Category:'..R..'|'..disp..']]'
		else
			link = '[[:Category:'..cat..'|'..disp..']]'
		end
	else
		link = '<span style="color:'..grey..'">'..disp..'</span>'
	end
	
	if listall then
		if nilorR then --#R followed
			table.insert( tlistall, '[[:Category:'..cat..']] → '..'[[:Category:'..nilorR..']] ('..link..')' )
		else --no #R
			table.insert( tlistall, '[[:Category:'..cat..']] ('..link..')' )
		end
	end
	
	return {
		['cat'] = cat,
		['catexists'] = exists,
		['rtarget'] = nilorR,
		['navelement'] = link,
		['displaytext'] = disp,
	}
end

--Returns a numbered list of all {{Category redirect}}s followed by catlinkfollowr() -> rtarget().
--For a nav_hyphen() cat, also returns a formatted list of all cats searched for & found, & all loop indices.
--Used by all nav_*().
local function listalllinks()
	local nl = '\n# '
	local out = ''
	if currtitle.nsText == 'Category' then
		errors = p.errorclass('The <b><code>|list-all-links=yes</code></b> parameter/utility '..
							'should not be saved in category space, only previewed.')
		out = p.failedcat(errors, 'Z')
	end
	
	local bwd, fwd = '', ''
	if tlistallbwd[1] then
		bwd = '\n\nbackward search:\n# '..table.concat(tlistallbwd, nl)
	end
	if tlistallfwd[1] then
		fwd = '\n\nforward search:\n# '..table.concat(tlistallfwd, nl)
	end
	
	if tlistall[1] then
		return out..nl..table.concat(tlistall, nl)..bwd..fwd
	else
		return out..nl..'No links found!?'..bwd..fwd
	end
end

--Returns the difference b/w 2 ints separated by endash|hyphen, nil if error.
--Used by nav_hyphen() only.
local function find_duration( cat )
	local from, to = mw.ustring.match(cat, '(%d+)[–-](%d+)')
	if from and to then
		if to == '00' then return nil end --doesn't follow MOS:DATERANGE
		if (#from == 4) and (#to == 2) then             --1900-01
			to = string.match(from, '(%d%d)%d%d')..to   --1900-1901
		elseif (#from == 2) and (#to == 4) then         --  01-1902
			from = string.match(to, '(%d%d)%d%d')..from --1901-1902
		end
		return (tonumber(to) - tonumber(from))
	end
	return 0
end

--Returns the ending of a terminal cat, and sets the appropriate tracking cat, else nil.
--Used by nav_hyphen() only.
local function find_terminaltxt( cat )
	local terminaltxt = nil
	if mw.ustring.match(cat, '%d+[–-]present$') then
		terminaltxt = 'present'
		trackcat(14, 'Navseasoncats range ends (present)')
	elseif mw.ustring.match(cat, '%d+[–-]$') then
		terminaltxt = ''
		trackcat(15, 'Navseasoncats range ends (blank, MOS)')
	end
	return terminaltxt
end

--Returns an unsigned string of the 1-4 digit decade ending in "0", else nil.
--Used by nav_decade() only.
local function sterilizedec( decade )
	if decade == nil or decade == '' then
		return nil
	end
	
	local dec = string.match(decade, '^[-%+]?(%d?%d?%d?0)$') or
				string.match(decade, '^[-%+]?(%d?%d?%d?0)%D')
	if dec then
		return dec
	else
		--fix 2-4 digit decade
		local decade_fixed234 = string.match(decade, '^[-%+]?(%d%d?%d?)%d$') or
								string.match(decade, '^[-%+]?(%d%d?%d?)%d%D')
		if decade_fixed234 then
			return decade_fixed234..'0'
		end
		
		--fix 1-digit decade
		local decade_fixed1   = string.match(decade, '^[-%+]?(%d)$') or
								string.match(decade, '^[-%+]?(%d)%D')
		if decade_fixed1 then
			return '0'
		end
		
		--unfixable
		return nil
	end
end

--Check for nav_hyphen default gap size + isolatedcat() (not necessarily an error).
--Used by nav_hyphen() only.
local function defaultgapcat( bool )
	if bool and nexistingcats == 0 then
		--using "nexistingcats > 0" isn't as useful, since the default gap size obviously worked
		trackcat(17, 'Navseasoncats default season gap size')
	end
end

--12 -> 12th, etc.
--Used by nav_nordinal() & nav_wordinal().
function p.addord( i )
	if tonumber(i) then
		local s = tostring(i)
		
		local tens = string.match(s, '1%d$')
		if    tens then return s..'th' end
		
		local  ones = string.match(s, '%d$')
		if     ones == '1' then return s..'st'
		elseif ones == '2' then return s..'nd'
		elseif ones == '3' then return s..'rd' end
		
		return s..'th'
	end
	return i
end

--Returns the properly formatted central nav element.
--Expects an integer i, and a catlinkfollowr() table.
--Used by nav_decade() & nav_ordinal() only.
local function navcenter( i, catlink )
	if i == 0 then --center nav element
		if navborder == true then
			return '<b>'..catlink.displaytext..'</b>'
		else
			return '<b>'..catlink.navelement..'</b>'
		end
	else
		return catlink.navelement
	end
end

--Return conditionally aligned stacked navs.
--Used by main only.
local function nav1nav2( nav1, nav2 )
	if avoidself then
		local forcealign = '<div style="display:block !important; max-width: calc(100% - 25em);">'
		return forcealign..'\n'..nav1..'\n'..nav2..'\n</div>'
	else
		return nav1..'\n'..nav2
	end
end


--[[==========================================================================]]
--[[                  Formerly separated templates/modules                    ]]
--[[==========================================================================]]


--[[==========================={{  nav_hyphen  }}=============================]]

local function nav_hyphen( frame, start, hyph, finish, firstpart, lastpart, minseas, maxseas, testgap )
	--Expects a PAGENAME of the form "Some sequential 2015–16 example cat", where
	--	start     = 2015
	--	hyph      = –
	--	finish    = 16 (sequential years can be abbreviated, but others should be full year, e.g. "2001–2005")
	--	firstpart = Some sequential
	--	lastpart  = example cat
	--	minseas   = 1800 ('min' starting season shown; optional; defaults to -9999)
	--	maxseas   = 2000 ('max' starting season shown; optional; defaults to 9999; 2000 will show 2000-01)
	--	testgap   = 0 (testcasegap parameter for easier testing; optional)
	
	--sterilize start
	if string.match(start or '', '^%d%d?%d?%d?$') == nil then --1-4 digits, AD only
		local start_fixed = mw.ustring.match(start or '', '^%s*(%d%d?%d?%d?)%D')
		if start_fixed then
			start = start_fixed
		else
			errors = p.errorclass('Function nav_hyphen can\'t recognize the number "'..(start or '')..'" '..
								  'in the first part of the "season" that was passed to it. '..
								  'For e.g. "2015–16", "2015" is expected via "|2015|–|16|".')
			return p.failedcat(errors, 'H')
		end
	end
	local nstart = tonumber(start)
	
	--en dash check
	if hyph ~= '–' then
		trackcat(4, 'Navseasoncats range not using en dash') --nav still processable, but track
	end
	
	--sterilize finish & check for weird parents
	local tgaps   = {} --table of gap sizes found b/w terms    { [<gap size found>]    = 1 }
	local ttlens  = {} --table of term lengths found w/i terms { [<term length found>] = 1 }
	local tirregs = {} --table of ir/regular-term-length cats' "from"s & "to"s found
	local regularparent = true
	if (finish == -1) or --"Members of the Scottish Parliament 2021–present"
	   (finish == 0)	 --"Members of the Scottish Parliament 2021–"
	then
		regularparent = false
		if maxseas == nil or maxseas == '' then
			maxseas = start --hide subsequent ranges
		end
		if finish == -1 then trackcat(14, 'Navseasoncats range ends (present)')
		else				 trackcat(15, 'Navseasoncats range ends (blank, MOS)') end
	elseif (start == finish) and
		   (ttrackingcats[16] ~= '') --nav_year found isolated; check for surrounding hyphenated terms (e.g. UK MPs 1974)
	then
		trackcat(16, '') --reset for another check later
		trackcat(13, 'Navseasoncats range irregular, 0-length')
		ttlens[0] = 1 --calc ttlens for std cases below
		regularparent = 'isolated'
	end
	if (string.match(finish or '', '^%d+$') == nil) and
	   (string.match(finish or '', '^%-%d+$') == nil)
	then
		local finish_fixed = mw.ustring.match(finish or '', '^%s*(%d%d?%d?%d?)%D')
		if finish_fixed then
			finish = finish_fixed
		else
			errors = p.errorclass('Function nav_hyphen can\'t recognize "'..(finish or '')..'" '..
								  'in the second part of the "season" that was passed to it. '..
								  'For e.g. "2015–16", "16" is expected via "|2015|–|16|".')
			return p.failedcat(errors, 'I')
		end
	else
		if string.len(finish) >= 5 then
			errors = p.errorclass('The second part of the season passed to function nav_hyphen should only be four or fewer digits, not "'..(finish or '')..'". '..
								  'See [[MOS:DATERANGE]] for details.')
			return p.failedcat(errors, 'J')
		end
	end
	local nfinish = tonumber(finish)
	
	--save sterilized parent range for easier lookup later
	tirregs['from0'] = nstart
	tirregs['to0']   = nfinish
	
	--sterilize min/max
	local nminseas_default = -9999
	local nmaxseas_default =  9999
	local nminseas = tonumber(minseas) or nminseas_default --same behavior as nav_year
	local nmaxseas = tonumber(maxseas) or nmaxseas_default --same behavior as nav_year
	if nminseas > nstart then nminseas = nstart end
	if nmaxseas < nstart then nmaxseas = nstart end
	
	local lspace = ' ' --assume a leading space (most common)
	local tspace = ' ' --assume a trailing space (most common)
	if string.match(firstpart, '%($') then lspace = '' end --DNE for "Madrid city councillors (2007–2011)"-type cats
	if string.match(lastpart,  '^%)') then tspace = '' end --DNE for "Madrid city councillors (2007–2011)"-type cats
	
	--calculate term length/intRAseason size & finishing year
	local term_limit = 10
	local t = 1
	while t <= term_limit and regularparent == true do
		local nish = nstart + t --use switchADBC to flip this sign to work for years BC, if/when the time comes
		if (nish == nfinish) or (string.match(nish, '%d?%d$') == finish) then
			ttlens[t] = 1
			break
		end
		if t == term_limit then
			errors = p.errorclass('Function nav_hyphen can\'t determine a reasonable term length for "'..start..hyph..finish..'".')
			return p.failedcat(errors, 'K')
		end
		t = t + 1
	end
	
	--apply MOS:DATERANGE to parent
	local lenstart = string.len(start)
	local lenfinish = string.len(finish)
	if lenstart == 4 and regularparent == true then --"2001–..."
		if t == 1 then --"2001–02" & "2001–2002" both allowed
			if lenfinish ~= 2 and lenfinish ~= 4 then
				errors = p.errorclass('The second part of the season passed to function nav_hyphen should be two or four digits, not "'..finish..'".')
				return p.failedcat(errors, 'L')
			end
		else --"2001–2005" is required for t > 1; track "2001–05"; anything else = error
			if lenfinish == 2 then
				trackcat(5, 'Navseasoncats range abbreviated (MOS)')
			elseif lenfinish ~= 4 then
				errors = p.errorclass('The second part of the season passed to function nav_hyphen should be four digits, not "'..finish..'".')
				return p.failedcat(errors, 'M')
			end
		end
		if finish == '00' then --full year required regardless of term length
			trackcat(5, 'Navseasoncats range abbreviated (MOS)')
		end
	end
	
	--calculate intERseason gap size
	local hgap_default     = 0 --assume & start at the most common case: 2001–02 -> 2002–03, etc.
	local hgap_limit_reg   = 6 --less expensive per-increment (inc x 4)
	local hgap_limit_irreg = 6 --more expensive per-increment (inc x 23: inc x (k_bwd + k_fwd) = inc x (12 + 11))
	local hgap_success = false
	local hgap = hgap_default
	while hgap <= hgap_limit_reg and regularparent == true do --verify
		local prevseason2 = firstpart..lspace..(nstart-t-hgap)..hyph..string.match(nstart-hgap, '%d?%d$')    ..tspace..lastpart
		local nextseason2 = firstpart..lspace..(nstart+t+hgap)..hyph..string.match(nstart+2*t+hgap, '%d?%d$')..tspace..lastpart
		local prevseason4 = firstpart..lspace..(nstart-t-hgap)..hyph..(nstart-hgap)    ..tspace..lastpart
		local nextseason4 = firstpart..lspace..(nstart+t+hgap)..hyph..(nstart+2*t+hgap)..tspace..lastpart
		if t == 1 then --test abbreviated range first, then full range, to be frugal with expensive functions
			if catexists(prevseason2) or --use 'or', in case we're at the edge of the cat structure,
			   catexists(nextseason2) or --or we hit a "–00"/"–2000" situation on one side
			   catexists(prevseason4) or
			   catexists(nextseason4)
			then
				hgap_success = true
				break
			end
		elseif t > 1 then --test full range first, then abbreviated range, to be frugal with expensive functions
			if catexists(prevseason4) or --use 'or', in case we're at the edge of the cat structure,
			   catexists(nextseason4) or --or we hit a "–00"/"–2000" situation on one side
			   catexists(prevseason2) or
			   catexists(nextseason2)
			then
				hgap_success = true
				break
			end
		end
		hgap = hgap + 1
	end
	if hgap_success == false then
		hgap = tonumber(testgap) or hgap_default --tracked via defaultgapcat()
	end
	
	--preliminary scan to determine ir/regular spacing of nearby cats;
	--to limit expensive function calls, MOS:DATERANGE-violating cats are ignored;
	--an irregular-term-length series should follow "YYYY..hyph..YYYY" throughout
	if hgap <= hgap_limit_reg then --also to isolate temp vars
		--find # of nav-visible ir/regular-term-length cats
		local bwanchor = nstart       --backward anchor/common year
		local fwanchor = bwanchor + t --forward anchor/common year
		if regularparent == 'isolated' then
			fwanchor = bwanchor
		end
		local spangreen = '[<span style="color:green">j, g, k = ' --used for/when debugging via list-all-links=yes
		local spanblue = '<span style="color:blue">'
		local spanred = ' (<span style="color:red">'
		local span = '</span>'
		local lastg = nil --to check for run-on searches
		local lastk = nil --to check for run-on searches
		local endfound = false --switch used to stop searching forward
		local iirregs = 0 --index of tirregs[] for j < 0, since search starts from parent
		local j = -3 --index of tirregs[] for j > 0 & pseudo nav position
		while j <= 3 do
			
			if j < 0 then --search backward from parent
				local gbreak = false --switch used to break out of g-loop
				local g = 0 --gap size
				while g <= hgap_limit_irreg do
					local k = 0 --term length: 0 = "0-length", 1+ = normal
					while k <= term_limit do
						local from = bwanchor - k - g
						local to   = bwanchor - g
						local full = mw.text.trim( firstpart..lspace..from..hyph..to..tspace..lastpart )
						if k == 0 then
							if regularparent ~= 'isolated' then --+restrict to g == 0 if repeating year problems arise
								to = '0-length'
								full = mw.text.trim( firstpart..lspace..from..tspace..lastpart )
								if catlinkfollowr( frame, full ).rtarget ~= nil then --#R followed
									table.insert( tlistallbwd, spangreen..j..', '..g..', '..k..span..'] '..full..spanred..'#R ignored'..span..')' )
									full, to = '', '' --don't use/follow 0-length cat #Rs from nav_hyphen(); otherwise gets messy
								end
							end
						end
						if (k >= 1) or		  --the normal case; only continue k = 0 if 0-length found
						   (to == '0-length') --ghetto "continue" (thx Lua) to avoid expensive searches for "UK MPs 1974-1974", etc.
						then
							table.insert( tlistallbwd, spangreen..j..', '..g..', '..k..span..'] '..full )
							if (k == 1) and
							   (g == 0 or g == 1) and
							   (catexists(full) == false)
							then --allow bare-bones MOS:DATERANGE alternation, in case we're on a 0|1-gap, 1-year term series
								local to2 = string.match(to, '%d%d$')
								if to2 and to2 ~= '00' then --and not at a century transition (i.e. 1999–2000)
									to = to2
									full = mw.text.trim( firstpart..lspace..from..hyph..to..tspace..lastpart )
									table.insert( tlistallbwd, spangreen..j..', '..g..', '..k..span..'] '..full )
								end
							end
							if catexists(full) then
								if to == '0-length' then
									trackcat(13, 'Navseasoncats range irregular, 0-length')
								end
								tlistallbwd[#tlistallbwd] = spanblue..tlistallbwd[#tlistallbwd]..span..' (found)'
								ttlens[ find_duration(full) ] = 1
								tgaps[g] = 1
								iirregs = iirregs + 1
								tirregs['from-'..iirregs] = from
								tirregs['to-'..iirregs] = to
								bwanchor = from --ratchet down
								if to ~= '0-length' then
									gbreak = true
									break
								else
									g = 0 --soft-reset g, to keep stepping thru k
									j = j + 1 --save, but keep searching thru k
									if j > 3 then --lest we keep searching & finding 0-length cats ("MEPs for the Republic of Ireland 1973" & down)
										gbreak = true
										break
									end
								end
							end
						end --ghetto "continue"
						k = k + 1
						lastk = k
					end --while k
					if gbreak == true then break end
					g = g + 1
					lastg = g
				end --while g
			end --if j < 0
			
			if j > 0 and endfound == false then --search forward from parent
				local gbreak = false --switch used to break out of g-loop
				local g = 0 --gap size
				while g <= hgap_limit_irreg do
					local k = -2 --term length: -2 = "0-length", -1 = "2020–present", 0 = "2020–", 1+ = normal
					while k <= term_limit do
						local from = fwanchor + g
						local to4  = fwanchor + k + g	--override carefully
						local to2  = nil				--last 2 digits of to4, IIF exists
						if k == -1 then to4 = 'present'	--see if end-cat exists (present)
						elseif k == 0 then to4 = '' end	--see if end-cat exists (blank)
						local full = mw.text.trim( firstpart..lspace..from..hyph..to4..tspace..lastpart )
						if k == -2 then
							if regularparent ~= 'isolated' then --+restrict to g == 0 if repeating year problems arise
								to4 = '0-length' --see if 0-length cat exists
								full = mw.text.trim( firstpart..lspace..from..tspace..lastpart )
								if catlinkfollowr( frame, full ).rtarget ~= nil then --#R followed
									table.insert( tlistallfwd, spangreen..j..', '..g..', '..k..span..'] '..full..spanred..'#R ignored'..span..')' )
									full, to4 = '', '' --don't use/follow 0-length cat #Rs from nav_hyphen(); otherwise gets messy
								end
							end
						end
						if (k >= -1) or		   --only continue k = -2 if 0-length found
						   (to4 == '0-length') --ghetto "continue" (thx Lua) to avoid expensive searches for "UK MPs 1974-1974", etc.
						then
							table.insert( tlistallfwd, spangreen..j..', '..g..', '..k..span..'] '..full )
							if (k == 1) and
							   (g == 0 or g == 1) and
							   (catexists(full) == false)
							then --allow bare-bones MOS:DATERANGE alternation, in case we're on a 0|1-gap, 1-year term series
								to2 = string.match(to4, '%d%d$')
								if to2 and to2 ~= '00' then --and not at a century transition (i.e. 1999–2000)
									full = mw.text.trim( firstpart..lspace..from..hyph..to2..tspace..lastpart )
									table.insert( tlistallfwd, spangreen..j..', '..g..', '..k..span..'] '..full )
								end
							end
							if catexists(full) then
								if to4 == '0-length' then
									if rtarget(frame, full) == full then --only use 0-length cats that don't #R
										trackcat(13, 'Navseasoncats range irregular, 0-length')
									end
								end
								tirregs['from'..j] = from
								tirregs['to'..j] = (to2 or to4)
								if (k == -1) or (k == 0) then
									endfound = true --tentative
								else --k == { -2, > 0 }
									tlistallfwd[#tlistallfwd] = spanblue..tlistallfwd[#tlistallfwd]..span..' (found)'
									ttlens[ find_duration(full) ] = 1
									tgaps[g] = 1
									endfound = false
									if to4 ~= '0-length' then --k > 0
										fwanchor = to4 --ratchet up
										gbreak = true
										break --only break on k > 0 b/c old end-cat #Rs still exist like "Members of the Scottish Parliament 2011–"
									else --k == -2
										j = j + 1 --save, but keep searching k's, in case "1974" → "1974-1979"
										if j > 3 then --lest we keep searching & finding 0-length cats ("2018 CONCACAF Champions League" & up)
											gbreak = true
											break
										end
									end
								end
							end
						end --ghetto "continue"
						k = k + 1
						lastk = k
					end --while k
					if gbreak == true then break end
					g = g + 1
					lastg = g
				end --while g
			end --if j > 0
			
			if (lastg == (hgap_limit_irreg + 1)) and
			   (lastk == (term_limit + 1))
			then --search exhausted
				if j < 0 then j = 0 --bwd search exhausted; continue fwd
				elseif j > 0 then break end --fwd search exhausted
			end
			
			j = j + 1
		end --while j <= 3
	end --if hgap <= hgap_limit_reg
	
	--begin navhyphen
	local navh = '{| class="toccolours" style="text-align: center; margin: auto;"\n|\n'
	
	local navlist = {}
	local terminalcat = false --switch used to hide future cats
	local terminaltxt = nil
	local i = -3 --nav position
	while i <= 3 do
		local from = nstart + i*(t+hgap) --the logical, but not necessarily correct, 'from'
		if tirregs['from'..i] then from = tonumber(tirregs['from'..i]) end --prefer irregular term table
		local from2 = string.match(from, '%d?%d$')
		
		local to = tostring(from+t)	--the logical, naive range, but
		if tirregs['to'..i] then	--prefer irregular term table
			to = tirregs['to'..i]
		elseif regularparent == false and tirregs and i > 0 then
			to = tirregs['to-1']	--special treatment for parent terminal cats, since they have no natural 'to'
		end
		local to2 = string.match(to, '%d?%d$')
		local tofinal = (to2 or '')    --assume t=1 and abbreviated 'to' (the most common case)
		if t > 1 or                    --per MOS:DATERANGE (e.g. 1999-2004)
		  (from2 - (to2 or from2)) > 0 --century transition exception (e.g. 1999–2000)
		then
			tofinal = (to or '')       --default to the MOS-correct format, in case no fallbacks found
		end
		if to == '0-length' then
			tofinal = to
		end
		
		--check existance of 4-digit, MOS-correct range, with abbreviation fallback
		if tofinal ~= '0-length' then
			if t > 1 and string.len(from) == 4 then --e.g. 1999-2004
				--determine which link exists (full or abbr)
				local full = firstpart..lspace..from..hyph..tofinal..tspace..lastpart
				if not catexists(full) then
					local abbr = firstpart..lspace..from..hyph..to2..tspace..lastpart
					if catexists(abbr) then
						tofinal = (to2 or '') --rv to MOS-incorrect format; if full AND abbr DNE, then tofinal is still in its MOS-correct format
					end
				end
			elseif t == 1 then --full-year consecutive ranges are also allowed
				local abbr = firstpart..lspace..from..hyph..tofinal..tspace..lastpart --assume tofinal is in abbr format
				if not catexists(abbr) and tofinal ~= to then
					local full = firstpart..lspace..from..hyph..to..tspace..lastpart
					if catexists(full) then
						tofinal = (to or '') --if abbr AND full DNE, then tofinal is still in its abbr format (unless it's a century transition)
		end	end	end	end
		
		--populate navh
		if i ~= 0 then --left/right navh
			local orig = firstpart..lspace..from..hyph..tofinal..tspace..lastpart
			local disp = from..hyph..tofinal
			if tofinal == '0-length' then
				orig = firstpart..lspace..from..tspace..lastpart
				disp = from
			end
			local catlink = catlinkfollowr(frame, orig, disp, true) --force terminal cat display
			
			if terminalcat == false then
				terminaltxt = find_terminaltxt( disp ) --also sets tracking cats
				terminalcat = (terminaltxt ~= nil)
			end
			if catlink.rtarget and avoidself then --a {{Category redirect}} was followed, figure out why
				--determine new term length & gap size
				ttlens[ find_duration( catlink.rtarget ) ] = 1
				if i > -3 then
					local lastto = tirregs['to'..(i-1)]
					if lastto == nil then
						local lastfrom = nstart + (i-1)*(t+hgap)
						lastto = lastfrom+t --use last logical 'from' to calc lastto
					end
					if lastto then
						local gapcat = lastto..'-'..from --dummy cat to calc with
						local gap = find_duration(gapcat) or -1	--in case of nil,
						tgaps[ gap ] = 1						--tgaps[-1] is ignored
					end
				end
				
				--display/tracking handling
				local base_regex = '%d+[–-]%d+'
				local origbase = mw.ustring.gsub(orig, base_regex, '')
				local rtarbase, rtarbase_success = mw.ustring.gsub(catlink.rtarget, base_regex, '')
				if rtarbase_success == 0 then
					local base_regex_lax = '%d%d%d%d' --in case rtarget is a year cat
					rtarbase, rtarbase_success = mw.ustring.gsub(catlink.rtarget, base_regex_lax, '')
				end
				local terminal_regex = '%d+[–-]'..(terminaltxt or '')..'$' --more manual ORs bc Lua regex sux
				if mw.ustring.match(orig, terminal_regex) then
					origbase = mw.ustring.gsub(orig, terminal_regex, '')
				end
				if mw.ustring.match(catlink.rtarget, terminal_regex) then
					--finagle/overload terminalcat type to set nmaxseas on 1st occurence only
					if terminalcat == false then terminalcat = 1 end
					local dummy = find_terminaltxt( catlink.rtarget ) --also sets tracking cats
					rtarbase = mw.ustring.gsub(catlink.rtarget, terminal_regex, '')
				end
				origbase = mw.text.trim(origbase)
				rtarbase = mw.text.trim(rtarbase)
				if origbase ~= rtarbase then
					trackcat(6, 'Navseasoncats range redirected (base change)')
				elseif terminalcat == 1 then
					trackcat(8, 'Navseasoncats range redirected (end)')
				else --origbase == rtarbase
					local all4s_regex = '%d%d%d%d[–-]%d%d%d%d'
					local orig_all4s = mw.ustring.match(orig, all4s_regex)
					local rtar_all4s = mw.ustring.match(catlink.rtarget, all4s_regex)
					if orig_all4s and rtar_all4s then
						trackcat(10, 'Navseasoncats range redirected (other)')
					else
						local year_regex1 = '%d%d%d%d$'
						local year_regex2 = '%d%d%d%d[%s%)]'
						local year_rtar = mw.ustring.match(catlink.rtarget, year_regex1) or
										  mw.ustring.match(catlink.rtarget, year_regex2)
						if orig_all4s and year_rtar then
							trackcat(7, 'Navseasoncats range redirected (var change)')
						else
							trackcat(9, 'Navseasoncats range redirected (MOS)')
						end
					end
				end
			end
			
			if terminalcat then --true or 1
				if type(terminalcat) ~= 'boolean' then nmaxseas = from end --only want to do this once
				terminalcat = true --done finagling/overloading
			end
			if (from >= 0) and (nminseas <= from) and (from <= nmaxseas) then
				table.insert(navlist, catlink.navelement)
				if terminalcat then nmaxseas = nminseas_default end --prevent display of future ranges
			else
				local hidden = '<span style="visibility:hidden">'..disp..'</span>'
				table.insert(navlist, hidden)
				if listall then
					tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
				end
			end
		else --center navh
			if finish == -1 then finish = 'present'
			elseif finish == 0 then finish = '<span style="visibility:hidden">'..start..'</span>' end
			local disp = start..hyph..finish
			if regularparent == 'isolated' then disp = start end
			table.insert(navlist, '<b>'..disp..'</b>')
		end
		
		i = i + 1
	end
	
	-- add the list
	navh = navh .. horizontal(navlist) .. '\n'
	
	--tracking cats & finalize
	if avoidself then
		local igaps  = 0 --# of diff gap sizes > 0 found
		local itlens = 0 --# of diff term lengths found
		for s = 1, hgap_limit_reg do --must loop; #tgaps, #ttlens unreliable
			igaps = igaps + (tgaps[s] or 0)
		end
		for s = 0, term_limit do
			itlens = itlens + (ttlens[s] or 0)
		end
		if igaps  > 0 then trackcat(11, 'Navseasoncats range gaps') end
		if itlens > 1 and ttrackingcats[13] == '' then --avoid duplication in "Navseasoncats range irregular, 0-length"
			trackcat(12, 'Navseasoncats range irregular')
		end
	end
	isolatedcat()
	defaultgapcat(not hgap_success)
	if listall then
		return listalllinks()
	else
		return navh..'|}'
	end
end


--[[=========================={{  nav_tvseason  }}============================]]

local function nav_tvseason( frame, firstpart, tv, lastpart, maximumtv )
	--Expects a PAGENAME of the form "Futurama (season 1) episodes", where
	--	firstpart = Futurama (season
	--	tv        = 1
	--	lastpart  = ) episodes
	--	maximumtv = 7 ('max' tv season parameter; optional; defaults to 9999)
	tv = tonumber(tv)
	if tv == nil then
		errors = p.errorclass('Function nav_tvseason can\'t recognize the TV season number sent to its 2nd parameter.')
		return p.failedcat(errors, 'T')
	end
	
	local maxtv = tonumber(maximumtv) or 9999 --allow +/- qualifier
	if maxtv < tv then maxtv = tv end --input error; maxtv should be >= parent
	
	--begin navtvseason
	local navt = '{| class="toccolours" style="text-align: center; margin: auto;"\n|\n'
	
	local navlist = {}
	local i = -5 --nav position
	while i <= 5 do
		local t = tv + i
		if i ~= 0 then --left/right navt
			local catlink = catlinkfollowr( frame, firstpart..' '..t..lastpart, t )
			if (t >= 1 and t <= maxtv) then --hardcode mintv
				if catlink.rtarget then --a {{Category redirect}} was followed
					trackcat(25, 'Navseasoncats TV season redirected')
				end
				table.insert(navlist, catlink.navelement)
			else
				local hidden = '<span style="visibility:hidden">'..'0'..'</span>' --'0' to maintain dot spacing
				table.insert(navlist, hidden)
				if listall then
					tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
				end
			end
		else --center navt
			table.insert(navlist, '<b>'..tv..'</b>')
		end
		
		i = i + 1
	end
	-- add the list
	navt = navt .. horizontal(navlist) .. '\n'
	isolatedcat()
	if listall then
		return listalllinks()
	else
		return navt..'|}'
	end
end


--[[==========================={{  nav_decade  }}=============================]]

local function nav_decade( frame, firstpart, decade, lastpart, mindecade, maxdecade )
	--Expects a PAGENAME of the form "Some sequential 2000 example cat", where
	--	firstpart = Some sequential
	--	decade    = 2000
	--	lastpart  = example cat
	--	mindecade = 1800 ('min' decade parameter; optional; defaults to -9999)
	--	maxdecade = 2020 ('max' decade parameter; optional; defaults to 9999)
	
	--sterilize dec
	local dec = sterilizedec(decade)
	if dec == nil then
		errors = p.errorclass('Function nav_decade was sent "'..(decade or '')..'" as its 2nd parameter, '..
							'but expects a 1 to 4-digit year ending in "0".')
		return p.failedcat(errors, 'D')
	end
	local ndec = tonumber(dec)
	
	--sterilize mindecade & determine AD/BC
	local mindefault = '-9999'
	local mindec = sterilizedec(mindecade) --returns a tostring(unsigned int), or nil
	if mindec then
		if string.match(mindecade, '-%d') or
		   string.match(mindecade, 'BC')
		then
			mindec = '-'..mindec --better +/-0 behavior with strings (0-initialized int == "-0" string...)
		end
	elseif mindec == nil and mindecade and mindecade ~= '' then
		errors = p.errorclass('Function nav_decade was sent "'..(mindecade or '')..'" as its 4th parameter, '..
							'but expects a 1 to 4-digit year ending in "0", the earliest decade to be shown.')
		return p.failedcat(errors, 'E')
	else --mindec == nil
		mindec = mindefault --tonumber() later, after error checks
	end
	
	--sterilize maxdecade & determine AD/BC
	local maxdefault = '9999'
	local maxdec = sterilizedec(maxdecade) --returns a tostring(unsigned int), or nil + error
	if maxdec then
		if string.match(maxdecade, '-%d') or
		   string.match(maxdecade, 'BC')
		then                     --better +/-0 behavior with strings (0-initialized int == "-0" string...),
			maxdec = '-'..maxdec --but a "-0" string -> tonumber() -> tostring() = "-0",
		end                      --and a  "0" string -> tonumber() -> tostring() =  "0"
	elseif maxdec == nil and maxdecade and maxdecade ~= '' then
		errors = p.errorclass('Function nav_decade was sent "'..(maxdecade or '')..'" as its 5th parameter, '..
							'but expects a 1 to 4-digit year ending in "0", the highest decade to be shown.')
		return p.failedcat(errors, 'F')
	else --maxdec == nil
		maxdec = maxdefault
	end
	
	local tspace = ' ' --assume trailing space for "1950s in X"-type cats
	if string.match(lastpart, '^-') then tspace = '' end --DNE for "1970s-related"-type cats
	
	--AD/BC switches & vars
	
	local parentBC = string.match(lastpart, '^BC') --following the "0s BC" convention for all years BC
	lastpart = mw.ustring.gsub(lastpart, '^BC%s*', '') --handle BC separately; AD never used
	--TODO?: handle BCE, but only if it exists in the wild
	
	local dec0to40AD = (ndec >= 0 and ndec <= 40 and not parentBC) --special behavior in this range
	local switchADBC = 1                 --  1=AD parent
	if parentBC then switchADBC = -1 end -- -1=BC parent; possibly adjusted later
	local BCdisp = ''
	local D = -math.huge --secondary switch & iterator for AD/BC transition
	
	--check non-default min/max more carefully
	if mindec ~= mindefault then
		if tonumber(mindec) > ndec*switchADBC then
			mindec = tostring(ndec*switchADBC) --input error; mindec should be <= parent
		end
	end
	if maxdec ~= maxdefault then
		if tonumber(maxdec) < ndec*switchADBC then
			maxdec = tostring(ndec*switchADBC) --input error; maxdec should be >= parent
		end
	end
	local nmindec = tonumber(mindec) --similar behavior to nav_year & nav_nordinal
	local nmaxdec = tonumber(maxdec) --similar behavior to nav_nordinal
	
	--begin navdecade
	local bnb = '' --border/no border
	if navborder == false then --for Navseasoncats year and decade
		bnb = ' border-style: none; background-color: transparent;'
	end
	local navd = '{| class="toccolours" style="text-align: center; margin: auto;'..bnb..'"\n|\n'
	
	local navlist = {}
	local i = -50 --nav position x 10
	while i <= 50 do
		local d = ndec + i*switchADBC
		
		local BC = ''
		BCdisp = ''
		if dec0to40AD then
			if D < -10 then
				d = math.abs(d + 10) --b/c 2 "0s" decades exist: "0s BC" & "0s" (AD)
				BC = 'BC '
				if d == 0 then
					D = -10 --track 1st d = 0 use (BC)
				end
			elseif D >= -10 then
				D = D + 10 --now iterate from 0s AD
				d = D      --2nd d = 0 use
			end
		elseif parentBC then
			if switchADBC == -1 then --parentBC looking at the BC side (the common case)
				BC = 'BC '
				if d == 0 then     --prepare to switch to the AD side on the next iteration
					switchADBC = 1 --1st d = 0 use (BC)
					D = -10        --prep
				end
			elseif switchADBC == 1 then --switched to the AD side
				D = D + 10 --now iterate from 0s AD
				d = D      --2nd d = 0 use (on first use)
			end
		end
		if BC ~= '' and ndec <= 50 then
			BCdisp = ' BC' --show BC for all BC decades whenever a "0s" is displayed on the nav
		end
		
		--determine target cat
		local disp = d..'s'..BCdisp
		local catlink = catlinkfollowr( frame, firstpart..' '..d..'s'..tspace..BC..lastpart, disp )
		if catlink.rtarget then --a {{Category redirect}} was followed
			trackcat(18, 'Navseasoncats decade redirected')
		end
		
		--populate left/right navd
		local shown = navcenter(i, catlink)
		local hidden = '<span style="visibility:hidden">'..disp..'</span>'
		local dsign = d --use d for display & dsign for logic
		if BC ~= '' then dsign = -dsign end
		if (nmindec <= dsign) and (dsign <= nmaxdec) then
			if dsign == 0 and (nmindec == 0 or nmaxdec == 0) then --distinguish b/w -0 (BC) & 0 (AD)
				--"zoom in" on +/- 0 and turn dsign/min/max temporarily into +/- 1 for easier processing
				local zsign, zmin, zmax = 1, nmindec, nmaxdec
				if BC ~= '' then zsign = -1 end
				if     mindec == '-0' then zmin = -1
				elseif mindec ==  '0' then zmin =  1 end
				if     maxdec == '-0' then zmax = -1
				elseif maxdec ==  '0' then zmax =  1 end
				
				if (zmin <= zsign) and (zsign <= zmax) then
					table.insert(navlist, shown)
					hidden = nil
				else
					table.insert(navlist, hidden)
				end
			else
				table.insert(navlist, shown)--the common case
				hidden = nil
			end
		else
			table.insert(navlist, hidden)
		end
		if listall and hidden then
			tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
		end
		
		i = i + 10
	end
	-- add the list
	navd = navd .. horizontal(navlist) .. '\n'
	isolatedcat()
	if listall then
		return listalllinks()
	else
		return navd..'|}'
	end
end


--[[============================{{  nav_year  }}==============================]]

local function nav_year( frame, firstpart, year, lastpart, minimumyear, maximumyear )
	--Expects a PAGENAME of the form "Some sequential 1760 example cat", where
	--	firstpart   = Some sequential
	--	year        = 1760
	--	lastpart    = example cat
	--	minimumyear = 1758 ('min' year parameter; optional)
	--	maximumyear = 1800 ('max' year parameter; optional)
	local minyear_default = -9999
	local maxyear_default =  9999
	year = tonumber(year) or tonumber(mw.ustring.match(year or '', '^%s*(%d*)'))
	local minyear = tonumber(string.match(minimumyear or '', '-?%d+')) or minyear_default --allow +/- qualifier
	local maxyear = tonumber(string.match(maximumyear or '', '-?%d+')) or maxyear_default --allow +/- qualifier
	if string.match(minimumyear or '', 'BC') then minyear = -math.abs(minyear) end --allow BC qualifier (AD otherwise assumed)
	if string.match(maximumyear or '', 'BC') then maxyear = -math.abs(maxyear) end --allow BC qualifier (AD otherwise assumed)
	
	if year == nil then
		errors = p.errorclass('Function nav_year can\'t recognize the year sent to its 2nd parameter.')
		return p.failedcat(errors, 'Y')
	end
	
	--AD/BC switches & vars
	
	local yearBCElastparts = { --needed for parent = AD 1-5, when the BC/E format is unknown
		--"BCE" removed to match both AD & BCE cats; easier & faster than multiple string.match()s
		['example_Hebrew people_example'] = 'BCE', --example entry format; add to & adjust as needed
	}
	local parentAD = string.match(firstpart, 'AD$')  --following the "AD 1" convention from AD 1 to AD 10
	local parentBC = string.match(lastpart, '^BCE?') --following the "1 BC" convention for all years BC
	firstpart = mw.ustring.gsub(firstpart, '%s*AD$', '') --handle AD/BC separately for easier & faster accounting
	lastpart  = mw.ustring.gsub(lastpart,  '^BCE?%s*', '')
	local BCe = parentBC or yearBCElastparts[lastpart] or 'BC' --"BC" default
	
	local year1to10 = (year >= 1 and year <= 10)
	local year1to10ADBC = year1to10 and (parentBC or parentAD) --special behavior 1-10 for low-# non-year series
	local year1to15AD = (year >= 1 and year <= 15 and not parentBC) --special behavior 1-15 for AD/BC display
	local switchADBC = 1                 --  1=AD parent
	if parentBC then switchADBC = -1 end -- -1=BC parent; possibly adjusted later
	local Y = 0 --secondary iterator for AD-on-a-BC-parent
	
	if minyear > year*switchADBC then minyear = year*switchADBC end --input error; minyear should be <= parent
	if maxyear < year*switchADBC then maxyear = year*switchADBC end --input error; maxyear should be >= parent
	
	local lspace = ' ' --leading space before year, after firstpart
	if string.match(firstpart, '[%-VW]$') then
		lspace = '' --e.g. "Straight-8 engines"
	end
	
	local tspace = ' ' --trailing space after year, before lastpart
	if string.match(lastpart, '^-') then
		tspace = '' --e.g. "2018-related timelines"
	end
	
	--determine interyear gap size to condense special category types, if possible
	local ygapdefault = 1 --assume/start at the most common case: 2001, 2002, etc.
	local ygap = ygapdefault
	if string.match(lastpart, 'presidential') then
		local ygap1, ygap2 = ygapdefault, ygapdefault --need to determine previous & next year gaps indepedently
		local ygap1_success, ygap2_success = false, false
		
		local prevseason = nil
		while ygap1 <= 5 do --Czech Republic, Poland, Sri Lanka, etc. have 5-year terms
			prevseason = firstpart..lspace..(year-ygap1)..tspace..lastpart
			if catexists(prevseason) then
				ygap1_success = true
				break
			end
			ygap1 = ygap1 + 1
		end
		
		local nextseason = nil
		while ygap2 <= 5 do --Czech Republic, Poland, Sri Lanka, etc. have 5-year terms
			nextseason = firstpart..lspace..(year+ygap2)..tspace..lastpart
			if catexists(nextseason) then
				ygap2_success = true
				break
			end
			ygap2 = ygap2 + 1
		end
		
		if ygap1_success and ygap2_success then
			if ygap1 == ygap2 then ygap = ygap1 end
		elseif ygap1_success then  ygap = ygap1
		elseif ygap2_success then  ygap = ygap2
		end
	end
	
	--skip non-existing years, if requested
	local ynogaps = {} --populate with existing years in the range, at most, [year - (skipgaps_limit * 5), year + (skipgaps_limit * 5)]
	local skipgaps_limit = 25
	if skipgaps then
		if minyear == minyear_default then
			minyear = 0 --automatically set minyear to 0, as AD/BC not supported anyway
		end
		if (year > 70) or --add support for AD/BC (<= AD 10) if/when needed
		   (minyear >= 0 and --must be a non-year series like "AC with 0 elements"
		   	not parentAD and not parentBC)
		then
			local yskipped = {} --track skipped y's to avoid double-checking
			local cat, found, Yeary
			
			 --populate nav element queue outwards positively from the parent
			local Year = year --to save/ratchet progression
			local i = 1
			while i <= 5 do
				local y = 1
				while y <= skipgaps_limit do
					found = false
					Yeary = Year + y
					if yskipped[Yeary] == nil then
						yskipped[Yeary] = Yeary
						cat = firstpart..lspace..Yeary..tspace..lastpart
						found = catexists(cat)
						if found then break end
					end
					y = y + 1
				end
				if found then Year = Yeary
				else          Year = Year + 1 end
				ynogaps[i] =  Year
				i = i + 1
			end
			
			ynogaps[0] = year --the parent
			
			--populate nav element queue outwards negatively from the parent
			Year = year --reset ratchet
			i = -1
			while i >= -5 do
				local y = -1
				while y >= -skipgaps_limit do
					found = false
					Yeary = Year + y
					if yskipped[Yeary] == nil then
						yskipped[Yeary] = Yeary
						cat = firstpart..lspace..Yeary..tspace..lastpart
						found = catexists(cat)
						if found then break end
					end
					y = y - 1
				end
				if found then Year = Yeary
				else          Year = Year - 1 end
				ynogaps[i] =  Year
				i = i - 1
			end
		else
			skipgaps = false --AD/BC not supported
		end
	end
	
	--begin navyears
	local navy = '{| class="toccolours" style="text-align: center; margin: auto;"\n|\n'
	
	local navlist = {}
	local y
	local j = 0 --decrementor for special cases "2021 World Rugby Sevens Series" -> "2021–2022"
	local i = -5 --nav position
	while i <= 5 do
		if skipgaps then
			y = ynogaps[i]
		else
			y = year + i*ygap*switchADBC - j
		end
		local BCdisp = ''
		if i ~= 0 then --left/right navy
			
			local AD = ''
			local BC = ''
			if year1to15AD and not
			   (year1to10 and not year1to10ADBC) --don't AD/BC 1-10's if parents don't contain AD/BC
			then
				if year >= 11 then --parent = AD 11-15
					if y <= 10 then --prepend AD on y = 1-10 cats only, per existing cats
						AD = 'AD '
					end
					
				elseif year >= 1 then --parent = AD 1-10
					if y <= 0 then
						BC = BCe..' '
						y = math.abs(y - 1) --skip y = 0 (DNE)
					elseif y >= 1 and y <= 10 then --prepend AD on y = 1-10 cats only, per existing cats
						AD = 'AD '
					end
				end
				
			elseif parentBC then
				if switchADBC == -1 then --displayed y is in the BC regime
					if y >= 1 then     --the common case
						BC = BCe..' '
					elseif y == 0 then --switch from BC to AD regime
						switchADBC = 1
					end
				end
				if switchADBC == 1 then --displayed y is now in the AD regime
					Y = Y + 1 --skip y = 0 (DNE)
					y = Y     --easiest solution: start another iterator for these AD y's displayed on a BC year parent
					AD = 'AD '
				end
			end
			if BC ~= '' and year <= 5 then --only show 'BC' for parent years <= 5: saves room, easier to read,
				BCdisp = ' '..BCe          --and 6 is the first/last nav year that doesn't need a disambiguator;
			end                            --the center/parent year will always show BC, so no need to show it another 10x
			
			--populate left/right navy
			local ysign = y --use y for display & ysign for logic
			local disp = y..BCdisp
			if BC ~= '' then ysign = -ysign end
			local firsttry = firstpart..lspace..AD..y..tspace..BC..lastpart
			if (minyear <= ysign) and (ysign <= maxyear) then
				local catlinkAD = catlinkfollowr( frame, firsttry, disp ) --try AD
				local catlink = catlinkAD --tentative winner
				if AD ~= '' then --for "ACArt with 5 suppressed elements"-type cats
					local catlinkNoAD = catlinkfollowr( frame, firstpart..lspace..y..tspace..BC..lastpart, disp ) --try !AD
					if catlinkNoAD.catexists == true then
						catlink = catlinkNoAD --usurp
					elseif listall then
						tlistall[#tlistall] = tlistall[#tlistall]..' (tried; not displayed)<sup>1</sup>'
					end
				end
				if (AD..BC == '') and (catlink.catexists == false) and (y >= 1000) then --!ADBC & DNE; 4-digit only, to be frugal
					--try basic hyphenated cats: 1-year, endash, MOS-correct only, no #Rs
					local yHyph_4 = y..'–'..(y+1) --try 2010–2011 type cats
					local catlinkHyph_4 = catlinkfollowr( frame, firstpart..lspace..yHyph_4..tspace..BC..lastpart, yHyph_4 )
					if catlinkHyph_4.catexists and catlinkHyph_4.rtarget == nil then --exists & no #Rs
						catlink = catlinkHyph_4 --usurp
						trackcat(27, 'Navseasoncats year and range')
					else
						if listall then
							tlistall[#tlistall] = tlistall[#tlistall]..' (tried; not displayed)<sup>2</sup>'
						end
						local yHyph_2 = y..'–'..string.match(y+1, '%d%d$') --try 2010–11 type cats
						if i == 1 then
							local yHyph_2_special = (y-1)..'–'..string.match(y, '%d%d$') --try special case 2021 -> 2021–22
							local catlinkHyph_2_special = catlinkfollowr( frame, firstpart..lspace..yHyph_2_special..tspace..BC..lastpart, yHyph_2_special )
							if catlinkHyph_2_special.catexists and catlinkHyph_2_special.rtarget == nil then --exists & no #Rs
								catlink = catlinkHyph_2_special --usurp
								trackcat(27, 'Navseasoncats year and range')
								j = 1
							elseif listall then
								tlistall[#tlistall] = tlistall[#tlistall]..' (tried; not displayed)<sup>3</sup>'
							end
						end
						if not (i == 1 and j == 1) then
							local catlinkHyph_2 = catlinkfollowr( frame, firstpart..lspace..yHyph_2..tspace..BC..lastpart, yHyph_2 )
							if catlinkHyph_2.catexists and catlinkHyph_2.rtarget == nil then --exists & no #Rs
								catlink = catlinkHyph_2 --usurp
								trackcat(27, 'Navseasoncats year and range')
							elseif listall then
								tlistall[#tlistall] = tlistall[#tlistall]..' (tried; not displayed)<sup>4</sup>'
							end
						end
					end
				end
				if catlink.rtarget then --#R followed; determine why
					local r = catlink.rtarget
					local c = catlink.cat
					local year_regex  = '%d%d%d%d[–-]?%d?%d?%d?%d?' --prioritize year/range stripping, e.g. for "2006 Super 14 season"
					local hyph_regex  = '%d%d%d%d[–-]%d+' --stricter
					local num_regex   = '%d+' --strip any number otherwise
					local final_regex = nil   --best choice goes here
					if mw.ustring.match(r, year_regex) and mw.ustring.match(c, year_regex) then
						final_regex = year_regex
					elseif mw.ustring.match(r, num_regex) and mw.ustring.match(c, num_regex) then
						final_regex = num_regex
					end
					if final_regex then
						local r_base = mw.ustring.gsub(r, final_regex, '')
						local c_base = mw.ustring.gsub(c, final_regex, '')
						if r_base ~= c_base then
							trackcat(19, 'Navseasoncats year redirected (base change)') --acceptable #R target
						elseif mw.ustring.match(r, hyph_regex) then
							trackcat(20, 'Navseasoncats year redirected (var change)') --e.g. "2008 in Scottish women's football" to "2008–09"
						else
							trackcat(21, 'Navseasoncats year redirected (other)') --exceptions go here
						end
					else
						trackcat(20, 'Navseasoncats year redirected (var change)') --e.g. "V2 engines" to "V-twin engines"
					end
				end
				table.insert(navlist, catlink.navelement)
			else --OOB vs min/max
				local hidden = '<span style="visibility:hidden">'..disp..'</span>'
				table.insert(navlist, hidden)
				if listall then
					local dummy = catlinkfollowr( frame, firsttry, disp )
					tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
				end
			end
		else --center navy
			if parentBC then BCdisp = ' '..BCe end
			table.insert(navlist, '<b>'..year..BCdisp..'</b>')
		end
		
		i = i + 1
	end
	
	--add the list
	navy = navy .. horizontal(navlist) .. '\n'
	
	isolatedcat()
	if listall then
		return listalllinks()
	else
		return navy..'|}'
	end
end


--[[==========================={{  nav_roman  }}==============================]]

local function nav_roman( frame, firstpart, roman, lastpart, minimumrom, maximumrom )
	local toarabic = require('Module:ConvertNumeric').roman_to_numeral
	local toroman  = require('Module:Roman').main
	
	--sterilize/convert rom/num
	local num = tonumber(toarabic(roman))
	local rom = toroman({ [1] = num })
	if num == nil or rom == nil then --out of range or some other error
		errors = p.errorclass('Function nav_roman can\'t recognize one or more of "'..(num or 'nil')..'" & "'..
							(rom or 'nil')..'" in category "'..firstpart..' '..roman..' '..lastpart..'".')
		return p.failedcat(errors, 'R')
	end
	
	--sterilize min/max
	local minrom = tonumber(minimumrom or '') or tonumber(toarabic(minimumrom or ''))
	local maxrom = tonumber(maximumrom or '') or tonumber(toarabic(maximumrom or ''))
	if minrom < 1 then minrom = 1 end    --toarabic() returns -1 on error
	if maxrom < 1 then maxrom = 9999 end --toarabic() returns -1 on error
	if minrom > num then minrom = num end
	if maxrom < num then maxrom = num end
	
	--begin navroman
	local navr = '{| class="toccolours" style="text-align: center; margin: auto;"\n|\n'
	
	local navlist = {}
	local i = -5 --nav position
	while i <= 5 do
		local n = num + i
		
		if n >= 1 then
			local r = toroman({ [1] = n })
			if i ~= 0 then --left/right navr
				local catlink = catlinkfollowr( frame, firstpart..' '..r..' '..lastpart, r )
				if minrom <= n and n <= maxrom then
					if catlink.rtarget then --a {{Category redirect}} was followed
						trackcat(22, 'Navseasoncats roman numeral redirected')
					end
					table.insert(navlist, catlink.navelement)
				else
					local hidden = '<span style="visibility:hidden">'..r..'</span>'
					table.insert(navlist, hidden)
					if listall then
						tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
					end
				end
			else --center navr
				table.insert(navlist, '<b>'..r..'</b>')
			end
		else
			table.insert(navlist, '<span style="visibility:hidden">I</span>')
		end
		
		i = i + 1
	end
	
	-- add the list
	navr = navr .. horizontal(navlist) .. '\n'
	isolatedcat()
	if listall then
		return listalllinks()
	else
		return navr..'|}'
	end
end


--[[=========================={{  nav_nordinal  }}============================]]

local function nav_nordinal( frame, firstpart, ord, lastpart, minimumord, maximumord )
	local nord = tonumber(ord)
	local minord = tonumber(string.match(minimumord or '', '(-?%d+)[snrt]?[tdh]?')) or -9999 --allow full ord & +/- qualifier
	local maxord = tonumber(string.match(maximumord or '', '(-?%d+)[snrt]?[tdh]?')) or  9999 --allow full ord & +/- qualifier
	if string.match(minimumord or '', 'BC') then minord = -math.abs(minord) end --allow BC qualifier (AD otherwise assumed)
	if string.match(maximumord or '', 'BC') then maxord = -math.abs(maxord) end --allow BC qualifier (AD otherwise assumed)
	
	local temporal = string.match(lastpart, 'century') or
					 string.match(lastpart, 'millennium')
	
	local tspace = ' ' --assume a trailing space after ordinal
	if string.match(lastpart, '^-') then tspace = '' end --DNE for "19th-century"-type cats
	
	--AD/BC switches & vars
	
	local ordBCElastparts = { --needed for parent = AD 1-5, when the BC/E format is unknown
		--lists the lastpart of valid BCE cats
		--"BCE" removed to match both AD & BCE cats; easier & faster than multiple string.match()s
		['-century Hebrew people'] = 'BCE', --WP:CFD/Log/2016 June 21#Category:11th-century BC Hebrew people
		['-century Jews']          = 'BCE', --co-nominated
		['-century Judaism']       = 'BCE', --co-nominated
		['-century rabbis']        = 'BCE', --co-nominated
		['-century High Priests of Israel'] = 'BCE',
	}
	local parentBC = mw.ustring.match(lastpart, '%s(BCE?)')       --"1st-century BC" format
	local lastpartNoBC = mw.ustring.gsub(lastpart, '%sBCE?', '')  --easier than splitting lastpart up in 2; AD never used
	local BCe = parentBC or ordBCElastparts[lastpartNoBC] or 'BC' --"BC" default
	
	local switchADBC = 1                 --  1=AD parent
	if parentBC then switchADBC = -1 end -- -1=BC parent; possibly adjusted later
	local O = 0 --secondary iterator for AD-on-a-BC-parent
	
	if not temporal and minord < 1 then minord = 1 end --nothing before "1st parliament", etc.
	if minord > nord*switchADBC then minord = nord*switchADBC end --input error; minord should be <= parent
	if maxord < nord*switchADBC then maxord = nord*switchADBC end --input error; maxord should be >= parent
	
	--begin navnordinal
	local bnb = '' --border/no border
	if navborder == false then --for Navseasoncats decade and century
		bnb = ' border-style: none; background-color: transparent;'
	end
	local navo = '{| class="toccolours" style="text-align: center; margin: auto;'..bnb..'"\n|\n'
	
	local navlist = {}
	local i = -5 --nav position
	while i <= 5 do
		local o = nord + i*switchADBC
		local BC = ''
		local BCdisp = ''
		if parentBC then
			if switchADBC == -1 then --parentBC looking at the BC side
				if o >= 1 then     --the common case
					BC = ' '..BCe
				elseif o == 0 then --switch to the AD side
					BC = ''
					switchADBC = 1
				end
			end
			if switchADBC == 1 then --displayed o is now in the AD regime
				O = O + 1 --skip o = 0 (DNE)
				o = O     --easiest solution: start another iterator for these AD o's displayed on a BC year parent
			end
		elseif o <= 0 then --parentAD looking at BC side
			BC = ' '..BCe
			o = math.abs(o - 1) --skip o = 0 (DNE)
		end
		if BC ~= '' and nord <= 5 then --only show 'BC' for parent ords <= 5: saves room, easier to read,
			BCdisp = ' '..BCe          --and 6 is the first/last nav ord that doesn't need a disambiguator;
		end                            --the center/parent ord will always show BC, so no need to show it another 10x
		
		--populate left/right navo
		local oth = p.addord(o)
		local osign = o --use o for display & osign for logic
		if BC ~= '' then osign = -osign end
		local hidden = '<span style="visibility:hidden">'..oth..'</span>'
		if temporal then --e.g. "3rd-century BC"
			local lastpart = lastpartNoBC --lest we recursively add multiple "BC"s
			if BC ~= '' then
				lastpart = string.gsub(lastpart, temporal, temporal..BC) --replace BC if needed
			end
			local catlink = catlinkfollowr( frame, firstpart..' '..oth..tspace..lastpart, oth..BCdisp )
			if (minord <= osign) and (osign <= maxord) then
				if catlink.rtarget then --a {{Category redirect}} was followed
					trackcat(23, 'Navseasoncats nordinal redirected')
				end
				table.insert(navlist, navcenter(i, catlink))
			else
				table.insert(navlist, hidden)
				if listall then
					tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
				end
			end
		elseif BC == '' and minord <= osign and osign <= maxord then --e.g. >= "1st parliament"
			local catlink = catlinkfollowr( frame, firstpart..' '..oth..tspace..lastpart, oth )
			if catlink.rtarget then --a {{Category redirect}} was followed
				trackcat(23, 'Navseasoncats nordinal redirected')
			end
			table.insert(navlist, navcenter(i, catlink))
		else --either out-of-range (hide), or non-temporal + BC = something might be wrong (2nd X parliament BC?); handle exceptions if/as they arise
			table.insert(navlist, hidden)
		end
		
		i = i + 1
	end
	
	navo = navo .. horizontal(navlist) .. '\n'
	
	isolatedcat()
	if listall then
		return listalllinks()
	else
		return navo..'|}'
	end
end


--[[========================={{  nav_wordinal  }}=============================]]

local function nav_wordinal( frame, firstpart, word, lastpart, minimumword, maximumword, ordinal, frame )
	--Module:ConvertNumeric.spell_number2() args:
	--   ordinal == true : 'second' is output instead of 'two'
	--   ordinal == false: 'two' is output instead of 'second'
	local ord2eng = require('Module:ConvertNumeric').spell_number2
	local eng2ord = require('Module:ConvertNumeric').english_to_ordinal
	local th = 'th'
	if not ordinal then
		th = ''
		eng2ord = require('Module:ConvertNumeric').english_to_numeral
	end
	local capitalize = nil ~= string.match(word, '^%u') --determine capitalization
	local nord = eng2ord(string.lower(word)) --operate on/with lowercase, and restore any capitalization later
	
	local lspace = ' ' --assume a leading space (most common)
	local tspace = ' ' --assume a trailing space (most common)
	if string.match(firstpart, '[%-%(]$') then lspace = '' end --DNE for "Straight-eight engines"-type cats
	if string.match(lastpart, '^[%-%)]' ) then tspace = '' end --DNE for "Nine-cylinder engines"-type cats
	
	--sterilize min/max
	local minword = 1
	local maxword = 99
	if minimumword then
		local num = tonumber(minimumword)
		if num and 0 < num and num < maxword then
			minword = num
		else
			local ord = eng2ord(minimumword)
			if 0 < ord and ord < maxword then
				minword = ord
			end
		end
	end
	if maximumword then
		local num = tonumber(maximumword)
		if num and 0 < num and num < maxword then
			maxword = num
		else
			local ord = eng2ord(maximumword)
			if 0 < ord and ord < maxword then
				maxword = ord
			end
		end
	end
	if minword > nord then minword = nord end
	if maxword < nord then maxword = nord end
	
	--begin navwordinal
	local navw = '{| class="toccolours" style="text-align: center; margin: auto;"\n|\n'
	
	local navlist = {}
	local i = -5 --nav position
	while i <= 5 do
		local n = nord + i
		
		if n >= 1 then
			local nth = p.addord(n)
			if not ordinal then nth = n end
			if i ~= 0 then --left/right navw
				local w = ord2eng{ num = n, ordinal = ordinal, capitalize = capitalize }
				local catlink = catlinkfollowr( frame, firstpart..lspace..w..tspace..lastpart, nth )
				if minword <= n and n <= maxword then
					if catlink.rtarget then --a {{Category redirect}} was followed
						trackcat(24, 'Navseasoncats wordinal redirected')
					end
					table.insert(navlist, catlink.navelement)
				else
					local hidden = '<span style="visibility:hidden">'..nth..'</span>'
					table.insert(navlist, hidden)
					if listall then
						tlistall[#tlistall] = tlistall[#tlistall]..' ('..hidden..')'
					end
				end
			else --center navw
				table.insert(navlist, '<b>'..nth..'</b>')
			end
		else
			table.insert(navlist, '<span style="visibility:hidden">'..'0'..th..'</span>')
		end
		
		i = i + 1
	end
	-- Add the list
	navw = navw .. horizontal(navlist) .. '\n'
	
	isolatedcat()
	if listall then
		return listalllinks()
	else
		return navw..'|}'
	end
end


--[[==========================={{  find_var  }}===============================]]

local function find_var( pn )
	--Extracts the variable text (e.g. 2015, 2015–16, 2000s, 3rd, III, etc.) from a string,
	--and returns { ['vtype'] = <'year'|'season'|etc.>, <v> = <2015|2015–16|etc.> }
	local pagename = currtitle.text
	if pn and pn ~= '' then
		pagename = pn
	end
	
	local cpagename = 'Category:'..pagename --limited-Lua-regex workaround
	
	local d_season = mw.ustring.match(cpagename, ':(%d+s).+%(%d+[–-]%d+%)') --i.e. "1760s in the Province of Quebec (1763–1791)"
	
	local y_season = mw.ustring.match(cpagename, ':(%d+) .+%(%d+[–-]%d+%)') --i.e. "1763 establishments in the Province of Quebec (1763–1791)"
	
	local e_season = mw.ustring.match(cpagename, '%s(%d+[–-])$') or --irreg; ending unknown, e.g. "Members of the Scottish Parliament 2021–"
					 mw.ustring.match(cpagename, '%s(%d+[–-]present)$') --e.g. "UK MPs 2019–present"
	
	local season   = mw.ustring.match(cpagename, '[:%s%(](%d+[–-]%d+)[%)%s]') or --split in 2 b/c you can't frontier '$'/eos?
					 mw.ustring.match(cpagename, '[:%s](%d+[–-]%d+)$')
	
	local tvseason = mw.ustring.match(cpagename, 'season (%d+)') or
					 mw.ustring.match(cpagename, 'series (%d+)')
	
	local nordinal = mw.ustring.match(cpagename, '[:%s](%d+[snrt][tdh])[-%s]') or
					 mw.ustring.match(cpagename, '[:%s](%d+[snrt][tdh])$')
	
	local decade   = mw.ustring.match(cpagename, '[:%s](%d+s)[%s-]') or
					 mw.ustring.match(cpagename, '[:%s](%d+s)$')
	
	local year     = mw.ustring.match(cpagename, '[:%s](%d%d%d%d)%s') or --prioritize 4-digit years
					 mw.ustring.match(cpagename, '[:%s](%d%d%d%d)$') or
					 mw.ustring.match(cpagename, '[:%s](%d+)%s') or
					 mw.ustring.match(cpagename, '[:%s](%d+)$') or
					 --expand/combine exceptions below as needed
					 mw.ustring.match(cpagename, '[:%s](%d+)-related') or
					 mw.ustring.match(cpagename, '[:%s](%d+)-cylinder') or
					 mw.ustring.match(cpagename, '[:%-VW](%d+)%s') --e.g. "Straight-8 engines"
	
	local roman    = mw.ustring.match(cpagename, '%s([IVXLCDM]+)%s')
	
	local found    = d_season or y_season or e_season or season or tvseason or
					 nordinal or decade or year or roman
	
	if found then
		if string.match(found, '%d%d%d%d%d') == nil then
			--return in order of decreasing complexity/least chance for duplication
			if nordinal and season --i.e. "18th-century establishments in the Province of Quebec (1763–1791)"
						then return { ['vtype'] = 'nordinal', ['v'] = nordinal } end
			if d_season then return { ['vtype'] = 'decade',   ['v'] = d_season } end
			if y_season then return { ['vtype'] = 'year',     ['v'] = y_season } end
			if e_season then return { ['vtype'] = 'ending',   ['v'] = e_season } end
			if season   then return { ['vtype'] = 'season',   ['v'] = season   } end
			if tvseason then return { ['vtype'] = 'tvseason', ['v'] = tvseason } end
			if nordinal then return { ['vtype'] = 'nordinal', ['v'] = nordinal } end
			if decade   then return { ['vtype'] = 'decade',   ['v'] = decade   } end
			if year     then return { ['vtype'] = 'year',     ['v'] = year     } end
			if roman    then return { ['vtype'] = 'roman',    ['v'] = roman    } end
		end
	else
		--try wordinals ('zeroth' to 'ninety-ninth' only)
		local eng2ord = require('Module:ConvertNumeric').english_to_ordinal
		local split = mw.text.split(pagename, ' ')
		for i=1, #split do
			if eng2ord(split[i]) > -1 then
				return { ['vtype'] = 'wordinal', ['v'] = split[i] }
			end
		end
		
		--try English numerics ('one'/'single' to 'ninety-nine' only)
		local eng2num = require('Module:ConvertNumeric').english_to_numeral
		local split = mw.text.split(pagename, '[%s%-]') --e.g. "Nine-cylinder engines"
		for i=1, #split do
			if eng2num(split[i]) > -1 then
				return { ['vtype'] = 'enumeric', ['v'] = split[i] }
			end
		end
	end
	
	errors = p.errorclass('Function find_var can\'t find the variable text in category "'..pagename..'".')
	return { ['vtype'] = 'error', ['v'] = p.failedcat(errors, 'V') }
end


--[[==========================================================================]]
--[[                                  Main                                    ]]
--[[==========================================================================]]

function p.navseasoncats( frame )
	--arg checks & handling
	local args = frame:getParent().args
	checkforunknownparams(args)       --for template args
	checkforunknownparams(frame.args) --for #invoke'd args
	local cat  = args['cat']                --'testcase' alias for catspace
	local list = args['list-all-links']     --debugging utility to output all links & followed #Rs
	local follow = args['follow-redirects'] --default 'yes'
	local testcase    = args['testcase']
	local testcasegap = args['testcasegap']
	local minimum = args['min']
	local maximum = args['max']
	local skip_gaps = args['skip-gaps']
	
	--apply args
	local pagename = testcase or cat or currtitle.text
	local testcaseindent = ''
	if testcasecolon == ':' then testcaseindent = '\n::' end
	if follow and follow == 'no' then followRs = false end
	if list and list == 'yes' then listall = true end
	if skip_gaps and skip_gaps == 'yes' then
		skipgaps = true
		trackcat(26, 'Navseasoncats using skip-gaps parameter')
	end
	
	--ns checks
	if currtitle.nsText == 'Category' then
		if cat and cat ~= '' then
			trackcat(1, 'Navseasoncats using cat parameter')
		end
		if testcase and testcase ~= '' then
			trackcat(2, 'Navseasoncats using testcase parameter')
		end
	elseif currtitle.nsText == '' then
		trackcat(30, 'Navseasoncats in mainspace')
	end
	
	--find the variable parts of pagename
	local findvar = find_var(pagename)
	if findvar.vtype == 'error' then --basic format error checking in find_var()
		return findvar.v..table.concat(ttrackingcats)
	end
	local start = string.match(findvar.v, '^%d+')
	
	--the rest is static
	local findvar_escaped = string.gsub( findvar.v, '%-', '%%%-')
	local firstpart, lastpart = string.match(pagename, '^(.-)'..findvar_escaped..'(.*)$')
	if findvar.vtype == 'tvseason' then --double check for cases like '30 Rock (season 3) episodes'
		firstpart, lastpart = string.match(pagename, '^(.-season )'..findvar_escaped..'(.*)$')
		if firstpart == nil then
			firstpart, lastpart = string.match(pagename, '^(.-series )'..findvar_escaped..'(.*)$')
		end
	end
	firstpart = mw.text.trim(firstpart or '')
	lastpart  = mw.text.trim(lastpart or '')
	
	--call the appropriate nav function, in order of decreasing popularity
	if findvar.vtype == 'year' then     --e.g. "500", "2001"; nav_year..nav_decade; ~75% of cats
		local nav1 = nav_year( frame, firstpart, start, lastpart, minimum, maximum )..testcaseindent..table.concat(ttrackingcats)
		
		local dec = math.floor(findvar.v/10)
		local decadecat = nil
		local firstpart_dec = firstpart
		if firstpart_dec ~= '' then
			firstpart_dec = firstpart_dec..' the'
		elseif firstpart_dec == 'AD' and dec <= 1 then
			firstpart_dec = ''
			if dec == 0 then dec = '' end
		end
		local decade = dec..'0s '
		decadecat = mw.text.trim( firstpart_dec..' '..decade..lastpart )
		local exists = catexists(decadecat)
		if exists then
			navborder = false
			trackcat(28, 'Navseasoncats year and decade')
			local nav2 = nav_decade( frame, firstpart_dec, decade, lastpart, minimum, maximum )..testcaseindent..table.concat(ttrackingcats)
			return nav1nav2( nav1, nav2 )
		elseif ttrackingcats[16] ~= '' then --nav_year isolated; check nav_hyphen (e.g. UK MPs 1974, Moldovan MPs 2009, etc.)
			local hyphen = '–'
			local finish = start
			local nav2 = nav_hyphen( frame, start, hyphen, finish, firstpart, lastpart, minimum, maximum, testcasegap )..testcaseindent..table.concat(ttrackingcats)
			if ttrackingcats[16] ~= '' then return nav1 --still isolated; rv to nav_year
			else return nav2 end
		else --regular nav_year
			return nav1
		end
		
	elseif findvar.vtype == 'decade' then   --e.g. "0s", "2010s"; nav_decade..nav_nordinal; ~12% of cats
		local nav1 = nav_decade( frame, firstpart, start, lastpart, minimum, maximum )..testcaseindent..table.concat(ttrackingcats)
		
		local decade = tonumber(string.match(findvar.v, '^(%d+)s'))
		local century = math.floor( ((decade-1)/100) + 1 ) --from {{CENTURY}}
		if century == 0 then century = 1 end --no 0th century
		if string.match(decade, '00$') then
			century = century + 1 --'2000' is in the 20th, but the rest of the 2000s is in the 21st
		end
		local clastpart = ' century '..lastpart
		local centurycat = mw.text.trim( firstpart..' '..p.addord(century)..clastpart )
		local exists = catexists(centurycat)
		if not exists then --check for hyphenated century
			clastpart = '-century '..lastpart
			centurycat = mw.text.trim( firstpart..' '..p.addord(century)..clastpart )
			exists = catexists(centurycat)
		end
		if exists then
			navborder = false
			trackcat(29, 'Navseasoncats decade and century')
			local nav2 = nav_nordinal( frame, firstpart, century, clastpart, minimum, maximum )..testcaseindent..table.concat(ttrackingcats)
			return nav1nav2( nav1, nav2 )
		else
			return nav1
		end
		
	elseif findvar.vtype == 'nordinal' then --e.g. "1st", "99th"; ~7.5% of cats
		return nav_nordinal( frame, firstpart, start, lastpart, minimum, maximum )..testcaseindent..table.concat(ttrackingcats)
		
	elseif findvar.vtype == 'season' then   --e.g. "1–4", "1999–2000", "2001–02", "2001–2002", "2005–2010", etc.; ~5.25%
		local hyphen, finish = mw.ustring.match(findvar.v, '%d([–-])(%d+)') --ascii 150 & 45 (ndash & keyboard hyphen); mw req'd
		return nav_hyphen( frame, start, hyphen, finish, firstpart, lastpart, minimum, maximum, testcasegap )..testcaseindent..table.concat(ttrackingcats)
		
	elseif findvar.vtype == 'tvseason' then --e.g. "1", "15" but preceded with "season" or "series"; <1% of cats
		return nav_tvseason( frame, firstpart, start, lastpart, maximum )..testcaseindent..table.concat(ttrackingcats) --"minimum" defaults to 1
		
	elseif findvar.vtype == 'wordinal' then --e.g. "first", "ninety-ninth"; <<1% of cats
		local ordinal = true
		return nav_wordinal( frame, firstpart, findvar.v, lastpart, minimum, maximum, ordinal, frame )..testcaseindent..table.concat(ttrackingcats)
		
	elseif findvar.vtype == 'enumeric' then --e.g. "one", "ninety-nine"; <<1% of cats
		local ordinal = false
		return nav_wordinal( frame, firstpart, findvar.v, lastpart, minimum, maximum, ordinal, frame )..testcaseindent..table.concat(ttrackingcats)
		
	elseif findvar.vtype == 'roman' then    --e.g. "I", "XXVIII"; <<1% of cats
		return nav_roman( frame, firstpart, findvar.v, lastpart, minimum, maximum )..testcaseindent..table.concat(ttrackingcats)
		
	elseif findvar.vtype == 'ending' then   --e.g. "2021–" (irregular; ending unknown); <<<1% of cats
		local hyphen, finish = mw.ustring.match(findvar.v, '%d([–-])present$'), -1 --ascii 150 & 45 (ndash & keyboard hyphen); mw req'd
		if hyphen == nil then
			hyphen, finish = mw.ustring.match(findvar.v, '%d([–-])$'), 0 --0/-1 are hardcoded switches for nav_hyphen()
		end
		return nav_hyphen( frame, start, hyphen, finish, firstpart, lastpart, minimum, maximum, testcasegap )..testcaseindent..table.concat(ttrackingcats)
		
	else                                 --malformed
		errors = p.errorclass('Failed to determine the appropriate nav function from malformed season "'..findvar.v..'". ')
		return p.failedcat(errors, 'N')..table.concat(ttrackingcats)
	end
end

return p
