local p = {}

function p._id(idOrTitle, alt)
	local function checkId(id)
		if id and mw.wikibase.entityExists(id) then
			return mw.wikibase.getEntity(id).id
		end
		return alt
	end

	if type(idOrTitle) == 'string' then
		idOrTitle = mw.ustring.upper(mw.ustring.sub(idOrTitle, 1, 1)) .. mw.ustring.sub(idOrTitle, 2)
		if mw.wikibase.isValidEntityId(idOrTitle) then
			-- idOrTitle is in the proper format for a Wikidata entity ID
			return checkId(idOrTitle)
		else
			local eid = mw.wikibase.getEntityIdForTitle(idOrTitle)
			if eid then
				-- idOrTitle is a title that matches a Wikidata entity
				local instanceOf = mw.wikibase.getBestStatements(eid, 'P31')
				local notDisambiguation = true
				for i = 1, #instanceOf do
					local datavalue = instanceOf[i].mainsnak.datavalue
					if datavalue and datavalue.value and datavalue.value.id == 'Q4167410' then
						notDisambiguation = false
					end
				end
				if notDisambiguation then
					-- "instance of" doesn't contain "disambiguation page" value
					return checkId(eid)
				end
			else
				-- idOrTitle is a title, but no wikidata item exists for that title
				local page = mw.title.new(idOrTitle)
				if page then -- valid title
					local rtarget = page.redirectTarget
					if rtarget then	-- title is a Wikipedia redirect
						return p._id(rtarget.fullText, alt)
					end
				end
			end
		end
	end
	return alt
end

function p.entityid(frame)
	return p._id(frame.args[1], frame.args[2])
end

return p
