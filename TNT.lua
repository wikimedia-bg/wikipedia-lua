--
-- INTRO:   (!!! DON'T RENAME THIS PAGE !!!)
--    This module allows any template or module to be copy/pasted between
--    wikis without any translation changes. All translation text is stored
--    in the global  Data:*.tab  pages on Commons, and used everywhere.
--
-- SEE:   https://www.mediawiki.org/wiki/Multilingual_Templates_and_Modules
-- ATТENTION:
--    Please do NOT rename this module - it has to be identical on all wikis.
--    This code is maintained at https://www.mediawiki.org/wiki/Module:TNT
--    Please do not modify it anywhere else, as it may get copied and override your changes.
--    Suggestions can be made at https://www.mediawiki.org/wiki/Module_talk:TNT
-- DESCRIPTION:
--    The "msg" function uses a Commons dataset to translate a message
--    with a given key (e.g. source-table), plus optional arguments
--    to the wiki markup in the current content language.
--    Use lang=xx to set language.  Example:
-- end
--    {{#invoke:TNT | msg
--     | I18n/Template:Graphs.tab  <!-- http://commons.wikimedia.org/wiki/Data:I18n/Template:Graphs.tab -->
--     | source-table              <!-- uses a translation message with id = "source-table" -->
--     | param1 }}                 <!-- optional parameter -->
--
--
--    The "doc" function will generate the <templatedata> parameter documentation for templates.
--    This way all template parameters can be stored and localized in a single Commons dataset.
--    NOTE: "doc" assumes that all documentation is located in Data:Templatedata/* on Commons.
--
--    {{#invoke:TNT | doc | Graph:Lines }}
--        uses https://commons.wikimedia.org/wiki/Data:Templatedata/Graph:Lines.tab
--        if the current page is Template:Graph:Lines/doc
-- end

local p = {}
local i18nDataset = 'I18n/Module:TNT.tab'
local checkType = require('libraryUtil').checkType

-- Forward declaration of the local functions
local formatMessage, loadData, link

function p.msg(frame)
	local dataset, id
	local params = {}
	local lang = nil
	for k, v in pairs(frame.args) do
		if k == 1 then
			dataset = mw.text.trim(v)
		elseif k == 2 then
			id = mw.text.trim(v)
		elseif type(k) == 'number' then
			table.insert(params, mw.text.trim(v))
		elseif k == 'lang' and v ~= '_' then
			lang = mw.text.trim(v)
		end
	end
	return formatMessage(dataset, id, params, lang)
end

-- Identical to p.msg() above, but used from other lua modules
function p.format(dataset, key, params, lang)
	checkType('format', 1, dataset, 'string')
	checkType('format', 2, key, 'string')
	checkType('format', 3, params, 'table', true)
	checkType('format', 4, lang, 'string', true)
	-- end
	return formatMessage(dataset, key, params, lang)
end

-- Converts first parameter to a interwiki-ready link. For example, it converts
-- "Sandbox/Sample.tab" -> 'commons:Data:Sandbox/Sample.tab'
function p.link(frame)
	return link(frame.args[1])
end

function p.doc(frame)
	return frame:extensionTag(
			'templatedata',
			p.getTemplateData(mw.text.trim(frame.args[1]))
	) .. formatMessage(i18nDataset, 'edit_doc', {link(dataset)})
end

function p.getTemplateData(page)
	dataset = 'Templatedata/' .. mw.text.trim(page)
	-- TODO: add '_' parameter once lua starts reindexing properly for "all" languages
	local data = loadData(dataset)
	local names = {}
	for _, field in pairs(data.schema.fields) do
		table.insert(names, field.name)
	end

	local params = {}
	local paramOrder = {}
	for _, row in pairs(data.data) do
		local newVal = {}
		local name = nil
		for pos, val in pairs(row) do
			local columnName = names[pos]
			if columnName == 'name' then
				name = val
			else
				newVal[columnName] = val
			end
		end
		if name then
			params[name] = newVal
			table.insert(paramOrder, name)
		end
	end

	-- Work around json encoding treating {"1":{...}} as an [{...}]
	params['zzz123']=''

	local json = mw.text.jsonEncode({
		params=params,
		paramOrder=paramOrder,
		description=data.description
	})

	json = string.gsub(json,'"zzz123":"",?', "")

	return json
end

-- Local functions

loadData = function(dataset, lang)
	if not dataset or dataset == '' then
		error(formatMessage(i18nDataset, 'error_no_dataset', {}))
	end
	if string.sub(dataset,-4) ~= '.tab' then
		dataset = dataset .. '.tab'
	end

	local data = mw.ext.data.get(dataset, lang)

	if data == false then
		if dataset == i18nDataset then
			-- Prevent cyclical calls
			error('Missing Commons dataset ' .. i18nDataset)
		else
			error(formatMessage(i18nDataset, 'error_bad_dataset', {link(dataset)}))
		end
	end
	return data
end

-- Given a dataset name, convert it to a title with the 'commons:data:' prefix
link = function(dataset)
	dataset = 'Data:' .. mw.text.trim(dataset or '')
	if mw.site.siteName == 'Wikimedia Commons' then
		return dataset
	else
		return 'commons:' .. dataset
	end
end

formatMessage = function(dataset, key, params, lang)
	for _, row in pairs(loadData(dataset, lang).data) do
		local id, msg = unpack(row)
		if id == key then
			local result = mw.message.newRawMessage(msg, unpack(params or {}))
			return result:plain()
		end
	end
	if dataset == i18nDataset then
		-- Prevent cyclical calls
		error('Invalid message key "' .. key .. '"')
	else
		error(formatMessage(i18nDataset, 'error_bad_msgkey', {key, link(dataset)}))
	end
end

return p
