local p = {}
local CS1 = require('Module:Citation/CS1')

p[''] = function(frame)
	local newFrame = {
	    getParent = function(self)
	    	return frame
	    end,
	    getTitle = function(self)
	    	return 'Template:Cite news'
	    end,
	    args = {CitationClass='news'}
	}
	setmetatable(newFrame, {
		__index = function(t, k)
			if type(frame[k]) == 'function' then
				return function(...)
					return frame[k](frame, select(2, ...))
				end
			else
				return frame[k]
			end
		end
	})
	return CS1.citation(newFrame)
end

return p
