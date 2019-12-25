--[[
  __  __           _       _        _                      ____          _ _       _     
 |  \/  | ___   __| |_   _| | ___ _| |    __ _ _ __   __ _/ ___|_      _(_) |_ ___| |__  
 | |\/| |/ _ \ / _` | | | | |/ _ (_) |   / _` | '_ \ / _` \___ \ \ /\ / / | __/ __| '_ \ 
 | |  | | (_) | (_| | |_| | |  __/_| |__| (_| | | | | (_| |___) \ V  V /| | || (__| | | |
 |_|  |_|\___/ \__,_|\__,_|_|\___(_)_____\__,_|_| |_|\__, |____/ \_/\_/ |_|\__\___|_| |_|
                                                     |___/                               
 Authors and maintainers:
* User:Zolo   - original version in Module:Fallback
* User:Jarekt 
]]

local p = {}

--[[
_langSwitch
 
This function is the core part of the LangSwitch template. 
 
Example usage from Lua:
text = _langSwitch({en='text in english', pl='tekst po polsku'}, lang)
 
Parameters:
  args - table with translations by language
  lang - desired language (often user's native language)
 
 Error Handling:
 
]]
local function defaultCheck(args)
	if not args.en and not args.default then
		local err = '<b class="error">LangSwitch Error: no default</b>'
		if args.nocat == '1' then
			return err
		else
			return err .. '[[Category:LangSwitch template without default version]]'
		end
	end
	return false
end


local function quickSwitch(args, arg)
	local err = defaultCheck(args)
	if err then
		return err
	end
	if arg == '~' then
		arg = ''
	end
	return arg
end


function p._langSwitch(args, lang) -- args: table of translations
	-- Return error if there is not default and no english version
	local err = defaultCheck(args)
	if err then
		return err
	end
	-- get the list of accepetable language (lang + those in lang's fallback chain) and check their content
	assert(lang, 'LangSwitch Error: no lang')

	--local langList = {lang}
	--if not args[lang] then
	local langList = mw.language.getFallbacksFor(lang)
	table.insert(langList, 1, lang)
	table.insert(langList, math.max(#langList, 2), 'default')
	--end

	for _, language in ipairs(langList) do
		lang = args[language]
		if lang == '~' then
			return ''
		elseif lang and lang ~= '' then
			return lang
		end
	end
end

--[[
langSwitch
 
This function is the core part of the LangSwitch template. 
 
Example Usage from a template:
{{#invoke:fallback|langSwitch|en=text in english|pl=tekst po polsku|lang={{int:lang}} }}
 
Parameters:
  frame.args - table with translations by language
  frame.args.lang - desired language (often user's native language)
 
 Error Handling:
 
]]
function p.langSwitch(frame) -- version to be used from wikitext
	local args = frame.args
	-- if no expected args provided than check parent template/module args
	if args.en == nil and args.default == nil and args.nocat == nil then
		args = mw.getCurrentFrame():getParent().args
	end

	local lang = args.lang
	if not lang or not mw.language.isSupportedLanguage(lang) then
		lang = frame:callParserFunction("int", "lang") -- get user's chosen language
	end

	-- Try quick switch
	local args1 = args[lang]
	if args1 and args1 ~= '' then
		return quickSwitch(args, args1)
	end

	-- Allow input in format: {{LangSwitch|de=Grün|es/it/pt=Verde|fr=Vert|en=Green |lang=en}}
	-- with multiple languages mapping to a single value
	args1 = {}
	for name, value in pairs(args) do
		if value ~= '' and type(name) == 'string' then
			-- split multi keys
			for str in string.gmatch(name, "([^/]+)") do
				args1[str] = value
			end
		end
	end
	return p._langSwitch(args1, lang)
end

return p
