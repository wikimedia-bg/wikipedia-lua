local p = {}

function p.fblist(lang) -- list the full fallback chain from a language to en
	local fbtable = mw.language.getFallbacksFor(lang)
	table.insert(fbtable, 1, lang)
	table.insert(fbtable, 'message')
	table.insert(fbtable, 'default')
	return fbtable
end

function p._langSwitch(args, lang) -- args: table of translations
	-- Return error if there is not default and no English version
	-- otherwise returns the message in the most appropriate, plus the lang code as a second value
	if not args.en and not args.default and not args.message and args.nocat ~= '1' then
		return error("langSwitch error: no default")
	end
	-- get language (either stated one or user's default language)
	if not lang then
		return '<strong class="error">LangSwitch Error: no lang</strong>' -- must become proper error
	end
	-- get the list of acceptable language (lang + those in lang's fallback chain) and check their content
	for i, j in ipairs(p.fblist(lang)) do
		if args[j] then
			if args[j] == '~' then return nil, j end
			if j == 'message' then return tostring(mw.message.new(args[j]):inLanguage(lang)) end -- if this is an interface message
			if args[j] ~= '' then return args[j], j end
		end
	end
	return nil
end

function p.langSwitch(frame) -- version to be used from wikitext
	local args = frame.args
	-- if no expected args provided than check parent template/module args
	if not args.en and not args.default and not args.nocat then
		args = frame:getParent().args
	end
	local lang
	if args.lang and args.lang ~= '' then
		lang = args.lang
		args.lang = nil
	else -- get user's chosen language
		lang = frame:preprocess( "{{int:lang}}" )
	end
	local str, language = p._langSwitch(args, lang)
	return str -- get the first value of the langSwitch, (the text) not the second (the language)
end

function p.fallbackpage(base, lang, formatting)
	local languages = p.fblist(lang)
	for i, lng in ipairs(languages) do
		if mw.title.new(base .. '/' .. lng).exists then
			if formatting == 'table' then
				return {base .. '/' .. lng, lng} -- returns name of the page + name of the language
			else
				return base .. '/' .. lng -- returns only the page
			end
		end
	end
	return base
end

function p.autotranslate(frame) -- logic for [[template:Autotranslate]]
	local args = frame.args
	if not args.lang or args.lang == '' then
		args.lang = frame:preprocess( "{{int:lang}}" )           -- get user's chosen language
	end

	-- find base page
	local base = args.base
	if not base or base == '' then
		return '<strong class="error">Base page not provided for autotranslate</strong>'
	end
	if string.sub(base, 2, 9) ~= 'emplate:' then
		base = 'Template:' .. base   -- base provided without 'Template:' part
	end

	-- find base template language subpage
	local page = p.fallbackpage(base, args.lang) --
	if (not page and base ~= args.base) then
		-- try the original args.base string. This case is only needed if base is not in template namespace
		page = p.fallbackpage(args.base, args.lang)
	end
	if not page then
		return string.format('<strong class="error">no fallback page found for autotranslate (base=[[%s]], lang=%s)</strong>', args.base, args.lang)
	end

	-- repack args in a standard table
	local newargs = {}
	for field, value in pairs(args) do
		if field ~= 'base' then
			newargs[field] = value
		end
	end

	-- Transclude {{page |....}} with template arguments the same as the ones passed to {{autotranslate}} template.
	return frame:expandTemplate{ title = page, args = newargs }
end

function p.translate(page, key, lang) --translate data stored in a module
	if type(page) == 'string' then -- if the requested translation table is not yet loaded
		page = require('Module:' .. page)
	end

	local val
	if page[key] then
		val = page[key]
	elseif page.keys and page.keys[key] then-- key 'keys" is an index of all keys, including redirects, see [[Module:i18n/datatype]]
		val = page.keys[key]
	end
	if not val then
		return '<' .. key .. '>'
	end
	return p._langSwitch(val, lang)
end

function p.translatelua(frame)
	local lang = frame.args.lang
	local page = require('Module:' .. mw.text.trim(frame.args[1])) -- page should only contain a simple of translations
	if not lang or mw.text.trim(lang) == '' then
		lang = frame:preprocess( "{{int:lang}}" )
	end
	if frame.args[2] then
		page = page[mw.text.trim(frame.args[2])]
	end
	return p._langSwitch(page, lang)
end

function p.runTests()
	local toFallbackTest = require('Module:Fallback/tests/fallbacks')
	local result = true

	mw.log('Testing fallback chains')
	for i, t in ipairs(toFallbackTest) do
		local fbtbl = table.concat(p.fblist(t.initial), ', ')
		local expected = table.concat(t.expected, ', ')
		local ret = (fbtbl == expected)
		mw.log(i, ret and 'passed' or 'FAILED', t.initial, (not ret) and ('FAILED\nis >>' .. fbtbl .. '<<\nbut should be >>' .. expected .. '<<\n') or '')
		result = result and ret
	end
	
	return result
end

function p.showTemplateArguments(frame)
-- list all input arguments of the template that calls "{{#invoke:Fallback|showTemplateArguments}}"
	local str = ''
	for name, value in pairs( frame:getParent().args ) do
		if str == '' then
			str = string.format('%s=%s', name, value)          -- argument #1
		else
			str = string.format('%s, %s=%s', str, name, value) -- the rest
		end
	end
	return str
end

return p
