local p = {}

function p.usesProperty(frame)
	local parent = frame.getParent(frame)
	local result = ''
	local ii = 1
	while true do
		local p_num = parent.args[ii] or ''
		if p_num ~= '' then
			local label = mw.wikibase.label(p_num) or "Няма етикет"
			result = result .. "<li><b><i>[[d:Property:" .. p_num .. "|" .. label .. " <small>(" .. string.upper(p_num) .. ")</small>]]</i></b><br />(виж [[d:Special:WhatLinksHere/Property:" .. p_num .. "|къде се ползва]])</li>"
			ii = ii + 1
		else break
		end
	end
	return result
end
 
return p