local p = {}

local getArgs

function p.main(frame)
	if not getArgs then
		getArgs = require('Module:Arguments').getArgs
	end

	local args = getArgs(frame, {wrappers = 'Template:Gapnum'})
	local n = args[1]

	if not n then
		error('Parameter 1 is required')
	elseif not tonumber(n) and not tonumber(n, 36) then -- Validates any number with base ≤ 36
		error('Unable to convert "' .. args[1] .. '" to a number')
	end

	local gap = args.gap
	local precision = tonumber(args.prec)

	return p.gaps(n,{gap=gap,prec=precision})
end

-- Not named p._main so that it has a better function name when required by Module:Val
function p.gaps(n,tbl)
	local nstr = tostring(n)
	if not tbl then
		tbl = {}
	end
	local gap = tbl.gap or '.25em'

	local int_part, frac_part = p.groups(n,tbl.prec)

	local ret = mw.html.create('span')
							:css('white-space','nowrap')
							-- No gap necessary on first group
							:wikitext(table.remove(int_part,1))

	-- Build int part
	for _, v in ipairs(int_part) do
		ret:tag('span')
				:css('margin-left',gap)
				:wikitext(v)
	end

	if frac_part then
		-- The first group after the decimal shouldn't have a gap
		ret:wikitext('.' .. table.remove(frac_part,1))
		-- Build frac part
		for _, v in ipairs(frac_part) do
			ret:tag('span')
					:css('margin-left',gap)
					:wikitext(v)
		end
	end

	return ret
end

-- Creates tables where each element is a different group of the number
function p.groups(num,precision)
	local nstr = tostring(num)
	if not precision then
		precision = -1
	end

	local decimalloc = nstr:find('.', 1, true)
	local int_part, frac_part
	if decimalloc == nil then
		int_part = nstr
	else
		int_part = nstr:sub(1, decimalloc-1)
		frac_part = nstr:sub(decimalloc + 1)
	end
	-- only define ret_i as an empty table, let ret_d stay nil
	local ret_i,ret_d = {}
	-- Loop to handle most of the groupings; from right to left, so that if a group has less than 3 members, it will be the first group
	while int_part:len() > 3 do
		-- Insert in first spot, since we're moving backwards
		table.insert(ret_i,1,int_part:sub(-3))
		int_part = int_part:sub(1,-4)
	end
	-- handle any left over numbers
	if int_part:len() > 0 then
		table.insert(ret_i,1,int_part)
	end

	if precision ~= 0 and frac_part then
		ret_d = {}
		if precision == -1 then
			precision = frac_part:len()
		end
		-- Reduce the length of the string if required precision is less than actual precision
		-- OR
		-- Increase it (by adding 0s) if the required precision is more than actual
		local offset = precision - frac_part:len()
		if offset < 0 then
			frac_part = frac_part:sub(1,precision)
		elseif offset > 0 then
			frac_part = frac_part .. string.rep('0', offset)
		end

		-- Allow groups of 3 or 2 (3 first)
		for v in string.gmatch(frac_part,'%d%d%d?') do
			table.insert(ret_d,v)
		end
		-- Preference for groups of 4 instead of groups of 1 at the end
		if #frac_part % 3 == 1 then
			if frac_part:len() == 1 then
				ret_d = {frac_part}
			else
				local last_g = ret_d[#ret_d] or ''
				last_g = last_g..frac_part:sub(-1)
				ret_d[#ret_d] = last_g
			end
		end
	end

	return ret_i,ret_d
end

return p
