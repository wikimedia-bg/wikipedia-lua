local conf = require( 'Модул:Taxonbar/conf' ) --configuration module
local TaxonItalics = require('Модул:TaxonItalics') --use a function from Module:TaxonItalics to italicize a taxon name

--[[==========================================================================]]
--[[                             Local functions                              ]]
--[[==========================================================================]]

local function isNilOrEmpty( thing )
	if thing == nil or thing == '' then
		return true
	end
	return nil
end

local function getIdFromWikidata( item, property )
	local id = nil
	if property == 'PWikispecies:$1' then
		local siteLinks = item.sitelinks
		if siteLinks then
			local speciesWiki = item.sitelinks.specieswiki
			if speciesWiki then
				id = speciesWiki.title
			end
		end
		return id
	elseif item.claims[property] == nil then
		return id
	end
	for _, statement in pairs( item.claims[property] ) do
		if statement.mainsnak.datavalue then
			id = statement.mainsnak.datavalue.value
			break
		end
	end
	return id
end

local function getLink( property, val )
	local link, returnVal = '', {}
	
	returnVal.isError = false
	
	if mw.ustring.find( val, '//' ) then
		link = val
	else
		if type(property) == 'number' and property > 0 then
			local entityObject = mw.wikibase.getEntity('P'..property)
			local dataType
			
			if entityObject then dataType = entityObject.datatype
			else returnVal.isError = true end
			
			if dataType == 'external-id' then
				local formatterURL = nil
				if property == 3746 or --Wildflowers of Israel
				   property == 3795 or --Flora of Israel Online
				   property == 5397 --Tierstimmenarchiv
				then
					formatterURL = entityObject:getBestStatements('P1630')[2] --use 2nd formatterURL for English version
				end
				if formatterURL == nil then formatterURL = entityObject:getBestStatements('P1630')[1] end --default to [1]
				if formatterURL then
					if formatterURL.mainsnak.datavalue and formatterURL.mainsnak.datavalue.value then --nil check for ABA
						link = formatterURL.mainsnak.datavalue.value
					end
				end
			elseif dataType == 'url' then
				local subjectItem = entityObject:getBestStatements('P1629')[1]
				if subjectItem then
					local officialWebsite = mw.wikibase.getEntity(subjectItem.mainsnak.datavalue.value.id):getBestStatements('P856')[1]
					if officialWebsite then	link = officialWebsite.mainsnak.datavalue.value end
				end
			elseif dataType == 'string' then
				local formatterURL = entityObject:getBestStatements('P1630')[1]
				if formatterURL then
					link = formatterURL.mainsnak.datavalue.value
				else
					local subjectItem = entityObject:getBestStatements('P1629')[1]
					if subjectItem then
						local officialWebsite = mw.wikibase.getEntity(subjectItem.mainsnak.datavalue.value.id):getBestStatements('P856')[1]
						if officialWebsite then	link = officialWebsite.mainsnak.datavalue.value end
					end
				end
			else
				returnVal.isError = true
			end
		elseif type(property) == 'string' then
			link = property
		end
		
		local valurl = val
		if mw.ustring.find( link, 'antweb.org' ) then valurl = mw.ustring.gsub(valurl, ' ', '%%20') end
		if type(property) == 'number' then
			--doublecheck language for Wildflowers of Israel ID
			if property == 3746 then link = mw.ustring.gsub(link, '/hebrew/', '/english/') end
			--format spaces in PfaF, e.g. for "Elaeagnus x ebbingei"
			if property == 4301 then valurl = mw.ustring.gsub(valurl, ' ', '+') end
		end
		valurl = mw.ustring.gsub(valurl,'%%','%%%%')
		link = mw.ustring.gsub(link, '$1', valurl)
	end
	
	link = mw.ustring.gsub(link, '^[Hh][Tt][Tt][Pp]([Ss]?)&#58;//', 'http%1://') -- fix wikidata URL
	val = mw.ustring.match(val, '([^=/]*)/?$') -- get display name from end of URL
	if mw.ustring.find( link, '//' ) then
		returnVal.text = '['..link..' '..mw.text.encode(mw.uri.decode(val, 'PATH'),'%[%]')..']'
	elseif link == '' then
		returnVal.text = val
	else
		returnVal.text = '[['..link..'|'..val..']]'
	end
	return returnVal
end

local function createRow( id, label, rawValue, link, withUid )
	if link then
		local outStr = '*' .. label .. ' <span'
		if withUid then outStr = outStr..' class="uid"' end
		return outStr..'>' .. link .. '</span>\n'
	else
		return '* ' .. mw.text.tag('span', {class='error'}, 'Идентификаторът ' .. id .. ' ' .. rawValue .. ' не е валиден.') .. '\n'
	end
end

local function copyTable(inTable)
	if type(inTable) ~= 'table' then return inTable end
	local outTable = setmetatable({}, getmetatable(inTable))
	for key, value in pairs (inTable) do outTable[copyTable(key)] = copyTable(value) end
	return outTable
end

local p = {}

--[[==========================================================================]]
--[[								Doc table								  ]]
--[[==========================================================================]]

function p.docConfTable( frame )
	local wikiTable = '{| class="wikitable sortable"\n'..
					  '|-\n'..
					  '!Параметър'..
					  '!!Показване<br />в нав. лента'..
					  '!!data-sort-type="number"|Свойство<br />в Уикиданни\n'
	for _, db in pairs( conf.databases ) do
		local param, link, pid = db[1], db[2], db[3]
		if type(pid) == 'number' and pid > 0 then
		wikiTable = wikiTable..
					'|-\n'..
					'|'..param..
					'||'..link..
					'||data-sort-value="'..pid..'"|[[:d:property:P'..pid..'|P'..pid..']]\n'
		end
	end
	return wikiTable..
					'|}'
end

--[[==========================================================================]]
--[[                                   Main                                   ]]
--[[==========================================================================]]

function p.authorityControlTaxon( frame )
	local resolveEntity = require( 'Модул:ResolveEntityId' )
	local parentArgs = copyTable(frame:getParent().args)
	local currentTitle = mw.title.getCurrentTitle()
	local currentEntityId = mw.wikibase.getEntityIdForCurrentPage()
	
	local stringArgs = false
	local fromTitleCount, firstRow, rowCount = 1, 0, 0
	local outString, errors = '', ''
	local tFroms = {} --non-sequential table of unique froms
	local iFroms = 0 --integer size of tFroms, b/c Lua
	local categories = {
		'[[Категория:Таксономичен контрол без from параметри]]',
		'[[Категория:Таксономичен контрол, десинхронизиран с Уикиданни]]',
		'', -- [3] placeholder for [[Category:Taxonbars using multiple manual Wikidata items]]
		'', -- [4] placeholder for [[Category:Taxonbars with invalid from parameters]]
		'', -- [5] placeholder for [[Category:Taxonbars using manual taxon IDs]]
		'', -- [6] placeholder for [[Category:Taxonbar pages requiring a Wikidata item]]
		'', -- [7] placeholder for [[Category:Taxonbar pages without Wikidata taxon IDs]]
		'', -- [8] placeholder for [[Category:Taxonbars with duplicate from parameters]]
		'', -- [9] placeholder for [[Category:Taxonbars with manual taxon IDs differing from Wikidata]]
		'', --[10] placeholder for [[Category:Taxonbars with manual taxon IDs identical to Wikidata]]
		'', --[11] placeholder for [[Category:Taxonbars on possible non-taxon pages]]
		'', --[12] placeholder for [[Category:Taxonbars with 20–24 taxon IDs]]
		'', --[13] placeholder for [[Category:Taxonbars with 25–29 taxon IDs]]
		'', --[14] placeholder for [[Category:Taxonbars with 30–34 taxon IDs]]
		'', --[15] placeholder for [[Category:Taxonbars with automatically added basionyms]]
		'', --[16] placeholder for [[Category:Taxonbars with automatically added original combinations]]
		'', --[17] placeholder for [[Category:Taxonbars with automatically added monotypic genera]]
		'', --[18] placeholder for [[Category:Taxonbars of monotypic species missing genera]]
		'', --[19] placeholder for [[Category:Taxonbars with unknown parameters]]
		'', --[20] placeholder for [[Category:Taxonbars with 35–39 taxon IDs]]
		'', --[21] placeholder for [[Category:Taxonbars with 40+ taxon IDs]]
	}
	
	--Assess the page's relationship with Wikidata
	local currentItem = nil
	if currentTitle.namespace == 10 then --i.e. Module:Taxonbar/sandbox, Template:Taxonbar/doc, etc.
		if resolveEntity._id(parentArgs['from']) then
			currentItem = mw.wikibase.getEntity(parentArgs['from'])
		end
		if currentItem == nil then
			if resolveEntity._id(parentArgs['from1']) then
				currentItem = mw.wikibase.getEntity(parentArgs['from1'])
			end
		end
	elseif resolveEntity._id(currentEntityId) then
		currentItem = mw.wikibase.getEntity(currentEntityId)
	else --currentEntityId == nil/unresolvable
		categories[6] = '[[Категория:Страници с таксономичен контрол, изискващи елементи в Уикиданни]]'
	end
	if currentItem then
		local acceptable = {
		   ['Q16521'] = 'taxon',                      --strict
		   ['Q310890'] = 'monotypic taxon',           --strict
		   ['Q2568288'] = 'ichnotaxon',               --strict
		   ['Q23038290'] = 'fossil taxon',            --strict
		   ['Q47487597'] = 'monotypic fossil taxon',  --strict
		   ['Q42621'] = 'hybrid',                     --lax
		   ['Q235536'] = 'incertae sedis',            --lax
		   ['Q713623'] = 'clade',                     --lax
		   ['Q848328'] = 'serotype',                  --lax
		   ['Q857968'] = 'candidatus',                --lax
		   ['Q17487588'] = 'unavailable combination', --lax
		}
		categories[11] = '[[Категория:Таксономичен контрол в страница с вероятна нетаксономична единица]]' --unset if acceptable found
		for _, instanceOfState in pairs ( currentItem:getBestStatements('P31') ) do --instance of
			local instanceOf = instanceOfState.mainsnak.datavalue.value.id
			if acceptable[instanceOf] then
				categories[11] = ''
				break
			end
		end
	end
	
	--Cleanup args
	for k, v in pairs( frame:getParent().args ) do
		if type(k) == 'string' then
			--make args case insensitive
			local lowerk = mw.ustring.lower(k)
			if isNilOrEmpty( parentArgs[lowerk] ) then
				parentArgs[k] = nil
				parentArgs[lowerk] = v
			end
			--remap abc to abc1
			if mw.ustring.find(lowerk,'%d$') == nil then --if no number at end of param
				if isNilOrEmpty( parentArgs[lowerk..'1'] ) then
					parentArgs[lowerk] = nil
					lowerk = lowerk..'1'
					parentArgs[lowerk] = v
				end
			end
			if v and v ~= '' then
				--remap 'for' to 'title'
				if mw.ustring.sub(lowerk,1,3) == 'for' then
					local forTitle = mw.ustring.gsub(lowerk,'^for','title',1)
					if isNilOrEmpty( parentArgs[forTitle] ) then
						parentArgs[lowerk] = nil
						lowerk = forTitle
						parentArgs[lowerk] = v
					end
				end
				--find highest from or title param
				if mw.ustring.sub(lowerk,1,4) == 'from' then
					local fromNumber = tonumber(mw.ustring.sub(lowerk,5,-1))
					if fromNumber and fromNumber >= fromTitleCount then fromTitleCount = fromNumber end
					--look for duplicate froms while we're here
					if mw.ustring.find(v, '^Q%d') then
						if tFroms[v] then
							categories[8] = '[[Категория:Таксономичен контрол с дублирани from параметри]]'
							tFroms[v] = tFroms[v] + 1
						else
							tFroms[v] = 1
							iFroms = iFroms + 1
						end
						if iFroms == 2 then
							categories[3] = '[[Категория:Таксономичен контрол, използващ множество ръчно въведени елементи от Уикиданни]]'
						end
					end
				elseif mw.ustring.sub(lowerk,1,5) == 'title' then
					local titleNumber = tonumber(mw.ustring.sub(lowerk,4,-1))
					if titleNumber and titleNumber >= fromTitleCount then fromTitleCount = titleNumber end
				elseif mw.ustring.lower(v) ~= 'no' then
					stringArgs = true
					categories[5] = '[[Категория:Таксономичен контрол, използващ ръчно въведени идентификатори на таксон]]'
				end
			end
		end
	end
	
	--Check for unknown parameters
	--create knowns list
	local acceptableArgs = { from = true, } --master list of l/c acceptable args
	local AuCl = require( 'Модул:Нормативен контрол' ) --exclude Authority control parameters; they shouldn't appear as unknown
	for _, d in pairs( conf.databases ) do
		if d[1] ~= 'Wikidata' then --made obsolete by from
			acceptableArgs[mw.ustring.lower(d[1])] = true
		end
	end
	for _, a in pairs( conf.aliases ) do
		acceptableArgs[mw.ustring.lower(a[1])] = true
	end
	for _, acc in pairs( AuCl.conf ) do
		acceptableArgs[mw.ustring.lower(acc[1])] = true
	end
	for _, aca in pairs( AuCl.aliases ) do
		acceptableArgs[mw.ustring.lower(aca[1])] = true
	end
	--create trimmed parents list
	local baseParentArgs = {} --condensed list of l/c parent args w/o trailing #s
	for k, v in pairs( parentArgs ) do
		if type(k) == 'string' then --ignore unnamed params, which have keys of type 'number'
			local lowerk = mw.ustring.lower(k)
			local base = mw.ustring.gsub(lowerk, '[%d]*$', '')
			baseParentArgs[base] = true
		end
	end
	--compare lists and spit out unknowns
	local unknownParams = {}
	for k, v in pairs( baseParentArgs ) do
		if acceptableArgs[k] == nil then
			categories[19] = '[[Категория:Таксономичен контрол с неизвестни параметри|' .. k ..']]'
			unknownParams[#unknownParams + 1] = k
		end
	end
	--warn if unknown(s) present
	if #unknownParams > 0 then
		local unknplural = nil
		local plural = nil
		local itthem = nil
		if #unknownParams == 1 then
			unknplural = 'ен'
			plural = 'ър'
			itthem = 'го'
		else
			unknplural = 'ни'
			plural = 'ри'
			itthem = 'ги'
		end
		if frame:preprocess( '{{REVISIONID}}' ) == '' then
			errors = errors..'<div style="padding:0.5em 0 0.5em 1.6em; color:red; font-size:larger">'..
				     '<b>Внимание:</b> неизвест'..unknplural..' парамет'..plural..' <b>'..table.concat(unknownParams, ', ')..'</b>.<br />'..
				     'Моля, коригирайте '..itthem..' или '..itthem..' добавете към Уикиданни.<br />'..
				     'Това съобщение е генерирано от Модул:Тaxonbar и се показва при предварителен преглед.<br />'..
				     'Ако не намирате проблем, можете да пропуснете съобщението и да запазите промените.</div>'
		end
	end
	
	--Append basionym to arg list, if not already provided
	if currentItem then
		local currentBasState = currentItem:getBestStatements('P566')[1] --basionym
		if currentBasState then
			local basionymId = currentBasState.mainsnak.datavalue.value.id
			if basionymId and resolveEntity._id(basionymId) and tFroms[basionymId] == nil then
				--check that basionym is a strict instance of taxon
				local basionymItem = mw.wikibase.getEntity(basionymId)
				if basionymItem then
					local acceptable = {
					   ['Q16521'] = 'taxon',                     --strict
					   ['Q310890'] = 'monotypic taxon',          --strict
					   ['Q2568288'] = 'ichnotaxon',              --strict
					   ['Q23038290'] = 'fossil taxon',           --strict
					   ['Q47487597'] = 'monotypic fossil taxon', --strict
					}
					for _, instanceOfState in pairs ( basionymItem:getBestStatements('P31') ) do --instance of
						local instanceOf = instanceOfState.mainsnak.datavalue.value.id
						if acceptable[instanceOf] then
							--housekeeping
							tFroms[basionymId] = 1
							iFroms = iFroms + 1
							fromTitleCount = fromTitleCount + 1
							--append basionym & track
							parentArgs['from'..fromTitleCount] = basionymId
							categories[15] = '[[Категория:Таксономичен контрол с автоматично добавени базионими]]'
							break
	end	end	end	end	end	end
	
	--Append original combination to arg list, if not already provided
	if currentItem then
		local currentOCState = currentItem:getBestStatements('P1403')[1] --original combination
		if currentOCState then
			local orcoId = currentOCState.mainsnak.datavalue.value.id
			if orcoId and resolveEntity._id(orcoId) and tFroms[orcoId] == nil then
				--check that orco is a strict instance of taxon
				local orcoItem = mw.wikibase.getEntity(orcoId)
				if orcoItem then
					local acceptable = {
					   ['Q16521'] = 'taxon',                     --strict
					   ['Q310890'] = 'monotypic taxon',          --strict
					   ['Q2568288'] = 'ichnotaxon',              --strict
					   ['Q23038290'] = 'fossil taxon',           --strict
					   ['Q47487597'] = 'monotypic fossil taxon', --strict
					}
					for _, instanceOfState in pairs ( orcoItem:getBestStatements('P31') ) do --instance of
						local instanceOf = instanceOfState.mainsnak.datavalue.value.id
						if acceptable[instanceOf] then
							--housekeeping
							tFroms[orcoId] = 1
							iFroms = iFroms + 1
							fromTitleCount = fromTitleCount + 1
							--append orco & track
							parentArgs['from'..fromTitleCount] = orcoId
							categories[16] = '[[Категория:Таксономичен контрол с автоматично добавени оригинални комбинации]]'
							break
	end	end	end	end	end	end
	
	--Append monotypic genus/species to arg list of monotypic species/genus, if not already provided
	if currentItem then
		for _, instanceOfState in pairs ( currentItem:getBestStatements('P31') ) do --instance of
			local taxonRank = nil
			local parentItem = nil
			local parentTaxon = nil
			local parentTaxonRank = nil
			local parentMonoGenus = nil --holy grail/tbd
			local instanceOf = instanceOfState.mainsnak.datavalue.value.id
			if instanceOf and (instanceOf == 'Q310890' or instanceOf == 'Q47487597') then --monotypic/fossil taxon
				local taxonRankState = currentItem:getBestStatements('P105')[1] --taxon rank
				if taxonRankState then taxonRank = taxonRankState.mainsnak.datavalue.value.id end
				
				if taxonRank and taxonRank == 'Q7432' then --species
					--is monotypic species; add genus
					local parentTaxonState = currentItem:getBestStatements('P171')[1] --parent taxon
					if parentTaxonState then parentTaxon = parentTaxonState.mainsnak.datavalue.value.id end
					--confirm parent taxon rank == genus & monotypic
					if parentTaxon and resolveEntity._id(parentTaxon) then
						parentItem = mw.wikibase.getEntity(parentTaxon)
						if parentItem then
							local parentTaxonRankState = parentItem:getBestStatements('P105')[1] --taxon rank
							if parentTaxonRankState then parentTaxonRank = parentTaxonRankState.mainsnak.datavalue.value.id end
							if parentTaxonRank and parentTaxonRank == 'Q34740' then --parent == genus
								for _, parentInstanceOfState in pairs ( parentItem:getBestStatements('P31') ) do --instance of
									local parentInstanceOf = parentInstanceOfState.mainsnak.datavalue.value.id 
									if parentInstanceOf and
									  (parentInstanceOf == 'Q310890' or parentInstanceOf == 'Q47487597') then --monotypic/fossil taxon
										parentMonoGenus = parentTaxon --confirmed
										break
									end
								end
								if parentMonoGenus and tFroms[parentMonoGenus] == nil then
									--housekeeping
									tFroms[parentMonoGenus] = 1
									iFroms = iFroms + 1
									fromTitleCount = fromTitleCount + 1
									--append monotypic genus & track
									parentArgs['from'..fromTitleCount] = parentMonoGenus
									categories[17] = '[[Категория:Таксономичен контрол с автоматично добавени монотипни родове]]'
									break
								end
							end
						end
					end
					if parentMonoGenus == nil or tFroms[parentMonoGenus] == nil then
						categories[18] = '[[Категория:Таксономичен контрол на монотипни видове с липсващи родове]]'
						break
					end
				elseif taxonRank and taxonRank == 'Q34740' then --genus
					--is monotypic genus; add species
					--...
				end
				
			end
		end
	end --if currentItem
	
	--Setup navbox
	local navboxParams = {
		name  = 'Таксономичен контрол',
		bodyclass = 'hlist hlist-big plainlinks',
		listclass = '',
		groupstyle = 'text-align:left',
	}
	
	for f = 1, fromTitleCount, 1
	do
		local elements, title = {}, nil
		--cleanup parameters
		if parentArgs['from'..f] == '' then parentArgs['from'..f] = nil end
		if parentArgs['title'..f] == '' then parentArgs['title'..f] = nil end
		--remap aliases
		for _, a in pairs( conf.aliases ) do
			local alias, name = mw.ustring.lower(a[1]), mw.ustring.lower(a[2])
			if parentArgs[alias..f] and parentArgs[name..f] == nil then
				parentArgs[name..f] = parentArgs[alias..f]
				parentArgs[alias..f] = nil
			end
		end
		--Fetch Wikidata item
		local from = resolveEntity._id(parentArgs['from'..f])
		local item = mw.wikibase.getEntity(from)
		local label = nil
		if type(item) == 'table' then
			local statements = item:getBestStatements('P225')[1] --taxon name
			if statements then
				local datavalue = statements.mainsnak.datavalue
				if datavalue then
					label = datavalue.value
				end
			end
			label = label or item:getLabel()
		else
			if parentArgs['from'..f] then
				categories[1] = ''
				categories[4] = '[[Категория:Таксономичен контрол с невалидни from параметри]]'
				errors = errors .. mw.text.tag('strong', {class='error'}, 'Грешка: „' .. 
				         parentArgs['from'..f] .. '“ с невалиден идентификатор на обект в Уикиданни.<br />')				
			end
		end
		if label and label ~= '' then
			title = mw.title.new(label)
		end
		if title == nil and parentArgs['title'..f] then
			title = mw.title.new(parentArgs['title'..f])
		end
		if title == nil and f == 1 then
			title = currentTitle
		end
		
		if title then
			if isNilOrEmpty( parentArgs['wikidata'..f] ) and 
			   (title.namespace == 0) then
				if parentArgs['from'..f] then
					parentArgs['wikidata'..f] = parentArgs['from'..f]
				elseif item then
					parentArgs['wikidata'..f] = item.id
				end
			end
			if title.namespace == 0 or stringArgs then --only in mainspace or if manual overrides exist
				local sourceCount = 0
				for _, params in pairs( conf.databases ) do
					params[1] = mw.ustring.lower(params[1])
					local propId = params[3]
					--Wikidata fallback if requested
					if (item and item.claims) and
					   (type(propId) == 'string' or (type(propId) == 'number' and propId > 0)) then
						local wikidataId = getIdFromWikidata( item, 'P' .. propId )
						local v = parentArgs[params[1]..f]
						if wikidataId then
							if isNilOrEmpty(v) then
								parentArgs[params[1]..f] = wikidataId
							else
								if v and v ~= 'no' and v ~= wikidataId then
									categories[9] = '[[Категория:Таксономичен контрол с ръчно въведени идентификатори за таксони, различаващи се с тези от Уикиданни]]'
								elseif v and v == wikidataId then
									categories[10] = '[[Категория:Таксономичен контрол с ръчно въведени идентификатори за таксони, идентични с тези от Уикиданни]]'
								end
							end
						end
					end
					local val = parentArgs[params[1]..f]
					if val and val ~= '' and mw.ustring.lower(val) ~= 'no' then
						if type(propId) == 'number' then
							if propId < 0 then propId = -propId end --allow link
							if propId > 0 then --link
								table.insert( elements, createRow( params[1], params[2]..':', val, getLink( propId, val ).text, true ) )
							else --propId == 0; no link
								table.insert( elements, createRow( params[1], params[2]..':', val, val, true ) )
							end
						else
							table.insert( elements, createRow( params[1], params[2]..':', val, getLink( propId, val ).text, true ) )
						end
						if params[1] ~= 'wikidata' and params[1] ~= 'wikispecies' then
							sourceCount = sourceCount + 1
						end
					end
				end
				
				if     sourceCount >= 40 then categories[21] = '[[Категория:Таксономичен контрол с ≥40 идентификатора на таксони]]'
				elseif sourceCount >= 35 then categories[20] = '[[Категория:Таксономичен контрол с 35 – 39 идентификатора на таксони]]'
				elseif sourceCount >= 30 then categories[14] = '[[Категория:Таксономичен контрол с 30 – 34 идентификатора на таксони]]'
				elseif sourceCount >= 25 then categories[13] = '[[Категория:Таксономичен контрол с 25 – 29 идентификатора на таксони]]'
				elseif sourceCount >= 20 then categories[12] = '[[Категория:Таксономичен контрол с 20 – 24 идентификатора на таксони]]'
				end
				
				--Generate navbox title
				if sourceCount > 0 then
					rowCount = rowCount + 1
					if firstRow == 0 then firstRow = f end
					--set title from wikidata if it doesn't exist
					if isNilOrEmpty( parentArgs['title'..f] ) then
						parentArgs['noTitle'..f] = true
						parentArgs['title'..f] = title.text
					end
					--if it exists now, set row heading to title
					if not isNilOrEmpty( parentArgs['title'..f] ) then
						navboxParams['group'..f] = TaxonItalics.italicizeTaxonName(parentArgs['title'..f], false)
					else
						navboxParams['group'..f] = ''
					end
					navboxParams['list'..f] = table.concat( elements )
				elseif currentEntityId then
					categories[7] = '[[Категория:Страници, съдържащи таксономичен контрол без идентификатори на таксон от Уикиданни]]'
				end
				
				--Categorize
				if not isNilOrEmpty( parentArgs['from'..f] ) then
					--blank "missing from" if 'from' exists
					categories[1] = ''
					--blank "desynced" if 'from' matches current page
					if parentArgs['from'..f] == currentEntityId then categories[2] = '' end
				end
					--cannot be "desynced" if no 'from' params
				if categories[1] ~= '' then categories[2] = '' end
			end
		end
	end --for f = 1, fromTitleCount, 1
	
	if rowCount > 0 then
		local Navbox = require('Модул:Navbox')
		if rowCount > 1 then
			--remove duplicates and move page title to top
			local rowIDs = {}
			for f = 1,fromTitleCount,1
			do
				if not isNilOrEmpty( parentArgs['title'..f] ) then
					if rowIDs[parentArgs['wikidata'..f]] then --remove duplicate
						navboxParams['group'..f] = nil
						navboxParams['list'..f] = nil
					else
						rowIDs[parentArgs['wikidata'..f]] = true
						if f > firstRow and (parentArgs['title'..f] == currentTitle.text or 
						   parentArgs['wikidata'..f] == currentEntityId) then --move item linked to page to top
							if navboxParams['group'..f] and 
							   navboxParams['group'..f] ~= '' and 
							   navboxParams['list'..f] and 
							   navboxParams['list'..f] ~= '' then
								local tempGroup, tempList = navboxParams['group'..f], navboxParams['list'..f]
								navboxParams['group'..f], navboxParams['list'..f] = navboxParams['group'..firstRow], navboxParams['list'..firstRow]
								navboxParams['group'..firstRow], navboxParams['list'..firstRow] = tempGroup, tempList
							end
						end
					end
				end
			end
			--adjust navbox for number of rows
			navboxParams['title'] = 'Таксономичен контрол'
			if rowCount > 2 then
				navboxParams['navbar'] = 'plain'
			else
				navboxParams['state'] = 'off'
				navboxParams['navbar'] = 'off'
			end
		elseif parentArgs['noTitle'..firstRow] then
			navboxParams['group'..firstRow] = 'Таксономичен контрол'
		else
			navboxParams['group'..firstRow] = 'Таксономичен контрол<br />' .. navboxParams['group'..firstRow]
		end
		
		--return navbox
		outString = Navbox._navbox(navboxParams)
	end --if rowCount > 0
	
	--Add categories
	if string.sub(currentTitle.subpageText,1,9) == 'testcases' then parentArgs['demo'] = true end
	if not isNilOrEmpty( parentArgs['demo'] ) then
		outString = outString .. mw.text.nowiki(table.concat(categories)) .. '<br />'
	elseif currentTitle.namespace == 0 and outString ~= '' then
		outString = outString .. table.concat(categories)
	end
	return outString .. errors
end

return p
