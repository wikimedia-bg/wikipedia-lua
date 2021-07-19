local p = {}

local Date = require('Module:Date')._Date

function p.snowflakeToDate(frame)
	local format = frame.args.format or "%B %e, %Y"
	local epoch = tonumber(frame.args.epoch) or 1288834974
	local id_str = frame.args.id_str
	if type(id_str) ~= "string" then error("bad argument #1 (expected string, got " .. type(id_str) .. ")", 2) end
	if type(format) ~= "string" then error("bad argument #2 (expected string, got " .. type(format) .. ")", 2) end
	if type(epoch) ~= "number" then error("bad argument #3 (expected number, got " .. type(epoch) .. ")", 2) end
	local hi, lo = 0, 0
	local hiexp = 1
	local two32 = 2^32
	for c in id_str:gmatch(".") do
		lo = lo * 10 + c
		if lo >= two32 then
			hi, lo = hi * 10^hiexp + math.floor(lo / two32), lo % two32
			hiexp = 1
		else hiexp = hiexp + 1 end
	end
	hi = hi * 10^(hiexp-1)
	local timestamp = math.floor((hi * 1024 + math.floor(lo / 4194304)) / 1000) + epoch
	return os.date(format, timestamp)
end

function p.getDate(frame)
	-- just pass frame directly to snowflakeToDate, this wraps it but the args are the same plus
	if (frame.args.id_str):match("%D") then -- not a number, so return -2
		return -2
	end
	frame.args.format = "%B %e, %Y"
	frame.args.epoch = tonumber(frame.args.epoch) or 1288834974
	local epochdate = Date(os.date("%B %e, %Y", frame.args.epoch))
	local twitterdate = Date(p.snowflakeToDate(frame))
	if twitterdate == epochdate then -- created before epoch, so can't determine the date
		return -1
	end
	local date = Date(frame.args.date) or 0 -- if we error here, then an input of no date causes an error, which is contrary to the entire way {{TwitterSnowflake/datecheck}} works
	return date - twitterdate
end

local function abs_datediff(x)
	if type(x) == 'number' then return math.abs(x) end
	return math.abs(x.age_days)
end

function p.datecheck(frame)
	local args = frame.args
	if not (args.date and args.id_str) then
		error('Must define date and id_str, even if they are blank.')
	end
	local errors = {
		args.error1 or 'Date mismatch of two or more days',
		args.error2 or 'No date, and posted before November 4, 2010',
		args.error3 or 'Invalid id_str'
	}
	if mw.title.getCurrentTitle():inNamespace(0) and args.error_cat then
		for i = 1, 3 do errors[i] = errors[i] .. '[[' .. args.error_cat .. ']]' end
	end
	if not args.date:match('^%s*$') then -- #if:{{{date|}}}
		local testResult = p.getDate{ args = { date = args.date, id_str = args.id_str }}
		if testResult == -2 then return errors[3] end
		if abs_datediff(testResult) > 1 then return errors[1] end
	elseif not args.id_str:match('^%s*$') then
		local testResult = p.getDate{ args = { id_str = args.id_str }}
		if testResult == -1 then return errors[2] end
		if testResult == -2 then return errors[3] end
	end
end

return p
