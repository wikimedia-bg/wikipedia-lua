local p = {}

function p._entityid(_,id,alt)
	-- backwards compatibility for deprecated _entityid function
	return p._id(id,alt)
end

function p._id(id,alt)
	if type(id) == 'string' then
		id = mw.ustring.upper(mw.ustring.sub(id,1,1))..mw.ustring.sub(id,2)
		if mw.ustring.match(id,'^Q%d+$') then
			-- id is in the proper format for a Wikidata entity
			if mw.wikibase.isValidEntityId(id) then
				-- id is valid
				id = mw.wikibase.getEntity(id)
				if id then
					-- entity exists
					return id.id
				end
			end
		else
			id = mw.wikibase.getEntityIdForTitle(id)
			if id then
				-- id is a title that matches a Wikidata entity
				local instanceOf = mw.wikibase.getBestStatements(id, 'P31')[1] --instance of
				if instanceOf and instanceOf.mainsnak.datavalue.value.id ~= 'Q4167410' then
					-- not disambiguation
					return mw.wikibase.getEntity(id).id
				elseif instanceOf == nil then
					-- id is a title, but is missing an instance-of value
					return mw.wikibase.getEntity(id).id
				end
			end
		end
	end
	return alt or nil
end

function p.entityid(frame)
	return p._id(frame.args[1], frame.args[2])
end

return p
