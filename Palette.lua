local Palette = { }

function Palette.listPalette( frame )
	local args = frame.args
	local relativeArgs = frame:getRelative().args 
	
	local wikiTable = { '<div class="navbox_group" style="clear:both;">\n' }
	setmetatable( wikiTable, { __index = table } )   -- permet d'utiliser les fonctions de table comme des méthodes
	local palettesVerticales = ''
	
	local maxPalette = tonumber( args.maxPalette ) or 4
	local categoriePaletteInconnue = '[[Категория:Шаблони за палитри]]'
	local categorieTropDePalette = '[[Категория:Шаблони за палитри]]'
	local categoriePaletteEnDouble = '[[Категория:Шаблони за палитри]]'
	
	local categories = { }
	
	local function _erreur( texte, param, ... )
		if param then texte = texte:format( param, ... )
		end 
		local sep = #wikiTable > 1 and '<hr>' or ''
		return sep .. '<p><strong class="error" style="padding-left:.5em;">' .. texte .. '</strong></p>\n'
	end
	local function _pasDePalette()
		return _erreur( 'Erreur dans l’utilisation du [[Шаблон:palette]] : paramètre obligatoire absent.' )
	end
	
	local function _paletteInconnue( i )
		categories.paletteInconnue = categoriePaletteInconnue
		local nomPalette = mw.text.trim( relativeArgs[i] )
		return _erreur( 'Erreur : il n’existe pas de modèle {{[[Шаблон:Palette %s|Palette %s]]}} [[:en:Aide:Palette de navigation|(aide)]]', nomPalette, nomPalette )
	end

	local function _paletteEnDouble ( i )
		categories.paletteEnDouble = categoriePaletteEnDouble
		return "" -- inutile d'afficher une erreur visible pour ce cas puisque la mise en page n'est pas cassée
	end
	
	local function _paletteAvecParametres( i )
		local argsPalette = { }
		for n, v in pairs( relativeArgs ) do
			if not tonumber(n) then
				if n:match( ' ' .. i .. '$' ) then
					argsPalette[ n:sub(1, n:len() - 1 - tostring(i):len() ) ] = v
				elseif n == 'nocat' .. i then
					argsPalette.nocat = v
				elseif not argsPalette[n] and n ~= 'stylecorps' then
					argsPalette[n] = v					
				end
			end
		end
		return frame:expandTemplate{ title = 'Palette ' .. mw.text.trim(relativeArgs[i]), args = argsPalette }
	end
	
	local function _tropDePalettes()
		categories.tropDePalette = categorieTropDePalette
		return _erreur( 'Erreur dans le [[Шаблон:Palette]] : trop de palettes (maximum : %s)', maxPalette )
	end 
	
	
	local boite = relativeArgs['titre boîte déroulante'] or relativeArgs['titre boite déroulante']
	if boite then
		wikiTable[1] = '<div class="NavFrame navbox_group" style="clear:both;" >\n'
			.. '<div class="NavHead" style="text-align:center; height:1.6em; background-color:'
			.. ( relativeArgs.couleurFondT or '#CCF' )
			.. '; color:' .. ( relativeArgs.couleurTexteT or 'black' ) .. ';">'
			.. boite
			.. '</div>\n<div class="NavContent" style="margin-top:2px;">\n'
	end
	local i = 1
	
	while relativeArgs[i] and i <= maxPalette  do
		if relativeArgs[i]:match( '%S' ) then
			local j 
			for j = 1, i - 1 do
			    if args[i] == args[j] and not args[i]:match('^palette ') then
					wikiTable:insert ( _paletteEnDouble(i))
				end
			end
			if relativeArgs[i]:match( '<table class="navbox' ) or relativeArgs[i]:match( '{| ?class="navbox' ) then
				wikiTable:insert( relativeArgs[i] )
			else
				local codePalette = args[i]  
				local testCodePalette = codePalette:lower()
				if testCodePalette:match( '^%[%[:modèle:' ) then                  -- La palette n'existe pas
					wikiTable:insert( _paletteInconnue( i ) )
				elseif testCodePalette:match( '^palette avec paramètres' ) then  -- C'est une palette nécessitant des paramètres nommés
					wikiTable:insert( _paletteAvecParametres( i ) )
				elseif testCodePalette:match( '^palette verticale avec paramètres' ) then  -- C'est une palette verticale nécessitant des paramètres nommés
					palettesVerticales = palettesVerticales .. ( _paletteAvecParametres( i ) )
				elseif testCodePalette:match( '^palette verticale' ) then        -- C'est une palette verticale
					palettesVerticales = palettesVerticales .. codePalette:sub( 18 )
				else
					wikiTable:insert( (codePalette:gsub( '^<div class="navbox_group"', '<div' ) ) )
				end
			end
		end
		i = i + 1
	end
		
	if i == 1 then
		wikiTable:insert( _pasDePalette() )
	elseif i > maxPalette and relativeArgs[i] and relativeArgs[i] ~= '' then
		wikiTable:insert( _tropDePalettes() )
	end
	if #wikiTable == 1 then
		wikiTable[1] = palettesVerticales
	else
		if boite then
			wikiTable:insert( '</div>' )
		end
		wikiTable:insert( '</div>' .. palettesVerticales )
	end
	if mw.title.getCurrentTitle().namespace == 0 then
		for i, v in pairs( categories ) do
			wikiTable:insert( v )
		end
	end
	
	return wikiTable:concat()
end


return Palette