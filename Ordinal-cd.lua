--[[  
 
This template will add the appropriate ordinal suffix to a given integer.
 
Please do not modify this code without applying the changes first at Module:Ordinal/sandbox and testing 
at Module:Ordinal/sandbox/testcases and Module talk:Ordinal/sandbox/testcases.
 
Authors and maintainers:
* User:RP88
 
]]
 
-- =======================================
-- === Dependencies ======================
-- =======================================
local i18n       = require('Module:I18n/ordinal')        -- get localized translations of ordinals
local LangSwitch = require('Module:LangSwitch')          -- get LangSwitch function
local yesno      = require('Module:Yesno')               -- boolean value interpretation
local formatnum  = require('Module:Formatnum')           -- number formatting

-- =======================================
-- === Private Functions =================
-- =======================================

--[[
Helper function to generate superscripted content
]]
local function Superscript( str, superscript, nosup, period )
	if superscript and (not nosup) and (str ~= '') then
		return period .. '<sup>' .. str .. '</sup>'
	else
		return str
	end
end

	
--[[
Helper function to call Formatnum.
]]
local function FormatNum( value, lang )
	if lang == 'roman' then
		return require("Module:Roman-cd")._Numeral(value)
	else
		return formatnum.formatNum(value, lang)
	end
end
	
--[[
Helper function to add append a category to a message.
]]
local function output_cat( message, category )
    return message .. '[[Category:' .. category .. ']]'
end

--[[
Helper function to handle error messages.
]]
local function output_error( error_str, value )
	error_str = '<strong class="error"><span title="Error: ' .. error_str .. '">' .. value .. '</span></strong>'
    return output_cat(error_str, 'Errors reported by Module Ordinal');
end

--[[
This function is the core functionality for adding the appropriate ordinal suffix to a given integer.
]]
local function OrdinalCore( value, lang, style, gender, nosup )	
	-- Just in case someone breaks the internationalization code, fix the english scheme
	if i18n.SchemeFromLang['en'] == nil then
		i18n.SchemeFromLang['en'] = 'en-scheme'
	end	
	if i18n.Scheme['en-scheme'] == nil then
		i18n.Scheme['en-scheme'] = {rules = 'skip-tens', superscript = true, suffix = 'th', suffix_1 = 'st', suffix_2 = 'nd', suffix_3 = 'rd'}
	end
	
	-- Add the default scheme (i.e. "<value>.")
	if i18n.SchemeFromLang['default'] == nil then
		i18n.SchemeFromLang['default'] = 'period-scheme'
	end	
	if i18n.Scheme['period-scheme'] == nil then
		i18n.Scheme['period-scheme'] = {rules = 'suffix', suffix = '.'}
	end
		
	-- which scheme should we use to format the ordinal value? 
	-- Use Fallback module to handle languages groups that map to a supported language
	local schemeSpecifier = LangSwitch._langSwitch(i18n.SchemeFromLang, lang)
	
	-- Look up scheme based on scheme specifier (and possibly style)
	local scheme = i18n.Scheme[schemeSpecifier .. '/' .. style] or i18n.Scheme[schemeSpecifier]
	
	-- process scheme by applying rules identified by Scheme
	local output = ''
	local period = (scheme.period and '.') or ''
	local rules = scheme.rules
	if rules == 'skip-tens' then
		local suffix
		local mod100 = math.floor(math.abs(value)) % 100
		if (mod100 >= 10) and (mod100 <= 19) then
			suffix = scheme.suffix or ''
		else
			local mod10 = math.floor(math.abs(value)) % 10
			suffix = scheme['suffix_'..mod10] or scheme.suffix or ''
		end
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'suffix' then
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( scheme.suffix or '', scheme.superscript, nosup, period)
	elseif rules == 'prefix' then
		output = (scheme.prefix or '') .. FormatNum(value, scheme.formatlang or lang)
	elseif rules == 'mod10-suffix' then
		local index = math.floor(math.abs(value)) % 10
		local suffix = scheme['suffix_'..index] or scheme.suffix or ''
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'gendered-suffix' then
		local suffix = scheme['suffix_'..gender] or scheme.suffix or ''
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'gendered-suffix-one' then
		local suffix
		if value == 1 then
			suffix = scheme['suffix_1_'..gender] or scheme['suffix_1'] or scheme.suffix or ''
		else
			suffix = scheme['suffix_'..gender] or scheme.suffix or ''
		end
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'gendered-suffix-n' then
		local suffix
		if value <= 9 then
			suffix = scheme['suffix_'..value..'_'..gender] or scheme['suffix_'..value] or scheme['suffix_'..gender] or scheme.suffix or ''
		else
			suffix = scheme['suffix_'..gender] or scheme.suffix or ''
		end
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'suffix-one' then
		local prefix, suffix
		if value == 1 then
			prefix = scheme['prefix_1'] or scheme.prefix or ''
			suffix = scheme['suffix_1'] or scheme.suffix or ''
		else
			prefix = scheme.prefix or ''
			suffix = scheme.suffix or ''
		end
		output = prefix .. FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'mod10-gendered-suffix-skip-tens' then
		local suffix
		local mod100 = math.floor(math.abs(value)) % 100
		if (mod100 >= 10) and (mod100 <= 19) then
			suffix = scheme['suffix_'..gender] or scheme.suffix or ''
		else
			local mod10 = math.floor(math.abs(value)) % 10
			suffix = scheme['suffix_'..mod10..'_'..gender] or scheme['suffix_'..mod10] or scheme['suffix_'..gender] or scheme.suffix or ''
		end
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	elseif rules == 'uk-rules' then
		local suffix
		local mod100 = math.floor(math.abs(value)) % 100
		local mod1000 = math.floor(math.abs(value)) % 1000
		if (mod1000 == 0) then
			suffix = scheme['suffix_1000_'..gender] or scheme.suffix or ''
		elseif (mod100 == 40) then
			suffix = scheme['suffix_40_'..gender] or scheme.suffix or ''
		elseif (mod100 >= 10) and (mod100 <= 19) then
			suffix = scheme['suffix_'..gender] or scheme.suffix or ''
		else
			local mod10 = math.floor(math.abs(value)) % 10
			suffix = scheme['suffix_'..mod10..'_'..gender] or scheme['suffix_'..mod10] or scheme['suffix_'..gender] or scheme.suffix or ''
		end
		output = FormatNum(value, scheme.formatlang or lang) .. Superscript( suffix, scheme.superscript, nosup, period)
	else
		output = FormatNum(value, lang)
	end 
	
	return output
end

-- =======================================
-- === Public Functions ==================
-- =======================================

local p = {}
--[[
Ordinal
 
This function converts an integer value into a numeral followed by ordinal indicator.  The output string might 
contain HTML tags unless you set nosup=y.
 
Usage:
{{#invoke:Ordinal|Ordinal|1=|lang=|style=|gender=|nosup=|debug=}}
{{#invoke:Ordinal|Ordinal}} - uses the caller's parameters
 
Parameters
    1: Positive integer number. 
    lang: language
    style: Presentation style. Different options for different languages. In English there is "style=d" adding -d suffixes to all numbers.
    gender: Gender is used in French and Polish language versions. Genders: m for male, f for female and n for neuter.	
    nosup: Set nosup=y to display the ordinals without superscript.
    debug: Set debug=y to output error messages.
    
Error Handling:
   Unless debug=y, any error results in parameter 1 being echoed to the output.  This reproduces the behavior of the original Ordinal template.
]]
function p.Ordinal( frame )
	-- if no argument provided than check parent template/module args
	local args = frame.args
	if args[1]==nil then
		args = frame:getParent().args 
	end
	
	--  if we don't have a specified language, attempt to use the user's language
	local lang = args.lang
	if not lang or lang == '' or not mw.language.isValidCode( lang ) then
		lang = frame:preprocess('{{int:lang}}')
	end
	
	local nosup = yesno(args["nosup"] or '', false) -- nosup can be true or false
	local debugging = yesno(args["debug"], false) -- debugging can be nil, true, or false

	-- also enable debugging if debug is unspecified, and "nosup" is false
	debugging = debugging or ((debugging == nil) and not nosup)
		
	local output = p._Ordinal( 
		args[1],  					-- positive integer number
		lang,						-- language
		args["style"],				-- allows to set presentation style
		args["gender"], 			-- allows to specify gender (m, f, or n)
		nosup,						-- set nosup to "y" to suppress superscripts
		debugging					-- Set debug=y to output error messages
	)
	
	-- Add maintenance category
	if (i18n.SchemeFromLang[lang] == nil) and debugging then 
		output = output_cat(output, 'Pages with calls to Module Ordinal using an unsupported language')
	end
	
	return output
end


--[[
This function will add the appropriate ordinal suffix to a given integer. 

Parameters
	input: Numeral as a positive integer or string.
	lang: Language code as a string (e.g. 'en', 'de', etc.).
	style: Presentation style as a string (e.g. 'd', 'roman', etc.).
	gender: Gender as a string ('m', 'f', 'n').  Use empty string '' to leave gender unspecified.
	nosup: Boolean, set to true to force the ordinals to display without superscript.
	debug: Boolean, set to true to output error messages.

Error Handling:
   Unless debug is true, any error results in value being echoed to the output.
]]
function p._Ordinal( input, lang, style, gender, nosup, debugging )	
	local output = input
	
	if input then
		local value = tonumber(input)
		if value and (value > 0) then
		
			-- Normalize style, the style 'roman year' is an alias for 'roman'
			style = string.lower(style or '')
			if style == 'roman year' then
				style = 'roman'
			end
			
			-- Normalize gender parameter
			gender = string.lower(gender or '')
			if (gender ~= 'm') and (gender ~= 'f') and (gender ~= 'n') then
				gender = ''
			end
	
			-- if no language is specified, default to english (caller might want to get user's language)
			if not lang or lang == '' then
				lang = 'en';
			end
			
			output = OrdinalCore( value, lang, style, gender, nosup )
		else
			if debugging then
				output = output_error( "not a number", input )
			end
		end
	else
		if debugging then
			output = output_error( "not a number", '' )
		end
	end
		
	return output
end

return p
