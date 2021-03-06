--[[

This module provides a number of basic mathematical operations.

]]
local z = {}

-- Generate random number
function z.random( frame )
    first = tonumber(frame.args[1]) -- if it doesn't exist it's NaN, if not a number it's nil
    second = tonumber(frame.args[2])

    if first then -- if NaN or nil, will skip down to final return
        if first <= second then -- could match if both nil, but already checked that first is a number in last line
            return math.random(first, second)
        end
        return math.random(first)
    end   
    return math.random()
end

--[[
order

Determine order of magnitude of a number

Usage:
    {{#invoke: Math | order | value }}
]]
function z.order(frame)
    local input_string = (frame.args[1] or frame.args.x or '0');
    local input_number;
    
    input_number = z._cleanNumber( frame, input_string );
    if input_number == nil then
        return '<strong class="error">Formatting error: Order of magnitude input appears non-numeric</strong>'
    else
        return z._order( input_number )
    end    
end
function z._order(x)
    if x == 0 then return 0 end
    return math.floor(math.log10(math.abs(x)))
end

--[[
precision

Detemines the precision of a number using the string representation

Usage:
    {{ #invoke: Math | precision | value }}
]]
function z.precision( frame )
    local input_string = (frame.args[1] or frame.args.x or '0');
    local trap_fraction = frame.args.check_fraction or false;
    local input_number;
    
    if type( trap_fraction ) == 'string' then
        trap_fraction = trap_fraction:lower();
        if trap_fraction == 'false' or trap_fraction == '0' or
                trap_fraction == 'no' or trap_fraction == '' then
            trap_fraction = false;
        else
            trap_fraction = true;
        end
    end
    
    if trap_fraction then
        local pos = string.find( input_string, '/', 1, true );
        if pos ~= nil then
            if string.find( input_string, '/', pos + 1, true ) == nil then
                local denominator = string.sub( input_string, pos+1, -1 );
                local denom_value = tonumber( denominator );
                if denom_value ~= nil then
                    return math.log10(denom_value);
                end
            end                        
        end
    end    
    
    input_number, input_string = z._cleanNumber( frame, input_string );
    if input_string == nil then
        return '<strong class="error">Formatting error: Precision input appears non-numeric</strong>'
    else
        return z._precision( input_string )
    end    
end
function z._precision( x )    
    x = string.upper( x )

    local decimal = string.find( x, '.', 1, true )
    local exponent_pos = string.find( x, 'E', 1, true )
    local result = 0;
    
    if exponent_pos ~= nil then
        local exponent = string.sub( x, exponent_pos + 1 )
        x = string.sub( x, 1, exponent_pos - 1 )
        result = result - tonumber( exponent )
    end    
    
    if decimal ~= nil then
        result = result + string.len( x ) - decimal
        return result
    end
        
    local pos = string.len( x );
    while x:byte(pos) == string.byte('0') do
        pos = pos - 1
        result = result - 1
        if pos <= 0 then
            return 0
        end
    end
    
    return result
end

--[[
max

Finds the maximum argument

Usage:
    {{#invoke:Math| max | value1 | value2 | ... }}
OR
    {{#invoke:Math| max }}

When used with no arguments, it takes its input from the parent
frame.  Note, any values that do not evaluate to numbers are ignored.
]]
function z.max( frame )
    local args = frame.args;
    
    if args[1] == nil then
        local parent = frame:getParent();
        args = parent.args;
    end
    local max_value = nil;
    
    local i = 1;
    while args[i] ~= nil do
        local val = z._cleanNumber( frame, args[i] );
        if val ~= nil then
            if max_value == nil or val > max_value then
                max_value = val;
            end
        end        
        i = i + 1;
    end
  
    return max_value
end

--[[
min 

Finds the minimum argument

Usage:
    {{#invoke:Math| min | value1 | value2 | ... }}
OR
    {{#invoke:Math| min }}

When used with no arguments, it takes its input from the parent
frame.  Note, any values that do not evaluate to numbers are ignored.
]]
function z.min( frame )
    local args = frame.args;
    
    if args[1] == nil then
        local parent = frame:getParent();
        args = parent.args;
    end
    local min_value = nil;
    
    local i = 1;
    while args[i] ~= nil do
        local val = z._cleanNumber( frame, args[i] );
        if val ~= nil then
            if min_value == nil or val < min_value then
                min_value = val;
            end
        end        
        i = i + 1;
    end
  
    return min_value
end

--[[
average 
 
Finds the average
 
Usage:
    {{#invoke:Math| average | value1 | value2 | ... }}
OR
    {{#invoke:Math| average }}
 
When used with no arguments, it takes its input from the parent
frame.  Note, any values that do not evaluate to numbers are ignored.
]]
function z.average( frame )
    local args = frame.args;
    if args[1] == nil then
        local parent = frame:getParent();
        args = parent.args;
    end
    local sum = 0;
    local count = 0;
 
    local i = 1;
    while args[i] ~= nil do
        local val = z._cleanNumber( frame, args[i] );
        if val ~= nil then
            sum = sum + val
            count = count + 1
        end        
        i = i + 1;
    end
 
    return (count == 0 and 0 or sum/count)
end

--[[
sum
 
Finds the sum
 
Usage:
    {{#invoke:Math| sum | value1 | value2 | ... }}
OR
    {{#invoke:Math| sum }}
 
When used with no arguments, it takes its input from the parent
frame.  Note, any values that do not evaluate to numbers are ignored.
]]
function z.sum( frame )
    local args = frame.args;
    if args[1] == nil then
        local parent = frame:getParent();
        args = parent.args;
    end
    local sum = 0;
 
    local i = 1;
    while args[i] ~= nil do
        local val = z._cleanNumber( frame, args[i] );
        if val ~= nil then
            sum = sum + val
        end        
        i = i + 1;
    end
 
    return sum
end

--[[
round

Rounds a number to specified precision

Usage:
    {{#invoke:Math | round | value | precision }}
    
--]]
function z.round(frame)
    local value, precision;
    
    value = z._cleanNumber( frame, frame.args[1] or frame.args.value or 0 );
    precision = z._cleanNumber( frame, frame.args[2] or frame.args.precision or 0 );
    
    if value == nil or precision == nil then
        return '<strong class="error">Formatting error: Round input appears non-numeric</strong>'
    else
        return z._round( value, precision );
    end    
end
function z._round( value, precision )
    local rescale = math.pow( 10, precision );
    return math.floor( value * rescale + 0.5 ) / rescale;
end

--[[
precision_format

Rounds a number to the specified precision and formats according to rules 
originally used for {{template:Rnd}}.  Output is a string.

Usage:
    {{#invoke: Math | precision_format | number | precision }}
]]
function z.precision_format( frame )
    -- For access to Mediawiki built-in formatter.
    local lang = mw.getContentLanguage();
    
    local value_string, value, precision;
    value, value_string = z._cleanNumber( frame, frame.args[1] or 0 );
    precision = z._cleanNumber( frame, frame.args[2] or 0 );
    
    -- Check for non-numeric input
    if value == nil or precision == nil then
        return '<strong class="error">Formatting error: invalid input when rounding</strong>'
    end
    
    local current_precision = z._precision( value );

    local order = z._order( value );
    
    -- Due to round-off effects it is neccesary to limit the returned precision under
    -- some circumstances because the terminal digits will be inaccurately reported.
    if order + precision >= 14 then
        orig_precision = z._precision( value_string );
        if order + orig_precision >= 14 then
            precision = 13 - order;        
        end        
    end

    -- If rounding off, truncate extra digits
    if precision < current_precision then
        value = z._round( value, precision );
        current_precision = z._precision( value );
    end    
    
    local formatted_num = lang:formatNum( math.abs(value) );
    local sign;
    
    -- Use proper unary minus sign rather than ASCII default
    if value < 0 then
        sign = '−';
    else
        sign = '';
    end    
        
    -- Handle cases requiring scientific notation
    if string.find( formatted_num, 'E', 1, true ) ~= nil or math.abs(order) >= 9 then
        value = value * math.pow( 10, -order );
        current_precision = current_precision + order;
        precision = precision + order;
        formatted_num = lang:formatNum( math.abs(value) );
    else
        order = 0;        
    end
    formatted_num = sign .. formatted_num;
    
    -- Pad with zeros, if needed    
    if current_precision < precision then
        local padding;
        if current_precision <= 0 then
            if precision > 0 then
                local zero_sep = lang:formatNum( 1.1 );
                formatted_num = formatted_num .. zero_sep:sub(2,2);

                padding = precision;
                if padding > 20 then
                    padding = 20;
                end
                
                formatted_num = formatted_num .. string.rep( '0', padding );
            end            
        else                   
            padding = precision - current_precision
            if padding > 20 then
                padding = 20;
            end
            formatted_num = formatted_num .. string.rep( '0', padding );
        end
    end

    -- Add exponential notation, if necessary.
    if order ~= 0 then
        -- Use proper unary minus sign rather than ASCII default
        if order < 0 then
            order = '−' .. lang:formatNum( math.abs(order) );
        else
            order = lang:formatNum( order );
        end    
        
        formatted_num = formatted_num .. '<span style="margin:0 .15em 0 .25em">×</span>10<sup>' .. order .. '</sup>'
    end
    
    return formatted_num;
end

--[[
Helper function that interprets the input numerically.  If the 
input does not appear to be a number, attempts evaluating it as
a parser functions expression.
]]

function z._cleanNumber( frame, number_string )
    if number_string == nil or number_string:len() == 0 then
        return nil, nil;
    end    
    
    -- Evaluate comma as decimal separator
    number_string = mw.ustring.gsub( number_string, ',', '.', 1 );
    
    -- Attempt basic conversion
    local number = tonumber( number_string )
        
    -- If failed, attempt to evaluate input as an expression
    if number == nil then        
        local attempt = frame:preprocess( '{{#expr: ' .. number_string .. '}}' );
        attempt = tonumber( attempt );
        if attempt ~= nil then
            number = attempt;
            number_string = tostring( number );
        else
            number = nil;
            number_string = nil;
        end
    else
    -- String is valid but may contain padding, clean it.
        number_string = number_string:match( "^%s*(.-)%s*$" );
    end
    
    return number, number_string;
end

return z