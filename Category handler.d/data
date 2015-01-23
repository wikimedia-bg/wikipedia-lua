-- This module assembles data to be passed to [[Module:Category handler]] using
-- mw.loadData. This includes the configuration data and whether the current
-- page matches the title blacklist.

local data = require('Module:Category handler/config')
local mShared = require('Module:Category handler/shared')
local blacklist = require('Module:Category handler/blacklist')
local title = mw.title.getCurrentTitle()

data.currentTitleMatchesBlacklist = mShared.matchesBlacklist(
	title.prefixedText,
	blacklist
)

data.currentTitleNamespaceParameters = mShared.getNamespaceParameters(
	title,
	mShared.getParamMappings()
)

return data