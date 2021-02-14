local p = {}

local pref = '[[File:Cyrillic '
local suff1 = ' Lazov.svg|x'
local suff2 = 'px|sub]]'

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
	local fsiz = frame.args[2]
	if ( fsiz == nil or fsiz == '' ) then fsiz = '20' end
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
			ostr = ostr .. pref .. case .. lookup[l] .. suff1 .. fsiz .. suff2
		end
	end
	return ostr
end

return p
