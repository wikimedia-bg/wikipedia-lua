-- Implement [[Template:Time ago]]

local numberSpell, yesno  -- lazy load

function numberSpell(arg)
	numberSpell = require('Module:NumberSpell')._main
	return numberSpell(arg)
end

function yesno(arg)
	yesno = require('Module:Yesno')
	return yesno(arg)
end

local p = {}

-- Table to convert entered text values to numeric values.
local timeText = {
	['seconds'] = 1,
	['minutes'] = 60,
	['hours'] = 3600,
	['days'] = 86400,
	['weeks'] = 604800,
	['months'] = 2629800,  -- 365.25 * 24 * 60 * 60 / 12
	['years'] = 31557600
}

-- Table containing tables of possible units to use in output.
local timeUnits = {
	[1] = { 'second', 'seconds', "second's", "seconds'" },
	[60] = { 'minute', 'minutes', "minutes'", "minutes'" },
	[3600] = { 'hour', 'hours', "hour's", "hours'" },
	[86400] = { 'day', 'days', "day's", "days'" },
	[604800] = { 'week', 'weeks', "week's", "weeks'", unit = 'w' },
	[2629800] = { 'month', 'months', "month's", "months'", unit = 'm'  },
	[31557600] = { 'year', 'years', "year's", "years'", unit = 'y'  }
}


function p._main( args )
	-- Initialize variables
	local lang = mw.language.getContentLanguage()
	local auto_magnitude_num
	local min_magnitude_num
	local magnitude = args.magnitude
	local min_magnitude = args.min_magnitude
	local purge = args.purge

	-- Add a purge link if something (usually "yes") is entered into the purge parameter
	if purge then
		purge = ' <span class="plainlinks">([' .. mw.title.getCurrentTitle():fullUrl('action=purge') .. ' purge])</span>'
	else
		purge = ''
	end

	-- Check that the entered timestamp is valid. If it isn't, then give an error message.
	local success, inputTime = pcall( lang.formatDate, lang, 'xnU', args[1] )
	if not success then
		return '<strong class="error">Error: first parameter cannot be parsed as a date or time.</strong>'
	end

	-- Store the difference between the current time and the inputted time, as well as its absolute value.
	local timeDiff = lang:formatDate( 'xnU' ) - inputTime
	local absTimeDiff = math.abs( timeDiff )

	if magnitude then
		auto_magnitude_num = 0
		min_magnitude_num = timeText[magnitude]
	else
		-- Calculate the appropriate unit of time if it was not specified as an argument.
		local autoMagnitudeData = {
			{ factor = 2, amn = 31557600 },
			{ factor = 2, amn = 2629800 },
			{ factor = 2, amn = 86400 },
			{ factor = 2, amn = 3600 },
			{ factor = 2, amn = 60 }
		}
		for _, t in ipairs( autoMagnitudeData ) do
			if absTimeDiff / t.amn >= t.factor then
				auto_magnitude_num = t.amn
				break
			end
		end
		auto_magnitude_num = auto_magnitude_num or 1
		if min_magnitude then
			min_magnitude_num = timeText[min_magnitude]
		else
			min_magnitude_num = -1
		end
	end

	if not min_magnitude_num then
		-- Default to seconds if an invalid magnitude is entered.
		min_magnitude_num = 1
	end
	local result_num
	local magnitude_num = math.max( min_magnitude_num, auto_magnitude_num )
	local unit = timeUnits[magnitude_num].unit
	if unit and absTimeDiff >= 864000 then
		local Date = require('Module:Date')._Date
		local input = lang:formatDate('Y-m-d H:i:s', args[1])  -- Date needs a clean date
		input = Date(input)
		if input then
			local id
			if input.hour == 0 and input.minute == 0 then
				id = 'currentdate'
			else
				id = 'currentdatetime'
			end
			result_num = (Date(id) - input):age(unit)
		end
	end
	result_num = result_num or math.floor ( absTimeDiff / magnitude_num )

	local punctuation_key, suffix
	if timeDiff >= 0 then -- Past
		if result_num == 1 then
			punctuation_key = 1
		else
			punctuation_key = 2
		end
		if args.ago == '' then
			suffix = ''
		else
			suffix = ' ' .. (args.ago or 'ago')
		end
	else -- Future
		if args.ago == '' then
			suffix = ''
			if result_num == 1 then
				punctuation_key = 1
			else
				punctuation_key = 2
			end
		else
			suffix = ' time'
			if result_num == 1 then
				punctuation_key = 3
			else
				punctuation_key = 4
			end
		end
	end
	local result_unit = timeUnits[ magnitude_num ][ punctuation_key ]

	-- Convert numerals to words if appropriate.
	local spell_out = args.spellout
	local spell_out_max = tonumber(args.spelloutmax)
	local result_num_text
	if spell_out and (
		( spell_out == 'auto' and 1 <= result_num and result_num <= 9 and result_num <= ( spell_out_max or 9 ) ) or
		( yesno( spell_out ) and 1 <= result_num and result_num <= 100 and result_num <= ( spell_out_max or 100 ) )
		)
	then
		result_num_text = numberSpell( result_num )
	else
		result_num_text = tostring( result_num )
	end
	
	-- numeric or string
	local numeric_out = args.numeric
	local result = ""
	if numeric_out then
		result = tostring( result_num )
	else
		result = result_num_text .. ' ' .. result_unit .. suffix -- Spaces for suffix have been added in earlier.
	end

	return result .. purge
end

function p.main( frame )
	local args = require( 'Module:Arguments' ).getArgs( frame, {
		valueFunc = function( k, v )
			if v then
				v = v:match( '^%s*(.-)%s*$' ) -- Trim whitespace.
				if k == 'ago' or v ~= '' then
					return v
				end
			end
			return nil
		end,
		wrappers = 'Template:Time ago'
	})
	return p._main( args )
end

return p
