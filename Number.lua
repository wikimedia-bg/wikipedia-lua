--[[  

This module will provide some helper functions for dealing with numbers.

Unit tests for this module are available at Module:Number/testcases.
]]

local p = {}

function p.tonumber(frame)
	if not getArgs then
		getArgs = require('Module:Arguments').getArgs
	end
	args = getArgs(frame)
	return stringToNumber( args[1] )
end

function p.stringToNumber(str)
	return tonumber( str:gsub(' ', ''):gsub( string.char(160), '' ):gsub(',', '.'), 10 )
end

return p
