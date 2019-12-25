local p = {}

local _fetch = require('Module:Transclusion_count').fetch

function p.num(frame, count)
	if count == nil then count = _fetch(frame) end
	
	-- Build output string
	local return_value = ""
	if count == nil then
		if frame.args[1] == "risk" then
			return_value = "a very large number of"
		else
			return_value = "many"
		end
	else
		-- Use 2 sigfigs for smaller numbers and 3 for larger ones
		local sigfig = 2
		if count >= 100000 then
			sigfig = 3
		end
		
		-- Prepare to round to appropriate number of sigfigs
		local f = math.floor(math.log10(count)) - sigfig + 1
		
		-- Round and insert "apprxomimately" or "+" when appropriate
		if (frame.args[2] == "yes") or (mw.ustring.sub(frame.args[1],-1) == "+") then
			-- Round down
			return_value = string.format("%s+", mw.getContentLanguage():formatNum(math.floor( (count / 10^(f)) ) * (10^(f))) )
		else
			-- Round to nearest
			return_value = string.format("approximately&#x20;%s", mw.getContentLanguage():formatNum(math.floor( (count / 10^(f)) + 0.5) * (10^(f))) )
		end
		
		-- Insert percent of pages
		if frame.args["all-pages"] and frame.args["all-pages"] ~= "" then
			local percent = math.floor( ( (count/frame:callParserFunction('NUMBEROFPAGES', 'R') ) * 100) + 0.5)
			return_value = string.format("%s&#x20;pages, which is ≈%s%% of all", return_value, percent)
		end	
	end
	
	return return_value
end

function p.risk(frame)
	local return_value = ""
	if frame.args[1] == "risk" then
		return_value = "risk"
	else
		local count = _fetch(frame)
		if count and count >= 100000 then return_value = "risk" end
	end
	return return_value
end

function p.text(frame, count)
	if count == nil then count = _fetch(frame) end
	local return_value = {}
	
	local title = mw.title.getCurrentTitle()
	if title.subpageText == "doc" or title.subpageText == "sandbox" then
		title = title.basePageTitle
	end
	
	local templatecount = string.format("https://tools.wmflabs.org/templatecount/index.php?lang=en&namespace=%s&name=%s",mw.title.getCurrentTitle().namespace,mw.uri.encode(title.text))
	
	local used_on_text = string.format("'''This %s is used on [%s %s pages]'''",
			(mw.title.getCurrentTitle().namespace == 828 and "Lua module" or "template"),
			templatecount,
			p.num(frame, count)
	)
	
	local sandbox_text =  string.format("%s's [[%s/sandbox|/sandbox]] or [[%s/testcases|/testcases]] subpages%s ",
			(mw.title.getCurrentTitle().namespace == 828 and "module" or "template"),
			title.fullText, title.fullText,
			(mw.title.getCurrentTitle().namespace == 828 and "." or ", or in your own [[Wikipedia:Subpages#How to create user subpages|user subpage]].")
	)
	
	if (frame.args[1] == "risk" or (count and count >= 100000) ) then
		local info = "" 
		if frame.args["info"] and frame.args["info"] ~= "" then
			info = "<br />" .. frame.args["info"]
		end
		sandbox_text = string.format(".%s<br /> To avoid large-scale disruption and unnecessary server load, any changes to it should first be tested in the %sThe tested changes can then be added to this page in a single edit.&#x20;",
				info, sandbox_text
		)
	else
		sandbox_text = string.format(", so changes to it will be widely noticed. Please test any changes in the %s",
				sandbox_text
		)
	end
	
	local discussion_text = "Please consider discussing changes "
	if frame.args["2"] and frame.args["2"] ~= "" and frame.args["2"] ~= "yes" then
		discussion_text = string.format("%sat [[%s]]", discussion_text, frame.args["2"])
	else
		discussion_text = string.format("%son the [[%s|talk page]]", discussion_text, title.talkPageTitle.fullText )
	end
	
	return table.concat({used_on_text, sandbox_text, discussion_text, " before implementing them."})
end

function p.main(frame)
	local count = _fetch(frame)
	local return_value = ""
	local image = "[[File:Ambox warning yellow.svg|40px|alt=Warning|link=]]"
	local type_param = "style"
	if (frame.args[1] == "risk" or (count and count >= 100000) ) then
		image = "[[File:Ambox warning orange.svg|40px|alt=Warning|link=]]"
		type_param = "content"
	end
	
	if frame.args["form"] == "editnotice" then
		return_value = frame:expandTemplate{
				title = 'editnotice',
				args = {
						["image"] = image,
						["text"] = p.text(frame, count),
						["expiry"] = (frame.args["expiry"] or "")
				}
		}
	else
		return_value = frame:expandTemplate{
				title = 'ombox',
				args = {
						["type"] = type_param,
						["image"] = image,
						["text"] = p.text(frame, count),
						["expiry"] = (frame.args["expiry"] or "")
				}
		}
	end
	
	return return_value
end

return p
