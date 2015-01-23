-- This module contains shared functions used by [[Module:Category handler]]
-- and its submodules.

local p = {}

function p.matchesBlacklist(page, blacklist)
	for i, pattern in ipairs(blacklist) do
		local match = mw.ustring.match(page, pattern)
		if match then
			return true
		end
	end
	return false
end

function p.getParamMappings(useLoadData)
	local dataPage = 'Module:Namespace detect/data'
	if useLoadData then
		return mw.loadData(dataPage).mappings
	else
		return require(dataPage).mappings
	end
end

function p.getNamespaceParameters(titleObj, mappings)
	-- We don't use title.nsText for the namespace name because it adds
	-- underscores.
	local mappingsKey
	if titleObj.isTalkPage then
		mappingsKey = 'talk'
	else
		mappingsKey = mw.site.namespaces[titleObj.namespace].name
	end
	mappingsKey = mw.ustring.lower(mappingsKey)
	return mappings[mappingsKey] or {}
end

return p