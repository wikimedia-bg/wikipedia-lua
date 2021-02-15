local p = {}

-- For each letter we build a wiki markup to display the relevant SVG image.
-- The SVG images have names with the following structure:
-- File:Cyrillic [small|capital] <letter name> Lazov.svg
-- Vertical size is set with "xNpx", where N is the default size (see below).
-- Vertical alignment is set to "sub". The generated file link is disabled.
local pref = '[[File:Cyrillic' .. ' '
local suff1 = ' ' .. 'Lazov.svg|x'
local suff2 = 'px|sub|link=]]'

-- Default vertical size of the SVG letters, in pixels ([[File:...|xNpx|...]]).
local vsize_def = '20'

-- The spaces in the input text are replaced with this for better legibility.
local spc = '<span style="display: inline-block; width: .5em;"> </span>'

-- The substitute (lookup) table: ['<input letter>'] = '<letter name>'
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
	['ѡ'] = 'omega',
	['ω'] = 'omega',
	['ѻ'] = 'roundomega',
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
	['ѯ'] = 'ksi',
	['ѱ'] = 'psi',
	['ѳ'] = 'fita',
	['ѵ'] = 'izhitsa',
	['ѷ'] = 'doublegraveaccentizhitsa',
	['ҁ'] = 'koppa',
	['ѿ'] = 'ot',
}

function p.render(frame)
	local istr = frame.args[1]
	local ostr = ''
	local vsize = frame.args[2]
	if ( vsize == nil or vsize == '' ) then vsize = vsize_def end
	for l in mw.ustring.gmatch(istr, '.') do
		if l == mw.ustring.lower(l) then
			case = 'small' .. ' '
		else
			case = 'capital' .. ' '
			l = mw.ustring.lower(l)
		end
		if lookup[l] ~= nil then
			ostr = ostr .. pref .. case .. lookup[l] .. suff1 .. vsize .. suff2
		elseif l == ' ' then
			ostr = ostr .. spc
		else
			ostr = ostr .. l
		end
	end
	return ostr
end

return p
