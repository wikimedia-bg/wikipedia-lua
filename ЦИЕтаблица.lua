-- WikimediaCEETable: builds a list of articles based on information from Wikidata
-- Sample use: {{#invoke:WikimediaCEETable|table|Q1|Q2|Q3|Q4|Q5}}
-- Can be used to list 400+ articles on 1 page
-- by User:Voll, with additions by Halibutt, Braveheart, Jura1, Strainu, Yupik, Iketsi
-- Original at https://meta.wikimedia.org/wiki/Module:WikimediaCEETable. Please contribute amendments there and keep copies in sync with that version.
--
	local langTable = { 'en','az','ba','be','be_x_old','bs','bg','crh','cs','de','el','eo','et','hr', 'hu','hy','ka', 'kk', 'lt', 'lv','mk','mt','myv','pl','ro','ru','sh','sk','sl','sq','sr','tr','tt','uk','fiu_vro',}

local mylang = mw.getCurrentFrame():callParserFunction('int', 'lang')
local mylangObj = mw.language.new( mylang )
local i18nPage = 'Template:WikimediaCEETable/i18n'
local i18nSubpage = mw.title.new(i18nPage .. '/' .. mylang).exists and (i18nPage .. '/' .. mylang) or (i18nPage .. '/en')

local p = {}

local function def(bla)
  local zdef = {}
  for _, l in ipairs(bla) do zdef[l] = true end
  return zdef
end

local function formatnum(number)
	return mylangObj:formatNum(number)
end

local function formatnumcell(number, extraclasses)
	return string.format(
		'| lang="%s" class="%s" | %s',
		mylangObj:getCode(),
		'wikimedia-cee-table-numeric' .. (extraclasses and (' ' .. extraclasses) or ''),
		formatnum(number)
	)
end

local function i18n(args)
	return mw.getCurrentFrame():expandTemplate{ title = i18nSubpage, args = args }
end

local function getmainsnakid(entity, property)
	local stmt = entity:getBestStatements(property)[1]
	return stmt and stmt.mainsnak.snaktype == 'value' and stmt.mainsnak.datavalue.type == 'wikibase-entityid' and stmt.mainsnak.datavalue.value['id'] or nil
end

local function renderDate(entity, property)
	local stmt = entity:getBestStatements(property)[1]
	if stmt and stmt.mainsnak.snaktype == 'value' and stmt.mainsnak.datavalue.type == 'time' then
		local snak = stmt.mainsnak
		if snak.datavalue.value.precision > 9 then
			-- more precise than year, make it year-precise
			-- make a deep copy to make sure we don’t change anything outside of this function
			snak = mw.clone(snak)
			snak.datavalue.value.precision = 9
		end
		return mw.wikibase.renderSnak(snak)
	else
		return nil
	end
end

function p.table(frame)
	local resultTable = { i18n{ 'header', ['occupation'] = frame.args['occupation'], ['dir'] = mylangObj:getDir() } }
	index = 1
	ctt = {}
	statementst = 0
	coords = 0
	images = 0
	wqsitems = ""
	qids = {}
	timeline = 0
	for langCount = 1, #langTable do
		ctt[langCount] = 0
	end

	-- rows
	while frame.args[index] do
		Id = frame.args[index]
		local entity = mw.wikibase.getEntityObject(Id)
		-- if not entity or not entity.sitelinks then
		if not entity then
			return '<b>Entity ' .. Id .. ' not found</b>'
		end
		local Label, LabelLang = entity:getLabelWithLang()
		if not Label then
			Label = ''
			LabelLang = ''
		end
   		local ensitelink = entity:getSitelink( 'enwiki' )
		if ensitelink then
			if Label == '' then
				Label = ensitelink
				LabelLang = 'en'
			end
		end
		local cells = {
			formatnumcell(index),
			'| ', -- the label cell, to be filled later
		}
    	ct = 0
    	wqsitems = wqsitems .. "wd%3A" .. Id .. "%20"
		table.insert(qids, string.sub(Id, 2))
    	idinternal = def { "P373", "P948", "P935", "P460", "P856", "P910", "P213", "P1343", "P973", "P345", "P227", "P244","P1612", "P1472", "P1325", "P106" }
    	commonsp = def {'P18','P10','P14','P15','P41','P51','P94','P109','P117','P154','P158','P181','P207','P242','P367', 'P373','P443','P491','P692','P935','P948','P989','P990','P996','P1442','P1472','P1543','P1612','P1621','P1766','P1801','P1846','P1943','P1944'}    	
		
		-- occupation (P106)
		if frame.args['occupation'] then
			local occupationid = getmainsnakid(entity, 'P106')
			if occupationid then
				local occupation, occupationLang = mw.wikibase.getLabelWithLang(occupationid)
				table.insert(cells, '| lang="' .. occupationLang .. '" dir="auto" | ' .. occupation)
			else
				table.insert(cells, '\n| - ')
			end
		end
    	
    	-- columns per row
    	for langCount = 1, #langTable do
	   		local sitelink = entity:getSitelink( langTable[langCount] .. 'wiki' )
			if sitelink then
				iw = langTable[langCount]
				if iw == "be_x_old" then iw = "be-tarask" end
				if iw == "fiu_vro" then iw = "fiu-vro" end
				table.insert(cells, string.format('| class="wikimedia-cee-table-good" | [[:%s:%s| +]]', iw, sitelink))
				ct = ct + 1
				ctt[langCount] = ctt[langCount] + 1
				if Label == '' then
					Label = sitelink
					LabelLang = langTable[langCount]:gsub('_', '-')
				end
			else
				table.insert(cells, '| –')
			end
		end

		if Label ~= '' then
			cells[2] = string.format(
				'| <bdi lang="%s">%s</bdi>',
				LabelLang,
				ensitelink and ('[[:en:' .. ensitelink .. '|' .. Label ..']]') or Label
			)
		end

		-- icon for females (Q6581072 & Q1052281)
		local genderid = getmainsnakid(entity, 'P21')
		if genderid == 'Q6581072' or genderid == 'Q1052281' then
			cells[2] = cells[2] .. ' [[File:Female Icon.svg|link=|alt=♀|18px]]'
		end

		-- years for humans (Q5)
		mw.log(entity:getId(), getmainsnakid(entity, 'P31'))
		if getmainsnakid(entity, 'P31') == 'Q5' then
			local p569 = renderDate(entity, 'P569')
			local p570 = nil
			if p569 then
				p570 = renderDate(entity, 'P570')
			end
			cells[2] = cells[2] .. ' ' .. i18n{ 'lifespan', ['birth'] = p569, ['death'] = p570 }
		end
		if (
			entity:getBestStatements( 'P580' )[1] or
			entity:getBestStatements( 'P569' )[1] or
			entity:getBestStatements( 'P571' )[1] or
			entity:getBestStatements( 'P582' )[1] or
			entity:getBestStatements( 'P576' )[1] or
			entity:getBestStatements( 'P577' )[1]
		) then
			timeline = timeline + 1
		end

		local p625 = entity:getBestStatements( 'P625' )[1]
		if p625 then
			local label = i18n{ 'view on maps' }
			local url = "https://geohack.toolforge.org/geohack.php?language=en&pagename=" .. mw.uri.encode( Label, "PATH" ) .. "&params=" .. p625.mainsnak.datavalue.value.latitude .. "_N_" .. p625.mainsnak.datavalue.value.longitude .. "_E"
			cells[2] = cells[2] .. string.format("&nbsp;[[File:Geographylogo.svg|18px|%s|alt=%s|link=%s]]", label, label, url)
			coords = coords + 1
 		end
		if entity:getBestStatements( 'P18' )[1] then
			images = images + 1
		end

		-- last cells of row
		index = index + 1

		local commons = false
		local statements = 0
		if entity.claims then
			for i, statement in pairs( entity.claims ) do
				if statement then
					if statement[1].mainsnak then
						if not idinternal[i] then
							if statement[1].mainsnak.datatype ~= 'external-id' then
                   				statements = statements+1
                   			end
               			end
               			if commonsp[i] then 
               				commons = true
               			end
					end
				end
			end
		end
		-- local statements = #entity:getProperties()

		statementst = statementst + statements
		table.insert(cells, formatnumcell(ct, 'wikimedia-cee-table-small'))
		table.insert(cells, '| class="wikimedia-cee-table-good" data-sort-value="' .. string.sub(Id, 2) .. '" | [[d:' .. Id .. '|' .. Id .. ']]')
		table.insert(cells, formatnumcell(statements, 'wikimedia-cee-table-small' .. (statements > 0 and ' wikimedia-cee-table-good' or '')))
		-- TODO check for Commons sitelinks
		if commons then
			table.insert(cells, '| class="wikimedia-cee-table-good" |' .. i18n{ 'commons-resources' })
		else
			table.insert(cells, '|')
		end
		table.insert(resultTable, '|-\n' .. table.concat(cells, '\n'))
	end
	
	-- footer
	local qidsurl = mw.uri.encode("items[" .. table.concat(qids, ',') .. "]", "PATH" )
	local tline = ""
	if timeline > 2 then
		tline = i18n{ 'timeline', ['url'] = 'https://wikidata-timeline.toolforge.org/#/timeline?query=' .. qidsurl }
	end	
	local mapme = ""
	if coords > 0 or images > 0 then
		mapme = i18n{
			'mapme',
			['map'] = coords > 0 and 1 or 0,
			['gallery'] = images > 0 and 1 or 0,
			['url'] = "https://query.wikidata.org/#%23%20click%20%22Execute%22%20to%20run%20the%20query%2C%20then%20%28on%20the%20right%20side%29%20below%20%22Display%22%20select%20the%20link%20%22Map%22%20or%20%22Image%20Grid%22%0ASELECT%20%0A%09%3Fitem%20%0A%09%3FitemLabel%20%0A%09%28GROUP_CONCAT%28DISTINCT%28%3FinstanceLabel%29%3B%20separator%3D%22%2C%20%22%29%20as%20%3Finstance_of%29%0A%09%28SAMPLE%28%3Fcoord%29%20as%20%3Fcoordinates%29%0A%09%28SAMPLE%28%3Fimg%29%20as%20%3Fimage%29%0AWHERE%0A{%0A%09VALUES%20%3Fitem%20{%20" .. wqsitems .. "%20}%09OPTIONAL%20{%3Fitem%20wdt%3AP625%20%3Fcoord1%20}%20.%0A%20%20%09OPTIONAL%20{%3Fitem%20wdt%3AP131%2Fwdt%3AP625%20%3Fcoord2%20}%20.%0A%20%20%09OPTIONAL%20{%3Fitem%20wdt%3AP276%2Fwdt%3AP625%20%3Fcoord3%20}%20.%0A%09BIND%28IF%28!BOUND%28%3Fcoord1%29%2C%28IF%28!BOUND%28%3Fcoord2%29%2C%3Fcoord3%2C%3Fcoord2%29%29%2C%3Fcoord1%29%20as%20%3Fcoord%29%0A%20.%20%20%0A%09OPTIONAL%20{%3Fitem%20wdt%3AP31%20%3Finstance%20}%20.%20%20%20%0A%20%20%09OPTIONAL%20{%3Fitem%20wdt%3AP18%20%3Fimg%20}%20.%20%20%20%0A%09SERVICE%20wikibase%3Alabel%20{%20bd%3AserviceParam%20wikibase%3Alanguage%20%22" .. mylang .. "%2Cen%22%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20.%20%3Fitem%20rdfs%3Alabel%20%3FitemLabel%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20.%20%3Finstance%20rdfs%3Alabel%20%3FinstanceLabel%20}%0A}%0AGROUP%20BY%20%3Fitem%20%3FitemLabel%20"
		}
	end
	local autolist = i18n{
		'autolist',
		['url'] = 'https://autolist.toolforge.org/?language=' .. mylang .. '&project=wikipedia&wdq=' .. qidsurl .. '&run=Run&mode_manual=or&mode_cat=or&mode_wdq=not&mode_wdqs=or&mode_find=or&chunk_size=10000'
	}
	local cells = {
		'! Σ ',
		'| ' .. autolist .. mapme .. tline,
	}
	ct = 0
	for langCount = 1, #langTable do
		table.insert(cells, formatnumcell(ctt[langCount]))
		ct = ct + ctt[langCount]
	end
	table.insert(cells, formatnumcell(ct))
	table.insert(cells, i18n{
		'avg',
		['numlang'] = formatnum(#langTable),
		['avglang'] = formatnum(math.floor(ct/(index-1)+0.5)),
		['numarticle'] = formatnum(index-1),
		['avgarticle'] = formatnum(math.floor(ct / #langTable + 0.5)),
		['numtotal'] = formatnum(#langTable * (index-1)),
		['avgtotal'] = formatnum(math.floor( ct / #langTable / (index-1)*100 + 0.5))
	})
	table.insert(cells, formatnumcell(statementst))
	local commonsname = i18n{ 'Wikimedia Commons' }
	table.insert(cells, string.format('| [[File:Commons-logo.svg|16px|link=|alt=%s|%s]]', commonsname, commonsname))
	table.insert(resultTable, '|- class="sortbottom wikimedia-cee-table-small"\n' .. table.concat(cells, '\n'))
	table.insert(resultTable, '|}\n')
	return table.concat(resultTable, '\n')
end

-- WikimediaCEETable.count: counts articles from the list in certain wiki
-- Sample use: {{#invoke:WikimediaCEETable|count|lang|Q1|Q2|Q3|Q4|Q5}}
-- based on previous "table" function stripped from all the table formatting.

function p.count(frame)
        resultText = ''
	anum = 2
        wikianum = 0
	ctt = {}

	for langCount = 1, #langTable do
		ctt[langCount] = 0          
	end
	
	while frame.args[anum] do          
		Id = frame.args[anum]
                anum = anum + 1
		local entity = mw.wikibase.getEntityObject(Id)

		-- if not entity or not entity.sitelinks then   
		if not entity then
			return '<b>Entity ' .. Id .. ' not found</b>'
		end

    	for langCount = 1, #langTable do
	   		local sitelink = entity:getSitelink( langTable[langCount] .. 'wiki' )
			if sitelink then
				iw = langTable[langCount]
				if iw == "be_x_old" then iw = "be-tarask" end
				if iw == "fiu_vro" then iw = "fiu-vro" end
				ctt[langCount] = ctt[langCount] + 1
			end
		end
        end

        anum = anum - 2                        

        -- number of articles in certain wiki. Straight...
        for langCount = 1, #langTable do
                if langTable[langCount] == frame.args[1] then wikianum = ctt[langCount] end
        end

	resultText = wikianum .. '/' .. anum              -- result is two numbers with '/' separator

	return resultText
end

return p
