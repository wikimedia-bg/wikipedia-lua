--
-- INTRO:   (!!! DO NOT RENAME THIS PAGE !!!)
--    This module allows any template or module to be copy/pasted between
--    wikis without any translation changes. All translation text is stored
--    in the g:   https://www.mediawiki.org/wiki/Multilingual_Templates_and_Modules
--
-- ATTENTION:
--    Please do NOT rename this module - it had to be identical
--    The "msg" function uses a Commons dataset to translate a message
--    with a given key (e.g. source-table), plus optional arguments
--    to the wiki markup in the current content language.
--    Use lang=xx to set language.  Example:
--
--    {{#invoke:TNT | msg
--     | I18n/Template:Graphs.tab  <!-- https://commons.wikimedia.org/wiki/Data:I18n/Template:Graphs.tab -->
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
--

local p = {}
local i18nDataset = 'I18n/Module:TNT.tab'

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
			table.insert(params, v)
		elseif k == 'lang' and v ~= '_' then
			lang = mw.text.trim(v)
		end
	end
	return formatMessage(dataset, id, params, lang)
end

-- Converts first parameter to a interwiki-ready link. For example, it converts
-- "Sandbox/Sample.tab" -> 'commons:Data:Sandbox/Sample.tab'
function p.link(frame)
	return link(frame.args[1])
end

-- Given a dataset name, convert it to a title with the 'commons:data:' prefix
function link(dataset)
	dataset = 'Data:' .. mw.text.trim(dataset or '')
	if mw.site.siteName == 'Wikimedia Commons' then
		return dataset
	else
		return 'commons:' .. dataset
	end
end

function p.doc(frame)
	return frame:extensionTag(
		'templatedata',
		p.getTemplateData(frame.args[1])
	) .. tntMessage('edit_doc', {link(dataset)})
end

function p.getTemplateData(page)
	dataset = 'Templatedata/' .. normalizeDataset(page)
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

function formatMessage(dataset, key, params, lang)
    for _, row in pairs(loadData(dataset, lang).data) do
    	local id, msg = unpack(row)
    	if id == key then
    		local result = mw.message.newRawMessage(msg, unpack(params))
    		return result:plain()
    	end
    end
	if dataset == i18nDataset then
		-- Prevent cyclical calls
		error('Invalid message key "' .. key .. '"')
	else
		error(tntMessage('error_bad_msgkey', {key, link(dataset)}))
	end
end

function tntMessage(key, params)
	return formatMessage(i18nDataset, key, params)
end

function normalizeDataset(dataset)
	if not dataset or dataset == '' then
		error(tntMessage('error_no_dataset', {}))
	end
	if string.sub(dataset,-4) ~= '.tab' then
		dataset = dataset .. '.tab'
	end
	return dataset
end

function loadData(dataset, lang)
	local data = mw.ext.data.get(dataset, lang)
	if data == false then
		if dataset == i18nDataset then
			-- Prevent cyclical calls
			error('Missing Commons dataset ' .. i18nDataset)
		else
			error(tntMessage('error_bad_dataset', {link(dataset)}))
		end
	end
	return data
end

return p
