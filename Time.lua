local Time = {}

--Internal functions
--[[
    Validate a time defintion
    @param table definition data
    @return boolean
]]--
function validate( definition )
    --Validate constantes
    if not Time.knowsPrecision( definition.precision ) or ( definition.calendar ~= Time.CALENDAR.GREGORIAN and definition.calendar ~= Time.CALENDAR.JULIAN ) then
        return false
    end

    --Validate year
    if not (type( definition.year ) == 'number' or (definition.year == nil and precision == Time.PRECISION.DAY)) then
        return false
    end
    if definition.precision <= Time.PRECISION.YEAR then
        return true
    end

    --Validate month
    if not validateNumberInRange( definition.month, 1, 12 ) then
        return false
    end
    if definition.precision <= Time.PRECISION.MONTH then
        return true
    end

    --Validate day
    if not validateNumberInRange( definition.day, 1, 31 ) then
        return false
    end
    if definition.precision <= Time.PRECISION.DAY then
        return true
    end

    --Validate hour
    if not validateNumberInRange( definition.hour, 0, 23 ) then
        return false
    end
    if definition.precision <= Time.PRECISION.HOUR then
        return true
    end

    --Validate minute
    if not validateNumberInRange( definition.minute, 0, 59 ) then
        return false
    end
    if definition.precision <= Time.PRECISION.MINUTE then
        return true
    end

    --Validate second
    if not validateNumberInRange( definition.second, 0, 60 ) then
        return false
    end

    return true
end

--[[
    Check if a value is a number in the given range
    @param mixed value
    @param number min
    @param number max
    @return boolean
]]--
function validateNumberInRange( value, min, max )
    return type( value ) == 'number' and value >= min and value <= max
end

--[[
    Try to find the relevant precision for a time definition
    @param table time definition
    @return number the precision
]]--
function guessPrecision( definition )
    if definition.month == nil then
        return Time.PRECISION.YEAR
    elseif definition.day == nil then
        return Time.PRECISION.MONTH
    elseif definition.hour == nil then
        return Time.PRECISION.DAY
    elseif definition.minute == nil then
        return Time.PRECISION.HOUR
    elseif definition.second == nil then
        return Time.PRECISION.MINUTE
    else
        return Time.PRECISION.SECOND
    end
end

--[[
    Try to find the relevant calendar for a time definition
    @param table time definition
    @return string the calendar name
]]--
function guessCalendar( definition )
    if definition.year ~= nil and definition.year < 1583 and definition.precision > Time.PRECISION.MONTH then
        return Time.CALENDAR.JULIAN
    else
        return Time.CALENDAR.GREGORIAN
    end
end

--[[
    Parse an ISO 2061 string and return it as a time definition
    @param string iso the iso datetime
    @param boolean withoutRecurrence concider date in the format XX-XX as year-month and not month-day
    @return table
]]--
function parseIso8601( iso, withoutRecurrence )
    local definition = {}

    --Split date and time
    iso = mw.text.trim( iso:upper() )
    local beginMatch, endMatch, date, time, offset = iso:find( '([%+%-]?[%d%-]+)[T ]?([%d%.:]*)([Z%+%-]?[%d:]*)' )

    if beginMatch ~= 1 or endMatch ~= iso:len() then --iso is not a valid ISO string
        return {}
    end

    --date
    if date ~= nil then
        local isBC = false
        if date:sub( 1, 1 ) == '-' then
            isBC = true
            date = date:sub( 2, date:len() )
        end
        local parts = mw.text.split( date, '-' )
        if not withoutRecurrence and table.maxn( parts ) == 2 and parts[1]:len() == 2 then
            --MM-DD case
            definition.month = tonumber( parts[1] )
            definition.day = tonumber( parts[2] )
        else
            if isBC then
                definition.year = -1 * tonumber( parts[1] ) - 1 --Years BC are counted since 0 and not -1
            else
                definition.year = tonumber( parts[1] )
            end
            definition.month = tonumber( parts[2] )
            definition.day = tonumber( parts[3] )
        end
    end

    --time
    if time ~= nil then
        local parts = mw.text.split( time, ':' )
        definition.hour = tonumber( parts[1] )
        definition.minute = tonumber( parts[2] )
        definition.second = tonumber( parts[3] )
    end

    --ofset
    if offset ~= nil then
        if offset == 'Z' then
            definition.utcoffset = '+00:00'
        else
            definition.utcoffset = offset
        end
    end

    return definition
end

--[[
    Format UTC offset for ISO output
    @param string offset UTC offset
    @return string UTC offset for ISO
]]--
function formatUtcOffsetForIso( offset )
    if offset == '+00:00' then
        return 'Z'
    else
        return offset
    end
end

--[[
    Prepend as mutch as needed the character c to the string str in order to to have a string of length length
    @param mixed str
    @param string c
    @param number length
    @return string
]]--
function prepend(str, c, length)
    str = tostring( str )
    while str:len() < length do
        str = c .. str
    end
    return str
end

--Public interface
--[[
    Build a new Time
    @param table definition definition of the time
    @return Time|nil
]]--
function Time.new( definition )
    --Default values
    if definition.precision == nil then
        definition.precision = guessPrecision( definition )
    end
    if definition.calendar == nil then
        definition.calendar = guessCalendar( definition )
    end

    if not validate( definition ) then
        return nil
    end

    local time = {
        year = definition.year or nil,
        month = definition.month or 1,
        day = definition.day or 1,
        hour = definition.hour or 0,
        minute = definition.minute or 0,
        second = definition.second or 0,
        utcoffset = definition.utcoffset or '+00:00',
        calendar = definition.calendar or Time.CALENDAR.GREGORIAN,
        precision = definition.precision or 0
    }

    setmetatable( time, {
        __index = Time,
        __tostring = function( self ) return self:toString() end
    } )
        
    return time
end

--[[
    Build a new Time from an ISO 8061 datetime
    @param string iso the time as ISO string
    @param boolean withoutRecurrence concider date in the format XX-XX as year-month and not month-day
    @return Time|nil
]]--
function Time.newFromIso8061( iso, withoutRecurrence )
    return Time.new( parseIso8601( iso, withoutRecurrence ) )
end

--[[
    Build a new Time from a Wikidata time value
    @param table wikidataValue the time as represented by Wikidata
    @return Time|nil
]]--
function Time.newFromWikidataValue( wikidataValue )
    local definition = parseIso8601( wikidataValue.time )
    definition.precision = wikidataValue.precision

    if  wikidataValue.calendarmodel == 'http://www.wikidata.org/entity/Q1985727' then
        definition.calendar = Time.CALENDAR.GREGORIAN
    elseif  wikidataValue.calendarmodel == 'http://www.wikidata.org/entity/Q1985786' then
        definition.calendar = Time.CALENDAR.JULIAN
    else
        return nil
    end

    return Time.new( definition )
end

--[[
    Return a Time as a ISO 8061 string
    @return string
]]--
function Time:toIso8061()
    local iso = ''
    if self.year ~= nil then
        if self.year < 0 then
             --Years BC are counted since 0 and not -1
            iso = '-' .. prepend( -1 * self.year - 1, '0', 4 )
        else
            iso = prepend( self.year, '0', 4 )
        end
    end

    --month
    if self.precision < Time.PRECISION.MONTH then
        return iso
    end
    if self.iso ~= '' then
        iso = iso .. '-'
    end
    iso = iso .. prepend( self.month, '0', 2 )

    --day
    if self.precision < Time.PRECISION.DAY then
        return iso
    end
    iso = iso .. '-' .. prepend( self.day, '0', 2 )

    --hour
    if self.precision < Time.PRECISION.HOUR then
        return iso
    end
    iso = iso .. 'T' .. prepend( self.hour, '0', 2 )

    --minute
    if self.precision < Time.PRECISION.MINUTE then
        return iso .. formatUtcOffsetForIso( self.utcoffset )
    end
    iso = iso .. ':' .. prepend( self.minute, '0', 2 )

    --second
    if self.precision < Time.PRECISION.SECOND then
        return iso .. formatUtcOffsetForIso( self.utcoffset )
    end
    return iso .. ':' .. prepend( self.second, '0', 2 ) .. formatUtcOffsetForIso( self.utcoffset )
end

--[[
    Return a Time as a string
    @param mw.language|string|nil language to use. By default the content language.
    @return string
]]--
function Time:toString( language )
    if language == nil then
        language = mw.language.getContentLanguage()
    elseif type( language ) == 'string' then
        language = mw.language.new( language )
    end

    return language:formatDate( 'j F Y', self:toIso8061() )
    --return self:toIso8061()
    --TODO: improve
end

--[[
    Return a Time in HTMl (with a <time> node)
    @param mw.language|string|nil language to use. By default the content language.
    @param table|nil attributes table of attributes to add to the <time> node.
    @return string
]]--
function Time:toHtml( language, attributes )
    if attributes == nil then
        attributes = {}
    end
    attributes['datetime'] = self:toIso8061()
    return mw.text.tag( 'time', attributes, self:toString( language ) )
end

--[[
    All possible precisions for a Time (same ids as Wikibase)
]]--
Time.PRECISION = {
    GY      = 0, --Gigayear
	MY100   = 1, --100 Megayears
	MY10    = 2, --10 Megayears
	MY      = 3, --Megayear
	KY100   = 4, --100 Kiloyears
	KY10    = 5, --10 Kiloyears
	KY      = 6, --Kiloyear
	YEAR100 = 7, --100 years
	YEAR10  = 8, --10 years
	YEAR    = 9,
	MONTH   = 10,
	DAY     = 11,
	HOUR    = 12,
	MINUTE  = 13,
	SECOND  = 14
}

--[[
    Check if the precision is known
    @param number precision ID
    @return boolean
]]--
function Time.knowsPrecision( precision )
	for _,id in pairs( Time.PRECISION ) do
		if id == precision then
			return true
		end
	end
    return false
end

--[[
    Supported calendar models
]]--
Time.CALENDAR = {
	GREGORIAN = 'Gregorian',
	JULIAN    = 'Julian'
}

return Time