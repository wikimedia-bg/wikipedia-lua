local p = {}

function p.Greece(frame)
	local year = frame.args.year

	if not year then
		return
	end

	local qid = mw.wikibase.getEntityIdForCurrentPage()

	local entity = mw.wikibase.getEntity(qid)

	if not entity or not entity.claims then
		return
	end

	local propertyID = "P1082" -- population
	local qualifierID = "P585" -- point in time

	local claims = entity.claims[propertyID]
	if not claims then
		return
	end

	for _, claim in ipairs(claims) do
		for _, qualifier in ipairs(claim.qualifiers[qualifierID] or {}) do
			local timeValue = qualifier.datavalue.value.time

			if timeValue:sub(2, 5) == year then
				return claim.mainsnak.datavalue.value["amount"]
			end
		end
	end

	return
end

return p
