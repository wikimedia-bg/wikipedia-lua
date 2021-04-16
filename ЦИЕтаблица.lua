-- WikimediaCEETable: builds a list of articles based on information from Wikidata
-- Sample use: {{#invoke:WikimediaCEETable|table|Q1|Q2|Q3|Q4|Q5}}
-- Can be used to list 400+ articles on 1 page
-- by User:Voll, with additions by Halibutt, Braveheart, Jura1
-- Original at https://meta.wikimedia.org/wiki/Module:WikimediaCEETable  . Please contribute amendments there and keep copies in sync with that version.
--
local langTable = { 'az','be','bs','bg','cs','de','el','eo','et','hr','hu','hy','ka','kk','lt','lv','mk','pl','ro','ru','sh','sk','sl','sq','sr','tr','uk',}

local p = {}

local function def(bla)
  local zdef = {}
  for _, l in ipairs(bla) do zdef[l] = true end
  return zdef
end

function p.table(frame)
	-- header/init
	resultTable = '{| class="wikitable sortable" width=100%\n|-\n! № !! style="width:18%"|Статия !! class="unsortable"|<span title="Азербайджански език">[[File:Azerbaijan-orb.png|15px]] аз </span>!! class="unsortable"|[[File:Belarus-orb.png|15px]] be !! class="unsortable"|[[File:Bosnia-and-Herzegovina-orb.png|15px]] bs !! class="unsortable"|[[File:Bulgaria-orb.png|15px]] bg !! class="unsortable"|[[File:Czech-Republic-orb.png|15px]] cs !! class="unsortable"|[[File:Austria-orb.png|15px]] de !! class="unsortable"|[[File:Greece-orb.png|15px]] el !! class="unsortable"| <br> eo !! class="unsortable"|[[File:Estonia-orb.png|15px]] et !! class="unsortable"|[[File:Croatia-orb.png|15px]] hr !! class="unsortable"|[[File:Hungary-orb.png|15px]] hu !! class="unsortable"|[[File:Armenia-orb.png|15px]] hy !! class="unsortable"|[[File:Georgia-orb.png|15px]] ka !! class="unsortable"|[[File:Kazakhstan-orb.png|15px]] kk !! class="unsortable"|[[File:Lithuania-orb.png|15px]] lt !! class="unsortable"|[[File:Latvia-orb.png|15px]] lv !! class="unsortable"|[[File:Macedonia-orb.png|15px]] mk !! class="unsortable"|[[File:Poland-orb.png|15px]] pl !! class="unsortable"|[[File:Romania-orb.png|15px]] ro !! class="unsortable"|[[File:Russia-orb.png|15px]] ru !! class="unsortable"| <br> sh !! class="unsortable"|[[File:Slovakia-orb.png|15px]] sk !! class="unsortable"|[[File:slovenia-orb.png|15px]] sl !! class="unsortable"|[[File:Albania-orb.png|15px]] sq !! class="unsortable"|[[File:Serbia-and-Montenegro-orb.png|15px]] sr !! class="unsortable"|[[File:Turkey-orb.png|15px]] tr !! class="unsortable"|[[File:Ukraine-orb.png|15px]] uk !! Σ <br> !! Уикиданни !! <span title="Брой изявления на обекта">Из.</span> !! \n|-'
	index = 1
	ctt = {}
	statementst = 0
	coords = 0
	images = 0
	wqsitems = ""
	qids = ""
	timeline = 0
	mylang = frame:preprocess('bg')
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
		Label = entity:getLabel( 'en' )
		if not Label then
			Label = ''
		end
   		local ensitelink = entity:getSitelink( 'enwiki' )
		if ensitelink then
			if Label == '' then
				Label = ensitelink
			end
		end
    	result2 = ''
    	ct = 0
    	wqsitems = wqsitems .. "wd%3A" .. Id .. "%20"
    	qids = qids .. string.sub(Id, 2) .. ","
    	idinternal = def { "P373", "P948", "P935", "P460", "P856", "P910", "P213", "P1343", "P973", "P345", "P227", "P244","P1612", "P1472", "P1325" }
    	commonsp = def {'P18','P10','P14','P15','P41','P51','P94','P109','P117','P154','P158','P181','P207','P242','P367', 'P373','P443','P491','P692','P935','P948','P989','P990','P996','P1442','P1472','P1543','P1612','P1621','P1766','P1801','P1846','P1943','P1944'}
    	
    	-- columns per row
    	for langCount = 1, #langTable do
	   		local sitelink = entity:getSitelink( langTable[langCount] .. 'wiki' )
			if sitelink then
				result2 = result2 .. '\n| style="background:#cfc;"|' .. '[[:' .. langTable[langCount] .. ':' .. sitelink .. '| +]]'
				ct = ct + 1
				ctt[langCount] = ctt[langCount] + 1
				if Label == '' then
					Label = sitelink
				end
			else
				result2 = result2 .. '\n| -'
			end
		end
	
		-- first cells of row
    	result1 = '|-\n|align=right|' .. index .. '\n|'
    	if ensitelink then
    		result1 = result1 .. '[[:en:' .. ensitelink .. '|' .. Label ..']]'
    	else
    		result1 = result1 .. Label
    	end
		local sex = entity:formatPropertyValues( 'P21' ).value
		if sex then
			if sex == 'female' then
				result1 = result1 .. ' [[File:Female Icon.svg|18px]]'
			end
		end
		local p31 = entity:formatPropertyValues( 'P31' ).value
		if p31 then
			if p31 == 'human' then
				local yr = "%d%d%d%d$"
				local p569 = entity:formatPropertyValues( 'P569' ).value
				if p569 ~= "" then
					if p569:match(yr) ~= nil then
						p569 = p569:match(yr)
					end
					local p570 = entity:formatPropertyValues( 'P570' ).value
					if p570 ~= "" then
						if p570:match(yr) ~= nil then
							p570 = p570:match(yr)
						end
						result1 = result1 .. ' <span style="font-size:smaller;font-weight:100">(' .. p569 .. '-' .. p570 .. ')</span> '
					else
						result1 = result1 .. ' <span style="font-size:smaller;font-weight:100">(b. ' .. p569 .. ')</span>'
					end
				else
					result1 = result1 .. ' <span style="font-size:smaller;font-weight:100">(?)</span>'
				end
			end
		end
		local tl = ""
		tl = tl .. entity:formatPropertyValues( 'P580' ).value
		tl = tl .. entity:formatPropertyValues( 'P569' ).value
		tl = tl .. entity:formatPropertyValues( 'P571' ).value
		tl = tl .. entity:formatPropertyValues( 'P582' ).value
		tl = tl .. entity:formatPropertyValues( 'P576' ).value
		tl = tl .. entity:formatPropertyValues( 'P577' ).value
		if tl ~= "" then
			timeline = timeline + 1
		end 

		local p625 = entity:formatPropertyValues( 'P625' ).value
 		if p625 ~= "" then
				result1 = result1 .. "&nbsp;[[File:Geographylogo.svg|18px|view on maps|link=https://tools.wmflabs.org/geohack/geohack.php?language=en&pagename=" .. mw.uri.encode( Label, "PATH" ) .. "&params=" .. entity.claims.P625[1].mainsnak.datavalue.value.latitude .. "_N_" .. entity.claims.P625[1].mainsnak.datavalue.value.longitude .. "_E]]"
				coords = coords + 1
		end
		local p18 = entity:formatPropertyValues( 'P18' ).value
 		if p18 ~= "" then
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

		-- todo : check for Commons sitelinks
		local commonsstr = ""
		if commons then
			commonsstr = '<span title="Wikidata item includes Commons resources">+</span>'
			-- commonsstr = "[https://commons.wikimedia.org/w/index.php?fulltext=1&search=".. mw.uri.encode( Label, "PATH" ) .. " +]"
		end
		statementst = statementst + statements
		if statements == 0 then
			bgcolor = ''
		else
			bgcolor = 'background:#cfc;'
		end
		resultTable = resultTable .. result1 .. result2 ..'\n| align=right style="font-size:smaller;"| ' .. ct .. '\n| style="background:#cfc;" data-sort-value="' .. string.sub(Id, 2) .. '"|[[d:' .. Id .. '|' .. Id .. ']] \n|style="' .. bgcolor .. 'font-size:smaller;" align=right title="number of main statements on Wikidata item"|'.. statements .. '\n|style="background:#cfc;"|' .. commonsstr .. '\n'
	end
	
	-- footer
	tline = ""
	if timeline > 2 then
		tline = "[https://tools.wmflabs.org/wikidata-timeline/#/timeline?query=" .. mw.uri.encode("items[" .. qids .. "]", "PATH" ) .. " →&nbsp;timeline]"
	end	
	mapme = ""
	if coords > 0 or images > 0 then
		mapme = "[https://query.wikidata.org/#%23%20click%20%22Execute%22%20to%20run%20the%20query%2C%20then%20%28on%20the%20right%20side%29%20below%20%22Display%22%20select%20the%20link%20%22Map%22%20or%20%22Image%20Grid%22%0ASELECT%20%0A%09%3Fitem%20%0A%09%3FitemLabel%20%0A%09%28GROUP_CONCAT%28%3FinstanceLabel%3B%20separator%3D%22%2C%20%22%29%20as%20%3Finstance_of%29%0A%09%28SAMPLE%28%3Fcoord%29%20as%20%3Fcoordinates%29%0A%09%28SAMPLE%28%3Fimg%29%20as%20%3Fimage%29%0AWHERE%0A{%0A%09VALUES%20%3Fitem%20{%20" .. wqsitems .. "%20}%0A%09OPTIONAL%20{%3Fitem%20wdt%3AP625%20%3Fcoord%20}%20.%20%20%0A%09OPTIONAL%20{%3Fitem%20wdt%3AP31%20%3Finstance%20}%20.%20%20%20%0A%20%20%09OPTIONAL%20{%3Fitem%20wdt%3AP18%20%3Fimg%20}%20.%20%20%20%0A%09SERVICE%20wikibase%3Alabel%20{%20bd%3AserviceParam%20wikibase%3Alanguage%20%22" .. mylang .. "%2Cen%22%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20.%20%3Fitem%20rdfs%3Alabel%20%3FitemLabel%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20.%20%3Finstance%20rdfs%3Alabel%20%3FinstanceLabel%20}%0A}%0AGROUP%20BY%20%3Fitem%20%3FitemLabel%20 →"
		if coords > 0 then
			mapme = mapme .. "&nbsp;map"
		end
		if images > 0 then
			mapme = mapme .. "&nbsp;gallery"
		end
		mapme = mapme .. "]"
	end
	local autolist = "[https://tools.wmflabs.org/autolist/?language=" .. mylang .. "&project=wikipedia&wdq=" .. mw.uri.encode("items[" .. qids .. "]", "PATH" ) .. "&run=Run&mode_manual=or&mode_cat=or&mode_wdq=not&mode_wdqs=or&mode_find=or&chunk_size=10000 →&nbsp;Autolist]"
	result1 = '|- align=right style="font-size:smaller" class="sortbottom"\n! Σ \n|'  .. autolist .. mapme .. tline
	result2 = ''
	ct = 0
    for langCount = 1, #langTable do
			result2 = result2 .. '\n |' .. ctt[langCount]
			ct = ct + ctt[langCount]
	end
	resultTable = resultTable .. result1 .. result2 ..'\n| ' .. ct .. '\n| data-sort-value="999999999999"| avg:&nbsp;<span title="average number of language versions (of ' .. #langTable .. ') per article">' .. math.floor(ct/(index-1)+0.5) .. '</span>\\<span title="average number of articles (of ' .. (index-1) .. ') per language">' .. math.floor(ct / #langTable + 0.5) .. '</span>\\<span title="overall in percent (all: '..  (#langTable * (index-1)) .. ')">' .. math.floor( ct / #langTable / (index-1)*100 + 0.5) .. '%</span>\n|' .. statementst .. '\n| [[File:Commons-logo.svg|16px|Wikimedia Commons]]'

	resultTable = resultTable .. '\n|}\n'
	return resultTable
end

return p
