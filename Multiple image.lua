-- иплементира [[Шаблон:Няколко картинки]]
local p = {}

local autoscaledimages
local nonautoscaledimages
local numberofimages = -1

local function isnotempty(s)
	return s and s:match( '^%s*(.-)%s*$' ) ~= ''
end

local function removepx(s)
	return tostring(s or ''):match('^(.*)[Pp][Xx]%s*$') or s
end

local function getdimensions(s, w, h)
	if tonumber(w) and tonumber(h) then
		nonautoscaledimages = true
		return tonumber(w), tonumber(h)
	end
	local file = s and mw.title.new('File:' .. mw.uri.decode(mw.ustring.gsub(s,'%|.*$',''), 'WIKI'))
	file = file and file.file or {width = 0, height = 0}
	w = tonumber(file.width) or 0
	h = tonumber(file.height) or 0
	autoscaledimages = true
	return w, h
end

local function renderImageCell(image, width, height, link, alt, thumbtime, caption, class, textalign, istyle, border, tcolor)
	local root = mw.html.create('')
	local altstr = ''
	local classstr = class and ('|class=' .. class) or ''
	local linkstr = link and ('|link=' .. link) or ''
	local widthstr = '|' .. tostring(width) .. 'px'
	local thumbtimestr = ''
	if isnotempty( alt ) then
		altstr = '|alt=' .. alt
	end
	if widthstr == '|-nanpx' then
		widthstr = ''
	end
	if isnotempty( thumbtime ) then
		thumbtimestr = '|thumbtime=' .. thumbtime
	end

	local imagediv = root:tag('div')
	imagediv:addClass((border ~= 'infobox') and 'thumbimage' or nil)
	imagediv:cssText(istyle)
	if height then
		imagediv:css('height', tostring(height) .. 'px')
		imagediv:css('overflow', 'hidden')
	end
	imagediv:wikitext('[[File:' .. image .. classstr .. widthstr .. linkstr .. altstr .. thumbtimestr .. ']]')
	if isnotempty(caption) then
		local captiondiv = root:tag('div')
		captiondiv:addClass((border ~= 'infobox') and 'thumbcaption' or nil)
		if isnotempty(textalign) then
			captiondiv:addClass('text-align-' .. textalign)
		end
		if tcolor ~= '' then
			captiondiv:css('color', tcolor)
		end
		captiondiv:wikitext(caption)
	end
	return tostring(root)
end

local function getWidth(w1, w2)
	local w
	if isnotempty(w1) then
		w = tonumber(w1)
	elseif isnotempty(w2) then
		w = tonumber(w2)
	end
	return w or 200
end

local function getPerRow(pstr, ic)
	-- split string into array using any non-digit as a dilimiter
	local pr = mw.text.split(pstr or '', '[^%d][^%d]*')
	-- if split failed, assume a single row
	if (#pr < 1) then
		pr = {tostring(ic)}
	end
	-- convert the array of strings to an array of numbers,
	-- adding any implied/missing numbers at the end of the array
	local r = 1
	local thisrow = tonumber(pr[1] or ic) or ic
	local prownum = {}
	while( ic > 0 ) do
		prownum[r] = thisrow
		ic = ic - thisrow
		r = r + 1
		-- use the previous if the next is missing and
		-- make sure we don't overstep the number of images
		thisrow = math.min(tonumber(pr[r] or thisrow) or ic, ic)
	end
	return prownum
end

local function renderMultipleImages(frame)
	local pargs = frame:getParent().args
	local args = frame.args
	local width = removepx(pargs['width'] or '')
	local dir = pargs['direction'] or ''
	local border = pargs['border'] or args['border'] or ''
	local align = pargs['align'] or args['align'] or (border == 'infobox' and 'center' or '')
	local capalign = pargs['caption_align'] or args['caption_align'] or ''
	local totalwidth = removepx(pargs['total_width'] or args['total_width'] or '')
	local imgstyle = pargs['image_style'] or args['image_style']
	local header = pargs['header'] or pargs['title'] or ''
	local footer = pargs['footer'] or ''
	local imagegap = tonumber(pargs['image_gap'] or '1') or 1
	local thumbclass = {
		["left"] = 'floatleft',
		["none"] = 'tnone',
		["center"] = 'tnone',
		["centre"] = 'tnone',
		["right"] = 'floatright'
		}

	-- find all the nonempty images
	local imagenumbers = {}
	local imagecount = 0
	for k, v in pairs( pargs ) do
		local i = tonumber(tostring(k):match( '^%s*image([%d]+)%s*$' ) or '0')
		if i > 0 and isnotempty(v) then
			table.insert( imagenumbers, i)
			imagecount = imagecount + 1
		end
	end
	-- save number of images for tracking category
	numberofimages = imagecount
	
	-- sort the imagenumbers
	table.sort(imagenumbers)

	-- create an array with the number of images per row
	local perrow = getPerRow(dir == 'vertical' and '1' or pargs['perrow'], imagecount)

	-- compute the number of rows
	local rowcount = #perrow

	-- store the image widths and compute row widths and maximum row width
	local heights = {}
	local widths = {}
	local widthmax = 0
	local widthsum = {}
	local k = 0
	for r=1,rowcount do
		widthsum[r] = 0
		for c=1,perrow[r] do
			k = k + 1
			if k <= imagecount then
				local i = imagenumbers[k]
				if isnotempty(totalwidth) then
					widths[k], heights[k] = getdimensions(pargs['image' .. i], pargs['width' .. i], pargs['height' .. i])
				else
					widths[k] = getWidth(width, pargs['width' .. i])
				end
				widthsum[r] = widthsum[r] + widths[k]
			end
		end
		widthmax = math.max(widthmax, widthsum[r])
	end

	-- make sure the gap is non-negative
	if imagegap < 0 then imagegap = 0 end

	-- if total_width has been specified, rescale the image widths
	if isnotempty(totalwidth) then
		totalwidth = tonumber(totalwidth)
		widthmax = 0
		k = 0
		for r=1,rowcount do
			local koffset = k
			local tw = totalwidth - (3 + imagegap) * (perrow[r] - 1) - 12
			local ar = {}
			local arsum = 0
			for j=1,perrow[r] do
				k = k + 1
				if k<= imagecount then
					local h = heights[k] or 0
					if (h > 0) then
						ar[j] = widths[k]/h
						heights[k] = h
					else
						ar[j] = widths[k]/100
					end
					arsum = arsum + ar[j]
				end
			end
			local ht = tw/arsum
			local ws = 0
			k = koffset
			for j=1,perrow[r] do
				k = k + 1
				if k<= imagecount then
					widths[k] = math.floor(ar[j]*ht + 0.5)
					ws = ws + widths[k]
					if heights[k] then
						heights[k] = math.floor(ht)
					end
				end
			end
			widthsum[r] = ws
			widthmax = math.max(widthmax, widthsum[r])
		end
	end

	-- start building the array of images, if there are images
	if imagecount > 0 then
		-- compute width of outer div
		local bodywidth = 0
		for r=1,rowcount do
			if widthmax == widthsum[r] then
				bodywidth = widthmax + (3 + imagegap) * (perrow[r] - 1) + 12
			end
		end
		-- The body has a min-width of 100, which needs to be taken into account on specific widths
		bodywidth = math.max( 100, bodywidth - 8);

		local tc = pargs['color'] or pargs['text_color'] or ''
		local bg = pargs['bg_color'] or pargs['background_color'] or pargs['background color'] or ''
		-- create the array of images
		local root = mw.html.create('div')
		root:addClass('thumb')
		root:addClass('tmulti')
		-- root:addClass('tmulti-sandbox')
		root:addClass(thumbclass[align] or 'floatright')

		if align == 'center' or align == 'centre' then
			root:addClass('center')
		end
		if tc ~= '' then
			root:css('color', tc)
		end

		local div = root:tag('div')
		div:addClass((border ~= 'infobox') and 'thumbinner multiimageinner' or 'multiimageinner')
		div:css('width', tostring(bodywidth) .. 'px')
			:css('max-width', tostring(bodywidth) .. 'px')
		if bg ~= '' then
			div:css('background-color', bg)
		end
		if tc ~= '' then
			div:css('color', tc)
		end
		if border == 'infobox' or border == 'none' then
			div:css('border', 'none')
		end
		-- add the header
		if isnotempty(header) then
			div:tag('div')
				:addClass('trow')
				:tag('div')
					:addClass('theader')
					:css('text-align', pargs['header_align'])
					:css('background-color', 
						(pargs['header_background'] ~= '') and pargs['header_background'] or nil)
					:wikitext(header)
		end
		-- loop through the images
		k = 0
		for r=1,rowcount do
			local rowdiv = div:tag('div'):addClass('trow');
			for j=1,perrow[r] do
				k = k + 1
				if k <= imagecount then
					local imagediv = rowdiv:tag('div')
					imagediv:addClass('tsingle')
					if bg ~= '' then
						imagediv:css('background-color', bg);
					end
					if imagegap > 1 and k < imagecount then
						if dir == 'vertical' then
							imagediv:css('margin-bottom', tostring(imagegap) .. 'px')	
						elseif j < perrow[r] then
							imagediv:css('margin-right', tostring(imagegap) .. 'px')
						end
					end
					local i = imagenumbers[k]
					local img = pargs['image' .. i]
					local w = widths[k]
					imagediv:css('width', tostring(2 + w) .. 'px')
						:css('max-width', tostring(2 + w) .. 'px')
					imagediv:wikitext(renderImageCell(img, w, heights[k],
						pargs['link' .. i], pargs['alt' .. i],
						pargs['thumbtime' .. i], pargs['caption' .. i], pargs['class' .. i], capalign, imgstyle, border, tc))
				end
			end
		end
		-- add the footer
		if isnotempty(footer) then
			local falign = string.lower(pargs['footer_align'] or args['footer_align'] or '')
			falign = (falign == 'centre') and 'center' or falign
			div:tag('div')
				:addClass('trow')
				:css('display', (falign ~= '') and 'flow-root' or 'flex')
				:tag('div')
					:addClass((border ~= 'infobox') and 'thumbcaption' or nil)
					:css('text-align', (falign ~= '') and falign or nil)
					:css('background-color', 
						(pargs['footer_background'] ~= '') and pargs['footer_background'] or nil)
                    :css('color', (tc ~= '') and tc or nil)
					:wikitext(footer)
		end
		return tostring(root)
	end
	return ''
end

function p.render( frame )
	autoscaledimages = false
	nonautoscaledimages = false
	numberofimages = 0

	local check = require('Module:Check for unknown parameters')._check
	local tracking = check({
		['unknown'] = frame:expandTemplate{
			title = 'main other',
			args = {'[[Категория:Страници, използващи Шаблон:Няколко картинки с неизвестни параметри|_VALUE_ ]]'}
		},
		['preview'] = 'Page using [[Template:Multiple image]] with unknown parameter "_VALUE_"',
		['ignoreblank'] = 'y',
		regexp1 = 'image%d+',
		regexp2 = 'width%d+',
		regexp3 = 'height%d+',
		regexp4 = 'class%d+',
		regexp5 = 'alt%d+',
		regexp6 = 'link%d+',
		regexp7 = 'thumbtime%d+',
		regexp8 = 'caption%d+',
		'align', 'direction', 'header_background', 
		'header_align', 'header', 'width', 'total_width', 
		'caption_align', 'footer_background', 'footer_align', 'footer', 
		'perrow', 'title', 'image_gap', 'border', 'image_style',
		'color', 'text_color',
		'bg_color', 'background_color', 'background color'
	}, frame:getParent().args)
	
	return frame:extensionTag {name = 'templatestyles', args = {src = 'Multiple image/styles.css', wrapper = ".tmulti"}}
		.. renderMultipleImages( frame )
		.. (autoscaledimages and '[[Категория:Страници, използващи Шаблон:Няколко картинки с автоматично оразмерени изображения]]' or '')
		.. (nonautoscaledimages and '[[Категория:Страници, използващи Шаблон:Няколко картинки с ръчно оразмерени изображения]]' or '')
		.. ( (numberofimages == 0) and '[[Категория:Страници, използващи Шаблон:Няколко картинки без никакви изображения]]' or '')
		-- .. ( (numberofimages == 1) and '[[Категория:Страници, използващи Шаблон:Няколко картинки с едно изображение]]' or '' )
		.. tracking
end

p[''] = function( frame ) return p.render( frame:newChild{title = frame:getTitle()} ) end

return p
