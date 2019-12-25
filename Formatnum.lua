-- This module is intended to replace the functionality of Template:Formatnum and related templates. 
local p = {}

function p.main(frame)
    local args = frame:getParent().args
    local prec    = args.prec or ''
    local sep     = args.sep or ''
    local number  = args[1] or args.number or ''
    local lang    = args[2] or args.lang or ''
    -- validate the language parameter within MediaWiki's caller frame
    if lang == "arabic-indic" then -- only for back-compatibility ("arabic-indic" is not a SupportedLanguage)
        lang = "fa" -- better support than "ks"
    elseif lang == '' or not mw.language.isSupportedLanguage(lang) then
        -- Note that 'SupportedLanguages' are not necessarily 'BuiltinValidCodes', and so they are not necessarily
        -- 'KnownLanguages' (with a language name defined at least in the default localisation of the local wiki).
        -- But they all are ValidLanguageCodes (suitable as Wiki subpages or identifiers: no slash, colon, HTML tags, or entities)
        -- In addition, they do not contain any capital letter in order to be unique in page titles (restriction inexistant in BCP47),
        -- but they may violate the standard format of BCP47 language tags for specific needs in MediaWiki.
        -- Empty/unspecified and unsupported languages are treated here in Commons using the user's language,
        -- instead of the local 'ContentLanguage' of the Wiki.
        lang = frame:callParserFunction( "int", "lang" ) -- get user's chosen language
    end
    return p.formatNum(number, lang, prec, sep ~= '')
end

local digit = { -- substitution of decimal digits for languages not supported by mw.language:formatNum() in core Lua libraries for MediaWiki
    ["ml-old"] = { '൦', '൧', '൨', '൩', '൪', '൫', '൬', '൭', '൮', '൯' },
    ["mn"]     = { '᠐', '᠑', '᠒', '᠓', '᠔', '᠕', '᠖', '᠗', '᠘', '᠙'},
    ["ta"]     = { '௦', '௧', '௨', '௩', '௪', '௫', '௬', '௭', '௮', '௯'},
    ["te"]     = { '౦', '౧', '౨', '౩', '౪', '౫', '౬', '౭', '౮', '౯'},
    ["th"]     = { '๐', '๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙'}
}

function p.formatNum(number, lang, prec, compact)

    -- Do not alter the specified value when it is not a valid number, return it as is
    local value = tonumber(number)
    if value == nil then
        return number
    end
    -- Basic ASCII-only formatting (without paddings)
    number = tostring(value)

    -- Check the presence of an exponent (incorrectly managed in mw.language:FormatNum() and even forgotten due to an internal bug, e.g. in Hindi)
    local exponent
    local pos = string.find(number, '[Ee]')
    if pos ~= nil then
        exponent = string.sub(number, pos + 1, string.len(number))
        number = string.sub(number, 1, pos - 1)
    else
        exponent = ''
    end

    -- Check the minimum precision requested
    prec = tonumber(prec) -- nil if not specified as a true number
    if prec ~= nil then
        prec = math.floor(prec)
        if prec < 0 then
            prec = nil -- discard an incorrect precision (not a positive integer)
        elseif prec > 14 then
            prec = 14 -- maximum precision supported by tostring(number)
        end
    end

    -- Preprocess the minimum precision in the ASCII string
    local dot
    if (prec or 0) > 0 then
        pos = string.find(number, '.', 1, true) -- plain search, no regexp
        if pos ~= nil then
            prec = pos + prec - string.len(number) -- effective number of trailing decimals to add or remove
            dot = '' -- already present
        else
            dot = '.' -- must be added
        end
    else
        dot = '' -- don't add dot
        prec = 0 -- don't alter the precision
    end

    if lang ~= nil and mw.language.isKnownLanguageTag(lang) == true then
        -- Convert number to localized digits, decimal separator, and group separators
        local language = mw.getLanguage(lang)
        if compact then
            number = language:formatNum(tonumber(number), { noCommafy = 'y' }) -- caveat: can load localized resources for up to 20 languages
        else
            number = language:formatNum(tonumber(number)) -- caveat: can load localized resources for up to 20 languages
        end
        -- Postprocessing the precision
        if prec > 0 then
            local zero = language:formatNum(0)
            number = number .. dot .. mw.ustring.rep(zero, prec)
        elseif prec < 0 then
            -- TODO: rounding of last decimal; here only truncate decimals in excess
            number = mw.ustring.sub(number, 1, mw.ustring.len(number) + prec)
        end

        -- Append the localized base-10 exponent without grouping separators (there's no reliable way to detect a localized leading symbol 'E')
        if exponent ~= '' then
            number = number .. 'E' .. language:formatNum(tonumber(exponent),{noCommafy=true})
        end
    else -- not localized, ASCII only
        -- Postprocessing the precision
        if prec > 0 then
            number = number .. dot .. mw.string.rep('0', prec)
        elseif prec < 0 then
            -- TODO: rounding of last decimal; here only truncate decimals in excess
            number = mw.string.sub(number, 1, mw.string.len(number) + prec)
        end

        -- Append the base-10 exponent
        if exponent ~= '' then
            number = number .. 'E' .. exponent
        end
    end

    -- Special cases for substitution of ASCII digits (missing support in Lua core libraries for some languages)
    if digit[lang] then
        for i, v in ipairs(digit[lang]) do
            number = mw.ustring.gsub(number, tostring(i - 1), v)
        end
    end

    return number
end

return p
