--[[  
Този модул е все още бета версия (2021)

This module is intended to provide access to basic string functions.

Most of the functions provided here can be invoked with named parameters, 
unnamed parameters, or a mixture.  If named parameters are used, Mediawiki will 
automatically remove any leading or trailing whitespace from the parameter.  
Depending on the intended use, it may be advantageous to either preserve or
remove such whitespace.

Global options
    ignore_errors: If set to 'true' or 1, any error condition will result in 
        an empty string being returned rather than an error message.  
        
    error_category: If an error occurs, specifies the name of a category to 
        include with the error message.  The default category is  
        [Category:Errors reported by Module String].
        
    no_category: If set to 'true' or 1, no category will be added if an error
        is generated.
        
Unit tests for this module are available at Module:String/tests.
]]

local p = {}

--[[
Helper function that populates the argument list given that user may need to use a mix of
named and unnamed parameters.  This is relevant because named parameters are not
identical to unnamed parameters due to string trimming, and when dealing with strings
we sometimes want to either preserve or remove that whitespace depending on the application.
]]
function p.getParameters( frame_args, arg_list )
    local new_args = {};
    local index = 1;
    local value;
    
    for i,arg in ipairs( arg_list ) do
        value = frame_args[arg]
        if value == nil then
            value = frame_args[index];
            index = index + 1;
        end
        new_args[arg] = value;
    end
    
    return new_args;
end        

--[[
Helper Function to interpret boolean strings
]]
function p.getBoolean( boolean_str )
    local boolean_value;
    
    if type( boolean_str ) == 'string' then
        boolean_str = boolean_str:lower();
        if boolean_str == 'false' or boolean_str == 'no' or boolean_str == '0' 
                or boolean_str == '' then
            boolean_value = false;
        else
            boolean_value = true;
        end    
    elseif type( boolean_str ) == 'boolean' then
        boolean_value = boolean_str;
    else
        error( 'No boolean value found' );
    end    
    return boolean_value
end

function p.defined(frame)
	local arg = mw.text.trim(frame.args[1])
	--if arg == tostring(tonumber(arg)) then -- undesired result for '-0'
	--	arg = tonumber(arg)
	--end
	--if mw.ustring.find(arg, '^%s*-?[1-9][0-9]*%s*$') ~= nil or arg == '0' then
	--	arg = tonumber(arg)
	--end
	if mw.ustring.find(arg, '^-?[1-9][0-9]*$') ~= nil then
		arg = tonumber(arg)
	elseif arg == '0' then
		arg = 0
	end
	return frame:getParent().args[arg] ~= nil
end

return p
