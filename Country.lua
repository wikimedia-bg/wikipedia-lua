local Country = { }

-- Parameters :
--    1 : code ISO-3166 of country ;
--    text or 2 : text in this country ;
function Country.country( frame )
	local args = ( frame.getRelative and frame:getRelative().args ) or frame or { }         -- préparation pour appel par modèle ou direct.
	local code = mw.ustring.lower( mw.text.trim( args[1] or '' ) )
	local text = args.text or ''
	if text == '' then
		text = args[2] or ''
	end
	return text
end

-- See Шаблон:Indication country
-- Parameters :
--    1 : name of Country ;
--    2 : code ISO-3166 ;
--    text : text in this country ;
function Country.indicationDeCountry( frame )
	local args = ( frame.getRelative and frame:getRelative().args ) or frame or { }
	local nameCountry = args[1] or ''
	local code = args.Country or mw.text.trim( args[2] or '' )
	local text = args.text
	local wikiText = ''
	-- Cas où le premier et/ou le deuxième paramètre est vide.
	--if code .. nameCountry == '' then
	--	return text
	--elseif nameCountry == '' then
	--	nameCountry = datacountry[ mw.ustring.lower( code ) ]
	--	nameCountry = (namecountry and namecountry.name or '???')
	--elseif code == '' then
	--	code = dataCountry[ nameCountry ]
	--	code = ( code and code.code or '' )
	--	if code == '' then
	--		return text
	--	end
	--end
	-- Gestion du text.
	if text and text ~= '' then
		text = '&nbsp;' .. Country.country{ code, text = text }
	else
		text = ''
	end
	-- Compilation de l'indicateur de country et du text.
	wikiText = '<span class="indicator-country">(<abbr class="abbr" title="country : '
		.. nameCountry .. '">'
		.. code .. '</abbr>)</span>'
		.. text
	return wikiText
end

return Country