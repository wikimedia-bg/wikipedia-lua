-- Module:Transcluder is a general-purpose transclusion engine
-- Documentation and master version: https://en.wikipedia.org/wiki/Module:Transcluder
-- Authors: User:Sophivorus, User:Certes & others
-- License: CC-BY-SA-3.0

local p = {}

-- Helper function to test for truthy and falsy values
-- @todo Somehow internationalize it
local function truthy(value)
	if not value or value == '' or value == 0 or value == '0' or value == 'false' or value == 'no' or value == 'non' then
		return false
	end
	return true
end

-- Helper function to match from a list of regular expressions
-- Like so: match pre..list[1]..post or pre..list[2]..post or ...
local function matchAny(text, pre, list, post, init)
	local match = {}
	for i = 1, #list do
		match = { mw.ustring.match(text, pre .. list[i] .. post, init) }
		if match[1] then return unpack(match) end
	end
	return nil
end

-- Like matchAny but for Category/File links with less overhead
local function matchAnyLink(text, list)
	local match
	for _, v in ipairs(list) do
		match = string.match(text, '%[%[%s*' .. v .. '%s*:.*%]%]')
		if match then break end
	end
	return match
end

-- Helper function to escape a string for use in regexes
local function escapeString(str)
	return string.gsub(str, '[%^%$%(%)%.%[%]%*%+%-%?%%]', '%%%0')
end

-- Helper function to remove a string from a text
local function removeString(text, str)
	local pattern = escapeString(str)
	if #pattern > 9999 then -- strings longer than 10000 bytes can't be put into regexes
		pattern = escapeString(mw.ustring.sub(str, 1, 999)) .. '.-' .. escapeString(mw.ustring.sub(str, -999))
	end
	return string.gsub(text, pattern, '')
end

-- Helper function to convert a comma-separated list of numbers or min-max ranges into a list of booleans
-- @param flags Comma-separated list of numbers or min-max ranges, for example '1,3-5'
-- @return Map from integers to booleans, for example {1=true,2=false,3=true,4=true,5=true}
-- @return Boolean indicating whether the flags should be treated as a blacklist or not
local function parseFlags(value)
	local flags = {}
	local blacklist = false

	if not value then return nil, false end

	if type(value) == 'number' then
		if value < 0 then
			value = -value
			blacklist = true
		end
		flags = { [value] = true }

	elseif type(value) == 'string' then
		if string.sub(value, 1, 1) == '-' then
			blacklist = true
			value = string.sub(value, 2)
		end
		local ranges = mw.text.split(value, ',') -- split ranges: '1,3-5' to {'1','3-5'}
		for _, range in pairs(ranges) do
			range = mw.text.trim(range)
			local min, max = mw.ustring.match(range, '^(%d+)%s*[-–—]%s*(%d+)$') -- '3-5' to min=3 max=5
			if not max then min, max = string.match(range, '^((%d+))$') end -- '1' to min=1 max=1
			if max then
				for i = min, max do flags[i] = true end
			else
				flags[range] = true -- if we reach this point, the string had the form 'a,b,c' rather than '1,2,3'
			end
		end

	-- List has the form { [1] = false, [2] = true, ['c'] = false }
	-- Convert it to { [1] = true, [2] = true, ['c'] = true }
	-- But if ANY value is set to false, treat the list as a blacklist
	elseif type(value) == 'table' then
		for i, v in pairs(value) do
			if v == false then blacklist = true end
			flags[i] = true
		end
	end

	return flags, blacklist
end

-- Helper function to see if a value matches any of the given flags
local function matchFlag(value, flags)
	if not value then return false end
	value = tostring(value)
	local lang = mw.language.getContentLanguage()
	local lcvalue = lang:lcfirst(value)
	local ucvalue = lang:ucfirst(value)
	for flag in pairs(flags) do
		if value == tostring(flag)
		or lcvalue == flag
		or ucvalue == flag
		or ( not tonumber(flag) and mw.ustring.match(value, flag) ) then
			return true
		end
	end
end

-- Helper function to convert template arguments into an array of options fit for get()
local function parseArgs(frame)
	local args = {}
	for key, value in pairs(frame:getParent().args) do args[key] = value end
	for key, value in pairs(frame.args) do args[key] = value end -- args from Lua calls have priority over parent args from template
	return args
end

-- Error handling function
-- Throws a Lua error or returns an empty string if error reporting is disabled
local function throwError(key, value)
	local TNT = require('Module:TNT')
	local ok, message = pcall(TNT.format, 'I18n/Module:Transcluder.tab', 'error-' .. key, value)
	if not ok then message = key end
	error(message, 2)
end

-- Error handling function
-- Returns a wiki friendly error or an empty string if error reporting is disabled
local function getError(key, value)
	local TNT = require('Module:TNT')
	local ok, message = pcall(TNT.format, 'I18n/Module:Transcluder.tab', 'error-' .. key, value)
	if not ok then message = key end
	message = mw.html.create('div'):addClass('error'):wikitext(message)
	return message
end

-- Helper function to get the local name of a namespace and all its aliases
-- @param name Canonical name of the namespace, for example 'File'
-- @return Local name of the namespace and all aliases, for example {'File','Image','Archivo','Imagen'}
local function getNamespaces(name)
	local namespaces = mw.clone(mw.site.namespaces[name].aliases) -- Clone because https://en.wikipedia.org/w/index.php?diff=1056921358
	table.insert(namespaces, mw.site.namespaces[name].name)
	table.insert(namespaces, mw.site.namespaces[name].canonicalName)
	return namespaces
end

-- Get the page wikitext, following redirects
-- Also returns the page name, or the target page name if a redirect was followed, or false if no page was found
-- For file pages, returns the content of the file description page
local function getText(page, noFollow)
	local title = mw.title.new(page)
	if not title then return false, false end

	local target = title.redirectTarget
	if target and not noFollow then title = target end

	local text = title:getContent()
	if not text then return false, title.prefixedText end

	-- Remove <noinclude> tags
	text = string.gsub(text, '<[Nn][Oo][Ii][Nn][Cc][Ll][Uu][Dd][Ee]>.-</[Nn][Oo][Ii][Nn][Cc][Ll][Uu][Dd][Ee]>', '') -- remove noinclude bits

	-- Keep <onlyinclude> tags
	if string.find(text, 'onlyinclude') then -- avoid expensive search if possible
		text = text
			:gsub('</onlyinclude>.-<onlyinclude>', '') -- remove text between onlyinclude sections
			:gsub('^.-<onlyinclude>', '') -- remove text before first onlyinclude section
			:gsub('</onlyinclude>.*', '') -- remove text after last onlyinclude section
	end

	return text, title.prefixedText
end

-- Get the requested files from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of files to return, for example 2 or '1,3-5'. Omit to return all files.
-- @return Sequence of strings containing the wikitext of the requested files.
-- @return Original wikitext minus requested files.
local function getFiles(text, flags)
	local files = {}
	local flags, blacklist = parseFlags(flags)
	local fileNamespaces = getNamespaces('File')
	local name
	local count = 0
	for file in string.gmatch(text, '%b[]') do
		if matchAnyLink(file, fileNamespaces) then
			name = string.match(file, '%[%[[^:]-:([^]|]+)')
			count = count + 1
			if not blacklist and ( not flags or flags[count] or matchFlag(name, flags) )
			or blacklist and flags and not flags[count] and not matchFlag(name, flags) then
				table.insert(files, file)
			else
				text = removeString(text, file)
			end
		end
	end

	return files, text
end

-- Get the requested tables from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of tables to return, for example 2 or '1,3-5'. Omit to return all tables.
-- @return Sequence of strings containing the wikitext of the requested tables.
-- @return Original wikitext minus requested tables.
local function getTables(text, flags)
	local tables = {}
	local flags, blacklist = parseFlags(flags)
	local id
	local count = 0
	for t in string.gmatch('\n' .. text, '\n%b{}') do
		if string.sub(t, 1, 3) == '\n{|' then
			id = string.match(t, '\n{|[^\n]-id%s*=%s*["\']?([^"\'\n]+)["\']?[^\n]*\n')
			count = count + 1
			if not blacklist and ( not flags or flags[count] or flags[id] )
			or blacklist and flags and not flags[count] and not flags[id] then
				table.insert(tables, t)
			else
				text = removeString(text, t)
			end
		end
	end
	return tables, text
end

-- Get the requested templates from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of templates to return, for example 2 or '1,3-5'. Omit to return all templates.
-- @return Sequence of strings containing the wikitext of the requested templates.
-- @return Original wikitext minus requested templates.
local function getTemplates(text, flags)
	local templates = {}
	local flags, blacklist = parseFlags(flags)
	local name
	local count = 0
	for template in string.gmatch(text, '{%b{}}') do
		if string.sub(template, 1, 3) ~= '{{#' then -- skip parser functions like #if
			name = mw.text.trim( string.match(template, '{{([^}|\n]+)') or "" ) -- get the template name
			if name ~= "" then
				count = count + 1
				if not blacklist and ( not flags or flags[count] or matchFlag(name, flags) )
				or blacklist and flags and not flags[count] and not matchFlag(name, flags) then
					table.insert(templates, template)
				else
					text = removeString(text, template)
				end
			end
		end
	end
	return templates, text
end

-- Get the requested template parameters from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of parameters to return, for example 2 or '1,3-5'. Omit to return all parameters.
-- @return Map from parameter name to value, NOT IN THE ORIGINAL ORDER
-- @return Original wikitext minus requested parameters.
-- @return Order in which the parameters were parsed.
local function getParameters(text, flags)
	local parameters, parameterOrder = {}, {}
	local flags, blacklist = parseFlags(flags)
	local params, count, parts, key, value
	for template in string.gmatch(text, '{%b{}}') do
		params = string.match(template, '{{[^|}]-|(.*)}}')
		if params then
			count = 0
			-- Temporarily replace pipes in subtemplates and links to avoid chaos
			for subtemplate in string.gmatch(params, '{%b{}}') do
				params = string.gsub(params, escapeString(subtemplate), string.gsub(subtemplate, ".", {["%"]="%%", ["|"]="@@:@@", ["="]="@@_@@"}) )
			end
			for link in string.gmatch(params, '%b[]') do
				params = string.gsub(params, escapeString(link), string.gsub(link, ".", {["%"]="%%", ["|"]="@@:@@", ["="]="@@_@@"}) )
			end
			for parameter in mw.text.gsplit(params, '|') do
				parts = mw.text.split(parameter, '=')
				key = mw.text.trim(parts[1])
				if #parts == 1 then
					value = key
					count = count + 1
					key = count
				else
					value = mw.text.trim(table.concat(parts, '=', 2))
				end
				value = string.gsub(string.gsub(value, '@@:@@', '|'), '@@_@@', '=')
				if not blacklist and ( not flags or matchFlag(key, flags) )
				or blacklist and flags and not matchFlag(key, flags) then
					table.insert(parameterOrder, key)
					parameters[key] = value
				else
					text = removeString(text, parameter)
				end
			end
		end
	end
	return parameters, text, parameterOrder
end

-- Get the requested lists from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of lists to return, for example 2 or '1,3-5'. Omit to return all lists.
-- @return Sequence of strings containing the wikitext of the requested lists.
-- @return Original wikitext minus requested lists.
local function getLists(text, flags)
	local lists = {}
	local flags, blacklist = parseFlags(flags)
	local count = 0
	for list in string.gmatch('\n' .. text .. '\n\n', '\n([*#].-)\n[^*#]') do
		count = count + 1
		if not blacklist and ( not flags or flags[count] )
		or blacklist and flags and not flags[count] then
			table.insert(lists, list)
		else
			text = removeString(text, list)
		end
	end
	return lists, text
end

-- Get the requested paragraphs from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of paragraphs to return, for example 2 or '1,3-5'. Omit to return all paragraphs.
-- @return Sequence of strings containing the wikitext of the requested paragraphs.
-- @return Original wikitext minus requested paragraphs.
local function getParagraphs(text, flags)
	local paragraphs = {}
	local flags, blacklist = parseFlags(flags)

	-- Remove non-paragraphs
	local elements
	local temp = '\n' .. text .. '\n'
	elements, temp = getLists(temp, 0) -- remove lists
	elements, temp = getFiles(temp, 0) -- remove files
	temp = mw.text.trim((temp
		:gsub('\n%b{} *\n', '\n%0\n') -- add spacing between tables and block templates
		:gsub('\n%b{} *\n', '\n') -- remove tables and block templates
		:gsub('\n==+[^=]+==+ *\n', '\n') -- remove section titles
	))

	-- Assume that anything remaining is a paragraph
	local count = 0
	for paragraph in mw.text.gsplit(temp, '\n\n+') do
		if mw.text.trim(paragraph) ~= '' then
			count = count + 1
			if not blacklist and ( not flags or flags[count] )
			or blacklist and flags and not flags[count] then
				table.insert(paragraphs, paragraph)
			else
				text = removeString(text, paragraph)
			end
		end
	end

	return paragraphs, text
end

-- Get the requested categories from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of categories to return, for example 2 or '1,3-5'. Omit to return all categories.
-- @return Sequence of strings containing the wikitext of the requested categories.
-- @return Original wikitext minus requested categories.
local function getCategories(text, flags)
	local categories = {}
	local flags, blacklist = parseFlags(flags)
	local categoryNamespaces = getNamespaces('Category')
	local name
	local count = 0
	for category in string.gmatch(text, '%b[]') do
		if matchAnyLink(category, categoryNamespaces) then
			name = string.match(category, '%[%[[^:]-:([^]|]+)')
			count = count + 1
			if not blacklist and ( not flags or flags[count] or matchFlag(name, flags) )
			or blacklist and flags and not flags[count] and not matchFlag(name, flags) then
				table.insert(categories, category)
			else
				text = removeString(text, category)
			end
		end
	end
	return categories, text
end

-- Get the requested references from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of references to return, for example 2 or '1,3-5'. Omit to return all references.
-- @return Sequence of strings containing the wikitext of the requested references.
-- @return Original wikitext minus requested references.
local function getReferences(text, flags)
	local references = {}

	-- Remove all references, including citations, when 0 references are requested
	-- This is kind of hacky but currently necessary because the rest of the code
	-- doesn't remove citations like <ref name="Foo" /> if Foo is defined elsewhere
	if flags and not truthy(flags) then
		text = string.gsub(text, '<%s*[Rr][Ee][Ff][^>/]*>.-<%s*/%s*[Rr][Ee][Ff]%s*>', '')
		text = string.gsub(text, '<%s*[Rr][Ee][Ff][^>/]*/%s*>', '')
		return references, text
	end

	local flags, blacklist = parseFlags(flags)
	local name
	local count = 0
	for reference in string.gmatch(text, '<%s*[Rr][Ee][Ff][^>/]*>.-<%s*/%s*[Rr][Ee][Ff]%s*>') do
		name = string.match(reference, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?([^"\'>/]+)["\']?[^>]*%s*>')
		count = count + 1
		if not blacklist and ( not flags or flags[count] or matchFlag(name, flags) )
		or blacklist and flags and not flags[count] and not matchFlag(name, flags) then
			table.insert(references, reference)
		else
			text = removeString(text, reference)
			if name then
				for citation in string.gmatch(text, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?' .. escapeString(name) .. '["\']?[^/>]*/%s*>') do
					text = removeString(text, citation)
				end
			end
		end
	end
	return references, text
end

-- Get the lead section from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @return Wikitext of the lead section.
local function getLead(text)
	text = string.gsub('\n' .. text, '\n==.*', '')
	text = mw.text.trim(text)
	if not text then return throwError('lead-empty') end
	return text
end

-- Get the requested sections from the given wikitext.
-- @param text Required. Wikitext to parse.
-- @param flags Range of sections to return, for example 2 or '1,3-5'. Omit to return all sections.
-- @return Sequence of strings containing the wikitext of the requested sections.
-- @return Original wikitext minus requested sections.
local function getSections(text, flags)
	local sections = {}
	local flags, blacklist = parseFlags(flags)
	local count = 0
	local prefix, section, suffix
	for title in string.gmatch('\n' .. text .. '\n==', '\n==+%s*([^=]+)%s*==+') do
		count = count + 1
		prefix, section, suffix = string.match('\n' .. text .. '\n==', '\n()==+%s*' .. escapeString(title) .. '%s*==+(.-)()\n==')
		if not blacklist and ( not flags or flags[count] or matchFlag(title, flags) )
		or blacklist and flags and not flags[count] and not matchFlag(title, flags) then
			sections[title] = section
		else
			text = string.sub(text, 1, prefix) .. string.sub(text, suffix)
			text = string.gsub(text, '\n?==$', '') -- remove the trailing \n==
		end
	end
	return sections, text
end

-- Get the requested section or <section> tag from the given wikitext (including subsections).
-- @param text Required. Wikitext to parse.
-- @param section Required. Title of the section to get (in wikitext), for example 'History' or 'History of [[Athens]]'.
-- @return Wikitext of the requested section.
local function getSection(text, section)
	section = mw.text.trim(section)
	local escapedSection = escapeString(section)
	-- First check if the section title matches a <section> tag
	if string.find(text, '<%s*[Ss]ection%s+begin%s*=%s*["\']?%s*' .. escapedSection .. '%s*["\']?%s*/>') then -- avoid expensive search if possible
		text = mw.text.trim((text
			:gsub('<%s*[Ss]ection%s+end=%s*["\']?%s*'.. escapedSection ..'%s*["\']?%s*/>.-<%s*[Ss]ection%s+begin%s*=%s*["\']?%s*' .. escapedSection .. '%s*["\']?%s*/>', '') -- remove text between section tags
			:gsub('^.-<%s*[Ss]ection%s+begin%s*=%s*["\']?%s*' .. escapedSection .. '%s*["\']?%s*/>', '') -- remove text before first section tag
			:gsub('<%s*[Ss]ection%s+end=%s*["\']?%s*'.. escapedSection ..'%s*["\']?%s*/>.*', '') -- remove text after last section tag
		))
		if text == '' then return throwError('section-tag-empty', section) end
		return text
	end
	local level, text = string.match('\n' .. text .. '\n', '\n(==+)%s*' .. escapedSection .. '%s*==.-\n(.*)')
	if not text then return throwError('section-not-found', section) end
	local nextSection = '\n==' .. string.rep('=?', #level - 2) .. '[^=].*'
	text = string.gsub(text, nextSection, '') -- remove later sections with headings at this level or higher
	text = mw.text.trim(text)
	if text == '' then return throwError('section-empty', section) end
	return text
end

-- Replace the first call to each reference defined outside of the text for the full reference, to prevent undefined references
-- Then prefix the page title to the reference names to prevent conflicts
-- that is, replace <ref name="Foo"> for <ref name="Title of the article Foo">
-- and also <ref name="Foo" /> for <ref name="Title of the article Foo" />
-- also remove reference groups: <ref name="Foo" group="Bar"> for <ref name="Title of the article Foo">
-- and <ref group="Bar"> for <ref>
-- @todo The current regex may fail in cases with both kinds of quotes, like <ref name="Darwin's book">
local function fixReferences(text, page, full)
	if not full then full = getText(page) end
	local refNames = {}
	local refName
	local refBody
	local position = 1
	while position < mw.ustring.len(text) do
		refName, position = mw.ustring.match(text, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?([^"\'>]+)["\']?[^>]*/%s*>()', position)
		if refName then
			refName = mw.text.trim(refName)
			if not refNames[refName] then -- make sure we process each ref name only once
				table.insert(refNames, refName)
				refName = escapeString(refName)
				refBody = mw.ustring.match(text, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?%s*' .. refName .. '%s*["\']?[^>/]*>.-<%s*/%s*[Rr][Ee][Ff]%s*>')
				if not refBody then -- the ref body is not in the excerpt
					refBody = mw.ustring.match(full, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?%s*' .. refName .. '%s*["\']?[^/>]*>.-<%s*/%s*[Rr][Ee][Ff]%s*>')
					if refBody then -- the ref body was found elsewhere
						text = mw.ustring.gsub(text, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?%s*' .. refName .. '%s*["\']?[^>]*/?%s*>', mw.ustring.gsub(refBody, '%%', '%%%%'), 1)
					end
				end
			end
		else
			position = mw.ustring.len(text)
		end
	end
	page = string.gsub(page, '"', '') -- remove any quotation marks from the page title
	text = mw.ustring.gsub(text, '<%s*[Rr][Ee][Ff][^>]*name%s*=%s*["\']?([^"\'>/]+)["\']?[^>/]*(/?)%s*>', '<ref name="' .. page .. ' %1"%2>')
	text = mw.ustring.gsub(text, '<%s*[Rr][Ee][Ff]%s*group%s*=%s*["\']?[^"\'>/]+["\']%s*>', '<ref>')
	return text
end

-- Replace the bold title or synonym near the start of the page by a link to the page
local function linkBold(text, page)
	local lang = mw.language.getContentLanguage()
	local position = mw.ustring.find(text, "'''" .. lang:ucfirst(page) .. "'''", 1, true) -- look for "'''Foo''' is..." (uc) or "A '''foo''' is..." (lc)
		or mw.ustring.find(text, "'''" .. lang:lcfirst(page) .. "'''", 1, true) -- plain search: special characters in page represent themselves
	if position then
		local length = mw.ustring.len(page)
		text = mw.ustring.sub(text, 1, position + 2) .. "[[" .. mw.ustring.sub(text, position + 3, position + length + 2) .. "]]" .. mw.ustring.sub(text, position + length + 3, -1) -- link it
	else -- look for anything unlinked in bold, assumed to be a synonym of the title (e.g. a person's birth name)
		text = mw.ustring.gsub(text, "()'''(.-'*)'''", function(a, b)
			if not mw.ustring.find(b, "%[") and not mw.ustring.find(b, "%{") then -- if not wikilinked or some weird template
				return "'''[[" .. page .. "|" .. b .. "]]'''" -- replace '''Foo''' by '''[[page|Foo]]'''
			else
				return nil -- instruct gsub to make no change
			end
		end, 1) -- "end" here terminates the anonymous replacement function(a, b) passed to gsub
	end
	return text
end

-- Remove non-free files.
-- @param text Required. Wikitext to clean.
-- @return Clean wikitext.
local function removeNonFreeFiles(text)
	local fileNamespaces = getNamespaces('File')
	local fileName
	local fileDescription
	local frame = mw.getCurrentFrame()
	for file in string.gmatch(text, '%b[]') do
		if matchAnyLink(file, fileNamespaces) then
			fileName = 'File:' .. string.match(file, '%[%[[^:]-:([^]|]+)')
			fileDescription, fileName = getText(fileName)
			if fileName then
				if not fileDescription or fileDescription == '' then
					fileDescription = frame:preprocess('{{' .. fileName .. '}}') -- try Commons
				end
				if fileDescription and string.match(fileDescription, '[Nn]on%-free') then
					text = removeString(text, file)
				end
			end
		end
	end
	return text
end

-- Remove any self links
local function removeSelfLinks(text)
	local lang = mw.language.getContentLanguage()
	local page = escapeString(mw.title.getCurrentTitle().prefixedText)
	local ucpage = lang:ucfirst(page)
	local lcpage = lang:lcfirst(page)
	text = text
		:gsub('%[%[(' .. ucpage .. ')%]%]', '%1')
		:gsub('%[%[(' .. lcpage .. ')%]%]', '%1')
		:gsub('%[%[' .. ucpage .. '|([^]]+)%]%]', '%1')
		:gsub('%[%[' .. lcpage .. '|([^]]+)%]%]', '%1')
	return text
end

-- Remove all wikilinks
local function removeLinks(text)
	text = text
		:gsub('%[%[[^%]|]+|([^]]+)%]%]', '%1')
		:gsub('%[%[([^]]+)%]%]', '%1')
		:gsub('%[[^ ]+ ([^]]+)%]', '%1')
		:gsub('%[([^]]+)%]', '%1')
	return text
end

-- Remove HTML comments
local function removeComments(text)
	text = string.gsub(text, '<!%-%-.-%-%->', '')
	return text
end

-- Remove behavior switches, such as __NOTOC__
local function removeBehaviorSwitches(text)
	text = string.gsub(text, '__[A-Z]+__', '')
	return text
end

-- Remove bold text
local function removeBold(text)
	text = string.gsub(text, "'''", '')
	return text
end

-- Main function for modules
local function get(page, options)
	if not options then options = {} end

	-- Make sure the page exists
	if not page then return throwError('no-page') end
	page = mw.text.trim(page)
	if page == '' then return throwError('no-page') end
	local page, hash, section = string.match(page, '([^#]+)(#?)(.*)')
	local text, temp = getText(page, options.noFollow)
	if not temp then return throwError('invalid-title', page) end
	page = temp
	if not text then return throwError('page-not-found', page) end
	local full = text -- save the full text for fixReferences below

	-- Get the requested section
	if truthy(section) then
		text = getSection(text, section)
	elseif truthy(hash) then
		text = getLead(text)
	end

	-- Keep only the requested elements
	local elements
	if options.only then
		if options.only == 'sections' then elements = getSections(text, options.sections) end
		if options.only == 'lists' then elements = getLists(text, options.lists) end
		if options.only == 'files' then elements = getFiles(text, options.files) end
		if options.only == 'tables' then elements = getTables(text, options.tables) end
		if options.only == 'templates' then elements = getTemplates(text, options.templates) end
		if options.only == 'parameters' then elements = getParameters(text, options.parameters) end
		if options.only == 'paragraphs' then elements = getParagraphs(text, options.paragraphs) end
		if options.only == 'categories' then elements = getCategories(text, options.categories) end
		if options.only == 'references' then elements = getReferences(text, options.references) end
		text = ''
		if elements then
			for key, element in pairs(elements) do
				text = text .. '\n' .. element .. '\n'
			end
		end
	end

	-- Filter the requested elements
	if options.sections and options.only ~= 'sections' then elements, text = getSections(text, options.sections) end
	if options.lists and options.only ~= 'lists' then elements, text = getLists(text, options.lists) end
	if options.files and options.only ~= 'files' then elements, text = getFiles(text, options.files) end
	if options.tables and options.only ~= 'tables' then elements, text = getTables(text, options.tables) end
	if options.templates and options.only ~= 'templates' then elements, text = getTemplates(text, options.templates) end
	if options.parameters and options.only ~= 'parameters' then elements, text = getParameters(text, options.parameters) end
	if options.paragraphs and options.only ~= 'paragraphs' then elements, text = getParagraphs(text, options.paragraphs) end
	if options.categories and options.only ~= 'categories' then elements, text = getCategories(text, options.categories) end
	if options.references and options.only ~= 'references' then elements, text = getReferences(text, options.references) end

	-- Misc options
	if truthy(options.fixReferences) then text = fixReferences(text, page, full) end
	if truthy(options.linkBold) and not truthy(section) then text = linkBold(text, page) end
	if truthy(options.noBold) then text = removeBold(text) end
	if truthy(options.noLinks) then text = removeLinks(text) end
	if truthy(options.noSelfLinks) then text = removeSelfLinks(text) end
	if truthy(options.noNonFreeFiles) then text = removeNonFreeFiles(text) end
	if truthy(options.noBehaviorSwitches) then text = removeBehaviorSwitches(text) end
	if truthy(options.noComments) then text = removeComments(text) end

	-- Remove multiple newlines left over from removing elements
	text = string.gsub(text, '\n\n\n+', '\n\n')
	text = mw.text.trim(text)

	return text
end

-- Main invocation function for templates
local function main(frame)
	local args = parseArgs(frame)
	local page = args[1]
	local ok, text = pcall(get, page, args)
	if not ok then return getError(text) end
	return frame:preprocess(text)
end

-- Entry points for templates
function p.main(frame) return main(frame) end

-- Entry points for modules
function p.get(page, options) return get(page, options) end
function p.getText(page, noFollow) return getText(page, noFollow) end
function p.getLead(text) return getLead(text) end
function p.getSection(text, section) return getSection(text, section) end
function p.getSections(text, flags) return getSections(text, flags) end
function p.getParagraphs(text, flags) return getParagraphs(text, flags) end
function p.getParameters(text, flags) return getParameters(text, flags) end
function p.getCategories(text, flags) return getCategories(text, flags) end
function p.getReferences(text, flags) return getReferences(text, flags) end
function p.getTemplates(text, flags) return getTemplates(text, flags) end
function p.getTables(text, flags) return getTables(text, flags) end
function p.getLists(text, flags) return getLists(text, flags) end
function p.getFiles(text, flags) return getFiles(text, flags) end
function p.getError(message, value) return getError(message, value) end

-- Expose handy methods
function p.truthy(value) return truthy(value) end
function p.parseArgs(frame) return parseArgs(frame) end
function p.matchAny(text, pre, list, post, init) return matchAny(text, pre, list, post, init) end
function p.matchFlag(value, flags) return matchFlag(value, flags) end
function p.getNamespaces(name) return getNamespaces(name) end
function p.removeBold(text) return removeBold(text) end
function p.removeLinks(text) return removeLinks(text) end
function p.removeSelfLinks(text) return removeSelfLinks(text) end
function p.removeNonFreeFiles(text) return removeNonFreeFiles(text) end
function p.removeBehaviorSwitches(text) return removeBehaviorSwitches(text) end
function p.removeComments(text) return removeComments(text) end

return p
