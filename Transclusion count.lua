local p = {}

function p.fetch(frame)
	local template = nil
	local return_value = nil

	-- Use demo parameter if it exists, otherswise use current template name
	if frame.args["demo"] and frame.args["demo"] ~= "" then
		template = frame.args["demo"]
	elseif mw.title.getCurrentTitle().namespace == 10 then -- Template namespace only
		template = mw.title.getCurrentTitle().text
	end

	-- If in template namespace, look up count in /data
	if template ~= nil and mw.title.new(template, "Template").namespace == 10 then
		template =  mw.ustring.gsub(template, "/doc$", "") -- strip /doc from end
		local index = mw.ustring.upper(mw.ustring.sub(template,1,1))
		local data = mw.loadData('Module:Transclusion_count/data/' .. (mw.ustring.find(index, "%a") and index or "other"))
		return_value = tonumber(data[mw.ustring.gsub(template, " ", "_")])
	end
	
	-- If database value doesn't exist, use value passed to template
	if return_value == nil and frame.args[1] ~= nil then
		local arg1=mw.ustring.match(frame.args[1], '[%d,]+')
		return_value = tonumber(frame:callParserFunction('formatnum', arg1, 'R'))
	end
	
	return return_value	
end

return p
