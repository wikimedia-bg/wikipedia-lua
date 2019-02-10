local p = {}
local Userbox = require('Module:Userbox')
local getArgs = require('Module:Arguments').getArgs

local function urlencode(text)
	-- Return equivalent of {{urlencode:text}}.
	local function byte(char)
		return string.format('%%%02X', string.byte(char))
	end
	return text:gsub('[^ %w%-._]', byte):gsub(' ', '+')
end

local function formatNumber(number)
	number = number:gsub(',', '') 
	return  mw.getContentLanguage():formatNum( tonumber(number) )
end
	

function p.contrib(frame, args)
	if not args then
		args = getArgs(frame)
	end
	-- in the current template there is an {{#iferror: {{#expr: {{{1}}} }}. So I need to do a check to make sure the argument supplied is actually a number.
	local id_fc, id_c, info_fc, info_c
	local formated_count 
	local count = args[1] or '1'
	
	if count:match('^[%d,]*$') then
		count = count:gsub(',', '') 
		count = tonumber(count)
		formated_count = mw.getContentLanguage():formatNum( count )
    	-- 0-9,999 is shades of green
		if	   count < 1000  then id_fc = '#000000'; id_c = '#dddddd'; info_fc = '#000000'; info_c = '#eeeeee'
		elseif count < 2000  then id_fc = '#FFFFFF'; id_c = '#347235'; info_fc = '#000000'; info_c = '#728C00'	
		elseif count < 3000  then id_fc = '#FFFFFF'; id_c = '#6AA121'; info_fc = '#000000'; info_c = '#52D017'	
		elseif count < 4000  then id_fc = '#FFFFFF'; id_c = '#41A317'; info_fc = '#000000'; info_c = '#B2C248'	
		elseif count < 5000  then id_fc = '#FFFFFF'; id_c = '#4CC417'; info_fc = '#000000'; info_c = '#59E817'
		elseif count < 7500  then id_fc = '#FFFFFF'; id_c = '#54C571'; info_fc = '#000000'; info_c = '#239B56'
		elseif count < 10000 then id_fc = '#FFFFFF'; id_c = '#7FE817'; info_fc = '#000000'; info_c = '#387C44'
		
		-- 10,000-24,999 is shades of blue
		elseif count < 12500 then id_fc = '#000000'; id_c = '#33FFFF'; info_fc = '#000000'; info_c = '#99FFFF'
		elseif count < 15000 then id_fc = '#FFFFFF'; id_c = '#000080'; info_fc = '#000000'; info_c = '#157DEC'
		elseif count < 17500 then id_fc = '#FFFFFF'; id_c = '#15317E'; info_fc = '#000000'; info_c = '#1589FF'
		elseif count < 20000 then id_fc = '#FFFFFF'; id_c = '#0020C2'; info_fc = '#000000'; info_c = '#5CB3FF'
		elseif count < 25000 then id_fc = '#FFFFFF'; id_c = '#1569C7'; info_fc = '#000000'; info_c = '#C2DFFF'
			
		-- 25,000-49,999 is shades of red
		elseif count < 30000 then id_fc = '#000000'; id_c = '#FF0000'; info_fc = '#FFFFFF'; info_c = '#8C001A'
		elseif count < 35000 then id_fc = '#FFFFFF'; id_c = '#DC381F'; info_fc = '#FFFFFF'; info_c = '#800517'
		elseif count < 40000 then id_fc = '#FFFFFF'; id_c = '#F62817'; info_fc = '#000000'; info_c = '#C11B17'
		elseif count < 45000 then id_fc = '#000000'; id_c = '#C11B17'; info_fc = '#000000'; info_c = '#C04000'
		elseif count < 50000 then id_fc = '#FFFFFF'; id_c = '#8C001A'; info_fc = '#FFFFFF'; info_c = '#FF2400'
		-- 50,000-74,999 is shades of purple
		elseif count < 55000 then id_fc = '#FFFFFF'; id_c = '#4A235A'; info_fc = '#FFFFFF'; info_c = '#B048B5'
		elseif count < 60000 then id_fc = '#FFFFFF'; id_c = '#6C3483'; info_fc = '#000000'; info_c = '#7F38EC'
		elseif count < 65000 then id_fc = '#FFFFFF'; id_c = '#8E44AD'; info_fc = '#000000'; info_c = '#BB8FCE'
		elseif count < 70000 then id_fc = '#000000'; id_c = '#BB8FCE'; info_fc = '#000000'; info_c = '#E8DAEF'
		elseif count < 75000 then id_fc = '#000000'; id_c = '#E8DAEF'; info_fc = '#000000'; info_c = '#E0B0FF'
		
		-- 50,000-74,999 is shades of orange	
		elseif count < 80000  then id_fc = '#000000'; id_c = '#E66C2C'; info_fc = '#000000'; info_c = '#F87431'
		elseif count < 85000  then id_fc = '#000000'; id_c = '#FF8040'; info_fc = '#000000'; info_c = '#F70D1A'
		elseif count < 90000  then id_fc = '#000000'; id_c = '#F9966B'; info_fc = '#000000'; info_c = '#FFA62F'
		elseif count < 95000  then id_fc = '#000000'; id_c = '#F75D59'; info_fc = '#000000'; info_c = '#E78A61'
		elseif count < 100000 then id_fc = '#000000'; id_c = '#E55B3C'; info_fc = '#000000'; info_c = '#E67451'
		
		-- 100,000-124,999 is shades of yellow
		elseif count < 105000 then id_fc = '#FFD700'; id_c = '#000000'; info_fc = '#EDDA74'; info_c = '#000000'
		elseif count < 110000 then id_fc = '#000000'; id_c = '#FFF380'; info_fc = '#000000'; info_c = '#FFDB58'
		elseif count < 115000 then id_fc = '#000000'; id_c = '#FFFFC2'; info_fc = '#000000'; info_c = '#FDD017'
		elseif count < 120000 then id_fc = '#000000'; id_c = '#FFF8DC'; info_fc = '#000000'; info_c = '#EAC117'
		elseif count < 125000 then id_fc = '#000000'; id_c = '#FFFF00'; info_fc = '#000000'; info_c = '#EDE275'
		
		-- 125,000-149,999 is blue and red combos
		elseif count < 130000 then id_fc = '#000000'; id_c = '#F62817'; info_fc = '#FFFFFF'; info_c = '#571B7E'
		elseif count < 135000 then id_fc = '#FFFFFF'; id_c = '#15317E'; info_fc = '#000000'; info_c = '#DC381F'
		elseif count < 140000 then id_fc = '#FFFFFF'; id_c = '#0020C2'; info_fc = '#000000'; info_c = '#E42217'
		elseif count < 145000 then id_fc = '#FFFFFF'; id_c = '#571B7E'; info_fc = '#000000'; info_c = '#DC381F'
		elseif count < 150000 then id_fc = '#000000'; id_c = '#C11B17'; info_fc = '#000000'; info_c = '#43C6DB'
		
		-- 150,000-174,999 is green and orange combos
		elseif count < 155000 then id_fc = '#000000'; id_c = '#59E817'; info_fc = '#000000'; info_c = '#E9AB17'
		elseif count < 160000 then id_fc = '#000000'; id_c = '#E8A317'; info_fc = '#000000'; info_c = '#64E986'
		elseif count < 165000 then id_fc = '#000000'; id_c = '#5FFB17'; info_fc = '#000000'; info_c = '#D4A017'
		elseif count < 170000 then id_fc = '#000000'; id_c = '#D4A017'; info_fc = '#000000'; info_c = '#8AFB17'
		elseif count < 175000 then id_fc = '#000000'; id_c = '#98FF98'; info_fc = '#000000'; info_c = '#FFA62F'
		
		-- 150,000-174,999 is yellow and purple combos
		elseif count < 180000 then id_fc = '#000000'; id_c = '#FFFF00'; info_fc = '#FFFFFF'; info_c = '#4B0082'
		elseif count < 185000 then id_fc = '#000000'; id_c = '#8E35EF'; info_fc = '#000000'; info_c = '#C38EC7'
		elseif count < 190000 then id_fc = '#000000'; id_c = '#FBB917'; info_fc = '#000000'; info_c = '#C45AEC'
		elseif count < 195000 then id_fc = '#000000'; id_c = '#E238EC'; info_fc = '#000000'; info_c = '#FFA62F'
		elseif count < 200000 then id_fc = '#000000'; id_c = '#E8A317'; info_fc = '#000000'; info_c = '#C38EC7'
		
		-- 200,000+ is gold on black
		else                       id_fc = '#FDD017'; id_c = '#000000'; info_fc = '#FDD017'; info_c = '#000000'
		end
	else
		-- If you don't provide an actual number, then you don't get the color formatting. 
		 id_fc = '#000000'; id_c = '#dddddd'; info_fc = '#000000'; info_c = '#eeeeee'
		 formated_count = count
	end
	
	local user_args = {}
	
	local language = ''
	if args['lang'] then language = 'the '.. args['lang'] ..' ' end
	local project = args['project'] or 'Wikipedia'
	local project_site = args['projsite'] or 'en.wikipedia.org'
	local user = 'user'
	local username = args[2] or mw.title.getCurrentTitle().baseText
	local url = 'https://xtools.wmflabs.org/ec/'.. project_site .. '/' ..urlencode(username)
	
	local deleted, articles, automated, distinct, unique, images, insane = '','','', '', '', '', ''
	if args['deleted'] then deleted 	= ', over <b>' ..formatNumber(args['deleted'])..'</b> of which were to pages that are now deleted' end
	if args['articles'] then articles	= ', over <b>' ..formatNumber(args['articles'])..'</b> of which were to articles' end
	if args['automated'] then automated = ', over <b>' ..formatNumber(args['automated'])..'</b> of which were automated' end
	if args['distinct'] then distinct	= ', on over <b>' ..formatNumber(args['distinct'])..'</b> distinct pages' end
	if args['unique'] then unique		= ', on over <b>' ..formatNumber(args['unique'])..'</b> unique pages' end
	if args['images'] then images		= ', including over <b>' ..formatNumber(args['images'])..'</b> uploaded images' end
	if args['insane'] then insane		= ' and, as a result, may be slightly insane' end
	if args['bot']    then user         = 'bot' end
	
	user_args['id-s']      = 12
	user_args['info-c']	   = args['info-bg'] or info_c
	user_args['id-c']      = args['id-bg'] or id_c
	user_args['info-fc']   = args['info-font'] or info_fc
	user_args['id-fc']	   = args['id-font'] or id_fc
	user_args['border-c'] = args['border']
	user_args['id'] = formated_count .. '+'
	
	if args['log'] == 'yes' then
		url = 'https://en.wikipedia.org/w/index.php?title=Special:Log&user='..urlencode(username)
		user_args['info'] = '<span class="plainlinks neverexpand">This user has logged ['..url..' more than '.. '<b>'..formated_count..'</b>'..
		' moves or other log actions] on '.. language.. project
		.. automated
		.. deleted
		.. articles
		.. distinct
		.. unique
		.. images
		.. insane
		.. '.</span>'
	else
		user_args['info'] = '<span class="plainlinks neverexpand">This '
	    .. user .. ' has made ['
		..url
		..' <span style="color: '..user_args['info-fc']
		..'"> more than ' 
		.. '<b>'..formated_count..'</b>'
		.. ' contributions</span>] to '.. language.. project
		.. automated
		.. deleted
		.. articles
		.. distinct
		.. unique
		.. images
		.. insane
		.. '.</span>'
	end
	
	return Userbox.main('_userbox', user_args)
end

return p
