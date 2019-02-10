-- This module implements {{str endswith}}.

local TRUE_STRING = 'yes'
local FALSE_STRING = ''

local p = {}

local function trim(s)
	return s:match('^%s*(.-)%s*$')
end

function p.main(frame)
	local args = frame:getParent().args
	local s = args[1]
	local pattern = args[2]
	if not s or not pattern then
		-- TRUE_STRING is not the natural choice here, but is needed for
		-- backwards compatibility.
		return TRUE_STRING
	end
	s = trim(s)
	pattern = trim(pattern)
	if pattern == '' then
		-- All strings end with the empty string.
		return TRUE_STRING
	end
	if mw.ustring.sub(s, 0 - mw.ustring.len(pattern), -1) == pattern then
		return TRUE_STRING
	else
		return FALSE_STRING
	end
end

return p
