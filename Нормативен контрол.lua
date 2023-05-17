local p = {}

--[[==========================================================================]]
--[[                              Configuration                               ]]
--[[==========================================================================]]

--[[ Format: {
id = name of the parameter,
label = name to be displayed in the navbox (Note: skip if same as id key),
property = property id in Wikidata or direct link if no useful property exists,
pattern = Lua regex pattern(s) to check if the value string for the given property is in valid format (Note: if multiple patterns exist, consider putting them in a table),
} ]]--

local rep = mw.ustring.rep
local databases = {
	--COMMON
	{ id = 'AAT', property = 1014, pattern = '300%d%d%d%d%d%d' },
	{ id = 'ACM-DL', property = 864, pattern = '%d%d%d%d%d%d%d%d%d%d%d' },
	{ id = 'BALaT', property = 3293, pattern = '%d+' },
	{ id = 'BGCI', property = 5818, pattern = '%d+' },
	{ id = 'BIBSYS', property = 1015, pattern = '[1-9]%d*' },
	{ id = 'Bildindex', property = 2092, pattern = '%d+' },
	{ id = 'BNE', property = 950, pattern = { 'XX%d%d%d%d%d?%d?%d?', 'a%d%d%d%d%d?%d?%d?', '[bM]im[ao]%d%d%d%d%d%d%d%d%d%d%d', '[bM]ise%d%d%d%d%d%d%d%d%d%d%d', 'bivi%d%d%d%d%d%d%d%d%d%d%d' } },
	{ id = 'BNed', property = 2187, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'BNF', property = 268, pattern = '%d?%d%d%d%d%d%d%d%d[0-9bcdfghjkmnpqrstvwxz]' },
	{ id = 'BNper', property = 2188, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'BNpub', property = 2189, pattern = '[1-9]%d?%d?%d?' },
	{ id = 'Botanist', property = 428, pattern = "[%u%l%d%. '-]+" },
	{ id = 'BPN', property = 651, pattern = '%d%d%d%d%d%d%d?%d?' },
	{ id = 'CiNii', property = 271, pattern = 'D[AB]%d%d%d%d%d%d%d[%dX]' },
	{ id = 'CONOR.BG', property = 8849, pattern = '%d+' },
	{ id = 'DBLP', property = 2456, pattern = { '%d%d%d?/%d+', '%d%d%d?/%d+%-%d+', '[a-z]/[a-zA-Z][0-9A-Za-z]*', '[a-z]/[a-zA-Z][0-9A-Za-z]*%-%d+' } },
	{ id = 'DSI', property = 2349, pattern = '[1-9]%d*' },
	{ id = 'EBIDAT', property = 9725, pattern = '[1-9]%d?%d?%d?' },
	{ id = 'Emmy', property = 8381, pattern = '%S+' },
	{ id = 'Europeana', link = 'Europeana', property = 7704, pattern = { 'place/base/%d+', 'agent/base/%d+', 'concept/base/%d+', 'organisation/base/%d+' } },
	{ id = 'FAST', property = 2163, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'GND', property = 227, pattern = { '1[012]?%d%d%d%d%d%d%d[%dX]', '[47]%d%d%d%d%d%d%-%d', '[1-9]%d?%d?%d?%d?%d?%d?%d?%-[%dX]', '3%d%d%d%d%d%d%d[%dX]' } },
	{ id = 'Google Scholar', property = 1960, pattern = rep('[A-Za-z%d%-_]', 12) },
	{ id = 'Grammy', property = 7303, pattern = '%w[%w%-]+%/%d+' },
	{ id = 'HDS', property = 902, pattern = '%d%d%d%d%d%d' },
	{ id = 'IAAF', property = 1146, pattern = '%d+' },
	{ id = 'ICIA', property = 1736, pattern = '%d+' },
	{ id = 'ISIL', property = 791, pattern = '%D%D?%D?%D?%-[%w%-:/]' .. rep ('[%w%-:/]?', 10) },
	{ id = 'ISNI', property = 213, pattern = '0000[%s%-]?%d%d%d%d[%s%-]?%d%d%d%d[%s%-]?%d%d%d[%dX]' },
	{ id = 'J9U', label = 'NLI J9U', property = 8189, pattern = '98' .. rep('%d', 12) .. '5171' },
	{ id = 'Joconde', property = 347, pattern = rep('[%-%dA-Za-z]', 11) },
	{ id = 'Koninklijke', property = 1006, pattern = '%d%d%d%d%d%d%d%d[%dX]' },
	{ id = 'KulturNav', property = 1248, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'LCCN', property = 244, pattern = '%l%l?%d?%d?%d?%d?%d%d%d%d%d%d' },
	{ id = 'LIR', property = 886, pattern = '%d+' },
	{ id = 'LNB', property = 1368, pattern = rep('%d', 9) },
	{ id = 'Leonore', label = 'Léonore', property = 11152, pattern = '[1-9]%d*' }, -- transition to Léonore Web ID (P11152) since Léonore ID (P640) is not active anymore
	{ id = 'MBa', property = 434, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBarea', property = 982, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBi', property = 1330, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBl', property = 966, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBp', property = 1004, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBrg', property = 436, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBs', property = 1407, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MBw', property = 435, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'MGP', property = 549, pattern = '%d%d?%d?%d?%d?%d?' },
	{ id = 'NARA', property = 1225, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'NCL', property = 1048, pattern = '%d+' },
	{ id = 'NDL', property = 349, pattern = { 'a?1?%d?%d%d%d%d%d%d%d%d', 's?%d?%d%d%d%d%d%d%d%d' } },
	{ id = 'NEWW', label = 'NEWW Women Writers', property = 2533, pattern = rep('[a-z%d]', 8) .. rep('%-[a-z%d][a-z%d][a-z%d][a-z%d]', 3) .. '%-' .. rep('[a-z%d]', 12) },
	{ id = 'NKC', property = 691, pattern = '[a-z][a-z][a-z]?[a-z]?%d%d%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'NLA', property = 409, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'NLG', property = 3348, pattern = '[1-9]%d*' },
	{ id = 'NSK', property = 1375, pattern = rep('%d', 9) },
	{ id = 'OCLC', property = 243, pattern = '%d%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'OpenLibrary', label = 'Open Library', property = 648, pattern = 'OL[1-9]%d*[AMW]' },
	{ id = 'ORCID', property = 496, pattern = '0000%-?000%d%-?%d%d%d%d%-?%d%d%d[%dX]' },
	{ id = 'PIC', property = 2750, pattern = '[1-9]%d*' },
	{ id = 'PLWABN', property = 7293, pattern = '98' .. rep('%d', 10) .. '5606' },
	{ id = 'RID', label = 'Researcher', property = 1053, pattern = { '[A-Z][A-Z]?[A-Z]?%-%d%d%d%d%-19%d%d', '[A-Z][A-Z]?[A-Z]?%-%d%d%d%d%-20%d%d' } },
	{ id = 'RKDartists', label = 'RKD', property = 650, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'RKDID', label = 'RKDimages', property = 350, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'RSL', property = 947, pattern = '%d%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'SBN', label = 'ICCU', property = 396, pattern = '%D%D[A-Z0-3]V%d%d%d%d%d%d' },
	{ id = 'Scopus', property = 1153, pattern = '[1-9]%d%d%d%d%d%d%d%d%d%d?%d?' },
	{ id = 'SELIBR', label = 'LIBRIS', property = 906, pattern = '[1-9]%d%d%d%d%d?' },
	{ id = 'SIKART', property = 781, pattern = '%d%d%d%d%d%d%d%d?%d?' },
	{ id = 'SNAC-ID', label = 'SNAC', property = 3430, pattern = '%d*[A-Za-z][%dA-Za-z]*' },
	{ id = 'STRAZHA', label = 'Стража', property = 11446, pattern = { 'parl%-groups/[a-z%d-]+', 'parliaments/[a-z%d-]+', 'mps/[a-z%d-]+' } },
	{ id = 'SUDOC', label = 'IdRef', property = 269, pattern = '%d%d%d%d%d%d%d%d[%dX]' },
	{ id = 'TA', property = 1323, pattern = 'A%d%d%.%d%.%d%d%.%d%d%d[FM]?' },
	{ id = 'TLS', property = 1362, pattern = '%u[%S_]+' },
	{ id = 'ULAN', property = 245, pattern = '500%d%d%d%d%d%d' },
	{ id = 'USCongress', label = 'US Congress', property = 1157, pattern = '[A-Z]00[01]%d%d%d' },
	{ id = 'VIAF', property = 214, pattern = { '[1-9]%d' .. rep('%d?', 7), '[1-9]%d?%d?%d?' .. rep('%d', 18) } },
	{ id = 'WorldCat Entities', label = 'WorldCat', property = 10832, pattern = {'[a-zA-Z%d][a-zA-Z%d]' .. rep('[a-zA-Z%d]?', 26)} },
	{ id = 'WorldCat Identities', label = 'WorldCat', property = 7859, pattern = { 'viaf%-%d+', 'lccn%-n[a-z]?[%d%-]+' , 'n[cps]%-.+' } }, --deprecated as of March 2023; replaced by "WorldCat Entities"
	{ id = 'ZBMATH', property = 1556, pattern = '[a-z][a-z%-%.%d]*' },

	--TAXA
	{ id = 'ADW', property = 4024 },
	{ id = 'AFD', property = 6039 },
	{ id = 'AfroMoths', property = 6093, pattern = rep('[A-Z%d]', 8) }, ---[[AfroMoths]] DNE
	{ id = 'AlgaeBase', property = 1348 },
	{ id = 'AmphibiaWeb', property = 5036, pattern = '[1-9]%d*' },
	{ id = 'AntWeb', property = 5299, pattern = { '[A-Z][a-z]+', '[A-Z][a-z]+ [a-z]+', '[A-Z][a-z]+ [a-z]+ [a-z]+' } },
	{ id = 'AoI', property = 5003, pattern = '%d+' }, ---[[Amphibians of India]] DNE
	{ id = 'AoFP', property = 6159, pattern = '[1-9]%d*' }, ---[[Atlas of Florida Plants]] DNE
	{ id = 'APA', property = 6137, pattern = '[1-9]%d*' }, ---[[Alabama Plant Atlas]] DNE
	{ id = 'APDB', property = 2036, pattern = '%d%d?%d?%d?%d?%d?' }, ---[[African Plant Database]] DNE
	{ id = 'APNI', property = 5984, pattern = '[1-9]%d*' },
	{ id = 'Araneae', property = 3594, pattern = '[1-9]%d%d?%d?' }, ---[[]] DNE
	{ id = 'ARKive', property = 2833, pattern = '[a-z][a-z%-]*' },
	{ id = 'ASW', property = 5354, pattern = '[A-Za-z][A-Za-z/%-]*%d?%d?' },
	{ id = 'Avibase', property = 2026, pattern = { rep('[A-Z%d]', 8), rep('[A-Z%d]', 16) } }, ---[[]] DNE
	{ id = 'BacDive', property = 2946, pattern = '%d%d?%d?%d?%d?%d?' },
	{ id = 'BAMONA', property = 3398, pattern = { 'species/[^%s/]+', 'taxonomy/[^%s/]+' } }, ---[[Butterflies and Moths of North America]] DNE
	{ id = 'BHL', property = 687, pattern = '[1-9]%d*' },
	{ id = 'BioLib', property = 838, pattern = '%d%d?%d?%d?%d?%d?%d?' }, ---[[]] DNE
	{ id = 'BirdLife', property = 5257, pattern = '[1-9]%d%d%d%d%d%d%d%d?' },
	{ id = 'BirdLife-Australia', property = 6040, pattern = '[a-z][a-z%-]*' },
	{ id = 'BOLD', property = 3606, pattern = '[1-9]%d*' },
	{ id = 'BugGuide', property = 2464, pattern = '[1-9]%d?%d?%d?%d?%d?%d?' },
	{ id = 'ButMoth', property = 3060, pattern = '[1-9]%d?%d?%d?%d?%.0' },
	{ id = 'Calflora', property = 3420, pattern = '%d+' }, ---[[]] DNE
	{ id = 'Cal-IPC', property = 6176, pattern = '[a-z%-]+' }, ---[[California Invasive Plant Council]] DNE
	{ id = 'Center', property = 6003, pattern = '[a-z]+/[A-Za-z_%-]+' },
	{ id = 'CMS', property = 6033, pattern = { '[a-z][a-z%-]*', '[a-z][a-z%-]*%-%d' } },
	{ id = 'CNPS', property = 4194, pattern = '[1-9]%d*' },
	{ id = 'Cockroach Species File', property = 6052, pattern = '[1-9]%d*' }, ---[[]] DNE
	{ id = 'CoL-Taiwan', property = 3088, pattern = '.-%d+.-' }, ---[[]] DNE
	{ id = 'Conifers', property = 1940 }, ---[[]] DNE
	{ id = 'Coreoidea Species File', property = 6053, pattern = '[1-9]%d%d%d%d%d%d' }, ---[[]] DNE
	{ id = 'CzechNDOP', property = 5263, pattern = '[1-9]%d*' }, ---closest match
	{ id = 'DFCA', property = 6115, pattern = '[1-9]%d*' }, ---[[Digital Flora of Central Africa]] DNE
	{ id = 'DORIS', property = 4630, pattern = '[1-9]%d*' }, ---closest match
	{ id = 'Dyntaxa', property = 1939, pattern = '%d%d?%d?%d?%d?%d?%d?' }, ---[[]] DNE
	{ id = 'eBird', property = 3444, pattern = { '[a-z%-][a-z%-][a-z%-]?[a-z%-]?[a-z%-]?[a-z%-]?%d?%d?', '[xy]00%d%d%d' } },
	{ id = 'Ecocrop', property = 4753, pattern = '%d+' }, ---[[]] DNE
	{ id = 'ECOS', property = 6030, pattern = '[1-9]%d*' }, ---[[Environmental Conservation Online System]] DNE
	{ id = 'EEO', property = 6043, pattern = '[a-z][a-z%-]*' }, ---[[Espèces Envahissantes Outre-mer]] DNE
	{ id = 'EoL', property = 830, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'EPPO', property = 3031, pattern = rep('[A-Z%d]', 5) .. '[A-Z%d]?' },
	{ id = 'EUNIS', property = 6177, pattern = '[1-9]%d*' },
	{ id = 'FaunaEuropaea', label = 'Fauna Europaea', property = 1895, pattern = '%d%d?%d?%d?%d?%d?' },
	{ id = 'FaunaEuropaeaNew', label = 'Fauna Europaea (2016)', property = 4807, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'FEIS', property = 6044 }, ---[[Fire Effects Information System]] DNE
	{ id = 'FishBase', property = 938, pattern = '[1-9]%d?%d?%d?%d?' },
	{ id = 'FloraBase', property = 3101, pattern = '%d+' },
	{ id = 'FloraCatalana', property = 5179, pattern = 'VTax[1-9]%d?%d?%d?' }, ---[[]] DNE
	{ id = 'FloraWeb', property = 6094, pattern = '[1-9]%d*' }, ---[[]] DNE
	{ id = 'FLOW', property = 6096, pattern = '[1-9]%d*' }, ---[[Fulgoromorpha Lists On the Web]] DNE
	{ id = 'FNA', property = 1727, pattern = '[1-9]%d%d%d%d%d?%d?%d?%d?%d?' },
	{ id = 'FoAO', property = 3100, pattern = '%d+' },
	{ id = 'FoC', property = 1747, pattern = '[1-9]%d%d%d%d%d?%d?%d?%d?%d?' },
	{ id = 'FOIH', property = 4311, pattern = '[1-9]%d*' },
	{ id = 'FoIO', property = 3795, pattern = { '[a-zA-Z%d%-]+/?', 'systematics/[a-zA-Z%d%-]+/?' } }, ---[[Flora of Israel Online]] DNE, he.wiki link interferes with display
	{ id = 'Fossilworks', property = 842, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'Fungorum', property = 1391, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'GBIF', property = 846, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'GISD', property = 5626, pattern = '[1-9]%d*' }, ---closest match
	{ id = 'GNAB', property = 4715, pattern = '[a-z][a-z%-]*' }, ---[[Guide to North American Birds]] DNE
	{ id = 'GONIAT', property = 5216, pattern = 'tax' .. rep('%d', 29) }, ---[[]] DNE
	{ id = 'GrassBase', property = 1832, pattern = { 'imp%d%d%d%d%d', 'gen%d%d%d%d%d' } },
	{ id = 'GRIN', property = 1421 },
	{ id = 'GTIBMA', label = 'GT IBMA', property = 6054, pattern = '[a-z][a-z%-]*' }, ---[[Groupe de travail Invasions biologiques en milieux aquatiques]] DNE
	{ id = 'Hepaticarum', label = 'Index Hepaticarum', property = 2794, pattern = '%d+' }, ---[[]] DNE
	{ id = 'IBC', property = 3099 },
	{ id = 'iNaturalist', property = 3151, pattern = '[1-9]%d?%d?%d?%d?%d?%d?' },
	{ id = 'IPA', property = 6161, pattern = '[1-9]%d*' }, ---[[Invasive Plant Atlas of the United States]] DNE
	{ id = 'IPNI', property = 961, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?%-[123]' },
	{ id = 'IRMNG', property = 5055, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'ISC', property = 5698, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'ITIS', property = 815, pattern = '[1-9]%d%d?%d?%d?%d?%d?' },
	{ id = 'IUCN', property = 627, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'LepIndex', property = 3064, pattern = '[1-9]%d?%d?%d?%d?%d?%d?' },
	{ id = 'LoB', property = 5862, pattern = '[1-9]%d*' }, ---[[Catalogue of Lepidoptera of Belgium]] DNE
	{ id = 'LPSN', property = 1991 },
	{ id = 'Mantodea Species File', property = 6055, pattern = '[1-9]%d*' }, ---[[]] DNE
	{ id = 'MichiganFlora', property = 6103 }, ---[[Michigan Flora]] DNE
	{ id = 'MoBotPF', property = 6034, pattern = '[1-9]%d*' },
	{ id = 'MoL', property = 6092, pattern = '[A-Z][a-zA-Z_]+' }, ---[[Map of Life]] DNE
	{ id = 'MNHN', property = 6046 },
	{ id = 'MONA', property = 4758, pattern = { '%d%d%d?%d?%d?', '%d%d%d?%d?%d?.%d' } },
	{ id = 'MSW', property = 959, pattern = '1%d%d%d%d%d%d%d' },
	{ id = 'MycoBank', property = 962, pattern = '[1-9]%d?%d?%d?%d?%d?' },
	{ id = 'NAS', property = 6163, pattern = '[1-9]%d*' }, ---[[Nonindigenous Aquatic Species]] DNE
	{ id = 'NBN', property = 3240, pattern = '[A-Z][A-Z]' .. rep('[A-Z%d]', 14) },
	{ id = 'NCBI', property = 685, pattern = '[1-9]%d?%d?%d?%d?%d?%d?' },
	{ id = 'Neotropical', property = 6047 },
	{ id = 'NOAA', property = 6049, pattern = '[a-z][a-z%-]*' },
	{ id = 'NSWFlora', property = 3130, pattern = { '[A-Z][a-z]*', '[A-Z][a-z]*~[a-z]*' } }, ---[[New South Wales Flora]] DNE
	{ id = 'NTFlora', property = 5953, pattern = '[1-9]%d*' }, ---inconsistent property name/link
	{ id = 'NZBO', property = 6048, pattern = '[a-z][a-z%-]*' }, ---[[New Zealand Birds Online]] DNE
	{ id = 'NZOR', property = 2752, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' }, ---[[New Zealand Organisms Register]] DNE
	{ id = 'Oiseaux', property = 6025, pattern = '[a-z][a-z.]*' }, ---closest match
	{ id = 'Orthoptera Species File', property = 6050, pattern = '[1-9]%d*' }, ---[[]] DNE
	{ id = 'PalDat', property = 4122, pattern = '[A-Z][a-z]*%__?[a-z-]+' }, ---[[Palynological Database]] DNE
	{ id = 'Panartic', label = 'Panartic Flora', property = 2434, pattern = '%d+[a-z]?' }, ---[[]] DNE
	{ id = 'PfaF', property = 4301 },
	{ id = 'PFI', property = 6114, pattern = '[1-9]%d*' }, ---[[Portal to the Flora of Italy]] DNE
	{ id = 'Phasmida Species File', property = 4855, pattern = '[1-9]%d*' }, ---[[]] DNE
	{ id = 'PPE', property = 6061, pattern = '[a-z][a-z%-/]*[a-z]' }, ---[[Plant Parasites of Europe]] DNE
	{ id = 'Plantarium', property = 3102, pattern = '%d+' }, ---[[]] DNE
	{ id = 'PlantList', label = 'Plant List', property = 1070, pattern = { 'gcc%-%d+', 'ifn%-%d+', 'ild%-%d+', 'kew%-%d+', 'rjp%-%d+', 'tro%-%d+' } },
	{ id = 'PLANTS', property = 1772, pattern = '[A-Z][A-Z][A-Z][A-Z]?[A-Z]?%d?%d?%d?' },
	{ id = 'Plazi', property = 1992, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' },
	{ id = 'POWO', property = 5037, pattern = 'urn:lsid:ipni%.org:names:[1-9]%d?%d?%d?%d?%d?%d?%d?%-[1234]' },
	{ id = 'RD', property = 5473, pattern = 'genus=[A-Za-z]+%&species=[a-z%-]+' },
	{ id = 'SANBI', property = 6056, pattern = '[1-9]%d*%-[1-9]%d*' },
	{ id = 'SCC', property = 6057, pattern = '[1-9]%d*' }, ---[[Systematic Catalog of Culicidae]] DNE
	{ id = 'SeaLifeBase', property = 6018, pattern = '[1-9]%d*' },
	{ id = 'SEINet', property = 6209, pattern = '[1-9]%d*' }, ---[[]] DNE
	{ id = 'Soortenregister', property = 3405, pattern = '[1-9]%d*' }, ---closest match
	{ id = 'Species+', property = 2040, pattern = '%d%d?%d?%d?%d?' },
	{ id = 'SPRAT', property = 2455, pattern = '[1-9]%d*' },
	{ id = 'Steere', property = 6035, pattern = '[1-9]%d*' },
	{ id = 'TAXREF', property = 3186, pattern = '%d+' }, ---[[]] DNE
	{ id = 'TelaBotanica', property = 3105, pattern = '%d+' },
	{ id = 'Titan', property = 4125, pattern = '%d+' }, ---[[]] DNE
	{ id = 'Tree of Life', property = 5221, pattern = { '[1-9]%d*', '%a+' } },
	{ id = 'Tropicos', property = 960, pattern = '[1-9]%d?%d?%d?%d?%d?%d?%d?%d?' },
	{ id = 'uBio', property = 4728, pattern = '[1-9]%d*' }, ---[[Universal Biological Indexer and Organizer]] DNE
	{ id = 'VASCAN', property = 1745, pattern = '%d%d?%d?%d?%d?' }, ---[[Vascular Plants of Canada]] DNE
	{ id = 'Verspreidingsatlas', property = 6142, pattern = '[A-Z]?%d+' }, ---[[]] DNE
	{ id = 'VicFlora', property = 5945, pattern = '%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x' }, ---closest match
	{ id = 'Vlinderstichting', property = 3322, pattern = '%d+' }, ---[[]] DNE
	{ id = 'Watson', label = 'Watson & Dallwitz', property = 1761, pattern = '[a-z][a-z][a-z][a-z][a-z][a-z][a-z]?[a-z]?' }, ---[[]] DNE
	{ id = 'WCSP', property = 3591, pattern = '%d%d?%d?%d?%d?%d?%d?' },
	{ id = 'WikiAves', property = 4664, pattern = '[^%s/%?]+' }, ---[[]] DNE
	{ id = 'Wikispecies', label = 'Уикивидове', property = 'Wikispecies:$1' },
	{ id = 'WiO', property = 6285, pattern = '[a-z][a-z_]*' }, ---[[Weeds in Ontario]] DNE
	{ id = 'WisFlora', property = 6227, pattern = '[1-9]%d*' }, ---[[Flora of Wisconsin]] DNE
	{ id = 'WoI', property = 3746, pattern = '[1-9]%d?%d?%d?' }, ---[[Wildflowers of Israel]] DNE
	{ id = 'WoRMS', property = 850, pattern = '[1-9]%d?%d?%d?%d?%d?%d?' },
	{ id = 'WSC', property = 3288, pattern = 'urn:lsid:nmbe%.ch:spider[sgf][pea][nm]?:%d%d%d%d%d?%d?' },
	{ id = 'Xeno-canto', property = 2426, pattern = '[A-Z][a-z]+%-[a-z][a-z]+' },
	{ id = 'ZooBank', property = 1746, pattern = rep('[A-Z%d]', 8) .. rep('%-[A-Z%d][A-Z%d][A-Z%d][A-Z%d]', 3) .. '%-' .. rep('[A-Z%d]', 12) },
}

local tCats = {
	'[[Категория:Страници с празен нормативен контрол]]',
	'', --  [2] placeholder for [[Категория:Нормативен контрол с невалидни идентификатори]]
	'', --  [3] placeholder for [[Категория:Нормативен контрол с потиснати идентификатори]]
	'', --  [4] placeholder for [[Категория:Нормативен контрол с ръчно въведени идентификатори]]
	'', --  [5] placeholder for [[Категория:Нормативен контрол с ръчно въведени идентификатори, различаващи се с тези от Уикиданни]]
	'', --  [6] placeholder for [[Категория:Нормативен контрол с ръчно въведени идентификатори, идентични с тези от Уикиданни]]
	'', --  [7] placeholder for [[Категория:Нормативен контрол с повтарящи се стойности на параметри за извикване на Уикиданни]]
	'', --  [8] placeholder for [[Категория:Нормативен контрол с множество ръчно въведени параметри за извикване на Уикиданни]]
	'', --  [9] placeholder for [[Категория:Нормативен контрол с автоматично добавени базионими]]
	'', -- [10] placeholder for [[Категория:Нормативен контрол с автоматично добавени протоними]]
	'', -- [11] placeholder for [[Категория:Нормативен контрол с автоматично добавен монотипен род]]
	'', -- [12] placeholder for [[Категория:Нормативен контрол в монотипен вид с липсващи родове]]
}

--[[==========================================================================]]
--[[                              Local functions                             ]]
--[[==========================================================================]]
local function nilOrEmpty(v)
	return not v or v == ''
end

local function getLink(property, val, label)
	local link, returnVal = '', {}

	returnVal.isError = false

	if mw.ustring.match(val, '^//') or mw.ustring.match(val, '^[Hh][Tt][Tt][Pp][Ss]?://') then
		link = val
	else
		if type(property) == 'number' and property > 0 then
			local entityObject = mw.wikibase.getEntity('P' .. property)
			local dataType

			if entityObject then
				dataType = entityObject.datatype
			else
				returnVal.isError = true
			end

			if dataType == 'external-id' then
				local formatterURL = nil
				if property == 3746 or --Wildflowers of Israel
				   property == 3795 or --Flora of Israel Online
				   property == 5397 --Tierstimmenarchiv
				then
					formatterURL = entityObject:getBestStatements('P1630')[2] --use 2nd formatterURL for English version
				end
				if not formatterURL then formatterURL = entityObject:getBestStatements('P1630')[1] end --default to [1]
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
		if mw.ustring.find(link, 'antweb.org') then valurl = mw.ustring.gsub(valurl, ' ', '%%20') end
		if type(property) == 'number' then
			--doublecheck language for Wildflowers of Israel ID
			if property == 3746 then link = mw.ustring.gsub(link, '/hebrew/', '/english/') end
			--remove spaces in ISNI
			if property == 213 then valurl = mw.ustring.gsub(valurl, ' ', '') end
			--format spaces in PfaF, e.g. for "Elaeagnus x ebbingei"
			if property == 4301 then valurl = mw.ustring.gsub(valurl, ' ', '+') end
		end
		valurl = mw.ustring.gsub(valurl, '%%', '%%%%')
		link = mw.ustring.gsub(link, '$1', valurl)
	end

	link = mw.ustring.gsub(link, '^[Hh][Tt][Tt][Pp]([Ss]?)&#58;//', 'http%1://') -- fix wikidata URL
	--val = mw.ustring.match(val, '([^=/]*)/?$') -- get display name from end of URL
	if not nilOrEmpty(link) then
		if mw.ustring.find(link, '//') then
			returnVal.text = '[' .. link .. ' ' .. label .. ']'
		else
			returnVal.text = '[[' .. link .. '|' .. label .. ']]'
		end
	end

	return returnVal
end

local function getIdFromWikidata(item, property)
	if property == 'PWikispecies:$1' then
		return item:getSitelink('specieswiki')
	else
		local claim = item:getBestStatements(property)
		for i = 1, #claim do
			if claim[i].mainsnak.datavalue then
				return claim[i].mainsnak.datavalue.value
			end
		end
	end
end

local function createItem(label, rawValue, link, withUid, validValue, pencil)
	if not link then return nil end
	if not validValue then
		tCats[2] = '[[Категория:Нормативен контрол с невалидни идентификатори]]'
		return '* ' .. label .. ': <abbr title="Невалиден идентификатор" class="error" style="font-size:inherit">' .. rawValue .. '</abbr>' .. pencil .. '\n'
	end
	if withUid then link = '<span class="uid">' .. link .. '</span>' end
	return '* ' .. link .. '\n'
end

local function editAtWikidata(qid, pid)
	if not (qid and mw.ustring.match(qid, '^%s*[Qq]?%d+%s*$')) then return '' end
	local link = ':d:' .. mw.ustring.gsub(qid, '^%s*[Qq]?(%d+)%s*$', 'Q%1') .. mw.ustring.gsub(pid or '', '^%s*[Pp]?(%d+)%s*$', '#P%1')
	return '[[Файл:OOjs UI icon edit-ltr-progressive.svg|frameless|text-top|10px|link=' .. link .. '|Редактиране в Уикиданни]]'
end

--[[==========================================================================]]
--[[                           Documentation table                            ]]
--[[==========================================================================]]

-- Creates a human-readable wikitable version of databases
function p.doc(frame)
	local wikiTable = '\n{| class="wikitable sortable" style="width:98%; margin:0"' ..
					  '\n|-' ..
					  '\n! style="width:19.6%" | Параметър' ..
					  '\n! style="width:19.6%" | Показване в нав. лента' ..
					  '\n! style="width:19.6%" | Свойство в [[Уикиданни|УД]]' ..
					  '\n! style="width:19.6%" | Валидиране чрез [[Регулярен израз|РИ]]?' ..
					  '\n! style="width:19.6%" | Със свойство за валиден URL в УД?'
	for i = 1, #databases do
		local param = mw.ustring.lower(databases[i].id)
		local label = databases[i].label or databases[i].id
		local property = tonumber(databases[i].property)
		if property then
			property = '[[:d:Property:P' .. property .. '|P' .. property .. ']]'
		else
			property = '—'
		end
		local rxValidation = nilOrEmpty(databases[i].pattern) and 'не' or 'да'
		local validLink = getLink(databases[i].property, '', label).text and 'да' or 'не'
		--concat
		wikiTable = wikiTable ..
					'\n|-' ..
					'\n| ' .. param ..
					'\n| ' .. label ..
					'\n| ' .. property ..
					'\n| ' .. rxValidation ..
					'\n| ' .. validLink
	end
	wikiTable = wikiTable .. '\n|}\n'
	return mw.text.tag('div', { style = 'height:550px; width:99%; overflow:auto; padding:0' }, wikiTable)
end

--[[==========================================================================]]
--[[                                   Main                                   ]]
--[[==========================================================================]]

function p.main(frame)
	local resolveEntity = require('Модул:ResolveEntityId')._id
	local currentTitle = mw.title.getCurrentTitle()
	local namespace = currentTitle.namespace
	local currentId = namespace == 0 and resolveEntity(mw.wikibase.getEntityIdForCurrentPage())
	local parentArgs = {}
	local fromTitleCount, rowCount = 1, 0
	local outString = ''
	local tFroms = {} --non-sequential table of unique froms
	local iFroms = 0 --integer size of tFroms, b/c Lua

	--Process args
	for k, v in pairs(frame:getParent().args) do
		if type(k) == 'string' then
			--make args case insensitive
			local lowerk = mw.ustring.lower(k)
			parentArgs[lowerk] = v
			--remap abc to abc1
			if not mw.ustring.find(lowerk, '%d$') then --if no number at end of param
				if not parentArgs[lowerk .. '1'] then
					parentArgs[lowerk] = nil
					lowerk = lowerk .. '1'
					parentArgs[lowerk] = v
				end
			end
			--find highest from param
			if mw.ustring.sub(lowerk, 1, 4) == 'from' then
				v = resolveEntity(v)
				if v == currentId then v = nil end
				local fromNumber = tonumber(mw.ustring.sub(lowerk, 5, -1))
				if fromNumber and fromNumber >= fromTitleCount then fromTitleCount = fromNumber end
				if v then --is valid eid or title
					--look for duplicate froms while we're here
					if tFroms[v] then
						tCats[7] = '[[Категория:Нормативен контрол с повтарящи се стойности на параметри за извикване на Уикиданни]]'
						v = nil
					else
						tFroms[v] = true
						iFroms = iFroms + 1
					end
				end
				parentArgs[lowerk] = v
			end
		end
	end

	if iFroms > 2 then
		tCats[8] = '[[Категория:Нормативен контрол с множество ръчно въведени параметри за извикване на Уикиданни]]'
	end

	--Assess the page's relationship with Wikidata
	local currentItem = nil
	if currentId then
		currentItem = mw.wikibase.getEntity(currentId)
	elseif parentArgs['from1'] then -- optional for pages not connected to WD or not in main namespace (for test purposes)
		currentItem = mw.wikibase.getEntity(parentArgs['from1'])
		parentArgs['from1'] = nil
	end

	if currentItem then --Taxа specific
		local acceptable = {
			['Q16521'] = 'taxon',
			['Q310890'] = 'monotypic taxon',
			['Q2568288'] = 'ichnotaxon',
			['Q23038290'] = 'fossil taxon',
			['Q47487597'] = 'monotypic fossil taxon',
		} --strict
		--Append basionym to arg list, if not already provided
		local currentBasState = currentItem:getBestStatements('P566')[1] --basionym
		if currentBasState then
			local basionymId = currentBasState.mainsnak.datavalue.value.id
			if basionymId and resolveEntity(basionymId) and not tFroms[basionymId] then
				--check that basionym is a strict instance of taxon
				local basionymItem = mw.wikibase.getEntity(basionymId)
				if basionymItem then
					for _, instanceOfState in pairs(basionymItem:getBestStatements('P31')) do --instance of
						local instanceOf = instanceOfState.mainsnak.datavalue.value.id
						if acceptable[instanceOf] then
							fromTitleCount = fromTitleCount + 1
							--append basionym & track
							parentArgs['from' .. fromTitleCount] = basionymId
							tCats[9] = '[[Категория:Нормативен контрол с автоматично добавени базионими]]'
							break
						end
					end
				end
			end
		end
		--Append original combination to arg list, if not already provided
		local currentOCState = currentItem:getBestStatements('P1403')[1] --original combination
		if currentOCState then
			local orcoId = currentOCState.mainsnak.datavalue.value.id
			if orcoId and resolveEntity(orcoId) and not tFroms[orcoId] then
				--check that orco is a strict instance of taxon
				local orcoItem = mw.wikibase.getEntity(orcoId)
				if orcoItem then
					for _, instanceOfState in pairs(orcoItem:getBestStatements('P31')) do --instance of
						local instanceOf = instanceOfState.mainsnak.datavalue.value.id
						if acceptable[instanceOf] then
							fromTitleCount = fromTitleCount + 1
							--append orco & track
							parentArgs['from' .. fromTitleCount] = orcoId
							tCats[10] = '[[Категория:Нормативен контрол с автоматично добавени протоними]]'
							break
						end
					end
				end
			end
		end
		--Append monotypic genus/species to arg list of monotypic species/genus, if not already provided
		for _, instanceOfState in pairs(currentItem:getBestStatements('P31')) do --instance of
			local taxonRank = nil
			local parentItem = nil
			local parentTaxon = nil
			local parentTaxonRank = nil
			local parentMonoGenus = nil --holy grail/tbd
			local instanceOf = instanceOfState.mainsnak.datavalue.value.id
			if instanceOf and (instanceOf == 'Q310890' or instanceOf == 'Q47487597') then --monotypic/fossil taxon
				local taxonRankState = currentItem:getBestStatements('P105')[1] --taxon rank
				if taxonRankState then
					taxonRank = taxonRankState.mainsnak.datavalue.value.id
				end
				if taxonRank and taxonRank == 'Q7432' then --species
					--is monotypic species; add genus
					local parentTaxonState = currentItem:getBestStatements('P171')[1] --parent taxon
					if parentTaxonState then parentTaxon = parentTaxonState.mainsnak.datavalue.value.id end
					--confirm parent taxon rank == genus & monotypic
					if parentTaxon and resolveEntity(parentTaxon) then
						parentItem = mw.wikibase.getEntity(parentTaxon)
						if parentItem then
							local parentTaxonRankState = parentItem:getBestStatements('P105')[1] --taxon rank
							if parentTaxonRankState then parentTaxonRank = parentTaxonRankState.mainsnak.datavalue.value.id end
							if parentTaxonRank and parentTaxonRank == 'Q34740' then --parent == genus
								for _, parentInstanceOfState in pairs(parentItem:getBestStatements('P31')) do --instance of
									local parentInstanceOf = parentInstanceOfState.mainsnak.datavalue.value.id
									if parentInstanceOf and
									  (parentInstanceOf == 'Q310890' or parentInstanceOf == 'Q47487597') then --monotypic/fossil taxon
										parentMonoGenus = parentTaxon --confirmed
										break
									end
								end
								if parentMonoGenus and not tFroms[parentMonoGenus] then
									fromTitleCount = fromTitleCount + 1
									--append monotypic genus & track
									parentArgs['from' .. fromTitleCount] = parentMonoGenus
									tCats[11] = '[[Категория:Нормативен контрол с автоматично добавен монотипен род]]'
									break
								end
							end
						end
					end
					if not (parentMonoGenus or tFroms[parentMonoGenus]) then
						tCats[12] = '[[Категория:Нормативен контрол в монотипен вид с липсващи родове]]'
						break
					end
				--elseif taxonRank and taxonRank == 'Q34740' then --genus
					--is monotypic genus; add species
					--...
				end
			end
		end
	end --if currentItem

	--Setup navbox
	local navboxParams = {
		name = 'Нормативен контрол',
		bodyclass = 'hlist hlist-big plainlinks',
		state = 'off',
		navbar = 'off',
	}

	local currentOnce = true
	for f = 1, fromTitleCount + 1 do
		local elements, fromWikidata = {}, {}
		local title, item = nil, nil
		if currentOnce and not parentArgs['from' .. f] then
			item = currentItem
			title = currentTitle.text
			parentArgs['from' .. f] = item and item.id or title
			currentOnce = false
		end
		if parentArgs['from' .. f] then
			--Fetch Wikidata item
			if not item and parentArgs['from' .. f] ~= title then
				item = mw.wikibase.getEntity(parentArgs['from' .. f])
			end
			if item then
				local statements = item:getBestStatements('P225') --taxon name
				if statements and statements[1] then
					local datavalue = statements[1].mainsnak.datavalue
					if datavalue then
						title = require('Модул:TaxonItalics').italicizeTaxonName(datavalue.value, false) -- italicize taxon name
					end
				end
				title = title or item:getLabel() or item:getSitelink() or item.id
			end

			if not nilOrEmpty(title) then
				title = mw.title.new(title)
			end

			if title then
				for i = 1, #databases do
					local param = mw.ustring.lower(databases[i].id)
					local label = databases[i].label or databases[i].id
					local propId = databases[i].property
					local pattern = databases[i].pattern
					local val = parentArgs[param .. f]
					--Wikidata fallback if requested
					local wikidataId = item and getIdFromWikidata(item, 'P' .. propId)
					if wikidataId then
						if not val then
							val = wikidataId
							fromWikidata[param .. f] = true
						elseif val == '' then
							tCats[3] = '[[Категория:Нормативен контрол с потиснати идентификатори]]'
						else
							if val ~= wikidataId then
								tCats[5] = '[[Категория:Нормативен контрол с ръчно въведени идентификатори, различаващи се с тези от Уикиданни]]'
							else
								tCats[6] = '[[Категория:Нормативен контрол с ръчно въведени идентификатори, идентични с тези от Уикиданни]]'
							end
						end
					else
						if not nilOrEmpty(val) then
							tCats[4] = '[[Категория:Нормативен контрол с ръчно въведени идентификатори]]'
						end
					end

					if not nilOrEmpty(val) then
						local validValue = false
						if nilOrEmpty(pattern) then
							--non-existent pattern; assume the value is always valid
							validValue = true
						elseif type(pattern) == 'string' then
							if mw.ustring.match(val, '^' .. pattern .. '$') then
								validValue = true
							end
						elseif type(pattern) == 'table' then
							for j = 1, #pattern do
								if mw.ustring.match(val, '^' .. pattern[j] .. '$') then
									validValue = true
								end
							end
						end

						local rowItem = nil
						--skip item creation for WorldCat Identities if there is a WorldCat Entities entry/item
						--or for Wikispecies for the current title/eid
						if not (param == 'worldcat identities' and (parentArgs['worldcat entities' .. f] or fromWikidata['worldcat entities' .. f]) or param == 'wikispecies' and (parentArgs['from' .. f] == mw.wikibase.getEntityIdForCurrentPage() or parentArgs['from' .. f] == currentTitle.text)) then
							rowItem = createItem(label, val, getLink(propId, val, label).text, param ~= 'worldcat identities' and param ~= 'wikispecies', validValue, editAtWikidata(fromWikidata[param .. f] and parentArgs['from' .. f], propId))
						end
						if rowItem then table.insert(elements, rowItem) end
					end
				end

				--Generate navbox row
				if #elements > 0 then
					rowCount = rowCount + 1
					navboxParams['wd-edit' .. rowCount] = editAtWikidata(parentArgs['from' .. f], '#identifiers')
					navboxParams['group' .. rowCount] = mw.ustring.gsub(title.text, '%s+%b()$', '') .. navboxParams['wd-edit' .. rowCount]
					navboxParams['list' .. rowCount] = table.concat(elements)
				end
			end
		end
	end --for f = 1, fromTitleCount

	--adjust navbox for number of rows
	if rowCount > 0 then
		tCats[1] = '' --AC is not empty
		if rowCount == 1 then
			navboxParams['group1'] = 'Нормативен контрол' .. navboxParams['wd-edit1']
		else
			navboxParams['title'] = 'Нормативен контрол'
			navboxParams['state'] = 'expanded'
		end
		outString = require('Модул:Navbox')._navbox(navboxParams)
	end

	if namespace == 0 or namespace == 2 or namespace == 118 then --tracking categories only in Main, User or Draft NS
		outString = outString .. table.concat(tCats)
		if not nilOrEmpty(parentArgs['demo1']) or not nilOrEmpty(parentArgs['test1']) then
			outString = mw.ustring.gsub(outString, '(%[%[)(Категория:)', '%1:%2')
		end
	end

	return outString
end

return p
