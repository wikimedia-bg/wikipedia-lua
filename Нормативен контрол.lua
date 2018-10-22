function getCatForId( id )
    local title = mw.title.getCurrentTitle()
    local namespace = title.namespace
    if namespace == 0 then
        return '[[Категория:Уикипедия:Статии с нормативен контрол (' .. id .. ')]]'
    elseif namespace == 2 and not title.isSubpage then
        return '[[Категория:Уикипедия:Потребителски страници с нормативен контрол (' .. id .. ')]]'
    else
        return '[[Категория:Уикипедия:Други страници с нормативен контрол (' .. id .. ')]]'
    end
end

function viafLink( id )
    if not string.match( id, '^%d+$' ) then
        return false
    end
    return '[https://viaf.org/viaf/' .. id .. ' ' .. id .. ']' .. getCatForId( 'VIAF' )
end

function kulturnavLink( id )
    return '[http://kulturnav.org/language/en/' .. id .. ' id]'
end

function sikartLink( id )
    return '[http://www.sikart.ch/KuenstlerInnen.aspx?id=' .. id .. '&lng=en ' .. id .. ']'
end

function tlsLink( id )
	id2 = mw.ustring.gsub(id, '%s', function(s) return mw.uri.encode(s, 'WIKI') end)
    return '[http://tls.theaterwissenschaft.ch/wiki/' .. id2 .. ' ' .. id .. ']'
end


function ciniiLink( id )
    return '[http://ci.nii.ac.jp/author/' .. id .. '?l=en ' .. id .. ']'
end

function bneLink( id )
    return '[http://catalogo.bne.es/uhtbin/authoritybrowse.cgi?action=display&authority_id=' .. id .. ' ' .. id .. ']'
end


function uscongressLink( id )
    return '[http://bioguide.congress.gov/scripts/biodisplay.pl?index=' .. id .. ' ' .. id .. ']'
end

function narapersonLink( id )
    return '[http://research.archives.gov/person/' .. id .. ' ' .. id .. ']'
end

function naraorganizationLink( id )
    return '[http://research.archives.gov/organization/' .. id .. ' ' .. id .. ']'
end

function botanistLink( id )
	id2 = mw.ustring.gsub(id, '%s', function(s) return mw.uri.encode(s, 'PATH') end)
    return '[http://www.ipni.org/ipni/advAuthorSearch.do?find_abbreviation=' .. id2 .. ' ' .. id .. ']'
end

function mgpLink( id )
    -- TODO Implement some sanity checking regex
    return '[http://www.genealogy.ams.org/id.php?id=' .. id .. ' ' .. id .. ']'
end

function rslLink( id )
    -- TODO Implement some sanity checking regex
    return '[http://aleph.rsl.ru/F?func=find-b&find_code=SYS&adjacent=Y&local_base=RSL11&request=' .. id .. '&CON_LNG=ENG ' .. id .. ']'
end

function leonoreLink( id )
-- Identifiants allant de LH/1/1 à LH/2794/54 (légionnaires)
-- Identifiants allant de C/0/1 à C/0/84 (84 légionnaires célèbres)
-- Identifiants allant de 19800035/1/1 à 19800035/385/51670 (légionnaires décédés entre 1954 et 1977, et quelques dossiers de légionnaires décédés avant 1954)
    if not string.match( id, '^LH/%d%d?%d?%d?/%d%d?%d?$' ) and
       not string.match( id, '^C/0/%d%d?$' ) and
	   not string.match( id, '^19800035/%d%d?%d?%d?/%d%d?%d?%d?%d?$' ) then
        return false
    end
    return '[//www.culture.gouv.fr/public/mistral/leonore_fr?ACTION=CHERCHER&FIELD_1=COTE&VALUE_1=' .. id .. ' ' .. id .. ']'
end

function sbnLink( id )
    if not string.match( id, '^IT\\ICCU\\%d%d%d%d%d%d%d%d%d%d$' ) and not string.match( id, '^IT\\ICCU\\%u%u[%d%u]%u\\%d%d%d%d%d%d$' ) then
        return false
    end
    return '[http://opac.sbn.it/opacsbn/opac/iccu/scheda_authority.jsp?bid=' .. id .. ' ' .. id .. ']'
end

function nkcLink( id )
	return '[http://aleph.nkp.cz/F/?func=find-c&local_base=aut&ccl_term=ica=' .. id .. '&CON_LNG=ENG ' .. id .. ']'
end

function nclLink( id )
    if not string.match( id, '^%d+$' ) then
        return false
    end
    return '[http://aleweb.ncl.edu.tw/F/?func=accref&acc_sequence=' .. id .. '&CON_LNG=ENG ' .. id .. ']'
end

function ndlLink( id )
	return '[http://id.ndl.go.jp/auth/ndlna/' .. id .. ' ' .. id .. ']'
end

function sudocLink( id )
    if not string.match( id, '^%d%d%d%d%d%d%d%d[%dxX]$' ) then
        return false
    end
    return '[http://www.idref.fr/' .. id .. ' ' .. id .. ']'
end

function hlsLink( id )
    if not string.match( id, '^%d+$' ) then
        return false
    end
    return '[http://www.hls-dhs-dss.ch/textes/f/F' .. id .. '.php ' .. id .. ']'
end

function lirLink( id )
    if not string.match( id, '^%d+$' ) then
        return false
    end
    return '[http://www.e-lir.ch/e-LIR___Lexicon.' .. id .. '.450.0.html ' .. id .. ']'
end

function lccnLink( id )
    local parts = splitLccn( id )
    if not parts then
        return false
    end
    id = parts[1] .. parts[2] .. append( parts[3], '0', 6 )
    return '[http://id.loc.gov/authorities/names/' .. id .. ' ' .. id .. ']' .. getCatForId( 'LCCN' )
end

function mbLink( id )
    -- TODO Implement some sanity checking regex
    return '[//musicbrainz.org/artist/' .. id .. ' ' .. id .. ']' .. getCatForId( 'MusicBrainz' )
end

function splitLccn( id )
    if id:match( '^%l%l?%l?%d%d%d%d%d%d%d%d%d?%d?$' ) then
        id = id:gsub( '^(%l+)(%d+)(%d%d%d%d%d%d)$', '%1/%2/%3' )
    end
    if id:match( '^%l%l?%l?/%d%d%d?%d?/%d+$' ) then
         return mw.text.split( id, '/' )
    end
    return false
end

function append(str, c, length)
    while str:len() < length do
        str = c .. str
    end
    return str
end

function isniLink( id )
    id = validateIsni( id )
    if not id then
        return false
    end
    return '[http://isni.org/' .. id .. ' ' .. id:sub( 1, 4 ) .. ' ' .. id:sub( 5, 8 ) .. ' '  .. id:sub( 9, 12 ) .. ' '  .. id:sub( 13, 16 ) .. ']' .. getCatForId( 'ISNI' )
end

--Validate ISNI (and ORCID) and retuns it as a 16 characters string or returns false if it's invalid
--See http://support.orcid.org/knowledgebase/articles/116780-structure-of-the-orcid-identifier
function validateIsni( id )
    id = id:gsub( '[ %-]', '' ):upper()
    if not id:match( '^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d[%dX]$' ) then
        return false
    end
    if getIsniCheckDigit( id ) ~= string.char( id:byte( 16 ) ) then
        return false
    end
    return id
end

--Returns the ISNI check digit isni must be a string where the 15 first elements are digits
function getIsniCheckDigit( isni )
    local total = 0
    for i = 1, 15 do
        local digit = isni:byte( i ) - 48 --Get integer value
        total = (total + digit) * 2
    end
    local remainder = total % 11
    local result = (12 - remainder) % 11
    if result == 10 then
        return "X"
    end
    return tostring( result )
end

function orcidLink( id )
    id = validateIsni( id )
    if not id then
        return false
    end
    id = id:sub( 1, 4 ) .. '-' .. id:sub( 5, 8 ) .. '-'  .. id:sub( 9, 12 ) .. '-'  .. id:sub( 13, 16 )
    return '[http://orcid.org/' .. id .. ' ' .. id .. ']' .. getCatForId( 'ORCID' )
end

function gndLink( id )
    return '[http://d-nb.info/gnd/' .. id .. ' ' .. id .. ']' .. getCatForId( 'GND' )
end

function selibrLink( id )
	if not string.match( id, '^%d+$' ) then
        return false
    end
    return '[//libris.kb.se/auth/' .. id .. ' ' .. id .. ']' .. getCatForId( 'SELIBR' )
end

function bnfLink( id )
    --Add cb prefix if it has been removed
    if not string.match( id, '^cb.+$' ) then
        id = 'cb' .. id
    end

    return '[http://catalogue.bnf.fr/ark:/12148/' .. id .. ' ' .. id .. '] [http://data.bnf.fr/ark:/12148/' .. id .. ' (архив)]' .. getCatForId( 'BNF' )
end

function bpnLink( id )
    if not string.match( id, '^%d+$' ) then
        return false
    end
    return '[http://www.biografischportaal.nl/en/persoon/' .. id .. ' ' .. id .. ']' .. getCatForId( 'BPN' )
end

function ridLink( id )
    return '[http://www.researcherid.com/rid/' .. id .. ' ' .. id .. ']' .. getCatForId( 'RID' )
end

function bibsysLink( id )
    return '[http://ask.bibsys.no/ask/action/result?cmd=&kilde=biblio&cql=bs.autid+%3D+' .. id .. '&feltselect=bs.autid ' .. id .. ']' .. getCatForId( 'BIBSYS' )
end

function ulanLink( id )
    return '[//www.getty.edu/vow/ULANFullDisplay?find=&role=&nation=&subjectid=' .. id .. ' ' .. id .. ']' .. getCatForId( 'ULAN' )
end

function nlaLink( id )
	return '[//nla.gov.au/anbd.aut-an' .. id .. ' ' .. id .. ']' .. getCatForId( 'NLA' )
end

local function rkdartistsLink( id )
	return '[https://rkd.nl/en/explore/artists/' .. id .. ' ' .. id .. ']' .. getCatForId( 'RKDartists' )
end

local function NLGIDLink( id )
    return '[https://catalogue.nlg.gr/Authority/Record?id=au.' .. id .. ' ' .. id .. ']' .. getCatForId( 'EBE' )
end

local function BNeditionLink( id )
    return '[http://www.biblionet.gr/main.asp?page=showbook&bookid=' .. id .. ' ' .. id .. ']' .. getCatForId( 'BiblioNet' )
end

local function BNpersonLink( id )
    return '[http://www.biblionet.gr/main.asp?page=showauthor&personsid=' .. id .. ' ' .. id .. ']' .. getCatForId( 'BiblioNet' )
end

local function BNpublisherLink( id )
    return '[http://www.biblionet.gr/com/' .. id .. ' ' .. id .. ']'.. getCatForId( 'BiblioNet' )
end

local function freebaseLink( id )
	return '[https://g.co/kg' .. id .. ' ' .. id .. ']' .. getCatForId( 'Freebase' )
end

local function jstorLink( id )
	return '[https://www.jstor.org/topic/' .. id .. ' ' .. id .. ']' .. getCatForId( 'JSTOR' )
end

local function newwLink( id )
	return '[http://resources.huygens.knaw.nl/womenwriters/vre/persons/' .. id .. ' ' .. id .. ']' .. getCatForId( 'NEWW' )
end

local function fastLink( id )
	return '[https://experimental.worldcat.org/fast/' .. id .. '/ ' .. id .. ']' .. getCatForId( 'FAST' )
end

local function aatLink( id )
	return '[http://vocab.getty.edu/page/aat/' .. id .. ' ' .. id .. ']' .. getCatForId( 'AAT')
end

local function koninklijkeLink( id )
	return '[http://data.bibliotheken.nl/doc/thes/p' .. id .. ' ' .. id .. ']' .. getCatForId( 'Koninklijke')
end

local function openLibraryLink( id )
	return '[https://openlibrary.org/works/' .. id .. ' ' .. id .. ']' .. getCatForId( 'OpenLibrary')
end

function getIdsFromWikidata( item, property )
    local ids = {}
    if not item.claims[property] then
        return ids
    end
    for _, statement in pairs( item.claims[property] ) do
        table.insert( ids, statement.mainsnak.datavalue.value )
    end
    return ids
end

function matchesWikidataRequirements( item, reqs )
    for _, group in pairs( reqs ) do
        local property = 'P' .. group[1]
        local qid = group[2]
        if item.claims[property] ~= nil then
            for _, statement in pairs ( item.claims[property] ) do
            	if statement.mainsnak.datavalue ~= nil then
	                if statement.mainsnak.datavalue.value['numeric-id'] == qid then
    	                return true
        	        end
        	    end
            end
        end
    end
    return false
end

function createRow( id, label, rawValue, link, withUid )
    if link then
        if withUid then
            return '* ' .. label .. ' <span class="uid">' .. link .. '</span>\n'
        else
            return '* ' .. label .. ' ' .. link .. '\n'
        end
    else
        return '* <span class="error">The ' .. id .. ' id ' .. rawValue .. ' is not valid.</span>[[Category:Wikipedia articles with faulty authority control identifiers (' .. id .. ')]]\n'
    end
end

--In this order: name of the parameter, label, propertyId in Wikidata, formatting function
local conf = {
    { 'VIAF', '[[Виртуален международен нормативен архив|VIAF]]', 214, viafLink },
    { 'LCCN', '[[Контролен номер на Библиотеката на Конгреса|LCCN]]', 244, lccnLink },
    { 'ISNI', '[[Международен стандартен идентификатор на имена|ISNI]]', 213, isniLink },
    { 'ORCID', '[[ORCID]]', 496, orcidLink },
    { 'GND', '[[Колективен нормативен архив|GND]]', 227, gndLink },
    { 'SELIBR', '[[LIBRIS|SELIBR]]', 906, selibrLink },
    { 'SUDOC', '[[Система за университетска документацията на Франция|SUDOC]]', 269, sudocLink },
    { 'BNF', '[[Национална библиотека на Франция|BNF]]', 268, bnfLink },
    { 'BPN', '[[Биографичен портал|BPN]]', 651, bpnLink },
    { 'RID', '[[ResearcherID]]', 1053, ridLink },
    { 'BIBSYS', '[[BIBSYS]]', 1015, bibsysLink },
    { 'ULAN', '[[Колективен архив на авторските имена|ULAN]]', 245, ulanLink },
    { 'HDS', '[[Швейцарски исторически лексикон|HDS]]', 902, hlsLink },
    { 'LIR', '[[Швейцарски исторически лексикон#Творби|LIR]]', 886, lirLink },
    { 'MBA', '[[MusicBrainz]]', 434, mbLink },
    { 'MGP', '[[Математическа генеалогия|MGP]]', 549, mgpLink },
    { 'NLA', '[[Национална библиотека на Австралия|NLA]]', 409, nlaLink },
    { 'NDL', '[[Национална парламентарна библиотека (Япония)|NDL]]', 349, ndlLink },
    { 'NCL', '[[Националнa централна библиотека (Тайван)|NCL]]', 1048, nclLink },
    { 'NKC', '[[Национална библиотека на Чехия|NKC]]', 691, nkcLink },
    { 'Léonore', '[[:fr:Base Léonore|Léonore]]', 640, leonoreLink },
    { 'SBN', '[[:it:Istituto centrale per il catalogo unico delle biblioteche italiane e per le informazioni bibliografiche|ICCU]]', 396, sbnLink },
    { 'RLS', '[[Руска държавна библиотека|RLS]]', 947, rslLink },
    { 'Botanist', '[[Авторски цитат (ботаника)|Botanist]]', 428, botanistLink },
    { 'NARA-person', '[[Национално управление на архивите и документите на САЩ|NARA]]', 1222, narapersonLink },
    { 'NARA-organization', '[[Национално управление на архивите и документите на САЩ|NARA]]', 1223, naraorganizationLink },
    { 'USCongress', '[[Биографичен лексикон на американския Конгрес|US Congress]]', 1157, uscongressLink },
    { 'BNE', '[[Национална библиотека на Испания|BNE]]', 950, bneLink },
    { 'CINII', '[[CiNii]]', 271, ciniiLink },
    { 'TLS', '[[Швейцарски театрален лексикон|TLS]]', 1362, tlsLink },
    { 'SIKART', '[[SIKART]]', 781, sikartLink },
    { 'KULTURNAV', '[[KulturNav]]', 1248, kulturnavLink },
    { 'RKDartists', '[[Нидерландски институт за история на изкуството|RKD]]', 650, rkdartistsLink },
    { 'NLG', '[[Национална библиотека на Гърция|ΕΒΕ]]', 3348, NLGIDLink },
    { 'BNed', '[[BiblioNet]]', 2187, BNeditionLink },
    { 'BNper', '[[BiblioNet]]', 2188, BNpersonLink },
    { 'BNpub', '[[BiblioNet]]', 2189, BNpublisherLink },
    { 'Freebase', '[[:en:Freebase|Freebase]]', 646, freebaseLink },
    { 'JSTOR', '[[JSTOR]]', 3827, jstorLink },
    { 'NEWW', 'NEWW Women Writers', 2533, newwLink },
    { 'FAST', 'FAST', 2163, fastLink },
    { 'AAT', 'Art & Architecture Thesaurus', 1014, aatLink },
    { 'Koninklijke', '[[Национална библиотека на Нидерландия|Koninklijke]]', 1006, koninklijkeLink },
    { 'OpenLibrary', 'Open Library', 648, openLibraryLink },
}

-- Check that the Wikidata item has this property-->value before adding it
local reqs = {}
reqs['MBA'] = {
    { 106, 177220 }, -- occupation -> singer
    { 31, 177220 }, -- instance of -> singer
    { 106, 13385019 }, -- occupation -> rapper
    { 31, 13385019 }, -- instance of -> rapper
    { 106, 639669 }, -- occupation -> musician
    { 31, 639669 }, -- instance of -> musician
    { 106, 36834 }, -- occupation -> composer
    { 31, 36834 }, -- instance of -> composer
    { 106, 488205 }, -- occupation -> singer-songwriter
    { 31, 488205 }, -- instance of -> singer-songwriter
    { 106, 183945 }, -- occupation -> record producer
    { 31, 183945 }, -- instance of -> record producer
    { 106, 10816969 }, -- occupation -> club DJ
    { 31, 10816969 }, -- instance of -> club DJ
    { 106, 130857 }, -- occupation -> DJ
    { 31, 130857 }, -- instance of -> DJ
    { 106, 158852 }, -- occupation -> conductor
    { 31, 158852 }, -- instance of -> conductor
    { 31, 215380 }, -- instance of -> band
    { 31, 5741069 }, -- instance of -> rock band
}

local p = {}

function p.authorityControl( frame )
    local parentArgs = frame:getParent().args
    --Create rows
    local elements = {}

    --redirect PND to GND
    if (parentArgs.GND == nil or parentArgs.GND == '') and parentArgs.PND ~= nil and parentArgs.PND ~= '' then
        parentArgs.GND = parentArgs.PND
    end

    --Wikidata fallback if requested
    local item = mw.wikibase.getEntityObject()
    if item ~= nil and item.claims ~= nil then
        for _, params in pairs( conf ) do
            if params[3] ~= 0 then
                local val = parentArgs[params[1]]
                if not val or val == '' then
                	local canUseWikidata = nil
                    if reqs[params[1]] ~= nil then
                        canUseWikidata = matchesWikidataRequirements( item, reqs[params[1]] )
                    else
                        canUseWikidata = true
                    end
                    if canUseWikidata then
                        local wikidataIds = getIdsFromWikidata( item, 'P' .. params[3] )
                        if wikidataIds[1] then
                            parentArgs[params[1]] = wikidataIds[1]
                        end
                    end
                end
            end
        end
    end

    --Worldcat
    if parentArgs['WORLDCATID'] and parentArgs['WORLDCATID'] ~= '' then
        table.insert( elements, createRow( 'WORLDCATID', '', parentArgs['WORLDCATID'], '[http://www.worldcat.org/identities/' .. parentArgs['WORLDCATID'] .. ' WorldCat]', false ) ) --Validation?
    elseif parentArgs['LCCN'] and parentArgs['LCCN'] ~= '' then
        local lccnParts = splitLccn( parentArgs['LCCN'] )
        if lccnParts then
            table.insert( elements, createRow( 'LCCN', '', parentArgs['LCCN'], '[http://www.worldcat.org/identities/lccn-' .. lccnParts[1] .. lccnParts[2] .. '-' .. lccnParts[3] .. ' WorldCat]', false ) )
        end
    end

    --Configured rows
    for k, params in pairs( conf ) do
        local val = parentArgs[params[1]]
        if val and val ~= '' then
            table.insert( elements, createRow( params[1], params[2] .. ':', val, params[4]( val ), true ) )
        end
    end
    local Navbox = require('Модул:Navbox')
    return Navbox._navbox( {
        name  = 'Authority control',
        bodyclass = 'hlist',
        group1 = '[[Нормативен контрол]]',
        list1 = table.concat( elements )
    } )
end

return p
