--[[
SDcat
Module to check whether local short description matches that on Wikidata
--]]

local p = {}

-------------------------------------------------------------------------------
--[[
setCat has the qid of a Wikidata entity passed as |qid=
(it defaults to the associated qid of the current article if omitted)
and the local short description passed as |sd=
It returns a category if there is an associated Wikidata entity.
It returns one of the following tracking categories, as appropriate:
* Category:Short description matches Wikidata (case-insensitive)
* Category:Short description is different from Wikidata
* Category:Short description with empty Wikidata description
For testing purposes, a link prefix |lp= may be set to ":" to make the categories visible.
--]]

-- function exported for use in other modules
-- (local short description, Wikidata entity-ID, link prefix)
p._setCat = function(sdesc, itemID, lp)
	if not mw.wikibase then return nil end
	if itemID == "" then itemID = nil end
	-- Wikidata description field
	local wdesc = (mw.wikibase.getDescription(itemID) or ""):lower()
	if wdesc == "" then
		return "[[" .. lp .. "Category:Short description with empty Wikidata description]]"
	elseif wdesc == sdesc then
		return "[[" .. lp .. "Категория:Краткото описание съвпада с Wikidata]]"
	else
		return "[[" .. lp .. "Category:Short description is different from Wikidata]]"
	end
end

-- function exported for call from #invoke
p.setCat = function(frame)
	local args
	if frame.args.sd then
		args = frame.args
	else
		args = frame:getParent().args
	end
	-- local short description
	local sdesc = mw.text.trim(args.sd or ""):lower()
	-- Wikidata entity-ID
	local itemID = mw.text.trim(args.qid or "")
	-- link prefix, strip quotes
	local lp = mw.text.trim(args.lp or ""):gsub('"', '')
	return p._setCat(sdesc, itemID, lp)
end

return p
