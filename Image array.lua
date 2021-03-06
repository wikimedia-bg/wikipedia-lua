-- implements [[template:image array]]

local p = {}

local function isnotempty(s)
	return s and s:match( '^%s*(.-)%s*$' ) ~= ''
end

local function renderArrayCell( img, c, a, b, l, tc, t, w, h)
	local alt = isnotempty(a) and ('|alt=' .. a) or ''
	local link = isnotempty(l) and ('|link=' .. l) or ''
	local text = (isnotempty(tc) and not isnotempty(t)) 
		and mw.text.unstrip(c) or mw.text.unstrip(t or '')
	local border = isnotempty(b) and '|border' or ''
		
	local cell = mw.html.create('')
	if( img ) then
		cell:tag('div')
			:css('display', 'table-cell')
			:css('vertical-align', 'middle')
			:css('width', w .. 'px')
			:css('height', h .. 'px')
			:css('margin-left', 'auto')
			:css('margin-right', 'auto')
			:wikitext(mw.ustring.format('[[Файл:%s|%dx%dpx%s|%s]]', 
				img, w, h, alt .. link .. border, text))
		cell:tag('div')
			:css('padding', '1px')
			:wikitext(c)
	end
	
	return tostring(cell)
end

local function imagearray( frame )
	local args = frame:getParent().args
	local width = tonumber(args['width'] or '60')
	local height = tonumber(args['height'] or '70')
	local perrow = tonumber(args['perrow'] or '4')
	local bw = tonumber(args['border-width'] or '0')
	local fs = args['font-size'] or '88%'
	local text = args['text'] or ''
	local margin = args['margin'] or 'auto'
	local border = ( bw > 0 ) and tostring(bw) .. 'px #aaa solid' or nil

	-- find all the nonempty image numbers
	local imagenums = {}
	local imagecount = 0
	for k, v in pairs( args ) do
		local i = tonumber(tostring(k):match( '^%s*image([%d]+)%s*$' ) or '0')
		if( i > 0 and isnotempty(v) ) then
			table.insert( imagenums, i )
			imagecount = imagecount + 1
		end
	end
	-- sort the image numbers
	table.sort(imagenums)
	
	-- compute the number of rows
	local rowcount = math.ceil(imagecount / perrow)
	
	if rowcount < 1 then
		return '[[Category:Pages using image array with no images]]'
	end	

	-- start table
	root = mw.html.create('table')
	root
		:addClass(args['class'])
		:css('border-collapse','collapse')
		:css('text-align','center')
		:css('font-size', fs)
		:css('line-height','1.25em')
		:css('margin',margin)
		:css('width', tostring(width*perrow) .. 'px')

	-- loop over the images
	for j = 1, rowcount do
		local row = root:tag('tr')
		row:css('vertical-align', 'top')
		for k = 1, perrow do
			i = imagenums[(j-1)*perrow + k] or 0
			row:tag('td')
				:css('width', width .. 'px')
				:css('text-align', 'center')
				:css(border and 'border' or '', border or '')
				:wikitext(renderArrayCell( 
					args['image' .. i], args['caption' .. i], args['alt' .. i], 
					args['border' .. i], args['link' .. i] , 
					args['text'], args['text' .. i] , width, height)
				)
		end
	end
    
	-- end table
    return tostring(root)
end
function p.array( frame )
    return imagearray( frame )
end
 
return p