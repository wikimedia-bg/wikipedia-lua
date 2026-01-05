require('strict')
return setmetatable({}, {
	__index = function(t, k)
		local what = mw.ustring[k]
		if type(what) ~= "function" then
			return what
		end
		return function(frame)
			local args = frame.args
			for _, v in ipairs(args) do
				args[_] = tonumber(v) or v:gsub("^\\", "", 1)
			end
			if not args.tag then
				return (what(unpack(args)))
			end
			local tagargs = {}
			for x, y in pairs(args) do
				if type(x) ~= 'number' and x ~= 'tag' then tagargs[x] = y end
			end
			return frame:extensionTag{name = args.tag, content = what(unpack(args)), args = tagargs}
		end
	end
})
