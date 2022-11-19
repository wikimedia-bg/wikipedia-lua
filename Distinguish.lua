local mHatnote = require('Module:Hatnote')
local mHatlist = require('Module:Hatnote list')
local mArguments --initialize lazily
local mTableTools --initialize lazily
local libraryUtil = require('libraryUtil')
local checkType = libraryUtil.checkType
local p = {}

function p.distinguish(frame)
	mArguments = require('Module:Arguments')
	mTableTools = require('Module:TableTools')
	local args = mArguments.getArgs(frame)
	local selfref = args.selfref
	local text = args.text
	args = mTableTools.compressSparseArray(args)
	return p._distinguish(args, text, selfref)
end

function p._distinguish(args, text, selfref)
	checkType("_distinguish", 1, args, 'table')
	if #args == 0 and not text then return '' end
	local text = string.format(
		'Not to be confused with %s.',
		text or mHatlist.orList(args, true)
	)
	hnOptions = {selfref = selfref}
	return mHatnote._hatnote(text, hnOptions)
end

return p
