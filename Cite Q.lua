require('strict')

local wdib = require('Module:WikidataIB')
local getValue = wdib._getValue
local _getPropOfProp = wdib._getPropOfProp
local followQid = wdib._followQid
local getPropertyIDs = wdib._getPropertyIDs
local cite_cfg = mw.loadData ('Module:Cite/config')
local cfg = mw.loadData ('Module:Cite_Q/config')
local cs1_module = 'Module:Citation/CS1'										-- don't load the module yet, may not be needed

--------------------------------------------------------------------------------
-- makeOrdinal needs to be internationalised along with cfg.i18n_t
-- takes cardinal number as a numeric and returns the ordinal as a string
-- we need three exceptions in English for 1st, 2nd, 3rd, 21st, .. 31st, etc.
--------------------------------------------------------------------------------
local makeOrdinal = function(cardinal)
	local card = tonumber(cardinal)
	if not card then return cardinal end
	local ordsuffix = cfg.i18n_t.ordinal.default
	if card % 10 == 1 then
		ordsuffix = cfg.i18n_t.ordinal[1]
	elseif card % 10 == 2 then
		ordsuffix = cfg.i18n_t.ordinal[2]
	elseif card % 10 == 3 then
		ordsuffix = cfg.i18n_t.ordinal[3]
	end
	-- In English, 1, 21, 31, etc. use 'st', but 11, 111, etc. use 'th'
	-- similarly for 12 and 13, etc.
	if (card % 100 == 11) or (card % 100 == 12) or (card % 100 == 13) then
		ordsuffix = cfg.i18n_t.ordinal.default
	end
	return card .. ordsuffix
end

--[[--------------------------< I S _ S E T >------------------------------------------------------------------
Returns true if argument is set; false otherwise. Argument is 'set' when it exists (not nil) or when it is not an empty string.
]]
local function is_set( var )
	return not (var == nil or var == '')
end

--[[--------------------------< I N _ A R R A Y >--------------------------------------------------------------
Whether needle is in haystack (taken from Module:Citation/CS1/Utilities)
]]
local function in_array( needle, haystack )
	if needle == nil then
		return false
	end
	for n, v in ipairs( haystack ) do
		if v == needle then
			return n
		end
	end
	return false
end


--[[--------------------------< A C C E P T _ V A L U E >-------------------------------------------------------
Accept WD value by framing in ((...)) if param_val is equal to keyword; else pass-through WD value as is.
]]
local function accept_value( param_val, wd_val )
	local val = param_val

	if val then
		if in_array (val, {'accept', '))((', ':d:'}) then
			val = '((' .. wd_val .. '))'
		elseif '((accept))' == val then
			val = 'accept'
		elseif '(())(())' == val then
			val = '))(('
		elseif '((:d:))' == val then
			val = ':d:'
		else
			val = wd_val
		end
	end

	return val
end

-- function to fetch a value to display
local function makelink(v, out, link, maxpos, wdl)
	local label
	if v.mainsnak.snaktype == "value" then
		if v.mainsnak.datatype == "wikibase-item" then
			local qnumber = v.mainsnak.datavalue.value.id
			local sitelink = mw.wikibase.getSitelink(qnumber)
			if qnumber == "Q2818964" then sitelink = nil end -- suppress link to "Various authors"
			if v.qualifiers and v.qualifiers.P1932 then
				label = v.qualifiers.P1932[1].datavalue.value
			else
				label = mw.wikibase.getLabel(qnumber)
				if label then
					label = mw.text.nowiki(label)
				else
					label = qnumber -- should add tracking category
				end
			end
			local position = maxpos + 1 -- Default to 'next' author.
			-- use P1545 (series ordinal) instead of default position.
			if v["qualifiers"] and v.qualifiers["P1545"] and v.qualifiers["P1545"][1] then
				position = tonumber(v.qualifiers["P1545"][1].datavalue.value)
			end
			maxpos = math.max(maxpos, position)
			if sitelink then
				-- just the plain name,
				-- but keep a record of the links, using the same index
				out[position] = label
				link[position] = sitelink
			else
				if wdl then
					-- show that there's a Wikidata entry available
					out[position] = string.format(
						"[[:d:Q%s|%s]]&nbsp;<span title='%s'>[[File:Wikidata-logo.svg|16px|alt=|link=]]</span>",
						v.mainsnak.datavalue.value["numeric-id"],
						label,
						cfg.i18n_t["errors"]["local-article-not-found"]
					)
				else
					-- no Wikidata links wanted, so just give the plain label
					out[position] = label
				end
			end
		elseif v.mainsnak.datatype == "string" then
			local position = maxpos + 1 -- Default to 'next' author.
			-- use P1545 (series ordinal) instead of default position.
			if v["qualifiers"] and v.qualifiers["P1545"] and v.qualifiers["P1545"][1] then
				position = tonumber(v.qualifiers["P1545"][1].datavalue.value)
			end
			maxpos = math.max(maxpos, position)
			out[position] = v.mainsnak.datavalue.value
		else
			-- not a wikibase-item or a string!
		end
	else
		-- code here if we want to return something when author is "unknown"
		if v.qualifiers and v.qualifiers.P1932 then
			label = v.qualifiers.P1932[1].datavalue.value
		else
			label = cfg.i18n_t["unknown-author"] .. (cfg.i18n_t.trackingcats["unknown-author"] or "")
		end
		maxpos = maxpos + 1
		out[maxpos] = label
	end
	return maxpos
end

--[=[-------------------------< G E T _ N A M E _ L I S T >----------------------------------------------------
get_name_list -- adapted from getAuthors code taken from Module:RexxS
arguments:
	nl_type - type of name list to fetch: nl_type = 'author' for authors; 'editor' for editors; 'translator' for translators
	args - pointer to the parameter arguments table from the template call
	qid - value from |qid= parameter; the Q-id of the source (book, etc.) in qid
	wdl - value from the |wdl= parameter; a Boolean passed to enable links to Wikidata when no article exists
returns nothing; modifies the args table
]=]

local function get_name_list (nl_type, args, qid, wdl)
	local propertyID = "P50"
	local fallbackID = "P2093" -- author name string

	if nl_type =="author" then
		propertyID = 'P50'		-- for authors
		fallbackID = 'P2093'	-- author-string
	elseif nl_type =="editor" then
		propertyID = 'P5769'	-- "editor-in-chief"
		fallbackID = 'P98'		-- for editors - So-called "fallbacks" are actually a second set of properties processed
		-- TBD. Take book series editors into account as well (if they have a separate P code as well)?
	elseif nl_type == "translator" then
		propertyID = 'P655'		-- for translators
		fallbackID = nil
--	elseif 'contributor' == nl_type then
--		f.e. author of forewords (P2679) and afterwords (P2680); requires |contribution=, |title= and |author=
--		propertyID = 'P'		-- for contributors
--		fallbackID = nil
	else
		return					-- not specified so return
	end

	-- wdl is a Boolean passed to enable links to Wikidata when no article exists
	-- if "false" or "no" or "0" is passed set it false
	-- if nothing or an empty string is passed set it false
	if wdl and (#wdl > 0) then
		wdl = wdl:lower()
		wdl = in_array (wdl, {"false", "no", "0"})
	else
		-- wdl is empty, so
		wdl = false
	end

	local props = nil
	local fallback = nil
	if mw.wikibase.entityExists(qid) then
		props = mw.wikibase.getAllStatements(qid, propertyID)
		if props and fallbackID then
			fallback = mw.wikibase.getAllStatements(qid, fallbackID)
		end
	end

	-- Make sure it actually has at least one of the properties requested
	if not (props and props[1]) and not (fallback and fallback[1]) then
		return nil
	end

	-- So now we have something to return:
	-- table 'out' is going to store the names(s):
	-- and table 'link' will store any links to the name's article
	local out = {}
	local link = {}
	local maxpos = 0
	if props and props[1] then
		for k, v in pairs(props) do
			if 'deprecated' ~= v.rank then										-- ignore deprecated names
				maxpos = makelink(v, out, link, maxpos, wdl)
			end
		end
	end
	if fallback and fallback[1] then
		-- second properties
		for k, v in pairs(fallback) do
			if 'deprecated' ~= v.rank then										-- ignore deprecated names
				maxpos = makelink(v, out, link, maxpos, wdl)
			end
		end
	end

	-- if there's anything to return, then insert the additions in the template arguments table
	-- in the form |author1=firstname secondname |author2= ...
	-- Renumber, in case we have inconsistent numbering
	local keys = {}
	for k, v in pairs(out) do
		keys[#keys + 1] = k
	end
	table.sort(keys) -- as they might be out of order
	for i, k in ipairs(keys) do
		out[k] = out[k]:gsub ('&#39;', '\'');									-- prevent cs1|2 multiple names categorization; replace html entity with the actual character
		mw.log(i .. " " .. k .. " " .. (out[k]))
		if args[nl_type .. i] then -- name gets overwritten
			-- pull corresponding -link only if overwritten name is same as WD name
			if link[k] and (args[nl_type .. i] == out[k]) then
				args[nl_type .. '-link' .. i] = args[nl_type .. '-link' .. i] or link[k] -- author-linkn or editor-linkn
			end
		else -- name does not get overwritten, so pull name from WD
			args[nl_type .. i] = out[k]
			if link[k] then
				args[nl_type .. '-link' .. i] = args[nl_type .. '-link' .. i] or link[k] -- author-linkn or editor-linkn
			end
		end
	end
end

-- gets language codes used for a monolingual text property as a table
local function _getLangOfProp(qid, pid)
	if not pid then return {} end
	local out = {}
	local props = mw.wikibase.getAllStatements(qid, pid)
	for i, v in ipairs(props) do
		if v.mainsnak.datatype == "monolingualtext" and v.mainsnak.datavalue then
			out[#out + 1] = v.mainsnak.datavalue.value.language
		end
	end
	return out
end
local function getLangOfProp(frame)
	local pid = frame.args.pid or mw.text.trim(frame.args[1] or "")
	if pid == "" then return end
	local qid = frame.args.qid
	if qid == "" then qid = nil end
	return table.concat(_getLangOfProp(qid, pid), ", ")
end

-- gets the language codes of a Wikidata entry as a table
local function _lang_code(qid)
	local lc = _getPropOfProp( {qid = qid, prop1 = "P407", prop2 = "P424", ps = 1} )
	if lc then return mw.text.split( lc, "[, ]+" ) end
	lc = _getPropOfProp( {qid = qid, prop1 = "P407", prop2 = "P218", ps = 1} )
	if lc then return mw.text.split( lc, "[, ]+" ) end
	return _getLangOfProp(qid, "P1476")
end
local function lang_code(frame)
	return table.concat(_lang_code(frame.args.qid or mw.text.trim(frame.args[1] or "")), ", ")
end

-- export for debug
local function getPropOfProp(frame)
	return _getPropOfProp(frame.args)
end

-- wraps a string in nowiki unless disable flag is set
local function wrap_nowiki(str, disable)
	if disable then return str or '' end
	return mw.text.nowiki(str or '')
end

-- sort sequence table whose values are key-value pairs by key
local function comp_key(a, b)
	local param_a, enum_a = a[1]:match ('(%D+)(%d+)$');							-- get param name and enumerator from <a>
	local param_b, enum_b = b[1]:match ('(%D+)(%d+)$');							-- get param name and enumerator from <b>
	
	if enum_a and enum_b then													-- if both parameters have neumerators
		if param_a == param_b then												-- are parameter names the same?
			return tonumber (enum_a) < tonumber (enum_b);						-- yes: compare enumerators
		end
	end

	return a[1] < b[1];															-- alpha sort if here
end

-- sort sequence table whose values are key-value pairs by value
local function comp_val(a, b)
	return a[2] < b[2]
end

--[[-------------------------< C I T E _ Q >------------------------------------------------------------------
Takes standard CS1|2 template parameters and passes all to {{citation}}.  If neither of |author= and |author1=
are set, calls get_authors() to try to get an author name-list from Wikidata.  The result is passed to
{{citation}} for rendering.
--]]
local function _cite_q (citeq_args)
	local frame = mw.getCurrentFrame()

	-- parameters that don't get passed to Citation
	local expand = citeq_args.expand -- when set to anything, causes {{cite q}} to render <code><nowiki>{{citation|...}}</nowiki></code>
	local qid = citeq_args.qid or citeq_args[1]
	local wdl = citeq_args.wdl
	local template = citeq_args.template
	citeq_args.expand = nil
	citeq_args[1] = nil
	citeq_args.qid = nil
	citeq_args.wdl = nil
	citeq_args.template = nil

	-- if title supplied, flag to not read html title
	local titleforced = (citeq_args.title ~= nil)

	local oth = {}

	-- put the language codes into a sequential table langcodes[]
	local langcodes = {}
	if citeq_args.language then
		-- check these are a supported language codes
		for lc in mw.text.gsplit( citeq_args.language, "[, ]+", false ) do
			langcodes[#langcodes+1] = mw.language.isSupportedLanguage(citeq_args.language) and citeq_args.language
		end
	end
	if not langcodes[1] then
		-- try to find language of work
		langcodes = _lang_code(qid)
	end
	if not langcodes[1] then
		-- try fallback to journal's language
		local journal_qid = followQid({qid = qid, props = "P1433"})
		langcodes = journal_qid and _lang_code(journal_qid)
	end
	citeq_args.language = citeq_args.language or table.concat(langcodes, ", ")

	-- loop through list of simple properties and get their values in citeq_args
	for name, data in pairs(cfg.simple_properties_t) do
		citeq_args[name] = getValue( {data.id, fwd = "ALL", osd = "no", noicon = "true", qid = qid, maxvals = data.maxvals, linked = data.linked, rank = data.rank or "best", citeq_args[name] } )
		if data.populate_from_journal then
			local publishedin = getValue( {"P1433", ps = 1, qid = qid, maxvals = 0, citeq_args[name], qual = data.id, qualsonly = 'yes'} )
			citeq_args[name] = publishedin or _getPropOfProp({qid = qid, prop1 = "P1433", prop2 = data.id, maxvals = data.maxvals, ps = 1})
		end
		if citeq_args[name] and citeq_args[name]:find (cfg.i18n_t.trackingcats["missing-wikidata"], 1, true) then
			-- try fallback to work's native language
			citeq_args[name] = getValue( {data.id, ps = 1, qid = qid, maxvals = data.maxvals, linked = "no", lang = langcodes[1] } )
			if citeq_args[name]:find('^Q%d+$') then -- qid was returned
				-- try fallback to qid's native language
				local qid_languages = _lang_code(citeq_args[name])
				citeq_args[name] = getValue( {data.id, ps = 1, qid = qid, maxvals = data.maxvals, linked = "no", lang = qid_languages[1] } )
				if citeq_args[name]:find('^Q%d+$') then -- qid was returned again
					citeq_args[name] = nil
				else
					-- record the language found if no lang specified
					citeq_args.language = citeq_args.language or qid_languages[1]
				end
			end
		end
		if data.others then
			oth[#oth + 1] = citeq_args[name] and (name:gsub("^%l", string.upper) .. ": " .. citeq_args[name])
			citeq_args[name] = nil
		end
	end

	citeq_args.others = citeq_args.others or table.concat(oth, ". ")
	if citeq_args.others == "" then
		citeq_args.others = nil
	end

	citeq_args.journal = citeq_args.journal and citeq_args.journal:gsub("^''", ""):gsub("''$", ""):gsub("|''", "|"):gsub("'']]", "]]")

	citeq_args.ol = (getValue( {"P648", ps = 1, qid = qid, maxvals = 1, citeq_args.ol } ) or ''):gsub("^OL(.+)$", "%1")
	if citeq_args.ol == "" then
		citeq_args.ol = nil
	end
	-- TBD. Take care of |ol-access=?

	citeq_args.biorxiv = citeq_args.biorxiv and ("10.1101/" .. citeq_args.biorxiv)

	citeq_args.isbn = getValue( {"P957", ps = 1, qid = qid, maxvals = 1, rank="best", citeq_args.isbn } ) -- try ISBN 10 (only one value accepted)

	-- if url then see if there's an archive: citeq_args.url
	local url
	if not citeq_args.url then
		for i, pr in ipairs( {"P953", "P856", "P2699"} ) do
			url = getValue( {pr, ps = 1, qid = qid, maxvals = 1, qual="P1065" } )
			if url then
				citeq_args.url = mw.text.split( url, " (", true )[1]
				local arcurl = mw.ustring.match( url, " %((.*)%)" )				-- when there is an archive url, <url> holds: url<space>(archive url); here extract the archive url if present
				if arcurl then
					local arcy, arcm, arcd = arcurl:match("(20%d%d)%p?(%d%d)%p?(%d%d)")
					if arcy and arcm and arcd then
						citeq_args["archive-url"] = arcurl
						citeq_args["archive-date"] = tonumber(arcd) .. " " .. cfg.i18n_t.months[tonumber(arcm)] .. " " .. arcy
					end
				end
				break
			end
		end
	end

	if citeq_args.publisher == "Unknown" then -- look for "stated as" (P1932)
		local stated_as = getValue( {"P123", ps = 1, qid = qid, maxvals = 1, qual="P1932", qo="y"} )
		if stated_as then citeq_args.publisher = stated_as end
	end

	if not titleforced then
		-- Handle subtitle.
		if citeq_args.title then
			local subtitle = mw.wikibase.getBestStatements (qid, 'P1680');
			if 0 ~= #subtitle then
				subtitle = subtitle[1].mainsnak.datavalue.value.text;
				citeq_args.title = citeq_args.title .. ": " .. subtitle
			end
		end
		
		local htmltitle = getValue( {"P1476", qual = "P6833", ps = 1, qid = qid, maxvals = 1, qo = "y"} )
		if htmltitle then
			citeq_args.title = htmltitle:gsub("</?i>", "''")
		else
			local title_display = citeq_args.title
				or mw.wikibase.getLabel(qid)
				or (langcodes[1] and mw.wikibase.getLabelByLang(qid, langcodes[1]))
			if citeq_args.url then
				citeq_args.title = wrap_nowiki(title_display)
			else
				local slink = mw.wikibase.getSitelink(qid)
				local slink_flag = false
				local wrap_title = ''
				local wslink = false
				if not slink then
					-- See if we have wikisource
					if not citeq_args.url then
						local wikisource_sitelink = mw.wikibase.getSitelink(qid, cfg.i18n_t.wikisource) or nil
						if wikisource_sitelink then
							slink = ':s:'..wikisource_sitelink
							wslink = true
						end
					end
				end
				if citeq_args.title then
					if slink then
						wrap_title = wrap_nowiki(citeq_args.title)
						slink_flag = true
					else
						citeq_args.title = wrap_nowiki(citeq_args.title)
					end
				else
					if slink and not wslink then
						if slink:lower() == title_display:lower() then
							citeq_args.title = '[[' .. slink .. ']]'
						else
							wrap_title = wrap_nowiki(slink:gsub("%s%(.+%)$", ""):gsub(",.+$", ""))
							slink_flag = true
						end
					elseif wslink then
						wrap_title = wrap_nowiki(title_display)
						slink_flag = true
					else
						citeq_args.title = wrap_nowiki(title_display)
					end
				end
				if slink_flag then
					if slink == wrap_title and not wslink then -- direct link
						citeq_args.title = '[[' .. slink .. ']]'
					else -- piped link
						citeq_args.title = '[[' .. slink .. '|' .. wrap_title .. ']]'
					end
				end
			end
		end
	end

	-- TBD: incorporate |at, |sheets= and |sheet= here as well
	-- Sort out what should happen if several of them are given at the same time
	if citeq_args.page or citeq_args.p then -- let single take precedence over multiple
		citeq_args.pages = nil
		citeq_args.pp = nil
	end
	if citeq_args.pages then
		local _, count = string.gsub(citeq_args.pages, "[,;%s]%d+", "")
		if count == 1 then
			citeq_args.page = citeq_args.pages
			citeq_args.pages = nil
		end
	end

	if is_set (qid) then
		if not is_set (citeq_args.author) and not is_set (citeq_args.author1)
			and not is_set (citeq_args.subject) and not is_set (citeq_args.subject1)
			and not is_set (citeq_args.host) and not is_set (citeq_args.host1)
			and not is_set (citeq_args.last) and not is_set (citeq_args.last1)
			and not is_set (citeq_args.surname) and not is_set (citeq_args.surname1)
			and not is_set (citeq_args['author-last']) and not is_set (citeq_args['author-last1']) and not is_set (citeq_args['author1-last'])
			and not is_set (citeq_args['author-surname']) and not is_set (citeq_args['author-surname1']) and not is_set (citeq_args['author1-surname1']) then	-- if neither are set, try to get authors from Wikidata
			get_name_list ('author', citeq_args, qid, wdl)				-- modify citeq_args table with authors from Wikidata
		end

		if not is_set (citeq_args.editor) and not is_set (citeq_args.editor1)
			and not is_set (citeq_args['editor-last']) and not is_set (citeq_args['editor-last1']) and not is_set (citeq_args['editor1-last'])
			and not is_set (citeq_args['editor-surname']) and not is_set (citeq_args['editor-surname1']) and not is_set (citeq_args['editor1-surname']) then	-- if neither are set, try to get editors from Wikidata
			get_name_list ('editor', citeq_args, qid, wdl)				-- modify citeq_args table with editors from Wikidata
		end

		if not is_set (citeq_args.translator) and not is_set (citeq_args.translator1)
			and not is_set (citeq_args['translator-last']) and not is_set (citeq_args['translator-last1']) and not is_set (citeq_args['translator1-last'])
			and not is_set (citeq_args['translator-surname']) and not is_set (citeq_args['translator-surname1']) and not is_set (citeq_args['translator1-surname']) then	-- if neither are set, try to get translators from Wikidata
			get_name_list ('translator', citeq_args, qid, wdl)			-- modify citeq_args table with translators from Wikidata
		end
	end

	for k, v in pairs(citeq_args) do
		if in_array (v, {'(())', 'unset', 'ignore'}) or 'string' ~= type(k) then -- empty accept-as-is-written (()) markup to indicate an empty/unused parameter value, other ((...)) markups are deliberately passed down to {{citation}}
			citeq_args[k] = nil
		elseif in_array (v, {'((unset))', '((ignore))'}) then -- strip off markup for free-text values clashing with local keywords
			citeq_args[k] = 'unset'
		end
	end

	local author_count = 0
	for k, v in pairs(citeq_args) do
		if k:find("^author%d+$") then
			author_count = author_count + 1
		end
	end
	if author_count > 8 then -- convention in astronomy journals, optional mode for this?
		if 'all' == citeq_args['display-authors'] then
			citeq_args['display-authors'] = nil;								-- unset because no longer needed
		else
			citeq_args['display-authors'] = citeq_args['display-authors'] or 3	-- limit to three displayed names
		end
	end

	local editor_count = 0
	for k, v in pairs(citeq_args) do
		if k:find("^editor%d+$") then
			editor_count = editor_count + 1
		end
	end
	if editor_count > 8 then -- convention in astronomy journals, optional mode for this?
		if 'all' == citeq_args['display-editors'] then
			citeq_args['display-editors'] = nil;								-- unset because no longer needed
		else
			citeq_args['display-editors'] = citeq_args['display-editors'] or 3	-- limit to three displayed names
		end
	end

	-- change edition to ordinal if it's set and numeric
	citeq_args.edition = citeq_args.edition and makeOrdinal(citeq_args.edition)

	-- code to make a guess what template to use from the supplied parameters
	-- (first draft for proof-of-concept)
	if citeq_args.isbn then
		template = template or "book"
		citeq_args.asin = nil -- suppress ASIN if ISBN exists
	elseif citeq_args.journal then
		template = template or "journal"
	elseif citeq_args.website then
		template = template or "web"
	end

	-- |id= could hold more than one identifier pulled from Wikidata not supported by {{citation}}, right now only add our qid to the list
	local list_sep = '. '
	if citeq_args.mode ~= 'cs1' then
		list_sep = ', '
	end
	local id = cfg.i18n_t.wdq.. '&nbsp;[[:d:' .. qid .. '|' .. qid .. ']]' 
	local old_id = citeq_args.id
	if wdl then -- show WD logo
		id = id .. '[[File:Wikidata-logo.svg|16px|alt=|link=]]' -- possibly replace by WD edit icon?
	end
	if is_set (old_id) then
		citeq_args.id = old_id .. list_sep .. id -- append to user-specified contents
	else
		citeq_args.id = id
	end

	-- clean up any blank parameters
	for k, v in pairs(citeq_args) do
		if v == "" then citeq_args[k] = nil end
	end

	-- if |expand=<anything>, write a nowiki'd version to see what the {{citation}} template call looks like
	if expand then
		
		local expand_args = { "{{" .. (template and ("Cite "..template) or "Citation") }	-- init with citation template
		if expand == "self" then
			citeq_args.id = old_id -- restore original |id= parameter
			expand_args = { cfg.i18n_t.cite_q .. qid } -- expand to itself
		end
		-- make a sortable table and sort it by param name
		local sorttable = {}
		for param, val in pairs (citeq_args) do
			table.insert(sorttable, {param, val})
		end
		table.sort(sorttable, comp_key)
		-- add contents to expand_args
		for idx, val in ipairs(sorttable) do
			table.insert(expand_args, val[1] .. '=' .. val[2])
		end
		-- make the nowiki'd string and done
		return frame:preprocess (table.concat ({'<syntaxhighlight lang="wikitext" inline="1">', table.concat (expand_args, ' |') .. '}}', '</syntaxhighlight>'}));
	end

	local erratumid = getPropertyIDs( { "P2507", qid = qid, fwd = "ALL", osd = "no", rank = "best", maxvals = 1 } )
	if erratumid then
		erratumid = " [[d:" .. erratumid .. "|" .. cfg.i18n_t.erratum .. "]]" .. cfg.i18n_t.trackingcats.erratum
	else
		erratumid = ""
	end

	local opt_cat = ''
	if getValue( {"P5824", ps = 1, qid = qid} ) then
		opt_cat = cfg.i18n_t.trackingcats.retracted
	end
	if getValue( {"P1366", ps = 1, qid = qid} ) then
		opt_cat = opt_cat .. cfg.i18n_t.trackingcats.replaced
	end
	if not citeq_args.title then												-- emit category link if missing title
		opt_cat = opt_cat .. cfg.i18n_t.trackingcats['no-label-or-title'];
	end
	
	-- render the template
	local lc_template = template and template:lower() or "citation"
	local output
	if cite_cfg.known_templates_t[lc_template] then
		local config_t = {['CitationClass'] = cite_cfg.citation_classes_t[lc_template] or lc_template};	-- set CitationClass value
		output = require (cs1_module)._citation (nil, citeq_args, config_t)	-- go render the citation
	else
		output = frame:expandTemplate{											-- render the template
			title = "Cite "..template, args = citeq_args
		} .. cfg.i18n_t.trackingcats["unknown-template"]
	end
	return output .. erratumid .. opt_cat
end

local function cite_q (frame)
	local args = {}
	for k, v in pairs(frame:getParent().args) do
		if v ~= "" then args[k] = v end
	end
	for k, v in pairs(frame.args) do
		if v ~= "" then args[k] = v end
	end
	args.qid = args.qid or args[1] or ""
	if args.qid == "" then return nil end
	args[1] = nil

	local citesep = (args.citesep or "")
	if citesep == "" then citesep = ", " end
	citesep = citesep:gsub('"', '') -- strip double quotes after setting default to allow |citesep="" as a blank separator
	args.citesep = nil

	local tag = args.tag or ""
	if tag == "" then tag = nil end
	args.tag = nil

	local list = args.list or ""
	if list == "" then list = nil end
	args.list = nil

	args.language = args.language or args.lang
	args.lang = nil

	local cites = {}
	for q in args.qid:gmatch("Q%d+") do
		-- make a new copy of the arguments
		local newargs = {}
		for k, v in pairs(args) do
			if k ~= "qid" then
				newargs[k] = v
			end
		end
		newargs.qid = q
		if tag == "ref" then
			cites[#cites + 1] = frame:callParserFunction{ name = "#tag:ref", args = { _cite_q(newargs), name = q } }
			-- expand like this: args = { _cite_q(newargs), name = 'foo', group = 'bar' }
		else
			cites[#cites + 1] = _cite_q(newargs)
		end
	end

	if list then
		return frame:expandTemplate{ title = list, args = cites }
	else
		return table.concat(cites, citesep)
	end
end

--[[--------------------------< E X P O R T E D   F U N C T I O N S >------------------------------------------
]]

return {
	makeOrdinal = makeOrdinal,
	_getLangOfProp = _getLangOfProp,
	getLangOfProp = getLangOfProp,
	lang_code = lang_code,
	getPropOfProp = getPropOfProp,
	_cite_q = _cite_q,
	cite_q = cite_q
}
