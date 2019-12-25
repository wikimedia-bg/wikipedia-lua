local p = {}

-- Credit to http://stackoverflow.com/a/1283608/2644759
-- cc-by-sa 3.0
local function tableMerge(t1, t2, overwrite)
	for k,v in pairs(t2) do
		if type(v) == "table" and type(t1[k]) == "table" then
			-- since type(t1[k]) == type(v) == "table", so t1[k] and v is true
			tableMerge(t1[k], v, overwrite) -- t2[k] == v
		else
			if overwrite or t1[k] == nil then t1[k] = v end
		end
	end
	return t1
end

function p.loadI18n(name, i18n_arg)
	local exist, res = pcall(require, name)
	if exist and next(res) ~= nil then
		if i18n_arg then
			tableMerge(i18n_arg, res.i18n, true)
		elseif type(i18n) == "table" then
			-- merge to global i18n
			tableMerge(i18n, res.i18n, true)
		end
	end
end

function p.loadI18nFrame(frame, i18n_arg)
	p.loadI18n(frame:getTitle().."/i18n", i18n_arg)
end

return p
