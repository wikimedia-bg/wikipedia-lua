-- This module takes positional parameters as input and concatenates them with
-- an optional separator. The final separator (the "conjunction") can be
-- specified independently, enabling natural-language lists like
-- "foo, bar, baz and qux". The starting parameter can also be specified.

local compressSparseArray = require('Module:TableTools').compressSparseArray
local p = {}

function p._main(args)
	local separator = args.separator
		-- Decode (convert to Unicode) HTML escape sequences, such as "&#32;" for space.
		and mw.text.decode(args.separator) or ''
	local conjunction = args.conjunction and mw.text.decode(args.conjunction) or separator
	-- Discard values before the starting parameter.
	local start = tonumber(args.start)
	if start then
		for i = 1, start - 1 do args[i] = nil end
	end
	-- Discard named parameters.
	local values = compressSparseArray(args)
	return mw.text.listToText(values, separator, conjunction)
end

local function makeInvokeFunction(separator, conjunction, first)
	return function (frame)
		local args = require('Module:Arguments').getArgs(frame)
		args.separator = separator or args.separator
		args.conjunction = conjunction or args.conjunction
		args.first = first or args.first
		return p._main(args)
	end
end

p.main = makeInvokeFunction()
p.br = makeInvokeFunction('<br />')
p.comma = makeInvokeFunction(mw.message.new('comma-separator'):plain())

return p
