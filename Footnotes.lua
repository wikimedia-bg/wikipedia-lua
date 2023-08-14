require('strict');
local getArgs = require ('Module:Arguments').getArgs;


--[[--------------------------< A R G S _ D E F A U L T >------------------------------------------------------

a table to specify initial values.

]]

local args_default = {
	bracket_left = '',
	bracket_right = '',
	bracket_year_left = '',
	bracket_year_right = '',
	postscript = '',
	page = '',
	pages = '',
	location = '',
	page_sep = ", p.&nbsp;",
	pages_sep = ", pp.&nbsp;",
	ref = '',
	template = 'harv',															-- if template name not provided in {{#invoke:}} use this
	};


--[[--------------------------< T A R G E T _ C H E C K >------------------------------------------------------

look for anchor_id (CITEREF name-list and year or text from |ref=) in anchor_id_list

the 'no target' error may be suppressed with |ignore-err=yes when target cannot be found because target is inside
a template that wraps another template; 'multiple targets' error may not be suppressed

]]

local function target_check (anchor_id, args)
	local namespace = mw.title.getCurrentTitle().namespace;
	local anchor_id_list_module = mw.loadData ('Module:Footnotes/anchor_id_list');
	local anchor_id_list = anchor_id_list_module.anchor_id_list;
	local article_whitelist = anchor_id_list_module.article_whitelist;
	local template_list = anchor_id_list_module.template_list;
	
	local whitelist_module = mw.loadData ('Module:Footnotes/whitelist');
	local whitelist = whitelist_module.whitelist;
	local special_patterns = whitelist_module.special_patterns;
	local DNB_special_patterns = whitelist_module.DNB_special_patterns;
	local DNB_template_names = whitelist_module.DNB_template_names;

	if 10 == namespace then
		return '';																-- automatic form of |no-tracking=yes; TODO: is this too broad?
	end

	local tally = anchor_id_list[anchor_id];									-- nil when anchor_id not in list; else a tally
	local msg;
	local category;

	if not tally then
		if args.ignore then
			return '';															-- if ignore is true then no message, no category
		end
		
		if article_whitelist and article_whitelist[anchor_id] then				-- if an article-local whitelist and anchor ID is in it
			return '';															-- done
		end
		
		local wl_anchor_id = anchor_id;											-- copy to be modified to index into the whitelist
		
		if args.year then														-- for anchor IDs created by this template (not in |ref=) that have a date
			if args.year:match ('%d%l$') or										-- use the date value to determine if we should remove the disambiguator
				args.year:match ('n%.d%.%l$') or
				args.year:match ('nd%l$') then
					wl_anchor_id = wl_anchor_id:gsub ('%l$', '');				-- remove the disambiguator
			end
		end		

		local t_tbl = whitelist[wl_anchor_id];									-- get list of templates associated with this anchor ID

		if t_tbl then															-- when anchor ID not whitelisted t_tbl is nil
			for _, t in ipairs (t_tbl) do										-- spin through the list of templates associated with this anchor ID
				if template_list[t] then										-- if associated template is found in the list of templates in the article
					return '';													-- anchor ID is whitlisted and article has matching template so no error
				end
			end
		end

		for _, pattern in ipairs (special_patterns) do							-- spin through the spcial patterns and try to match
			if anchor_id:match (pattern) then
				return '';
			end
		end

		for _, dnb_t in ipairs (DNB_template_names or {}) do					-- getting desparate now, are there any DNB templates? DNB_template_names may be nil; empty table prevents script error
			if template_list[dnb_t] then										-- if the article has this DNB template
				for _, pattern in ipairs (DNB_special_patterns) do				-- spin through the DNB-specifiec wildcard patterns
					if anchor_id:match (pattern) then							-- and attempt a match
						return '';												-- found a match
					end
				end
			end
		end

		msg = 'no target: ' .. anchor_id;										-- anchor_id not found
		category = '[[Category:Harv and Sfn no-target errors]]';

	elseif 1 < tally then
		msg = 'multiple targets (' .. tally .. '×): ' .. anchor_id;				-- more than one anchor_id in this article
		category = 0 == namespace and '[[Category:Harv and Sfn multiple-target errors]]' or '';								-- only categorize in article space
		return '<span class="error harv-error" style="display: inline; font-size:100%"> ' .. args.template .. ' error: ' .. msg .. ' ([[:Category:Harv and Sfn template errors|help]])</span>' .. category;
	end

--	category = 0 == namespace and '[[Category:Harv and Sfn template errors]]' or '';	-- only categorize in article space
	category = 0 == namespace and category or '';								-- only categorize in article space

--use this version to show error messages
--	return msg and '<span class="error harv-error" style="display: inline; font-size:100%"> ' .. args.template .. ' error: ' .. msg .. ' ([[:Category:Harv and Sfn template errors|help]])</span>' .. category or '';
--use this version to hide error messages
	return msg and '<span class="error harv-error" style="display: none; font-size:100%"> ' .. args.template .. ' error: ' .. msg .. ' ([[:Category:Harv and Sfn template errors|help]])</span>' .. category or '';

end


--[[--------------------------< I S _ Y E A R >----------------------------------------------------------------

evaluates param to see if it is one of these forms with or without lowercase letter disambiguator:
	YYYY
	n.d.
	nd	
	c. YYYY
	YYYY–YYYY	(separator is endash)
	YYYY–YY		(separator is endash)

return true when param has a recognized form; false else

]]

local patterns_date= {
	'^%d%d%d%d?%l?$',
	'^n%.d%.%l?$',
	'^nd%l?$',
	'^c%. %d%d%d%d?%l?$',
	'^%d%d%d%d–%d%d%d%d%l?$',
	'^%d%d%d%d–%d%d%l?$',
	}

local function is_year (param, args)
	args.year = '';																-- used for harv error; 
	
	for _, pattern in ipairs (patterns_date) do
		if mw.ustring.match (param, pattern) then
			args.year = param;													-- used for harv error; 
			return true;
		end
	end
end


--[[--------------------------< C O R E >----------------------------------------------------------------------

returns an anchor link (CITEREF) formed from one to four author names, year, and insource location (|p=, |pp=, loc=)

]]

local function core( args )
	local result;
	local err_msg = ''

	if args.P5 ~= '' then
		if is_year (args.P5, args) then
			result = table.concat ({args.P1, ' et al. ', args.bracket_year_left, args.P5, args.bracket_year_right});
		else
			args.P5 = '';														-- when P5 not a year don't include in anchor
			result = table.concat ({args.P1, ' et al.'});						-- and don't render it
		end

	elseif args.P4 ~= '' then
		if is_year (args.P4, args) then
			result = table.concat ({args.P1, ', ', args.P2, ' &amp; ', args.P3, ' ', args.bracket_year_left, args.P4, args.bracket_year_right});	-- three names and a year
		else
			result = table.concat ({args.P1, ' et al.'});						-- four names
		end

	elseif args.P3 ~= '' then
		if is_year (args.P3, args) then
			result = table.concat ({args.P1, ' &amp; ', args.P2, ' ', args.bracket_year_left, args.P3, args.bracket_year_right});	-- two names and a year
		else
			result = table.concat ({args.P1, ', ', args.P2, ' ', ' &amp; ', args.P3});	-- three names
		end
			
	elseif args.P2 ~= '' then
		if is_year (args.P2, args) then
			result = table.concat ({args.P1, ' ', args.bracket_year_left, args.P2, args.bracket_year_right});	-- one name and year
		else
			result = table.concat ({args.P1, ' &amp; ', args.P2});				-- two names
		end
		
	else
		result = args.P1;														-- one name
	end
																				-- when author-date result ends with a dot (typically when the last positional parameter holds 'n.d.')
																				-- and when no in-source location (no |p=, |pp=, or |loc=)
																				-- and when the first or only character in args.postscript is a dot
																				-- remove the author-date result trailing dot
																				-- the author-date result trailing dot will be replaced later with the content of args.postscript (usually a dot)
	if ('.' == result:sub(-1)) and ('.' == args.postscript:sub(1)) and ('' == args.page) and ('' == args.pages) and ('' == args.location) then
		result = result:gsub ('%.$', '');
	end
	
	if args.ref ~= 'none' then
		local anchor_id;
		if args.ref ~= '' then
			anchor_id = mw.uri.anchorEncode (args.ref);
			err_msg = target_check (anchor_id, args);
			result = table.concat ({'[[#', anchor_id, '|', result, ']]'});
		else
			anchor_id = mw.uri.anchorEncode (table.concat ({'CITEREF', args.P1, args.P2, args.P3, args.P4, args.P5}));
			err_msg = target_check (anchor_id, args);
			result = table.concat ({'[[#', anchor_id, '|', result, ']]'});
		end
	end

	if args.page ~= '' then
		result = table.concat ({result, args.page_sep, args.page});
	elseif args.pages ~= ''then
		result = table.concat ({result, args.pages_sep, args.pages});
	end      

	if args.location ~= '' then
		result = table.concat ({result, ', ', args.location});
	end

	result = table.concat ({args.bracket_left, result, args.bracket_right, args.postscript}):gsub ('%s+', ' ');		-- strip redundant spaces
	return result .. err_msg;
end


--[[--------------------------< H Y P H E N _ T O _ D A S H >--------------------------------------------------

Converts a hyphen to a dash under certain conditions.  The hyphen must separate
like items; unlike items are returned unmodified.  These forms are modified:
	letter - letter (A - B)
	digit - digit (4-5)
	digit separator digit - digit separator digit (4.1-4.5 or 4-1-4-5)
	letterdigit - letterdigit (A1-A5) (an optional separator between letter and
		digit is supported – a.1-a.5 or a-1-a-5)
	digitletter - digitletter (5a - 5d) (an optional separator between letter and
		digit is supported – 5.a-5.d or 5-a-5-d)

any other forms are returned unmodified.

str may be a comma- or semicolon-separated list

This code copied from Module:Citation/CS1.  The only modification is to require Module:Citation/CS1/Utilities
so that it has access to the functions is_set() and has_accept_as_written()

]]

local function hyphen_to_dash( str )
	local utilities = require ('Module:Citation/CS1/Utilities');				-- only modification so that this function has access to is_set() and has_accept_as_written()

	if not utilities.is_set (str) then
		return str;
	end

	local accept; -- Boolean

	str = str:gsub ('&[nm]dash;', {['&ndash;'] = '–', ['&mdash;'] = '—'});		-- replace &mdash; and &ndash; entities with their characters; semicolon mucks up the text.split
	str = str:gsub ('&#45;', '-'); -- replace HTML numeric entity with hyphen character

	str = str:gsub ('&nbsp;', ' '); -- replace &nbsp; entity with generic keyboard space character
	
	local out = {};
	local list = mw.text.split (str, '%s*[,;]%s*');								-- split str at comma or semicolon separators if there are any

	for _, item in ipairs (list) do												-- for each item in the list
		item, accept = utilities.has_accept_as_written (item);					-- remove accept-this-as-written markup when it wraps all of item
		if not accept and mw.ustring.match (item, '^%w*[%.%-]?%w+%s*[%-–—]%s*%w*[%.%-]?%w+$') then	-- if a hyphenated range or has endash or emdash separators
			if item:match ('^%a+[%.%-]?%d+%s*%-%s*%a+[%.%-]?%d+$') or			-- letterdigit hyphen letterdigit (optional separator between letter and digit)
				item:match ('^%d+[%.%-]?%a+%s*%-%s*%d+[%.%-]?%a+$') or			-- digitletter hyphen digitletter (optional separator between digit and letter)
				item:match ('^%d+[%.%-]%d+%s*%-%s*%d+[%.%-]%d+$') or			-- digit separator digit hyphen digit separator digit
				item:match ('^%d+%s*%-%s*%d+$') or								-- digit hyphen digit
				item:match ('^%a+%s*%-%s*%a+$') then							-- letter hyphen letter
					item = item:gsub ('(%w*[%.%-]?%w+)%s*%-%s*(%w*[%.%-]?%w+)', '%1–%2');	-- replace hyphen, remove extraneous space characters
			else
				item = mw.ustring.gsub (item, '%s*[–—]%s*', '–');				-- for endash or emdash separated ranges, replace em with en, remove extraneous whitespace
			end
		end
		table.insert (out, item);												-- add the (possibly modified) item to the output table
	end

	local temp_str = '';														-- concatenate the output table into a comma separated string
	temp_str, accept = utilities.has_accept_as_written (table.concat (out, ', ')); -- remove accept-this-as-written markup when it wraps all of concatenated out
	if accept then
		temp_str = utilities.has_accept_as_written (str);						-- when global markup removed, return original str; do it this way to suppress boolean second return value
		return temp_str;
	else
		return temp_str;														-- else, return assembled temp_str
	end
end


--[[--------------------------< A R G S  _ F E T C H >---------------------------------------------------------

Because all of the templates share a common set of parameters, a single common function to fetch those parameters
from frame and parent frame.

]]

local function args_fetch (frame, ps)
	local args = args_default;													-- create a copy of the default table
	local pframe = frame:getParent();											-- point to the template's parameter table

	for k, v in pairs (frame.args) do											-- override defaults with values provided in the #invoke: if any
		args[k] = v;	   
	end
	
	args.postscript = pframe.args.postscript or pframe.args.ps or ps;
	if 'none' == args.postscript then
		args.postscript = '';
	end
	args.page = pframe.args.p or pframe.args.page or '';
	args.pages = pframe.args.pp or pframe.args.pages or '';
	args.pages = ('' ~= args.pages) and hyphen_to_dash (args.pages) or '';
	args.location = pframe.args.loc or '';
	args.ref = pframe.args.ref or pframe.args.Ref or '';
	args.ignore = ('yes' == pframe.args['ignore-false-positive']) or ('yes' == pframe.args['ignore-err']);

	for i, v in ipairs ({'P1', 'P2', 'P3', 'P4', 'P5'}) do						-- loop through the five positional parameters and trim if set else empty string
		args[v] = (pframe.args[i] and mw.text.trim (pframe.args[i])) or '';
	end

	if args.P5 and not is_year (args.P5, args) then
		local i = 6;															-- initialize the indexer to the sixth positional parameter
		while pframe.args[i] do													-- in case there are too many authors loop through the authors looking for a year
			local v = mw.text.trim (pframe.args[i]);							-- trim
			if is_year (v, args) then											-- if a year
				args.P5 = v;													-- overwrite whatever was in args.P5 with year
				break;															-- and abandon the search
			end
			i = i + 1;															-- bump the indexer
		end
	end
	return args;
end


--[[--------------------------< H A R V A R D _ C I T A T I O N >----------------------------------------------

common entry point for:
	{{harvard citation}} aka {{harv}}
	{{Harvard citation no brackets}} aka {{harvnb}}
	{{harvcol}}
	{{harvcolnb}}
	{{harvcoltxt}}
	{{Harvard citation text}} aka {{harvtxt}}
	{{Harvp}}

Distinguishing features (brackets and page separators) are specified in this module's {{#invoke}} in the respective templates.

]]

local function harvard_citation (frame)
	local args = args_fetch (frame, '');										-- get the template and invoke parameters; default postscript is empty string

	return core (args);
end


--[[--------------------------< S T R I P _ U R L >------------------------------------------------------------

used by sfn() and sfnm().  This function fixes an issue with reference tooltip gadget where the tooltip is not displayed
when an insource locator (|p=, |pp=, |loc=) has an external wikilink that contains a # character

strip uri-reserved characters from urls in |p=, |pp-, and |loc= parameters  The researved characters are:
	!#$&'()*+,/:;=?@[]
	
]]

local function strip_url (pages)
	local escaped_uri;
	if not pages or ('' == pages) then
		return pages;
	end
	
	for uri in pages:gmatch ('%[(%a[%w%+%.%-]*://%S+)') do						-- for each external link get the uri
		escaped_uri = uri:gsub ("([%(%)%.%%%+%-%*%?%[%^%$%]])", "%%%1" );		-- save a copy with lua pattern characters escaped
		uri = uri:gsub ("[!#%$&'%(%)%*%+,/:;=%?@%[%]%.%%]", '');				-- remove reserved characters and '%' because '%20' (space character) is a lua 'invalid capture index'
		pages = pages:gsub (escaped_uri, uri, 1);								-- replace original uri with the stripped version
	end
	
	return pages;
end


--[[--------------------------< S F N >------------------------------------------------------------------------

entry point for {{sfn}} and {{sfnp}}

]]

local function sfn (frame)
	local args = args_fetch (frame, '.');										-- get the template and invoke parameters; default postscript is a dot

	local result = core (args);													-- go make a CITEREF anchor
																				-- put it all together and then strip redundant spaces
	local name = table.concat ({'FOOTNOTE', args.P1, args.P2, args.P3, args.P4, args.P5, strip_url (args.page), strip_url (args.pages), strip_url (args.location)}):gsub ('%s+', ' ');

	return frame:extensionTag ({name='ref', args={name=name}, content=result});	

	
end


--[[--------------------------< S F N M >----------------------------------------------------------------------

common entry point for {{sfnm}} and {{sfnmp}}

Distinguishing features (brackets) are specified in this module's {{#invoke}} in the respective templates.

]]

local function sfnm (frame)
	local args = args_default;													-- create a copy of the default table
	local pframe = frame:getParent();											-- point to the template's parameter table
	
	local n = 1;																-- index of source; this is the 'n' in na1, ny, etc
	local first_pnum = 1;														-- first of a pair of positional parameters
	local second_pnum = 2;														-- second of a pair of positional parameters

	local last_ps = 0;															-- index of the last source with |nps= set
	local last_index = 0;														-- index of the last source; these used to determine which of |ps= or |nps= will terminate the whole rendering

	local out = {};																-- table to hold rendered sources
	local footnote = {'FOOTNOTE'};												-- all author, date, insource location stuff becomes part of the reference's footnote id; added as we go

	for k, v in pairs (frame.args) do											-- override defaults with values provided in the #invoke: if any
		args[k] = v;	   
	end
	
	while true do
		if not pframe.args[table.concat ({n, 'a1'})] and not pframe.args[first_pnum] then
			break;																-- no na1 or matching positional parameter so done
		end
		
		if pframe.args[table.concat ({n, 'a1'})] then							-- does this source use named parameters?
			for _, v in ipairs ({'P1', 'P2', 'P3', 'P4', 'P5'}) do				-- initialize for this source
				args[v] = '';
			end

			for i, v in ipairs ({'P1', 'P2', 'P3', 'P4', 'P5'}) do				-- extract author and year parameters for this source
				args[v] = pframe.args[table.concat ({n, 'a', i})] or '';		-- attempt to assign author name
				if '' == args[v] then											-- when there wasn't an author name
					args[v] = pframe.args[table.concat ({n, 'y'})] or '';		-- attempt to assign year
					break;														-- done with author/date for this source
				end
			end

		else																	-- this source uses positional parameters
			args.P1 = mw.text.trim (pframe.args[first_pnum]);					-- yes, only one author supported
			args.P2 = (pframe.args[second_pnum] and mw.text.trim (pframe.args[second_pnum])) or '';	-- when positional author, year must also be positional

			for _, v in ipairs ({'P3', 'P4', 'P5'}) do							-- blank the rest of these for this source
				args[v] = '';
			end

			first_pnum = first_pnum + 2;										-- source must use positional author and positional year
			second_pnum = first_pnum + 1;										-- bump these for possible next positional source
		end
		
		args.postscript = pframe.args[table.concat ({n, 'ps'})] or '';
		if 'none' == args.postscript then										-- this for compatibility with other footnote templates; does nothing
			args.postscript = '';
		end

		args.ref = pframe.args[table.concat ({n, 'ref'})] or '';				-- alternate reference for this source

		args.page = pframe.args[table.concat ({n, 'p'})] or '';					-- insource locations for this source
		args.pages = pframe.args[table.concat ({n, 'pp'})] or '';
		args.pages = ('' ~= args.pages) and hyphen_to_dash (args.pages) or '';
		args.location = pframe.args[table.concat ({n, 'loc'})] or '';
		args.ignore = ('yes' == pframe.args[table.concat ({n, 'ignore-false-positive'})]) or ('yes' == pframe.args[table.concat ({n, 'ignore-err'})]);

		table.insert (out, core (args));										-- save the rendering of this source
		
		for k, v in ipairs ({'P1', 'P2', 'P3', 'P4', 'P5'}) do					-- create the FOOTNOTE id
			if '' ~= args[v] then
				table.insert (footnote, args[v]);
			end
		end
		for k, v in ipairs ({'page', 'pages', 'location'}) do					-- these done separately so that we can strip uri-reserved characters from extlinked page numbers 
			if '' ~= args[v] then
				table.insert (footnote, strip_url (args[v]))
			end
		end
		
		last_index = n;															-- flags used to select terminal postscript from nps or from end_ps
		if '' ~= args.postscript then							
			last_ps = n;
		end
		
		n = n+1;																-- bump for the next one
	end
	
	local name = table.concat (footnote):gsub ('%s+', ' ');						-- put the footnote together and strip redundant space
	
	args.end_ps = pframe.args.postscript or pframe.args.ps or '.';				-- this is the postscript for the whole not for the individual sources
	if 'none' == args.end_ps then												-- not an original sfnm parameter value; added for compatibility with other footnote templates
		args.end_ps = '';
	end

	local result = table.concat ({table.concat (out, '; '), (last_index == last_ps) and '' or  args.end_ps});
	return frame:extensionTag ({name='ref', args={name=name}, content=result});
end


--[[--------------------------< S F N R E F >------------------------------------------------------------------

implements {{sfnref}}

]]

local function sfnref (frame)
	local args = getArgs (frame);
	local out = {};
	
	for i=1, 5 do																-- get the first five args if there are five args
		if args[i] then
			out[i] = args[i];
		else
			break;																-- less than 5 args break out
		end
	end
	
	if 5 == #out then															-- when we have seen five args there may bemore
		local i = 6;															-- initialize the indexer to the sixth positional parameter
		while args[i] do														-- in case there are too many authors loop through the authors looking for a year
			if is_year (args[i], args) then										-- if a year
				out[5] = args[i];												-- overwrite whatever was in args[5] with year
				break;															-- and abandon the search
			end
			i = i + 1;															-- bump the indexer
		end
	end
	
	return mw.uri.anchorEncode ('CITEREF' .. table.concat (out));
end


--[[--------------------------< E X P O R T E D   F U N C T I O N S >------------------------------------------
]]

return {
	harvard_citation = harvard_citation,
	sfn = sfn,
	sfnm = sfnm,
	sfnref = sfnref,
	};
