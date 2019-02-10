local p = {}

-- Returns the expiry of a restriction of an action on a given title, or unknown if it cannot be known.
-- If no title is specified, the title of the page being displayed is used.
function p._main(action, pagename)
	local title
	if type(pagename) == 'table' and pagename.prefixedText then
		title = pagename
	elseif pagename then
		title = mw.title.new(pagename)
	else
		title = mw.title.getCurrentTitle()
	end
	pagename = title.prefixedText
	if action == 'autoreview' then
		local stabilitySettings = mw.ext.FlaggedRevs.getStabilitySettings(title)
		return stabilitySettings and stabilitySettings.expiry or 'unknown'
	elseif action ~= 'edit' and action ~= 'move' and action ~= 'create' and action ~= 'upload' then
		error( 'First parameter must be one of edit, move, create, upload, autoreview', 2 )
	end
	local rawExpiry = mw.getCurrentFrame():callParserFunction('PROTECTIONEXPIRY', action, pagename)
	if rawExpiry == 'infinity' then
		return 'infinity'
	elseif rawExpiry == '' then
		return 'unknown'
	else
		local year, month, day, hour, minute, second = rawExpiry:match(
			'^(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)$'
		)
		if year then
			return string.format(
				'%s-%s-%sT%s:%s:%s',
				year, month, day, hour, minute, second
			)
		else
			error('internal error in Module:Effective protection expiry; malformed expiry timestamp')
		end
	end
end

setmetatable(p, { __index = function(t, k)
	return function(frame)
		return t._main(k, frame.args[1])
	end
end })

return p
