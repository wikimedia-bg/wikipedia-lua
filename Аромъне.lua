local p = {}

local link_prefix = 'http://macedonia.kroraina.com/gva/gva_'
local link_suffix = '.htm'

local ranges = {
	[2] = false,
	[5] = 'pred',
	[6] = false,
	[39] = '1',
	[120] = '2',
	[170] = '3',
	[187] = '4',
	[213] = '5',
	[243] = '6',
	[257] = 'pr1',
	[297] = 'pr2',
	[305] = 'pr3',
}

local function sorted_range_keys()
	local range_keys = {}
	for k in pairs(ranges) do
		table.insert(range_keys, k)
	end
	table.sort(range_keys)
	return range_keys
end
	
local function match_range(page_num)
	for _, k in ipairs(sorted_range_keys()) do
		if page_num <= k then
			return ranges[k]
		end
	end
	return false
end

function p.get_link(frame)
	local page_ref = frame.args[1]
	local page_num = tonumber((page_ref:gsub('^(%d+)%D.*', '%1')))
	if not page_num then return '' end
	local web_page = match_range(page_num)
	if not web_page then return '' end
	return link_prefix .. web_page .. link_suffix
end

return p
