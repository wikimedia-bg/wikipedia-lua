-- Module:Wikibase
local p = {}
 
-- Return the item ID of the item linked to the current page.
function p.id(frame)
        if not mw.wikibase then
           return "wikibase module not found"
        end
 
        entity = mw.wikibase.getEntityObject()
 
        if entity == nil then
           return "(no item connected)"
        end
 
        return entity.id
end
 
-- Return the label of a given data item.
function p.label(frame)
        if frame.args[1] == nil then
            entity = mw.wikibase.getEntityObject()
            if not entity then return nil end
 
            id = entity.id
        else
            id = frame.args[1]
        end
 
        return mw.wikibase.label( id )
end
 
-- Return the local page about a given data item.
function p.page(frame)
        if frame.args[1] == nil then
            entity = mw.wikibase.getEntityObject()
            if not entity then return nil end
 
            id = entity.id
        else
            id = frame.args[1]
        end
 
        return mw.wikibase.sitelink( id )
end
 
return p