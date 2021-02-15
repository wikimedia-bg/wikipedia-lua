local p = {}

local pref = '[[File:Cyrillic' .. ' '
local suff1 = ' ' .. 'Lazov.svg|x'
local suff2 = 'px|sub|link=]]'
local spc = '<span style="display: inline-block; width: .5em;"> </span>'

local lookup = {
	['а'] = 'a',
	['б'] = 'be',
	['в'] = 've',
	['г'] = 'ghe',
	['д'] = 'de',
	['є'] = 'ie',
	['е'] = 'ie',
	['ж'] = 'zhe',
	['ѕ'] = 'dze',
	['з'] = 'ze',
	['и'] = 'i',
	['ї'] = 'yi',
	['й'] = 'shorti',
	['к'] = 'ka',
	['л'] = 'el',
	['м'] = 'em',
	['н'] = 'en',
	['о'] = 'o',
	['п'] = 'pe',
	['р'] = 'er',
	['с'] = 'es',
	['т'] = 'te',
	['у'] = 'u',
	['ѹ'] = 'uk',
	['ꙋ'] = 'uk',
	['ф'] = 'ef',
	['х'] = 'ha',
	['w'] = 'omega',
	['ω'] = 'omega',
	['Ѡ'] = 'omega',
	['Ѻ'] = 'roundomega',
	['ц'] = 'tse',
	['ч'] = 'che',
	['ш'] = 'sha',
	['щ'] = 'shcha',
	['ъ'] = 'hardsign',
	['ꙑ'] = 'yeru',
	['ы'] = 'yeru',
	['ь'] = 'softsign',
	['э'] = 'e',
	['ѣ'] = 'yat',
	['ю'] = 'yu',
	['я'] = 'ya',
	['ꙗ'] = 'ya',
	['ѥ'] = 'iotifiede',
	['ѧ'] = 'littleyus',
	['ѩ'] = 'iotifiedlittleyus',
	['ѫ'] = 'bigyus',
	['ѭ'] = 'iotifiedbigyus',
}

function p.render(frame)
	local istr = frame.args[1]
	local ostr = ''
	local fsiz = frame.args[2]
	if ( fsiz == nil or fsiz == '' ) then fsiz = '20' end
	for l in mw.ustring.gmatch(istr, '.') do
		if l == mw.ustring.lower(l) then
			case = 'small' .. ' '
		else
			case = 'capital' .. ' '
			l = mw.ustring.lower(l)
		end
		if lookup[l] ~= nil then
			ostr = ostr .. pref .. case .. lookup[l] .. suff1 .. fsiz .. suff2
		elseif l == ' ' then
			ostr = ostr .. spc
		else
			ostr = ostr .. l
		end
	end
	return ostr
end

return p
