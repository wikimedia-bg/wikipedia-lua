local wiki = {
	langcode = mw.language.getContentLanguage().code
}

local i18n = {
	["errors"] = {
		["property-param-not-provided"] = "Property parameter not provided.",
		["property-not-found"] = "Property not found.",
		["entity-not-found"] = "Entity not found.",
		["qualifier-not-found"] = "Qualifier not found.",
		["unknown-claim-type"] = "Unknown claim type.",
		["unknown-snak-type"] = "Unknown snak type.",
		["unknown-datavalue-type"] = "Unknown datavalue type.",
		["unknown-entity-type"] = "Unknown entity type.",
		["unknown-value-module"] = "You must set both value-module and value-function parameters.",
		["value-module-not-found"] = "The module pointed by value-module not found.",
		["value-function-not-found"] = "The function pointed by value-function not found."
	},
	["somevalue"] = "Неизвестна стойност",
	["novalue"] = "Липсва стойност",
	["datetime"] = {
		-- $1 is a placeholder for the actual number
		[0] = "$1 млрд. години",		-- precision: billion years
		[1] = "$100 млн. години",	-- precision: hundred million years
		[2] = "$10 млн. години",	-- precision: ten million years
		[3] = "$1 млн. години",		-- precision: million years
		[4] = "$100 000 години",	-- precision: hundred thousand years
		[5] = "$10 000 години",		-- precision: ten thousand years
		[6] = "$1 хилядолетие", 	-- precision: millenium
		[7] = "$1 век",	-- precision: century
		[8] = "$1-те",				-- precision: decade
		-- the following use the format of #time parser function
		[9]  = "Y",					-- precision: year,
		[10] = "F Y",				-- precision: month
		[11] = "j F Y",			-- precision: day
		[12] = 'j F Y, G "часа"',	-- precision: hour
		[13] = "j F Y G:i",		-- precision: minute
		[14] = "j F Y G:i:s",		-- precision: second
		["beforenow"] = "преди $1",	-- how to format negative numbers for precisions 0 to 5
		["afternow"] = "след $1",		-- how to format positive numbers for precisions 0 to 5
		["bc"] = '$1 "пр.н.е."',		-- how print negative years
		["ad"] = "$1"				-- how print positive years
	},
	["monolingualtext"] = '<span lang="%language">%text</span>'
}

-- the "qualifiers" and "snaks" field have a respective "qualifiers-order" and "snaks-order" field
-- use these as the second parameter and this function instead of the built-in "pairs" function
-- to iterate over all qualifiers and snaks in the intended order.
local function orderedpairs(array, order)
	if not order then return pairs(array) end

	-- return iterator function
	local i = 0
	return function()
		i = i + 1
		if order[i] then
			return order[i], array[order[i]]
		end
	end
end

function getEntityFromId( id )
	if id then
		return mw.wikibase.getEntityObject( id )
	end
	return mw.wikibase.getEntityObject()
end

function getEntityIdFromValue( value )
	local prefix = ''
	if value['entity-type'] == 'item' then
		prefix = 'Q'
	elseif value['entity-type'] == 'property' then
		prefix = 'P'
	else
		return formatError( 'unknown-entity-type' )
	end
	return prefix .. value['numeric-id']
end

function formatError( key )
	return '<span class="error">' .. i18n.errors[key] .. '</span>'
end

function formatStatements( options )
	if not options.property then
		return formatError( 'property-param-not-provided' )
	end

	--Get entity
	local entity = getEntityFromId( options.entityId )
	if not entity then
		return -- formatError( 'entity-not-found' )
	end

	if (entity.claims == nil) or (not entity.claims[string.upper(options.property)]) then
		return '' --TODO error?
	end

	--Format statement and concat them cleanly
	local formattedStatements = {}
	for i, statement in pairs( entity.claims[string.upper(options.property)] ) do
		table.insert( formattedStatements, formatStatement( statement, options ) )
	end
	if options.first then
		return formattedStatements[1]
	else
		return mw.text.listToText( formattedStatements, options.separator, options.conjunction )
	end
end

function formatStatement( statement, options )
	if not statement.type or statement.type ~= 'statement' then
		return formatError( 'unknown-claim-type' )
	end

	return formatSnak( statement.mainsnak, options )
	--TODO reference and qualifiers
end

function formatSnak( snak, options )
	if snak.snaktype == 'somevalue' then
		return i18n['somevalue']
	elseif snak.snaktype == 'novalue' then
		return i18n['novalue']
	elseif snak.snaktype == 'value' then
		return formatDatavalue( snak.datavalue, options )
	else
		return formatError( 'unknown-snak-type' )
	end
end

function formatGlobeCoordinate( value, options )
	if options['subvalue'] == 'latitude' then
		return value['latitude']
	elseif options['subvalue'] == 'longitude' then
		return value['longitude']
	else
		local eps = 0.0000001 -- < 1/360000
		local globe = '' -- TODO
		local lat = {}
		lat['abs'] = math.abs(value['latitude'])
		lat['ns'] = value['latitude'] >= 0 and 'N' or 'S'
		lat['d'] = math.floor(lat['abs'] + eps)
		lat['m'] = math.floor((lat['abs'] - lat['d']) * 60 + eps)
		lat['s'] = math.max(0, ((lat['abs'] - lat['d']) * 60 - lat['m']) * 60)
		local lon = {}
		lon['abs'] = math.abs(value['longitude'])
		lon['ew'] = value['longitude'] >= 0 and 'E' or 'W'
		lon['d'] = math.floor(lon['abs'] + eps)
		lon['m'] = math.floor((lon['abs'] - lon['d']) * 60 + eps)
		lon['s'] = math.max(0, ((lon['abs'] - lon['d']) * 60 - lon['m']) * 60)
		local coord = '{{coord'
		if (value['precision'] == nil) or (value['precision'] < 1/60) then -- по умолчанию с точностью до секунды
			coord = coord .. '|' .. lat['d'] .. '|' .. lat['m'] .. '|' .. lat['s'] .. '|' .. lat['ns']
			coord = coord .. '|' .. lon['d'] .. '|' .. lon['m'] .. '|' .. lon['s'] .. '|' .. lon['ew']
		elseif value['precision'] < 1 then
			coord = coord .. '|' .. lat['d'] .. '|' .. lat['m'] .. '|' .. lat['ns']
			coord = coord .. '|' .. lon['d'] .. '|' .. lon['m'] .. '|' .. lon['ew']
		else
			coord = coord .. '|' .. lat['d'] .. '|' .. lat['ns']
			coord = coord .. '|' .. lon['d'] .. '|' .. lon['ew']
		end
		coord = coord .. '|globe:' .. globe
		if options['display'] then
			coord = coord .. '|display=' .. options.display
		else
			coord = coord .. '|display=title'
		end
		coord = coord .. '}}'

		return g_frame:preprocess(coord)
	end
end

function formatDatavalue( datavalue, options )
	--Use the customize handler if provided
	if options['value-module'] or options['value-function'] then
		if not options['value-module'] or not options['value-function'] then
			return formatError( 'unknown-value-module' )
		end
		local formatter = require ('Module:' .. options['value-module'])
		if formatter == nil then
			return formatError( 'value-module-not-found' )
		end
		local fun = formatter[options['value-function']]
		if fun == nil then
			return formatError( 'value-function-not-found' )
		end
		return fun( datavalue.value, options )
	end

	--Default formatters
	if datavalue.type == 'wikibase-entityid' then
		return formatEntityId( getEntityIdFromValue( datavalue.value ), options )
	elseif datavalue.type == 'string' then
		if options.pattern and options.pattern ~= '' then
			return formatFromPattern( datavalue.value, options )
		else
			return datavalue.value
		end
	elseif datavalue.type == 'globecoordinate' then
		return formatGlobeCoordinate( datavalue.value, options )
	elseif datavalue.type == 'time' then
		local Time = require 'Module:Time'
		return Time.newFromWikidataValue( datavalue.value ):toHtml()
	else
		return formatError( 'unknown-datavalue-type' )
	end
end

function formatEntityId( entityId, options )
	if (options.format == 'id') then
		return entityId
	end

	local label = mw.wikibase.label( entityId )
	local link = mw.wikibase.sitelink( entityId )
	if link and (options.format ~= 'label') then
		if label then
			return '[[' .. link .. '|' .. label .. ']]'
		else
			return '[[' .. link .. ']]'
		end
	else
		return label --TODO what if no links and label + fallback language?
	end
end

local p = {}

function p.formatStatements( frame )
	local args = frame.args

	--If a value if already set, use it
	if args.value and args.value ~= '' then
		return args.value
	end
	return formatStatements( frame.args )
end

function p.getPageId(frame)
	local entity = mw.wikibase.getEntityObject()
	if not entity then return nil else return entity.id end
end

function p.getLabel( frame )
	if not frame.args.lang then
		return ''
	end

	local id = frame.args["id"]
	if not id then
		id = frame.args.entityId
	end

	local entity = getEntityFromId(id)
	if not entity then
		return ''
	end

	if (entity.labels == nil) or (not entity.labels[frame.args.lang]) then
		return ''
	end
	return entity.labels[frame.args.lang]['value']
end

local function formatDatavalueCoordinate(data, parameter)
	-- data fields: latitude [double], longitude [double], altitude [double], precision [double], globe [wikidata URI, usually http://www.wikidata.org/entity/Q2 [earth]]
	if parameter then
		if parameter == "globe" then data.globe = mw.ustring.match(data.globe, "Q%d+") end -- extract entity id from the globe URI
		return data[parameter]
	else
		return data.latitude .. "/" .. data.longitude -- combine latitude and longitude, which can be decomposed using the #titleparts wiki function
	end
end

local function formatDatavalueQuantity(data, parameter)
	-- data fields: amount [number], unit [string], upperBound [number], lowerBound [number]
	if parameter then
		return data[paramater]
	elseif data.unit == "http://www.wikidata.org/entity/Q172540" then
		return tonumber(data.amount) .. " лв"
	else
		return tonumber(data.amount)
	end
end

-- precision: 0 - billion years, 1 - hundred million years, ..., 6 - millenia, 7 - century, 8 - decade, 9 - year, 10 - month, 11 - day, 12 - hour, 13 - minute, 14 - second
local function normalizeDate(date)
	date = mw.text.trim(date, "+")
	-- extract year
	local yearstr = mw.ustring.match(date, "^\-?%d+")
	local year = tonumber(yearstr)
	-- remove leading zeros of year
	return year .. mw.ustring.sub(date, #yearstr + 1), year
end

function formatDate(date, precision, timezone)
	precision = precision or 11
	date, year = normalizeDate(date)
	if year == 0 and precision <= 9 then return "" end

	-- precision is 10000 years or more
	if precision <= 5 then
		local factor = 10 ^ ((5 - precision) + 4)
		local y2 = math.ceil(math.abs(year) / factor)
		local relative = mw.ustring.gsub(i18n.datetime[precision], "$1", tostring(y2))
		if year < 0 then
			relative = mw.ustring.gsub(i18n.datetime.beforenow, "$1", relative)
		else
			relative = mw.ustring.gsub(i18n.datetime.afternow, "$1", relative)
		end
		return relative
	end

 	-- precision is decades, centuries and millennia
	local era
	if precision == 6 then era = mw.ustring.gsub(i18n.datetime[6], "$1", tostring(math.floor((math.abs(year) - 1) / 1000) + 1)) end
	if precision == 7 then era = mw.ustring.gsub(i18n.datetime[7], "$1", tostring(math.floor((math.abs(year) - 1) / 100) + 1)) end
	if precision == 8 then era = mw.ustring.gsub(i18n.datetime[8], "$1", tostring(math.floor(math.abs(year) / 10) * 10)) end
	if era then
		if year < 0 then era = mw.ustring.gsub(mw.ustring.gsub(i18n.datetime.bc, '"', ""), "$1", era)
		elseif year > 0 then era = mw.ustring.gsub(mw.ustring.gsub(i18n.datetime.ad, '"', ""), "$1", era) end
		return era
	end

 	-- precision is year
 	if precision == 9 then
 		return year
 	end

	-- precision is less than years
	if precision > 9 then
		--[[ the following code replaces the UTC suffix with the given negated timezone to convert the global time to the given local time
		timezone = tonumber(timezone)
		if timezone and timezone ~= 0 then
			timezone = -timezone
			timezone = string.format("%.2d%.2d", timezone / 60, timezone % 60)
			if timezone[1] ~= '-' then timezone = "+" .. timezone end
			date = mw.text.trim(date, "Z") .. " " .. timezone
		end
		]]--

		local formatstr = i18n.datetime[precision]
		if year == 0 then formatstr = mw.ustring.gsub(formatstr, i18n.datetime[9], "")
		elseif year < 0 then
			-- Mediawiki formatDate doesn't support negative years
			date = mw.ustring.sub(date, 2)
			formatstr = mw.ustring.gsub(formatstr, i18n.datetime[9], mw.ustring.gsub(i18n.datetime.bc, "$1", i18n.datetime[9]))
		elseif year > 0 and i18n.datetime.ad ~= "$1" then
			formatstr = mw.ustring.gsub(formatstr, i18n.datetime[9], mw.ustring.gsub(i18n.datetime.ad, "$1", i18n.datetime[9]))
		end
		return mw.language.new(wiki.langcode):formatDate(formatstr, date)
	end
end

local function formatDatavalueTime(data, parameter)
	-- data fields: time [ISO 8601 time], timezone [int in minutes], before [int], after [int], precision [int], calendarmodel [wikidata URI]
	--   precision: 0 - billion years, 1 - hundred million years, ..., 6 - millenia, 7 - century, 8 - decade, 9 - year, 10 - month, 11 - day, 12 - hour, 13 - minute, 14 - second
	--   calendarmodel: e.g. http://www.wikidata.org/entity/Q1985727 for the proleptic Gregorian calendar or http://www.wikidata.org/wiki/Q11184 for the Julian calendar]
	if parameter then
		if parameter == "calendarmodel" then data.calendarmodel = mw.ustring.match(data.calendarmodel, "Q%d+") -- extract entity id from the calendar model URI
		elseif parameter == "time" then data.time = normalizeDate(data.time) end
		return data[parameter]
	else
		return formatDate(data.time, data.precision, data.timezone)
	end
end

local function formatDatavalueEntity(data, parameter)
	-- data fields: entity-type [string], numeric-id [int, Wikidata id]
	local id = "Q" .. data["numeric-id"]
	if parameter then
		if parameter == "link" then
			return "[[" .. (mw.wikibase.sitelink(id) or (":d:" .. id))  .. "|" ..  (mw.wikibase.label(id) or id)  .. "]]"
		else
			return data[parameter]
		end
	else
		if data["entity-type"] == "item" then return mw.wikibase.label("Q" .. data["numeric-id"]) or id else formatError("unknown-entity-type") end
	end
end

local function formatDatavalueMonolingualText(data, parameter)
	-- data fields: language [string], text [string]
	if parameter then
		return data[parameter]
	else
		return mw.ustring.gsub(mw.ustring.gsub(i18n.monolingualtext, "%%language", data["language"]), "%%text", data["text"])
	end
end

function findClaims(entity, property)
	if not property or not entity or not entity.claims then return end

	if mw.ustring.match(property, "^P%d+$") then
		-- if the property is given by an id (P..) access the claim list by this id
		return entity.claims[property]
	else
		-- otherwise, iterate over all properties, fetch their labels and compare this to the given property name
		property = mw.wikibase.resolvePropertyId(property)
		if property then
			return entity.claims[property]
		end

		return
	end
end

function getSnakValue(snak, parameter)
	-- snaks have three types: "novalue" for null/nil, "somevalue" for not null/not nil, or "value" for actual data
	if snak.snaktype == "novalue" then
		return i18n["novalue"]
	elseif snak.snaktype == "somevalue" then
		return i18n["somevalue"]
	elseif snak.snaktype ~= "value" then
		return nil, formatError("unknown-snak-type")
	end

	-- call the respective snak parser
	if snak.datavalue.type == "string" then
		return snak.datavalue.value
	elseif snak.datavalue.type == "globecoordinate" then
		return formatDatavalueCoordinate(snak.datavalue.value, parameter)
	elseif snak.datavalue.type == "quantity" then
		return formatDatavalueQuantity(snak.datavalue.value, parameter)
	elseif snak.datavalue.type == "time" then
		return formatDatavalueTime(snak.datavalue.value, parameter)
	elseif snak.datavalue.type == "wikibase-entityid" then
		return formatDatavalueEntity(snak.datavalue.value, parameter)
	elseif snak.datavalue.type == "monolingualtext" then
		return formatDatavalueMonolingualText(snak.datavalue.value, parameter)
	else
		return nil, formatError("unknown-datavalue-type")
	end
end

function getQualifierSnak(claim, qualifier, qualifierIndex, language)
	-- a "snak" is Wikidata terminology for a typed key/value pair
	-- a claim consists of a main snak holding the main information of this claim,
	-- as well as a list of attribute snaks and a list of references snaks
	if qualifier then
		-- search the attribute snak with the given qualifier as key
		if claim.qualifiers then
			local qualifierSnaks = claim.qualifiers[qualifier]
			if qualifierSnaks then
				if qualifierSnaks then
					return qualifierSnaks[qualifierIndex]
				end
				for name, snak in pairs(qualifierSnaks) do
					if snak.datatype == "monolingualtext" then
						-- if the snak is monolingual text search for the language
						local currentLanguage = getSnakValue(snak, "language")
						if (language and language == currentLanguage) or currentLanguage == "bg" then
							return snak
						end
					else
						-- returns the 1st entry if the value is not monolingual text
						return snak
					end
				end
			end
		end
		return nil, formatError("qualifier-not-found")
	else
		-- otherwise return the main snak
		return claim.mainsnak
	end
end

function getValueOfClaim(claim, qualifier, qualifierIndex, parameter, language)
	local error
	local snak
	snak, error = getQualifierSnak(claim, qualifier, qualifierIndex, language)
	if snak then
		return getSnakValue(snak, parameter)
	else
		return nil, error
	end
end

function p.getSiteLink(frame)
	local id = frame.args["id"]
	local entity
	if id then
		entity = getEntityFromId(id)
	else
	 	entity = mw.wikibase.getEntity()
	end
	local link = entity:getSitelink(frame.args[1])
	if not link then
		return
	end
	return link
end

function getReferences(frame, claim)
	local result = ""
	local refs = claim.references or {};
	-- traverse through all references in reversed order
	for ref = #refs, 1, -1 do
		local refparts
		-- traverse through all parts of the current reference
		for snakkey, snakval in orderedpairs(refs[ref].snaks or {}, refs[ref]["snaks-order"]) do
			if refparts then refparts = refparts .. ", " else refparts = "" end
			-- output the label of the property of the reference part, e.g. "imported from" for P143
			refparts = refparts .. tostring(mw.wikibase.label(snakkey)) .. ": "
			-- output all values of this reference part, e.g. "German Wikipedia" and "English Wikipedia" if the referenced claim was imported from both sites
			for snakidx = 1, #snakval do
				if snakidx > 1 then refparts = refparts .. ", " end
				refparts = refparts .. getSnakValue(snakval[snakidx])
			end
		end
		if refparts then result = result .. frame:extensionTag("ref", refparts) end
		if ref == #refs - 2 then break end	-- get no more than 3 references
	end
	return result
end

function p.getDescription(frame)
	local langcode = frame.args[1]
	local id = frame.args[2]	-- "id" must be nil, as access to other Wikidata objects is disabled in Mediawiki configuration
	local result = ''
	local entity = mw.wikibase.getEntity(id)
	if entity and entity.descriptions then
		local description = entity.descriptions[langcode or wiki.langcode]	-- get the description of a Wikidata entity in the given language or the default language of this Wikipedia site
		if description then
			result = description.value
		end
	end
	
	if ( langcode == 'bg' or not langcode ) and not mw.ustring.match( result, '^[А-я0-9].*$' ) then
		return ''
	else
		return result
	end
end

function p.count(frame)
	local property = frame.args[1] or ""
	local id = frame.args["id"]
	local entity = mw.wikibase.getEntityObject(id)
	local claims = findClaims(entity, property)
	
	local count = 0
	if claims ~= nil then
	   for _ in pairs(claims) do count = count + 1 end
	end
	
	return count;
end

function p.claim(frame)
	local property = frame.args[1] or ""
	local claimIndex = frame.args[2] and tonumber(frame.args[2]) or 1
	local id = frame.args["id"]	-- "id" must be nil, as access to other Wikidata objects is disabled in Mediawiki configuration
	local qualifier = frame.args["qualifier"]
	local qualifierIndex = frame.args[3] and tonumber(frame.args[3])
	local parameter = frame.args["parameter"]
	local language = frame.args["lang"]
	local list = frame.args["list"]
	local references = frame.args["references"]
	local showerrors = frame.args["showerrors"]
	local default = frame.args["default"]
	if default then showerrors = nil end

	-- get wikidata entity
	local entity = mw.wikibase.getEntityObject(id)
	if not entity then
		if showerrors then return formatError("entity-not-found") else return default end
	end
	-- fetch the first claim of satisfying the given property
	local claims = findClaims(entity, property)
	if not claims or not claims[claimIndex] then
		if showerrors then return formatError("property-not-found") else return default end
	end

	-- get initial sort indices
	local sortindices = {}
	for idx in pairs(claims) do
		sortindices[#sortindices + 1] = idx
	end
	-- sort by claim rank
	local comparator = function(a, b)
		local rankmap = { deprecated = 2, normal = 1, preferred = 0 }
		local ranka = rankmap[claims[a].rank or "normal"] ..  string.format("%08d", a)
		local rankb = rankmap[claims[b].rank or "normal"] ..  string.format("%08d", b)
		return ranka < rankb
	end
	table.sort(sortindices, comparator)

	local result
	local error
	if list then
		local value
		-- iterate over all elements and return their value (if existing)
		result = {}
		for idx in pairs(claims) do
			local claim = claims[sortindices[idx]]
			value, error = getValueOfClaim(claim, qualifier, qualifierIndex, parameter, language)
			if not value and showerrors then value = error end
			if value and references then value = value .. getReferences(frame, claim) end
			result[#result + 1] = value
		end
		result = table.concat(result, list)
	else
		local claim = claims[sortindices[claimIndex]]
		result, error = getValueOfClaim(claim, qualifier, qualifierIndex, parameter, language)
		if result and references then
			result = result .. getReferences(frame, claim)
		end
	end

	if result then return result else
		if showerrors then return error else return default end
	end
end

return p
