-- този модул прилага [[Шаблон:Гео координати]]

local geobox_coor = {}

local function isnotempty(s)
	return s and s:match( '^%s*(.-)%s*$' ) ~= ''
end

-- Wrapper function to grab args (from Модул:Координати), 
-- see Module:Arguments for this function's documentation.
local function makeInvokeFunc(funcName)
	return function (frame)
		local args = require('Модул:Arguments').getArgs(frame, {
			wrappers = 'Шаблон:Гео координати'
		})
		return geobox_coor[funcName](args, frame)
	end
end

local function coord_wrapper(frame, in_args)
	frame.args = in_args
	return require('Модул:Координати').coord(frame)
end

geobox_coor.coord = makeInvokeFunc('_coord')

function geobox_coor._coord(args, frame)
	local tstr = args['9'] or 'type:other'
	local dstr = isnotempty(args['title']) and 'inline,title' or 'inline'
	local lat_dir = isnotempty(args[4]) and args[4] or 'N'
	local lon_dir = isnotempty(args[8]) and args[8] or 'E'
	local prefix = args['prefix'] or ''
	local suffix = args['suffix'] or ''
	local innerprefix = args['innerprefix'] or ''
	local innersuffix = args['innersuffix'] or ''
	
	local cstr = ''

	if( isnotempty(args[3]) ) then
		cstr = coord_wrapper(frame,
			{args[1], args[2], args[3], lat_dir, args[5], args[6], args[7], lon_dir, 
				tstr, format = args['format'] or 'dms', display = dstr}
			)
	elseif( isnotempty(args[2]) ) then
		cstr = coord_wrapper(frame,
			{args[1], args[2], lat_dir, args[5], args[6], lon_dir, 
				tstr, format = args['format'] or 'dms', display = dstr}
			)
	elseif( isnotempty(args[4]) ) then
		cstr = coord_wrapper(frame,
			{args[1], lat_dir, args[5], lon_dir, 
				tstr, format = args['format'] or 'dec', display = dstr}
			)
	elseif( isnotempty(args[1]) ) then
		cstr = coord_wrapper(frame,
			{args[1], args[5],
				tstr, format = args['format'] or 'dec', display = dstr}
			)
	elseif( isnotempty(args['wikidata']) and mw.wikibase.getEntityObject()) then
		local entity = mw.wikibase.getEntityObject()
		if(entity and entity.claims	and entity.claims.P625
			and entity.claims.P625[1].mainsnak.snaktype == 'value') then
			local math_mod = require("Модул:Math")
			local precision = entity.claims.P625[1].mainsnak.datavalue.value.precision
			local latitude = entity.claims.P625[1].mainsnak.datavalue.value.latitude
			local longitude = entity.claims.P625[1].mainsnak.datavalue.value.longitude
			if precision then
				precision=-math_mod._round(math.log(precision)/math.log(10),0)
				latitude = math_mod._round(latitude,precision)
				longitude= math_mod._round(longitude,precision)
			end
			cstr = coord_wrapper(frame,
				{latitude, longitude, tstr, format = args['format'] or 'dms', display = dstr}
				)
		end
	else
		return ''	
	end

	if(isnotempty(args['wrap'])) then
		return prefix .. innerprefix .. cstr .. innersuffix .. suffix
	else 
		return prefix .. '<span style="white-space:nowrap">' .. innerprefix .. cstr  .. innersuffix .. '</span>' .. suffix
	end
end

return geobox_coor