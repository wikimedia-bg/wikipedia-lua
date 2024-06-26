local Date = require('Модул:Date')._Date
local p = {}

function p.main(frame)
	local args = frame.args
	local offset = args[1] or 0
	offset = offset + 0
	local year = args[2] or os.date('%Y')
	year = year + 0
	local linked = args[3] or 1
	linked = linked + 1

	local dates =
	{
		[2020] = '19-4',
		[2021] = '2-5',
		[2022] = '24-4',
		[2023] = '16-4',
		[2024] = '5-5',
		[2025] = '20-4',
		[2026] = '12-4',
		[2027] = '2-5',
		[2028] = '16-4',
		[2029] = '8-4',
		[2030] = '28-4',
		[2031] = '13-4',
		[2032] = '2-5',
		[2033] = '24-4',
		[2034] = '9-4',
		[2035] = '29-4',
		[2036] = '20-4',
		[2037] = '5-4',
		[2038] = '25-4',
		[2039] = '17-4',
		[2040] = '6-5',
		[2041] = '21-4',
		[2042] = '13-4',
		[2043] = '3-5',
		[2044] = '24-4',
		[2045] = '9-4',
		[2046] = '29-4',
		[2047] = '21-4',
		[2048] = '5-4',
		[2049] = '25-4',
		[2050] = '17-4',
	}

	local d, m = string.match(dates[year], "(.*)%-(.*)")
	local date = Date(year, m, d) + offset
	local monthmap =
	{
		[1] = 'януари',
		[2] = 'февруари',
		[3] = 'март',
		[4] = 'април',
		[5] = 'май',
		[6] = 'юни',
		[7] = 'юли',
		[8] = 'август',
		[9] = 'септември',
		[10] = 'октомври',
		[11] = 'ноември',
		[12] = 'декември',
	}

	if linked ~= 0 then
		return '[[' .. date.day .. ' ' .. monthmap[date.month] .. ']]'
	else
		return date.day .. ' ' .. monthmap[date.month]
	end
end

return p
