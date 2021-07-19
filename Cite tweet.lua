local p = {}
local TwitterSnowflake = require('Module:TwitterSnowflake')
local CiteWeb = require('Module:Cite web')['']

local function _if(arg)
	return arg and arg ~= '' or nil
end

p.main = function(frame)
	frame.args = frame:getParent().args
	return p[''](frame)
end

p[''] = function(frame)
	local args = frame.args
	local cite_args = {
		url 		= 'https://twitter.com/' .. ((args.user and args.number) and (args.user .. '/status/' .. args.number) or ''),
		title		= (args.title or ''):gsub('https*://', ''),
		['script-title'] = args['script-title'],
		['trans-title'] = args['trans-title'],
		language	= args.language,
		['author-link'] = args['author-link'] or args.authorlink,
		others		= _if(args.retweet) and ('Retweeted by ' .. args.retweet),
		via 		= args.link == 'no' and 'Twitter' or '[[Twitter]]',
		type		= 'Tweet',
		location	= args.location,
		['access-date'] = args['access-date'] or args.accessdate,
		['archive-date'] = args['archive-date'] or args.archivedate,
		['archive-url'] = args['archive-url'] or args.archiveurl,
		['url-status'] = args['url-status'] or args['dead-url'] or args.deadurl,
		ref			= args.ref,
		df			= args.df
	}
	if _if(args.last1 or args.last) then
		cite_args.author = (args.last1 or args.last) ..
			(_if(args.first1 or args.first) and (', ' .. (args.first1 or args.first)) or '') ..
			' [@' .. (args.user or '') .. ']'
	elseif _if(args.author1 or args.author) then
		cite_args.author = (args.author1 or args.author) .. ' [@' .. (args.user or '') .. ']'
	elseif _if(args['author-link']) then
		cite_args.author = args['author-link'] .. ' [@' .. (args.user or '') .. ']'
	else
		cite_args.author = '@' .. (args.user or '')
	end
	cite_args.date = args.date or (_if(args.number) and TwitterSnowflake.snowflakeToDate{ args = {id_str = args.number} })
	
	frame.args = cite_args
	local output = CiteWeb(frame)
	frame.args = args
	
	-- Error checking
	local error_template = '<span class="cs1-visible-error error citation-comment">%s</span>'
	local errors = {}
	if not (_if(args.title) or _if(args['script-title']) or args.user or args.number or args.date) then
		-- No title; error message is provided by CS1 module.
		errors[1] = ';'
	end
	if not _if(args.user) then
		errors[1 + #errors] = ' Missing or empty <kbd>&#124;user=</kbd>;'
	end
	if not _if(args.number) then
		errors[1 + #errors] = ' Missing or empty <kbd>&#124;number=</kbd>;'
	end
	errors[1 + #errors] = TwitterSnowflake.datecheck{ args = {
		id_str	= args.number or '',
		date	= args.date or '',
		error1	= ' <kbd>&#124;date=</kbd> mismatches calculated date from <kbd>&#124;number=</kbd> by two or more days;',
		error2  = ' Missing or empty <kbd>&#124;date=</kbd>, and posted before November 4, 2010;',
		error3	= ' Invalid <kbd>&#124;number=</kbd> parameter;'
	}}
	if errors[1] then
		local last = errors[#errors]
		errors[#errors] = last:sub(1, #last - 1) .. ' ([[Template:Cite_tweet#Error_detection|help]])'
		local error_out = error_template:rep(#errors):format(unpack(errors)) 
		if mw.title.getCurrentTitle():inNamespace(0) then
			error_out = error_out .. '[[Category:Cite tweet templates with errors]]'
		end
		output = output .. error_out
	end
	return output
end

return p
