local p = {}

function p.test(frame)
	return mw.language.new('en'):formatDate('Y', '1768-01-01T00:00:00Z')
end

return p