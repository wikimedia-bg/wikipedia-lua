local p = {}

local function norm_seq(str)
	return mw.ustring.gsub(str, '(%D+)', function(substr) return mw.ustring.gsub(substr, '^%s*[,;]+%s*$', ', ') end)
end

local function norm_range(str)
	return mw.ustring.gsub(str, '(%d+)%s*[-–—]+%s*(%d+)', '%1 – %2')
end

function p.normalize(frame)
	local pp_ref_str = frame.args[1]
	pp_ref_str = norm_seq(pp_ref_str)
	pp_ref_str = norm_range(pp_ref_str)
	return pp_ref_str
end

return p
