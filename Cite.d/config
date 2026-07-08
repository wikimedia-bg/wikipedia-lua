--local cfg = mw.loadData ('Module:Citation/CS1/Configuration');					-- TODO: in future, use this to replace current <known_templates_t> and <citation_classes_t>

--[[--------------------------< S E T T I N G S >--------------------------------------------------------------

settings definitions for i18n; translate only the rvalues

]]

local settings_t = {
	err_category = 'CS1 errors: cite module',									-- name of category that lists article with Module:Cite errors
	help = 'help',																-- help link display text for error messages
	help_text_link = 'Help:CS1 errors#module_cite',								-- help text for error messages can be found on this page
	
	unknown_name = 'unknown template name: $1',									-- error message; $1 is lowercase value extracted from invoke function name
	}


--[[--------------------------< K N O W N _ T E M P L A T E S _ T >--------------------------------------------

list of all known cs1|2 templates by their lowercase names.

key is lowercase template name

]]
--[[ TODO: in future, use this to replace current <known_templates_t> and <citation_classes_t>
local known_templates_t = {};													-- list of all known cs1|2 templates by their lowercase names.  key is lowercase template name
local citation_classes_t = {};													-- list of all known cs1|2 CitationClass values.  key is lowercase template name

for k, v in pairs (cfg.citation_class_map_t) do
	local template = v:gsub ('cite ', ''):lower();								-- remove 'cite ' prefix, set template name to lowercase
	known_templates_t[template] = true;											-- add as a known template
	citation_classes_t[template] = k;											-- add to list of citation classes
end
]]

local known_templates_t = {
	['arxiv'] = true,
	['av media'] = true,
	['av media notes'] = true,
	['biorxiv'] = true,
	['book'] = true,
	['citation'] = true,
	['citeseerx'] = true,
	['conference'] = true,
	['document'] = true,
	['encyclopedia'] = true,
	['episode'] = true,
	['interview'] = true,
	['journal'] = true,
	['magazine'] = true,
	['mailing list'] = true,
	['map'] = true,
	['medrxiv'] = true,
	['news'] = true,
	['newsgroup'] = true,
	['podcast'] = true,
	['press release'] = true,
	['report'] = true,
	['serial'] = true,
	['sign'] = true,
	['speech'] = true,
	['ssrn'] = true,
	['tech report'] = true,
	['thesis'] = true,
	['web'] = true,
	}


--[[--------------------------< C I T A T I O N _ C L A S S E S _ T >-----------------------------------------

|CitationClass= in the cs1|2 templates gets the lowercase template name except for these for which the canonical
template name has multiple words (and the oddity that is class="encyclopaedia" – really ought to fix that in
Module:Citation/CS1)

key is lowercase canonical template name

]]

local citation_classes_t = {
	['av media'] = 'audio-visual',
	['av media notes'] = 'AV-media-notes',
	['encyclopedia'] = 'encyclopaedia',
	['mailing list'] = 'mailinglist',
	['press release'] = 'pressrelease',
	['tech report'] = 'techreport',
	}


--[[--------------------------< E X P O R T S >----------------------------------------------------------------
]]

return {
	citation_classes_t = citation_classes_t,
	error_messages_t = error_messages_t,
	known_templates_t = known_templates_t,
	settings_t = settings_t,
	}
