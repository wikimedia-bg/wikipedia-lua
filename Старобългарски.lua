local p = {}

local pref = '[[File:Cyrillic '
local suff = ' Lazov.svg|x20px|baseline]]'

local lookup = {
	['а'] = 'a',
	['б'] = 'be',
	['в'] = 've',
	['г'] = 'ghe',
	['д'] = 'de',
}

function p.render(frame)
	local istr = frame.args[1]
	local ostr = ''
	for l in mw.ustring.gmatch( istr, '.' ) do
		if l == ' ' then
			ostr = ostr .. ' '
		else
			if l == mw.ustring.lower(l) then
				case = 'small '
			else
				case = 'capital '
				l = mw.ustring.lower(l)
			end
			ostr = ostr .. pref .. case .. lookup[l] .. suff
		end
	end
	return ostr
end

return p
