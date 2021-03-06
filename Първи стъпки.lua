--	test module created by user:Gangleri
--	status: 2015-12-25 draft; working as expected

local p = {}
	mw.log()

local libraryUtil = require('libraryUtil')
-- from https://wikimania2015.wikimedia.org/wiki/Module:TableTools i.e. from [[wm2015:Module:TableTools]]
local TableTools = require('Module:TableTools')
-- from https://commons.wikimedia.org/wiki/Module:TableTools i.e. from [[c:Module:TableTools]]

function p.inspect_mw()
	local result = ''
	local dump = ''

	local myobject = mw
    result = result .. ';MW\n'
    result = result .. '\n' .. 'type is: ' .. tostring(type(myobject)) .. '\n\n'
    dump = mw.dumpObject(myobject)
    result = result .. dump
    return result
end

function p.inspect__G()
	local result = ''
	local dump = ''

	local myobject = _G
    result = result .. ';_G\n'
    result = result .. '\n' .. 'type is: ' .. tostring(type(myobject)) .. '\n\n'
    dump = mw.dumpObject(myobject)
    result = result .. dump
    return result
end

return p