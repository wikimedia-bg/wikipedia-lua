local p = {}

local function comment_empty( row, col, colchar )
	if ((row + col) % 2 == 1) then
		return 'бяло поле ' .. colchar[col] .. row
	else
		return 'черно поле ' .. colchar[col] .. row
	end
end

local function image_square( img_empty, pc, row, col, size )
	local colornames = { l = 'бял', d = 'черен' }
	local piecenames = { 
		p = 'пешка',
		r = 'топ',
		n = 'кон',
		b = 'офицер',
		q = 'дама',
		k = 'цар',
		a = 'кардинал',
		c = 'канцлер',
		z = 'шампион',
		w = 'магьосник',
		t = 'шут',
		M = 'мъж',
		h = 'обърната пешка',
		m = 'обърнат топ',
		B = 'обърнат офицер',
		N = 'обърнат кон',
		f = 'обърнат цар',
		g = 'обърната дама',
		e = 'слон',
		s = 'лодка',
		G = 'жираф',
		U = 'еднорог',
		Z = 'зебра'
	}
	local fullpiecenames = {
		pl = 'бяла пешка',
		pd = 'черна пешка',
		ql = 'бяла дама',
		qd = 'черна дама',
		hl = 'бяла обърната пешка',
		hd = 'черна обърната пешка',
		gl = 'бяла обърната дама',
		gd = 'черна обърната дама',
		sl = 'бяла лодка',
		sd = 'черна лодка',
		Zl = 'бяла зебра',
		Zd = 'черна зебра'
	}
	local symnames = {
		xx = 'черен кръст',
		ox = 'бял кръст',
		xo = 'черен кръг',
		oo = 'бял кръг',
		ul = 'горно лява стрелка',
		ua = 'горна стрелка',
		ur = 'горно дясна стрелка',
		la = 'лява стрелка',
		ra = 'дясна стрелка',
		dl = 'долно лява стрелка',
		da = 'долна стрелка',
		dr = 'долно дясна стрелка',
		lr = 'двупосочна стрелка ляво-дясно',
		ud = 'двупосочна стрелка горе-долу',
		db = 'двупосочна стрелка горно дясно и долно ляво',
		dw = 'двупосочна стрелка горно ляво и долно дясно',
		x0 = 'нула',
		x1 = 'едно',
		x2 = 'две',
		x3 = 'три',
		x4 = 'четири',
		x5 = 'пет',
		x6 = 'шест',
		x7 = 'седем',
		x8 = 'осем',
		x9 = 'девет'
	}
	local colchar = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	local color = mw.ustring.gsub( pc, '^.*(%w)(%w).*$', '%2' ) or ''
	local colorLower = string.lower(color)
	local piece = mw.ustring.gsub( pc, '^.*(%w)(%w).*$', '%1' ) or ''
	local alt =  ''
	local colorSquare = 't'
	if ((row + col) % 2 == 1) then
		colorSquare = 'l'
	else
		colorSquare = 'd'
	end
	local caseName = piece .. color .. colorSquare

	if fullpiecenames[piece .. colorLower] or symnames[piece .. colorLower] or (colornames[colorLower] and piecenames[piece]) then
		local piecename = nil
		if fullpiecenames[piece .. colorLower] then
			piecename = fullpiecenames[piece .. colorLower]
		else
			piecename = symnames[piece .. colorLower] or ( colornames[colorLower] .. ' ' .. piecenames[piece] )
		end
		alt = alt .. ' на поле '
		if ((row + col) % 2 == 1) then
			alt = piecename .. ' на бяло поле ' .. colchar[col] .. row
		else
			alt = piecename .. ' на черно поле ' .. colchar[col] .. row
		end
	else
		alt = comment_empty(row, col, colchar)
		if not symnames[piece .. colorLower] then
			if not img_empty then
				return nil
			end
			caseName = colorSquare
		end
	end

	return '[[File:Chess ' .. caseName .. '45.svg|' .. size .. 'x' .. size .. 'px|alt=' .. alt .. '|' .. alt .. '|link=]]'
end
	
local function innerboard(board_name, board_width, board_height, args, size, rev)
	local colchar = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
	local root = mw.html.create('div')
	local img_name = board_name or 'Chessboard480.svg'
	root:addClass('chess-board')
		:css('position', 'relative')
		:wikitext(string.format( '[[File:%s|%dx%dpx|link=]]', img_name, board_width * size, board_height * size ))

	local widthValue = size .. 'px'
	local heightValue = size .. 'px'
	for trow = 1,board_height do
		local row = rev and trow or ( board_height + 1 - trow )
		local topValue = tostring(( trow - 1 ) * size) .. 'px'
		for tcol = 1,board_width do
			local leftValue = tostring(( tcol - 1 ) * size) .. 'px'
			local col = rev and ( board_width + 1 - tcol ) or tcol
			local piece = args[board_width * ( board_height - row ) + col + 2] or ''
			local pc = piece:match( '%w%w' ) or '  '
			local img = image_square(board_name == nil, pc, row, col, size)
			if img then
				root:tag('div')
					:css('position', 'absolute')
					:css('z-index', '3')
					:css('top', topValue)
					:css('left', leftValue)
					:css('width', widthValue)
					:css('height', heightValue)
					:wikitext(img)
			else
				root:tag('div')
					:attr('title', comment_empty(row, col, colchar))
					:css('position', 'absolute')
					:css('z-index', '3')
					:css('top', topValue)
					:css('left', leftValue)
					:css('width', widthValue)
					:css('height', heightValue)
			end
		end
	end

	return tostring(root)
end

function chessboard(board_name, board_width, board_height, args, size, rev, letters, numbers, header, footer, footer_align, align, clear)
	function letters_row( rev, num_lt, num_rt, width )
		local letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'}
		local root = mw.html.create('')
		if num_lt then
			root:tag('td')
				:css('vertical-align', 'inherit')
				:css('padding', '0')
		end
		for k = 1,board_width do
			root:tag('td')
				:css('padding', '0')
				:css('vartical-align', 'inherit')
				:css('height', '18px')
				:css('width', size .. 'px')
				:wikitext(rev and letters[board_width+1-k] or letters[k])
		end
		if num_rt then
			root:tag('td')
				:css('vertical-align', 'inherit')
				:css('padding', '0')
		end
		return tostring(root)
	end

	local letters_tp = letters:match( 'both' ) or letters:match( 'top' )
	local letters_bt = letters:match( 'both' ) or letters:match( 'bottom' )
	local numbers_lt = numbers:match( 'both' ) or numbers:match( 'left' )
	local numbers_rt = numbers:match( 'both' ) or numbers:match( 'right' )
	local width = board_width * size + 2
	if ( numbers_lt ) then width = width + 18 end
	if ( numbers_rt ) then width = width + 18 end

	local root = mw.html.create('div')
		:addClass('thumb')
		:addClass(align)
		:css('clear', clear)
		:css('text-align', 'center')
		:wikitext(header)
	local div = root:tag('div')
		:addClass('thumbinner')
		:css('width', width .. 'px')
	local b = div:tag('table')
		:css('border-collapse', 'collapse')
		:css('background', 'white')
		:css('font-size', '90%')
		:css('border' , '1px #b0b0b0 solid')
		:css('padding', '0')
		:css('margin', 'auto')

	if ( letters_tp ) then
		b:tag('tr')
			:css('vertical-align', 'middle')
			:wikitext(letters_row( rev, numbers_lt, numbers_rt ))
	end
	local tablerow = b:tag('tr'):css('vertical-align','middle')
	if ( numbers_lt ) then 
		tablerow:tag('td')
			:css('padding', '0')
			:css('vertical-align', 'inherit')
			:css('width', '18px')
			:css('height', size .. 'px')
			:wikitext(rev and 1 or board_height) 
	end
	local td = tablerow:tag('td')
		:attr('colspan', board_width)
		:attr('rowspan', board_height)
		:css('padding', '0')
		:css('vertical-align', 'inherit')
		:wikitext(innerboard(board_name, board_width, board_height, args, size, rev))

	if ( numbers_rt ) then 
		tablerow:tag('td')
			:css('padding', '0')
			:css('vertical-align', 'inherit')
			:css('width', '18px')
			:css('height', size .. 'px')
			:wikitext(rev and 1 or board_height) 
	end
	if ( numbers_lt or numbers_rt ) then
		for trow = 2, board_height do
			local idx = rev and trow or ( board_height + 1 - trow )
			tablerow = b:tag('tr')
				:css('vertical-align', 'middle')
			if ( numbers_lt ) then 
				tablerow:tag('td')
					:css('padding', '0')
					:css('vertical-align', 'inherit')
					:css('height', size .. 'px')
					:wikitext(idx)
			end
			if ( numbers_rt ) then 
				tablerow:tag('td')
					:css('padding', '0')
					:css('vertical-align', 'inherit')
					:css('height', size .. 'px')
					:wikitext(idx)
			end
		end
	end
	if ( letters_bt ) then
		b:tag('tr')
			:css('vertical-align', 'middle')
			:wikitext(letters_row( rev, numbers_lt, numbers_rt ))
	end

	if (footer and footer ~= '') then
		div:tag('div')
			:addClass('thumbcaption')
			:css('font-size', '90%')
			:css('text-align', footer_align)
			:wikitext(footer)
	end

	return tostring(root)
end

function convertFenToArgs( fen )
	-- converts FEN notation to 64 entry array of positions, offset by 2
	local res = { ' ', ' ' }
	-- Loop over rows, which are delimited by /
	for srow in string.gmatch( "/" .. fen, "/%w+" ) do
		-- Loop over all letters and numbers in the row
		for piece in srow:gmatch( "%w" ) do
			if piece:match( "%d" ) then -- if a digit
				for k=1,piece do
					table.insert(res,' ')
				end
			else -- not a digit
				local color = piece:match( '%u' ) and 'l' or 'd'
				piece = piece:lower()
				table.insert( res, piece .. color )
			end
		end
	end

	return res
end

function convertArgsToFen( args, offset )
	function nullOrWhitespace( s ) return not s or s:match( '^%s*(.-)%s*$' ) == '' end
	function piece( s ) 
		return nullOrWhitespace( s ) and 1
			or s:gsub( '%s*(%a)(%a)%s*', function( a, b ) return b == 'l' and a:upper() or a end )
	end
    
	local res = ''
	offset = offset or 0
	for row = 1, 8 do
		for file = 1, 8 do
			res = res .. piece( args[8*(row - 1) + file + offset] )
		end
		if row < 8 then res = res .. '/' end
	end
	return mw.ustring.gsub(res, '1+', function( s ) return #s end )
end

function p.board(frame)
	local args = frame.args
	local pargs = frame:getParent().args
	local size = args.size or pargs.size or '26'
	local reverse = ( args.reverse or pargs.reverse or '' ):lower() == "true"
	local letters = ( args.letters or pargs.letters or 'both' ):lower() 
	local numbers = ( args.numbers or pargs.numbers or 'both' ):lower() 
	local header = args.header or pargs.header or args[2] or pargs[2] or ''
	local board_width = args.width or pargs.width or 8
	local board_height = args.height or pargs.height or 8
	local footer = args.footer or pargs.footer or args[board_width * board_height + 3] or pargs[board_width * board_height + 3] or ''
	local footer_align = args.footer_align or pargs.footer_align or args.falign or pargs.falign or 'left'
	local align = (args.align or pargs.align or args[1] or pargs[1] or 'tright' ):lower()
	local clear = args.clear or pargs.clear or ( align:match('tright') and 'right' ) or 'none'
	local fen = args.fen or pargs.fen
	local board_name = nil
	if (board_width == 8) and (board_height == 8) then
		board_name = 'Chessboard480.svg'
	end

	size = mw.ustring.match( size, '[%d]+' ) or '26' -- remove px from size
	if (fen) then
		return chessboard(board_name, board_width, board_height, convertFenToArgs(fen), size, reverse, letters, numbers, header, footer, footer_align, align, clear)
	end
	if args[3] then
		return chessboard(board_name, board_width, board_height, args, size, reverse, letters, numbers, header, footer, footer_align, align, clear)
	else
		return chessboard(board_name, board_width, board_height, pargs, size, reverse, letters, numbers, header, footer, footer_align, align, clear)
	end
end

function p.fen2ascii(frame)
	-- {{#invoke:Chessboard|fen2ascii|fen=...}}
	local b = convertFenToArgs( frame.args.fen )
	local res = ''
	local offset = 2
	for row = 1,8 do
		local n = (9 - row)
		res = res .. ' |' .. 
		table.concat(b, '|', 8*(row-1) + 1 + offset, 8*(row-1) + 8 + offset) .. '\n'
	end
	res = mw.ustring.gsub( res,'\| \|', '|  |' )
	res = mw.ustring.gsub( res,'\| \|', '|  |' )
	return res
end

function p.ascii2fen( frame )
	-- {{#invoke:Chessboard|ascii2fen|kl| | |....}}
	return convertArgsToFen( frame.args, frame.args.offset or 1 )
end

return p
