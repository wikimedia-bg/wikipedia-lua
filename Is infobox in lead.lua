local p = {}

function p.main (frame)
	return p._main (frame.args[1])
end

function p._main (searchString)
	local content = mw.title.getCurrentTitle():getContent()
	local offset = string.find(content, "==", 1 , true)
	if offset then
		-- lead - Всичко преди първото заглавие в статията
		local lead = string.sub(content, 1, offset-1)
		if (mw.ustring.find(lead, searchString)) then
			--
			local iter2 = mw.ustring.gmatch(content, searchString)
			iter2()
			if not iter2() then --if able to find two of the specific infobox in the article, then don't return true
				return true
			end
			
		end
	end
end

return p
