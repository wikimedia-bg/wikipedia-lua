-- Module dédié à la création de bandeaux en tous genres

local fun = {}

function fun.metaBandeauAvertissement(frame)
    local pframe = frame:getRelative()
    local arguments = pframe.args
    return fun.do_metaBandeauAvertissement(arguments)
end

-- Squelette d'un bandeau d'avertissement
function fun.do_metaBandeauAvertissement(arguments)
    local result = ""
    local level = arguments.level or ""
    local bClass = mw.ustring.gsub(level,"é","e")
    local icone = ""
    local text = ""
    
	-- icons prédéfinies
	local iconeTable = {
		grave = "Fairytale no.svg",
		["modéré"] = "Emblem-important.svg",
		information = "Information_icon.svg",
		["stub"] = "Nuvola_apps_kedit.svg"
		}
	
	-- Utiliser l'icone fournie s'il y a lieu, ou prendre parmi celles de la table
	if(arguments["icone-complexe"] ~= nil and arguments["icone-complexe"] ~= "") then
		icone = arguments["icone-complexe"]
	else
		icone = "<div style=\"width:45px; text-align:center\">[[File:" .. (arguments["icone"] or iconeTable[arguments.level] or "Icon apps query.svg") .. "|45x35px|alt=|link=]]</div>"
	end
	
	-- text du bandeau
	if(arguments.text ~= nil) then
		text = "<div class=\"bandeau-text\">" .. arguments.text .. "</div>"
	end
	
	-- Mise en boîte
	result = "<div " .. (arguments.id or "") .. "class=\"plainlinks bandeau-level-" .. bClass .. " bandeau js-no-interprojets\"><table style=\"background-color:transparent\"><tr><td class=\"bandeau-icone\">" .. icone .. "</td><td><div class=\"bandeau-title\"><strong>" .. (arguments.title or "No title") .. "</strong>" .. (arguments.date or "") .. "</div>" .. text .. "</td></tr></table>" .. (arguments["supplément"] or "") .. "</div>"

	return result
end

function fun.ebauche(frame)
    local pframe = frame:getRelative()
    local arguments = pframe.args
    return fun.do_ebauche(arguments)
end

function fun.do_ebauche(arguments)
	-- Données relatives aux différents paramètres possibles du modèle
	-- Seront déplacées en sous-page dès que loadData sera activé
	-- local data = mw.loadData("Модул:Bandeau/мъниче")
	local data = {
		football = {"Soccer.svg", "[[футбол]]"},
		footballer = {"football", "[[Портал:Футбол|футболист]]"},
		["hip hop"] = {"redirection", "hip-hop"},
		["hip-hop"] = {"bandeauPortalHipHopSmall-fr.svg", "[[Портал:Хип-хоп|хип-хоп]]"},
		history = {"Pierre_Mignard_001.jpg", "[[история]]"},
		Italy = {"Italy looking like the flag.svg", "l’[[Портал:Италия|Италия]]"},
		gardening = {"Extracted pink rose.png", "[[градинарство]] и [[растениевъдство]]"},
		lake = {"Icon river reservoir.svg", "[[езеро]]"},
		rabbit = {"Lapin01.svg", "[[кролиководство]]", "Кролиководство"}
	}
	
	local index = 1
	local unknown = {false, ""}
	local newTheme = 0
	local nameTheme = arguments[1]
	local icons = {}
	local subject = {}
	local category = {}
	
	-- Récupération des données sur tous les thèmes
	while(arguments[index] ~= nil) do
		-- Récupération des données relatives au thème
		theme = data[nameTheme]
		if(theme ~= nil) then
			if(theme[1] == "alias" or theme[1] == "redirection") then
				-- Cas de redirection
				newTheme = newTheme + 1
				nameTheme = theme[2]
			else
				-- Cas normal
				newTheme = 0
				-- Gestion de l'icone
				if(theme[1] ~= nil) then
					local cibleIcone = data[theme[1]]
					-- Le name de l'icone est-il une référence directe à un autre thème ?
					if(cibleIcone == nil or cibleIcone[1] == "alias" or cibleIcone[1] == "redirection") then
						-- Non : on récupère le name du fichier
						icons[#icons+1] = theme[1]
					else
						-- Oui : on récupère l'icone de l'autre thème
						icons[#icons+1] = cibleIcone[1]
					end
				end
				-- Gestion du sujet
				if(theme[2] ~= nil) then
					subject[#subject+1] = theme[2]
				end
				-- Gestion de la catégorie
				if(theme[3] ~= nil) then
					category[#category+1] = theme[3]
				else
					-- Par défaut, la catégorie correspond au thème
					category[#category+1] = nameTheme
				end
			end
		else
			-- Thème unknown : on le mémorise et on passe au suivant
			newTheme = 0
			unknown[1] = true
			unknown[2] = unknown[2] .. arguments[index] .. " "
		end
        -- Passage éventuel au thème suivant
        if(newTheme > 2) then
			-- Prévention des boucles infinies
			newTheme = 0
		end
		if(newTheme == 0) then
			-- Nouveau thème (non issu d'une redirection)
			index = index + 1
			nameTheme = arguments[index]
		end
	end
	
	-- Génération du bandeau
	local multiIcone = ""
	local size = "45x35px"
	-- Réduire les icons si elles sont trop namebreuses
	if(#icons > 3) then
		size = "35x25px"
	end
	if(#icons > 0) then
		for i = 1, #icons do
			multiIcone = multiIcone .. "[[Image:" .. icons .. "|" .. size .. "|alt=|link=]]"
			-- Passage sur la deuxième ligne
			if(#icons > 3 and i == math.floor((#icons+1)/2)) then
				multiIcone = multiIcone .. "</span><br /><span style=\"white-space:nowrap;word-spacing:5px\">"
			elseif(i ~= #icons) then
				multiIcone = multiIcone .. " "
			end
		end
		multiIcone = "<div style=\"text-align:center;white-space:nowrap\"><span style=\"white-space:nowrap;word-spacing:5px\">" .. multiIcone .. "</span></div>"
	end
	
	-- text du bandeau, contenant les subject
	local textSuj = "Тази статия е [[Уикипедия:Мъниче|мъниче]]"
	if(#subject > 0) then
		textSuj = textSuj .. " concernant "
		for i = 1, #subject do
			textSuj = textSuj .. subject[i]
			if(i < #subject-1) then
				textSuj = textSuj .. ", "
			elseif(i == #subject-1) then
				textSuj = textSuj .. " et "
			end
		end
	end
	textSuj = textSuj .. ".\n"
	
	local textCat = ""
	-- Ne pas catégoriser si nocat est présent
	if(arguments.nocat == nil) then
		if(#category > 0) then
			for i = 1, #category do
				textCat = textCat .. "[[Категория:Мъничета " .. category[i] .. "]]\n"
			end
		else
			textCat = "[[Категория:Мъничета]]\n"
		end
	end
	
	-- Préparation de l'appel du modèle de méta-bandeau
	local metaArgs = {
		level = "stub",
		["icone-complexe"] = multiIcone,
		title = textSuj
		}
	
	return fun.do_metaBandeauAvertissement(metaArgs) .. textCat
		
end

return fun