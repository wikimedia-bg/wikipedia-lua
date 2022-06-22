local p = {}

--[[==========================================================================]]
--[[                              Local functions                             ]]
--[[==========================================================================]]

--- Creates a label that links to an article in the main namespace.
-- The link is external ([...], not [[...]]), so the 'What links here' results
-- don't get polluted from the widely transcluded authority control template.
-- See also https://bg.wikipedia.org/w/index.php?oldid=10493105
-- @param article The name of the article to be linked to in the label
-- @param text[opt=article] The text for the label (defaults to article name)
-- @return A string representing an external link in MediaWiki markup
local function linkedLabel( article, text )
	-- If 'text' is not provided, show the article name as text of the link.
	text = text or article
	local page = mw.title.makeTitle( 0, article )
	return '[' .. page:fullUrl() .. ' ' .. text .. ']'
end

--[[==========================================================================]]
--[[                            Category functions                            ]]
--[[==========================================================================]]

function p.getCatForId( id )
	local title = mw.title.getCurrentTitle()
	local namespace = title.namespace
	local catName = ''
	if namespace == 0 then
		catName = 'Уикипедия:Статии с нормативен контрол (' .. id .. ')'
	elseif namespace == 2 and not title.isSubpage then
		catName = 'Уикипедия:Потребителски страници с нормативен контрол'
	else
		catName = 'Уикипедия:Други страници с нормативен контрол'
	end
	catName = (id == 'Europeana' and 'Europeana') or catName
	return '[[Категория:' .. catName .. ']]'
end

--[[==========================================================================]]
--[[                      Property formatting functions                       ]]
--[[==========================================================================]]

function p.iaafLink( id )
	--P1146's format regex: [0-9][0-9]* (e.g. 123)
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[https://www.worldathletics.org/athletes/_/'..id..' '..id..']'..p.getCatForId( 'IAAF' )
end

function p.viafLink( id )
	--P214's format regex: [1-9]\d(\d{0,7}|\d{17,20}) (e.g. 123456789, 1234567890123456789012)
	if not string.match( id, '^[1-9]%d%d?%d?%d?%d?%d?%d?%d?$' ) and
	   not string.match( id, '^[1-9]%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d?%d?%d?$' ) then
		return false
	end
	return '[https://viaf.org/viaf/'..id..' '..id..']'..p.getCatForId( 'VIAF' )
end

function p.kulturnavLink( id )
	--P1248's format regex: [0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[http://kulturnav.org/'..id..' '..id..']'..p.getCatForId( 'KULTURNAV' ) --no https yet (10/2018)
end

function p.sikartLink( id )
	--P781's format regex: \d{7,9} (e.g. 123456789)
	if not string.match( id, '^%d%d%d%d%d%d%d%d?%d?$' ) then
		return false
	end
	return '[http://www.sikart.ch/KuenstlerInnen.aspx?id='..id..'&lng=en '..id..']'..p.getCatForId( 'SIKART' ) --no https yet (10/2018)
end

function p.tlsLink( id )
	local id2 = id:gsub(' +', '_')
	--P1362's format regex: \p{Lu}[\p{L}\d_',\.\-\(\)\*/–]{3,59} (e.g. Abcd)
	local class = "[%a%d_',%.%-%(%)%*/–]"
	local regex = "^%u"..string.rep(class, 3)..string.rep(class.."?", 56).."$"
	if not mw.ustring.match( id2, regex ) then
		return false
	end
	return '[http://tls.theaterwissenschaft.ch/wiki/'..id2..' '..id..']'..p.getCatForId( 'TLS' ) --no https yet (10/2018)
end

function p.ciniiLink( id )
	--P271's format regex: DA\d{7}[\dX] (e.g. DA12345678)
	if not string.match( id, '^DA%d%d%d%d%d%d%d[%dX]$' ) then
		return false
	end
	return '[https://ci.nii.ac.jp/author/'..id..' '..id..']'..p.getCatForId( 'CINII' )
end

function p.bneLink( id )
	--P950's format regex: (XX|a)\d{4,7}|(bima|bimo|bise|bivi|Mise|Mimo|Mima)\d{10} (e.g. XX1234567)
	if not string.match( id, '^XX%d%d%d%d%d?%d?%d?$' ) and
	   not string.match( id, '^a%d%d%d%d%d?%d?%d?$' ) and
	   not string.match( id, '^bi[msv][aoei]%d%d%d%d%d%d%d%d%d%d$' ) and
	   not string.match( id, '^Mi[sm][eoa]%d%d%d%d%d%d%d%d%d%d$' ) then
		return false
	end
	return '[http://datos.bne.es/resource/'..id..' '..id..']'..p.getCatForId( 'BNE' ) --no https yet (10/2018)
end

function p.uscongressLink( id )
	--P1157's format regex: [A-Z]00[01]\d{3} (e.g. A000123)
	if not string.match( id, '^[A-Z]00[01]%d%d%d$' ) then
		return false
	end
	return '[http://bioguide.congress.gov/scripts/biodisplay.pl?index='..id..' '..id..']'..p.getCatForId( 'USCongress' ) --no https yet (10/2018)
end

function p.naraLink( id )
	--P1225's format regex: ^([1-9]\d{0,8})$ (e.g. 123456789)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://catalog.archives.gov/id/'..id..' '..id..']'..p.getCatForId( 'NARA' )
end

function p.botanistLink( id )
	--P428's format regex: ('t )?(d')?(de )?(la )?(van (der )?)?(Ma?c)?(De)?(Di)?\p{Lu}?C?['\p{Ll}]*([-'. ]*(van )?(y )?(d[ae][nr]?[- ])?(Ma?c)?[\p{Lu}bht]?C?['\p{Ll}]*)*\.? ?f?\.? (e.g. L.)
	--not easily/meaningfully implementable in Lua's regex since "(this)?" is not allowed...
	if not mw.ustring.match( id, "^[%u%l%d%. '-]+$" ) then --better than nothing
		return false
	end
	local id2 = id:gsub(' +', '%%20')
	return '[https://www.ipni.org/ipni/advAuthorSearch.do?find_abbreviation='..id2..' '..id..']'..p.getCatForId( 'Botanist' )
end

function p.mgpLink( id )
	--P549's format regex: \d{1,6} (e.g. 123456)
	if not string.match( id, '^%d%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://genealogy.math.ndsu.nodak.edu/id.php?id='..id..' '..id..']'..p.getCatForId( 'MGP' ) --no https yet (10/2018)
end

function p.rslLink( id )
	--P947's format regex: \d{1,9} (e.g. 123456789)
	if not string.match( id, '^%d%d?%d?%d?%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[http://aleph.rsl.ru/F?func=find-b&find_code=SYS&adjacent=Y&local_base=RSL11&request='..id..'&CON_LNG=ENG '..id..']'..p.getCatForId( 'RSL' ) --no https yet (10/2018)
end

function p.leonoreLink( id )
	--P640's format regex: LH/\d{1,4}/\d{1,3}|19800035/\d{1,4}/\d{1,5}(Bis)?|C/0/\d{1,2} (e.g. LH/2064/18)
	if not id:match( '^LH/%d%d?%d?%d?/%d%d?%d?$' ) and             --IDs from       LH/1/1 to         LH/2794/54 (legionaries)
	   not id:match( '^19800035/%d%d?%d?%d?/%d%d?%d?%d?%d?$' ) and --IDs from 19800035/1/1 to 19800035/385/51670 (legionnaires who died 1954-1977 & some who died < 1954)
	   not id:match( '^C/0/%d%d?$' ) then                          --IDs from        C/0/1 to             C/0/84 (84 famous legionaries)
		return false
	end
	return '[http://www.culture.gouv.fr/public/mistral/leonore_fr?ACTION=CHERCHER&FIELD_1=COTE&VALUE_1='..id..' '..id..']'..p.getCatForId( 'Léonore' ) --no https yet (10/2018)
end

function p.sbnLink( id )
	--P396's format regex: \D{2}[A-Z0-3]V\d{6} (e.g. IT\ICCU\CFIV\000163)
	if not string.match( id, '^%D%D[A-Z0-3]V%d%d%d%d%d%d$' ) then
		return false
	end
	return '[https://opac.sbn.it/risultati-autori/-/opac-autori/detail/'..id..' '..id..']'..p.getCatForId( 'SBN' )
end

function p.nkcLink( id )
	--P691's format regex: [a-z]{2,4}[0-9]{2,14} (e.g. abcd12345678901234)
	if not string.match( id, '^[a-z][a-z][a-z]?[a-z]?%d%d%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://aleph.nkp.cz/F/?func=find-c&local_base=aut&ccl_term=ica='..id..' '..id..']'..p.getCatForId( 'NKC' )
end

function p.nclLink( id )
	--P1048's format regex: \d+ (e.g. 1081436)
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[http://aleweb.ncl.edu.tw/F/?func=accref&acc_sequence='..id..' '..id..']'..p.getCatForId( 'NCL' ) --no https yet (10/2018)
end

function p.ndlLink( id )
	--P349's format regex: 0?\d{8} (e.g. 012345678)
	if not string.match( id, '^0?%d%d%d%d%d%d%d%d$' ) then
		return false
	end
	return '[https://id.ndl.go.jp/auth/ndlna/'..id..' '..id..']'..p.getCatForId( 'NDL' )
end

function p.sudocLink( id )
	--P269's format regex: (\d{8}[\dX]|) (e.g. 026927608)
	if not string.match( id, '^%d%d%d%d%d%d%d%d[%dxX]$' ) then --legacy: allow lowercase 'x'
		return false
	end
	return '[https://www.idref.fr/'..id..' '..id..']'..p.getCatForId( 'SUDOC' )
end

function p.hdsLink( id )
	--P902's format regex: \d{6} (e.g. 50123)
	if not string.match( id, '^%d%d%d%d%d%d$' )then
		return false
	end
	return '[https://hls-dhs-dss.ch/de/articles/'..id..' '..id..']'..p.getCatForId( 'HDS' )
end

function p.lirLink( id )
	--P886's format regex: \d+ (e.g. 1)
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[http://www.e-lir.ch/e-LIR___Lexicon.'..id..'.450.0.html '..id..']'..p.getCatForId( 'LIR' ) --no https yet (10/2018)
end

function p.splitLccn( id )
	--P244's format regex: (n|nb|nr|no|ns|sh)([4-9][0-9]|00|20[0-1][0-9])[0-9]{6} (e.g. n78039510)
	if id:match( '^%l%l?%l?%d%d%d%d%d%d%d%d%d?%d?$' ) then
		id = id:gsub( '^(%l+)(%d+)(%d%d%d%d%d%d)$', '%1/%2/%3' )
	end
	if id:match( '^%l%l?%l?/%d%d%d?%d?/%d+$' ) then
		return mw.text.split( id, '/' )
	end
	return false
end

function p.append(str, c, length)
	while str:len() < length do
		str = c .. str
	end
	return str
end

function p.lccnLink( id )
	local parts = p.splitLccn( id ) --e.g. n78039510
	if not parts then
		return false
	end
	local lccnType = parts[1] ~= 'sh' and 'names' or 'subjects'
	id = parts[1] .. parts[2] .. p.append( parts[3], '0', 6 )
	return '[https://id.loc.gov/authorities/'..lccnType..'/'..id..' '..id..']'..p.getCatForId( 'LCCN' )
end

function p.mbaLink( id )
	--P434's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/artist/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz' )
end

function p.mbareaLink( id )
	--P982's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/area/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz area' )
end

function p.mbiLink( id )
	--P1330's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/instrument/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz instrument' )
end

function p.mblLink( id )
	--P966's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/label/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz label' )
end

function p.mbpLink( id )
	--P1004's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/place/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz place' )
end

function p.mbrgLink( id )
	--P436's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/release-group/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz release group' )
end

function p.mbsLink( id )
	--P1407's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/series/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz series' )
end

function p.mbwLink( id )
	--P435's format regex: [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} (e.g. 12345678-1234-1234-1234-1234567890AB)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[https://musicbrainz.org/work/'..id..' '..id..']'..p.getCatForId( 'MusicBrainz work' )
end

--Returns the ISNI check digit isni must be a string where the 15 first elements are digits, e.g. 0000000066534145
function p.getIsniCheckDigit( isni )
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

--Validate ISNI (and ORCID) and retuns it as a 16 characters string or returns false if it's invalid
--See http://support.orcid.org/knowledgebase/articles/116780-structure-of-the-orcid-identifier
function p.validateIsni( id )
	--P213 (ISNI) format regex: [0-9]{4} [0-9]{4} [0-9]{4} [0-9]{3}[0-9X] (e.g. 0000-0000-6653-4145)
	--P496 (ORCID) format regex: 0000-000(1-[5-9]|2-[0-9]|3-[0-4])\d{3}-\d{3}[\dX] (e.g. 0000-0002-7398-5483)
	id = id:gsub( '[ %-]', '' ):upper()
	if not id:match( '^%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d[%dX]$' ) then
		return false
	end
	if p.getIsniCheckDigit( id ) ~= string.char( id:byte( 16 ) ) then
		return false
	end
	return id
end

function p.isniLink( id )
	id = p.validateIsni( id ) --e.g. 0000-0000-6653-4145
	if not id then
		return false
	end
	return '[http://isni.org/isni/'..id..' '..id:sub( 1, 4 )..' '..id:sub( 5, 8 )..' '..id:sub( 9, 12 )..' '..id:sub( 13, 16 )..']'..p.getCatForId( 'ISNI' ) --no https yet (10/2018)
end

function p.orcidLink( id )
	id = p.validateIsni( id ) --e.g. 0000-0002-7398-5483
	if not id then
		return false
	end
	id = id:sub( 1, 4 )..'-'..id:sub( 5, 8 )..'-'..id:sub( 9, 12 )..'-'..id:sub( 13, 16 )
	return '[https://orcid.org/'..id..' '..id..']'..p.getCatForId( 'ORCID' )
end

function p.gndLink( id )
	--P227's format regex: 1[012]?\d{7}[0-9X]|[47]\d{6}-\d|[1-9]\d{0,7}-[0-9X]|3\d{7}[0-9X] (e.g. 4079154-3)
	if not string.match( id, '^1[012]?%d%d%d%d%d%d%d[0-9X]$' ) and
	   not string.match( id, '^[47]%d%d%d%d%d%d%-%d$' ) and
	   not string.match( id, '^[1-9]%d?%d?%d?%d?%d?%d?%d?%-[0-9X]$' ) and
	   not string.match( id, '^3%d%d%d%d%d%d%d[0-9X]$' ) then
		return false
	end
	return '[https://d-nb.info/gnd/'..id..' '..id..']'..p.getCatForId( 'GND' )
end

function p.selibrLink( id )
	--P906's format regex: [1-9]\d{4,5} (e.g. 123456)
	if not string.match( id, '^[1-9]%d%d%d%d%d?$' ) then
		return false
	end
	return '[https://libris.kb.se/auth/'..id..' '..id..']'..p.getCatForId( 'SELIBR' )
end

function p.bnfLink( id )
	--P268's format regex: \d{8,9}[0-9bcdfghjkmnpqrstvwxz] (e.g. 123456789)
	if not string.match( id, '^c?b?%d?%d%d%d%d%d%d%d%d[0-9bcdfghjkmnpqrstvwxz]$' ) then
		return false
	end
	--Add cb prefix if it has been removed
	if not string.match( id, '^cb.+$' ) then
		id = 'cb'..id
	end
	return '[https://catalogue.bnf.fr/ark:/12148/'..id..' '..id..'] [http://data.bnf.fr/ark:/12148/'..id..' (данни)]'..p.getCatForId( 'BNF' )
end

function p.bpnLink( id )
	--P651's format regex: \d{6,8} (e.g. 123456)
	if not string.match( id, '^%d%d%d%d%d%d%d?%d?$' ) then
		return false
	end
	return '[http://www.biografischportaal.nl/en/persoon/'..id..' '..id..']'..p.getCatForId( 'BPN' ) --no https yet (10/2018)
end

function p.ridLink( id )
	--P1053's format regex: [A-Z]+-\d{4}-(19|20)\d\d (e.g. A-1234-1934)
	if not string.match( id, '^[A-Z]+%-%d%d%d%d%-19%d%d$' ) and
	   not string.match( id, '^[A-Z]+%-%d%d%d%d%-20%d%d$' ) then
		return false
	end
	return '[https://www.researcherid.com/rid/'..id..' '..id..']'..p.getCatForId( 'RID' )
end

function p.bibsysLink( id )
	--P1015's format regex: [1-9]\d* (e.g. 1234567890123)
	if not string.match( id, '^[1-9]%d*$' ) then
		return false
	end
	return '[https://authority.bibsys.no/authority/rest/authorities/html/'..id..' '..id..']'..p.getCatForId( 'BIBSYS' )
end

function p.ulanLink( id )
	--P245's format regex: 500\d{6} (e.g. 500123456)
	if not string.match( id, '^500%d%d%d%d%d%d$' ) then
		return false
	end
	return '[https://www.getty.edu/vow/ULANFullDisplay?find=&role=&nation=&subjectid='..id..' '..id..']'..p.getCatForId( 'ULAN' )
end

function p.nlaLink( id )
	--P409's format regex: [1-9][0-9]{0,11} (e.g. 123456789012)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://nla.gov.au/anbd.aut-an'..id..' '..id..']'..p.getCatForId( 'NLA' )
end

function p.rkdartistsLink( id )
	--P650's format regex: [1-9]\d{0,5} (e.g. 123456)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://rkd.nl/en/explore/artists/'..id..' '..id..']'..p.getCatForId( 'RKDartists' )
end

function p.snacLink( id )
	--P3430's format regex: \d*[A-Za-z][0-9A-Za-z]* (e.g. A)
	if not string.match( id, '^%d*[A-Za-z][0-9A-Za-z]*$' ) then
		return false
	end
	return '[https://snaccooperative.org/ark:/99166/'..id..' '..id..']'..p.getCatForId( 'SNAC-ID' ) --no https yet (10/2018)
end

function p.dblpLink( id )
	--P2456's format regex: \d{2,3}/\d+(-\d+)?|[a-z]\/[a-zA-Z][0-9A-Za-z]*(-\d+)? (e.g. 123/123)
	if not string.match( id, '^%d%d%d?/%d+$' ) and
	   not string.match( id, '^%d%d%d?/%d+%-%d+$' ) and
	   not string.match( id, '^[a-z]/[a-zA-Z][0-9A-Za-z]*$' ) and
	   not string.match( id, '^[a-z]/[a-zA-Z][0-9A-Za-z]*%-%d+$' ) then
		return false
	end
	return '[https://dblp.org/pid/'..id..' '..id..']'..p.getCatForId( 'DBLP' )
end

function p.acmLink( id )
	--P864's format regex: \d{11} (e.g. 12345678901)
	if not string.match( id, '^%d%d%d%d%d%d%d%d%d%d%d$' ) then
		return false
	end
	return '[https://dl.acm.org/author_page.cfm?id='..id..' '..id..']'..p.getCatForId( 'ACM-DL' )
end

function p.autoresuyLink( id )
	--P2558's format regex: [1-9]\d{0,4} (e.g. 12345)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?$' ) then
		return false
	end
	return '[http://autores.uy/entidad/'..id..' '..id..']'..p.getCatForId( 'autores.uy' )
end

function p.picLink( id )
	--P2750's format regex: [1-9]\d* (e.g. 1)
	if not string.match( id, '^[1-9]%d*$' ) then
		return false
	end
	return '[http://pic.nypl.org/constituents/'..id..' '..id..']'..p.getCatForId( 'PIC' )
end

function p.bildLink( id )
	--P2092's format regex: \d+ (e.g. 1)
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[https://www.bildindex.de/document/obj'..id..' '..id..']'..p.getCatForId( 'Bildindex' )
end

function p.jocondeLink( id )
	--P347's format regex: [\-0-9A-Za-z]{11} (e.g. 12345678901)
	local regex = '^'..string.rep('[%-0-9A-Za-z]', 11)..'$'
	if not string.match( id, regex ) then
		return false
	end
	return '[https://www.pop.culture.gouv.fr/notice/joconde/'..id..' '..id..']'..p.getCatForId( 'Joconde' ) --no https yet (10/2018)
end

function p.rkdidLink( id )
	--P350's format regex: [1-9]\d{0,5} (e.g. 123456)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://rkd.nl/nl/explore/images/'..id..' '..id..']'..p.getCatForId( 'RKDID' )
end

function p.balatLink( id )
	--P3293's format regex: \d+ (e.g. 1)
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[http://balat.kikirpa.be/object/'..id..' '..id..']'..p.getCatForId( 'BALaT' ) --no https yet (10/2018)
end

function p.lnbLink( id )
	--P1368's format regex: \d{9} (e.g. 123456789)
	if #id < 9 then
		-- sometimes the id could be valid with less than 9 digits
		-- so we have to insert the (extra) leading zero(s) to pass the match
		id = string.rep('0', 9 - #id) .. id
	end
	if id:match('^%d%d%d%d%d%d%d%d%d$') then
		return '[https://kopkatalogs.lv/F?func=direct&local_base=lnc10&doc_number='..id..'&P_CON_LNG=ENG '..id..']'..p.getCatForId( 'LNB' )
	end
	return false
end

function p.nskLink( id )
	--P1375's format regex: \d{9} (e.g. 123456789)
	if not string.match( id, '^%d%d%d%d%d%d%d%d%d$' ) then
		return false
	end
	return '[http://katalog.nsk.hr/F/?func=direct&doc_number='..id..'&local_base=nsk10 '..id..']'..p.getCatForId( 'NSK' ) --no https yet (10/2018)
end

function p.iciaLink( id )
	--P1736's format regex: \d+ (e.g. 1)
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[https://www.imj.org.il/artcenter/newsite/en/?artist='..id..' '..id..']'..p.getCatForId( 'ICIA' )
end

function p.ta98Link( id )
	--P1323's format regex: A\d{2}\.\d\.\d{2}\.\d{3}[FM]? (e.g. A12.3.45.678)
	if not string.match( id, '^A%d%d%.%d%.%d%d%.%d%d%d[FM]?$' ) then
		return false
	end
	return '[https://tools.wmflabs.org/wikidata-externalid-url/?p=1323&url_prefix=https:%2F%2Fwww.unifr.ch%2Fifaa%2FPublic%2FEntryPage%2FTA98%20Tree%2FEntity%20TA98%20EN%2F&url_suffix=%20Entity%20TA98%20EN.htm&id='..id..' '..id..']'..p.getCatForId( 'TA98' )
end

function p.teLink( id )
	--P1693's format regex: E[1-8]\.\d{1,2}\.\d{1,2}\.\d{1,2}\.\d{1}\.\d{1}\.\d{1,3} (e.g. E1.23.45.67.8.9.0)
	local e1, e2 = string.match( id, '^E([1-8])%.(%d%d?)%.%d%d?%.%d%d?%.%d%.%d%.%d%d?%d?$' )
	if not e1 then
		return false
	end
	local TEnum = 'TEe0'..e1 --no formatter URL in WD, probably due to this complexity
	if e1 == '5' or e1 == '7' then
		if #e2 == 1 then e2 = '0'..e2 end
		TEnum = TEnum..e2
	end
	return '[http://www.unifr.ch/ifaa/Public/EntryPage/ViewTE/'..TEnum..'.html '..id..']'..p.getCatForId( 'TE' )
end

function p.thLink( id )
	--P1694's format regex: H\d\.\d{2}\.\d{2}\.\d\.\d{5} (e.g. H1.23.45.6.78901)
	local h1, h2 = string.match( id, '^H(%d)%.(%d%d)%.%d%d%.%d%.%d%d%d%d%d$' )
	if not h1 then
		return false
	end
	local THnum = 'THh'..h1..h2 --no formatter URL in WD, probably due to this complexity
	return '[http://www.unifr.ch/ifaa/Public/EntryPage/ViewTH/'..THnum..'.html '..id..']'..p.getCatForId( 'TH' )
end

function p.EBEIDLink( id )
	--P3348's format regex: [1-9]\d* (e.g. 1538)
	if not string.match( id, '^[1-9]%d*$' ) then
		return false
	end
	return '[https://catalogue.nlg.gr/Authority/Record?id=au.' .. id .. ' ' .. id .. ']'..p.getCatForId( 'EBE' )
end

function p.BNeditionLink( id )
	--P2187's format regex: [1-9][0-9]{0,5} (e.g. 1595; 15959)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?%d?$' ) then
		return false
	end
    return '[http://www.biblionet.gr/book/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'BiblioNet book' )
end

function p.BNpersonLink( id )
	--P2188's format regex: [1-9][0-9]{0,5} (e.g. 1595; 15959)
	if not string.match( id, '^[1-9]%d?%d?%d?%d%d?$' ) then
		return false
	end
    return '[http://www.biblionet.gr/author/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'BiblioNet author' )
end

function p.BNpublisherLink( id )
	--P2189's format regex: [1-9][0-9]{0,3} (e.g. 15; 159)
	if not string.match( id, '^[1-9]%d?%d%d?$' ) then
		return false
	end
    return '[http://www.biblionet.gr/com/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'BiblioNet' )
end

function p.jstorLink( id )
	--P3827's format regex:  [^\s\/]+ (e.g. atmm; 1237; at-80-pre)
	if not string.match( id, '^[^%s%/]+$' ) then
		return false
	end
	return '[https://www.jstor.org/topic/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'JSTOR' )
end

function p.newwLink( id )
	--P2533's format regex: [a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12} (e.g. 413e8c0d-8d35-42ea-90d2-29563884b304)
	if not string.match( id, '^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$' ) then
		return false
	end
	return '[http://resources.huygens.knaw.nl/womenwriters/vre/persons/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'NEWW' )
end

function p.dsiLink( id )
	--P2349's format regex: [1-9]\d* (e.g. 1538)
	if not string.match( id, '^[1-9]%d*$' ) then
		return false
	end
	return '[https://dsi.hi.uni-stuttgart.de/index.php?table_name=dsi&function=details&where_field=id&where_value='..id..' '..id..']'..p.getCatForId( 'DSI' )
end

function p.fastLink( id )
	--P2163's format regex: [1-9]\d{0,7} (e.g. 1358961)
	if not string.match( id, '^[1-9]%d?%d?%d?%d?%d?%d?%d?$' ) then
		return false
	end
	return '[https://experimental.worldcat.org/fast/' .. id .. '/ ' .. id .. ']'..p.getCatForId( 'FAST' )
end

function p.aatLink( id )
	--P1014's format regex: 300\d{6} (e.g. 300025486)
	if not string.match( id, '^300%d%d%d%d%d%d$' ) then
		return false
	end
	return '[http://vocab.getty.edu/page/aat/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'AAT')
end

function p.koninklijkeLink( id )
	--P1006's format regex: \d{8}(\d|X) (e.g. 069071632)
	if not string.match( id, '^%d%d%d%d%d%d%d%d[%dXx]$' ) then
		return false
	end
	return '[http://data.bibliotheken.nl/doc/thes/p' .. id .. ' ' .. id .. ']'..p.getCatForId( 'Koninklijke' )
end

function p.conorBGLink( id )
	--P8849's format regex: \d+
	if not string.match( id, '^%d+$' ) then
		return false
	end
	return '[https://plus.cobiss.net/cobiss/bg/bg/conor/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'CONOR.BG' )
end

function p.openLibraryLink( id )
	--P648's format regex: OL\d{1,7}[AMW] (e.g. OL3156833A)
	if not string.match( id, '^OL%d%d?%d?%d?%d?%d?%d?%d?[AMW]$' ) then
		return false
	end
	return '[https://openlibrary.org/works/' .. id .. ' ' .. id .. ']'..p.getCatForId( 'OpenLibrary' )
end

function p.europeanaLink(id)
	--P7704's format regex: (place|agent|concept|organisation)/base/[1-9]\d+ (e.g. agent/base/59832)
	local s1, s2, s3 = id:match('^([^/]+)([^%d]+)(%d+)$')
	if (s1 and s2 and s3) and (s1 == 'place' or s1 == 'agent' or s1 == 'concept' or s1 == 'organisation') then
 		return '[http://data.europeana.eu/' .. id .. ' ' .. s3 .. ']' .. p.getCatForId('Europeana')
	end
	return false
end

function p.oclcLink(id)
	--P243's format regex: 0*[1-9]\d* (e.g. 57722711)
	if id:match('^0*[1-9]%d*$') then
		return '[https://www.worldcat.org/oclc/' .. id .. ' ' .. id .. ']' .. p.getCatForId('OCLC')
	end
	return false
end

function p.worldcatidLink(id)
	--P7859's format regex: (viaf|lccn|np)-.+ (e.g. lccn-n88603570)
	local s1, s2, s3 = id:match('^(%l+)(%-)(.+)$')
	if (s1 and s2 and s3) and (s1 == 'viaf' or s1 == 'lccn' or s1 == 'np' or s1 == 'nc') then
		return '[https://www.worldcat.org/identities/' .. id .. ' ' .. id:gsub('%%20', ' ') .. ']' .. p.getCatForId('WorldCat')
	end
	return false
end

--[[==========================================================================]]
--[[          Wikidata, navigation bar, and documentation functions           ]]
--[[==========================================================================]]

function p.getIdsFromWikidata(itemId, property)
	local ids = {}
	local statements = mw.wikibase.getBestStatements(itemId, property)
	if statements then
		for _, statement in ipairs(statements) do
			if statement.mainsnak.datavalue then
				table.insert(ids, statement.mainsnak.datavalue.value)
			end
		end
	end
	return ids
end

function p.matchesWikidataRequirements(itemId, reqs)
	for _, group in ipairs(reqs) do
		local property = 'P' .. group[1]
		local qid = group[2]
		local statements = mw.wikibase.getBestStatements(itemId, property)
		if statements then
			for _, statement in ipairs(statements) do
				if statement.mainsnak.datavalue then
					if statement.mainsnak.datavalue.value['numeric-id'] == qid then
						return true
	end	end	end	end	end
	return false
end

function p.createRow(id, label, rawValue, link, withUid)
	if link then
		if withUid then
			return '* ' .. label .. ' <span class="uid">' .. link .. '</span>\n'
		end
		return '* ' .. label .. ' ' .. link .. '\n'
	end

	local catName = 'Уикипедия:Страници с невалиден нормативен контрол'
	return '* <span class="error">Нормативният контрол ' .. id .. ': ' .. rawValue .. ' е невалиден</span>[[Категория:' .. catName .. ']]\n'
end

function p.copyTable(inTable)
	if type(inTable) ~= 'table' then return inTable end
	local outTable = setmetatable({}, getmetatable(inTable))
	for key, value in pairs (inTable) do outTable[p.copyTable(key)] = p.copyTable(value) end
	return outTable
end

-- Creates a human-readable standalone wikitable version of p.conf, and tracking categories with page counts, for use in the documentation
function p.docConfTable(frame)
	local wikiTable = '{| class="wikitable sortable"\n'..
					  '|-\n'..
					  '!Параметър'..
					  '!!Показване<br />в нав. лента'..
					  '!!data-sort-type="number"|Свойство<br />в Уикиданни'..
					  '!!Брой в<br />категория\n'
	local lang = mw.getContentLanguage()
	for _, conf in pairs(p.conf) do
		local param, link, pid = conf[1], conf[2], conf[3]
		local category = conf.category or param
		--cats
		local articleCat = (category == 'Europeana' and 'Europeana') or 'Уикипедия:Статии с нормативен контрол ('..category..')'
		--counts
		local articleCount = lang:formatNum(mw.site.stats.pagesInCategory(articleCat, 'pages'))
		--concat
		wikiTable = wikiTable..
					'|-\n'..
					'|'..param..
					'||'..link..
					'||data-sort-value="'..pid..'"|[[:d:property:P'..pid..'|P'..pid..']]'..
					'||style="text-align:right"|[[:Категория:'..articleCat..'|'..articleCount..']]\n'
	end
	return wikiTable .. '|}'
end

--[[==========================================================================]]
--[[                              Configuration                               ]]
--[[==========================================================================]]

-- Check that the Wikidata item has this property-->value before adding it
local reqs = {}

-- Parameter format: { name of the parameter, label, propertyId in Wikidata, formatting function, category (used in p.docConfTable for tracking) }
-- IMPORTANT: Create links to articles in the label parameter _only_ with the
-- linkedLabel() function. In particular, do not use internal links ([[...]]).
-- See the discussion in https://bg.wikipedia.org/w/index.php?oldid=10493105
p.conf = {
	{ 'AAT', 'Art & Architecture Thesaurus', 1014, p.aatLink },
	{ 'ACM-DL', 'ACM DL', 864, p.acmLink },
	{ 'autores.uy', 'autores.uy', 2558, p.autoresuyLink },
	{ 'BALaT', 'BALaT', 3293, p.balatLink },
	{ 'BIBSYS', linkedLabel('BIBSYS'), 1015, p.bibsysLink },
	{ 'Bildindex', 'Bildindex', 2092, p.bildLink },
	{ 'BNE', linkedLabel('Национална библиотека на Испания', 'BNE'), 950, p.bneLink },
	{ 'BNed', 'BNed', 2187, p.BNeditionLink, category = 'BiblioNet book' },
	{ 'BNF', linkedLabel('Национална библиотека на Франция', 'BNF'), 268, p.bnfLink },
	{ 'BNper', 'BNper', 2188, p.BNpersonLink, category = 'BiblioNet author' },
	{ 'BNpub', 'BNpub', 2189, p.BNpublisherLink, category = 'BiblioNet' },
	{ 'Botanist', 'Botanist', 428, p.botanistLink },
	{ 'BPN', 'BPN', 651, p.bpnLink },
	{ 'CINII', 'CiNii', 271, p.ciniiLink },
	{ 'CONOR.BG', 'CONOR.BG', 8849, p.conorBGLink },
	{ 'DBLP', 'DBLP', 2456, p.dblpLink },
	{ 'DSI', 'DSI', 2349, p.dsiLink },
	{ 'EBE', linkedLabel('Национална библиотека на Гърция', 'ΕΒΕ'), 3348, p.EBEIDLink },
	{ 'Europeana', linkedLabel('Europeana'), 7704, p.europeanaLink },
	{ 'FAST', 'FAST', 2163, p.fastLink },
	{ 'GND', linkedLabel('Колективен нормативен архив', 'GND'), 227, p.gndLink },
	{ 'HDS', linkedLabel('Швейцарски исторически лексикон', 'HDS'), 902, p.hdsLink },
	{ 'IAAF', linkedLabel('Международна асоциация на лекоатлетическите федерации', 'IAAF'), 1146, p.iaafLink },
	{ 'ICIA', 'ICIA', 1736, p.iciaLink },
	{ 'ISNI', linkedLabel('Международен стандартен идентификатор на имена', 'ISNI'), 213, p.isniLink },
	{ 'Joconde', 'Joconde' , 347, p.jocondeLink },
	{ 'JSTOR', linkedLabel('JSTOR'), 3827, p.jstorLink },
	{ 'Koninklijke', linkedLabel('Кралска библиотека (Нидерландия)', 'Koninklijke'), 1006, p.koninklijkeLink },
	{ 'KULTURNAV', 'KulturNav', 1248, p.kulturnavLink },
	{ 'LCCN', linkedLabel('Контролен номер на Библиотеката на Конгреса', 'LCCN'), 244, p.lccnLink },
	{ 'LIR', linkedLabel('Швейцарски исторически лексикон', 'LIR'), 886, p.lirLink },
	{ 'LNB', 'LNB', 1368, p.lnbLink },
	{ 'Léonore', 'Léonore', 640, p.leonoreLink },
	{ 'MBA', linkedLabel('MusicBrainz', 'MBa'), 434, p.mbaLink, category = 'MusicBrainz' },
	{ 'MBAREA', linkedLabel('MusicBrainz', 'MBarea'), 982, p.mbareaLink, category = 'MusicBrainz area' },
	{ 'MBI', linkedLabel('MusicBrainz', 'MBi'), 1330, p.mbiLink, category = 'MusicBrainz instrument' },
	{ 'MBL', linkedLabel('MusicBrainz', 'MBl'), 966, p.mblLink, category = 'MusicBrainz label' },
	{ 'MBP', linkedLabel('MusicBrainz', 'MBp'), 1004, p.mbpLink, category = 'MusicBrainz place' },
	{ 'MBRG', linkedLabel('MusicBrainz', 'MBrg'), 436, p.mbrgLink, category = 'MusicBrainz release group' },
	{ 'MBS', linkedLabel('MusicBrainz', 'MBs'), 1407, p.mbsLink, category = 'MusicBrainz series' },
	{ 'MBW', linkedLabel('MusicBrainz', 'MBw'), 435, p.mbwLink, category = 'MusicBrainz work' },
	{ 'MGP', 'MGP', 549, p.mgpLink },
	{ 'NARA', 'NARA', 1225, p.naraLink },
	{ 'NCL', 'NCL', 1048, p.nclLink },
	{ 'NDL', linkedLabel('Национална парламентарна библиотека (Япония)', 'NDL'), 349, p.ndlLink },
	{ 'NEWW', 'NEWW Women Writers', 2533, p.newwLink },
	{ 'NKC', linkedLabel('Национална библиотека на Чехия', 'NKC'), 691, p.nkcLink },
	{ 'NLA', linkedLabel('Национална библиотека на Австралия', 'NLA'), 409, p.nlaLink },
	{ 'NSK', 'NSK', 1375, p.nskLink },
	{ 'OCLC', linkedLabel('Онлайн компютърен библиотечен център', 'OCLC'), 243, p.oclcLink },
	{ 'OpenLibrary', 'Open Library', 648, p.openLibraryLink },
	{ 'ORCID', 'ORCID', 496, p.orcidLink },
	{ 'PIC', 'PIC', 2750, p.picLink },
	{ 'RID', 'ResearcherID', 1053, p.ridLink },
	{ 'RKDartists', linkedLabel('Нидерландски институт за история на изкуството', 'RKD'), 650, p.rkdartistsLink },
	{ 'RKDID', 'RKDimages ID', 350, p.rkdidLink },
	{ 'RSL', linkedLabel('Руска държавна библиотека', 'RSL'), 947, p.rslLink },
	{ 'SBN', 'ICCU', 396, p.sbnLink },
	{ 'SELIBR', linkedLabel('LIBRIS', 'SELIBR'), 906, p.selibrLink },
	{ 'SIKART', 'SIKART', 781, p.sikartLink },
	{ 'SNAC-ID', 'SNAC', 3430, p.snacLink },
	{ 'SUDOC', linkedLabel('Система за университетска документация на Франция', 'SUDOC'), 269, p.sudocLink },
	{ 'TA98', 'TA98', 1323, p.ta98Link },
	{ 'TE', 'TE', 1693, p.teLink },
	{ 'TH', 'TH', 1694, p.thLink },
	{ 'TLS', 'TLS', 1362, p.tlsLink },
	{ 'ULAN', 'ULAN', 245, p.ulanLink },
	{ 'USCongress', 'US Congress', 1157, p.uscongressLink },
	{ 'VIAF', linkedLabel('Виртуален международен нормативен архив', 'VIAF'), 214, p.viafLink },
	{ 'WORLDCATID', 'WorldCat', 7859, p.worldcatidLink, category = 'WorldCat' },
}

-- Legitimate aliases to p.conf, for convenience
-- Format: { alias, parameter name in p.conf }
p.aliases = {
	{ 'Leonore', 'Léonore' },
	{ 'NLG', 'EBE' },
	{ 'autores', 'autores.uy' },
	{ 'SNAC', 'SNAC-ID' },
	{ 'WorldCat', 'WORLDCATID' },
}

-- Deprecated aliases to p.conf, which also get assigned to a tracking cat
-- Format: { deprecated parameter name, replacement parameter name in p.conf }
p.deprecated = {
	{ 'GKD', 'GND' },
	{ 'PND', 'GND' },
	{ 'SWD', 'GND' },
	{ 'NARA-organization', 'NARA' },
	{ 'NARA-person', 'NARA' },
}

--[[==========================================================================]]
--[[                                   Main                                   ]]
--[[==========================================================================]]

function p.authorityControl(frame)
	local resolveEntity = require('Модул:ResolveEntityId')
	local title = mw.title.getCurrentTitle()
	local namespace = title.namespace
	local talkspace = (mw.site.talkNamespaces[namespace] ~= nil)
	local testcases = (string.sub(title.subpageText, 1, 9) == 'testcases')
	local parentArgs = p.copyTable(frame:getParent().args)
	local elements = {} --create/insert rows later
	local suppressedIdCat = ''
	
	--Format args
	for k, v in pairs(frame:getParent().args) do
		if type(k) == 'string' then
			--make args case insensitive
			local lowerk = mw.ustring.lower(k)
			if parentArgs[lowerk] == nil or parentArgs[lowerk] == '' then
				parentArgs[k] = nil
				parentArgs[lowerk] = v
			end
		end
	end
	
	--Redirect aliases to proper parameter names
	for _, a in pairs(p.aliases) do
		local alias, param = mw.ustring.lower(a[1]), mw.ustring.lower(a[2])
		if (parentArgs[param] == nil or parentArgs[param] == '') and parentArgs[alias] then
			parentArgs[param] = parentArgs[alias]
		end
	end
	
	--Redirect deprecated parameters to proper parameter names
	for _, d in pairs(p.deprecated) do
		local dep, param = mw.ustring.lower(d[1]), mw.ustring.lower(d[2])
		if (parentArgs[param] == nil or parentArgs[param] == '') and parentArgs[dep] then
			parentArgs[param] = parentArgs[dep]
		end
	end
	
	--Use QID= parameter for testing/example purposes only
	local itemId = nil
	if testcases or talkspace then
		if parentArgs['QID'] then
			itemId = 'Q' .. mw.ustring.gsub(parentArgs['QID'], '^[Qq]', '')
			itemId = resolveEntity._id(itemId) --nil if unresolvable
		end
	else
		itemId = mw.wikibase.getEntityIdForCurrentPage()
	end
	
	--Wikidata fallback if requested
	if itemId then
		for _, params in ipairs(p.conf) do
			if params[3] > 0 then
				params[1] = mw.ustring.lower(params[1])
				local val = parentArgs[params[1]]
				if val == nil or val == '' then
					local canUseWikidata = nil
					if reqs[params[1]] then
						canUseWikidata = p.matchesWikidataRequirements(itemId, reqs[params[1]])
					else
						canUseWikidata = true
					end
					if canUseWikidata then
						local wikidataIds = p.getIdsFromWikidata(itemId, 'P' .. params[3])
						if wikidataIds[1] then
							if val == '' and (namespace == 0 or testcases) then
								suppressedIdCat = '[[Категория:Уикипедия:Статии с потиснат идентификатор на нормативен контрол]]'
							else
								parentArgs[params[1]] = wikidataIds[1]
	end	end	end	end	end	end	end
	
	--Configured rows
	local rct = 0
	for _, params in ipairs(p.conf) do
		local val = parentArgs[mw.ustring.lower(params[1])]
		if val and val ~= '' then
			local uid = true
			if params[1] == 'WORLDCATID' then
				uid = false
			end
			table.insert(elements, p.createRow(params[1], params[2] .. ':', val, params[4](val), uid))
			rct = rct + 1
		end
	end

	local Navbox = require('Модул:Navbox')
	local elementsCat = ''
	if rct > 20 then
		elementsCat  = '[[Категория:Нормативен контрол с над 20 контролни идентификатора]]'
	end
	
	local outString = ''
	if #elements > 0 then
		local args = {}
		if testcases and itemId then args = { qid = itemId } end --expensive
		outString = Navbox._navbox({
			name  = 'Нормативен контрол',
			bodyclass = 'hlist hlist-big plainlinks',
			group1 = '[[Нормативен контрол]]',
			list1 = table.concat(elements)
			})
		outString = outString .. elementsCat .. suppressedIdCat
		if testcases then
			outString = mw.ustring.gsub(outString, '(%[%[)(Категория)', '%1:%2') --for easier checking
		end
	end
	
	return outString
end

return p
