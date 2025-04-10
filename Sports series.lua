-- Module to build tables for aggregated match results in sports
-- See documentation for details

local p = {}
local ordinalbg = {'1<sup>-ви</sup>','2<sup>-ри</sup>','3<sup>-ти</sup>','4<sup>-ти</sup>','5<sup>-ти</sup>','6<sup>-ти</sup>','7<sup>-ми</sup>','8<sup>-ми</sup>','9<sup>-ти</sup>','10<sup>-ти</sup>'}

-- Function to parse and expand a template with given parameters
local function expandTemplate(frame, templateName, params)
    return frame:expandTemplate{ title = templateName, args = params }
end

-- Function to check the existence of flagTemplate
local function templateExists(templateName)
    local title = mw.title.new('Шаблон:' .. templateName)
    return title and title.exists
end

-- Function to process country codes and variants, dividing parameters by the "+" sign
local function processIcon(iconString)
    if not iconString or iconString:match("^%s*$") then
        return nil, nil  -- Return nil for both iconCode and variant if the input is empty or only whitespace
    elseif iconString:find('+') then
        local parts = mw.text.split(iconString, '+', true)
        local iconCode = parts[1]
        local variant = parts[2]
        return iconCode, variant
    else
        return iconString, nil  -- Return the input string as iconCode if no "+" is present
    end
end

-- Function to determine the correct ordinal suffix for a given number for the heading
local function ordinal(n)
    local last_digit = n % 10
    local last_two_digits = n % 100
    if last_digit == 1 and last_two_digits ~= 11 then
        return n .. 'st'
    elseif last_digit == 2 and last_two_digits ~= 12 then
        return n .. 'nd'
    elseif last_digit == 3 and last_two_digits ~= 13 then
        return n .. 'rd'
    else
        return n .. 'th'
    end
end

-- Function to replace wiki links with their display text or link text
local function replaceLink(match)
    local pipePos = match:find("|")
    if pipePos then
        return match:sub(pipePos + 1, -3) -- Return text after the '|'
    else
        return match:sub(3, -3) -- Return text without the brackets
    end
end

-- Function to clean and process the aggregate score for comparison
local function cleanScore(score)
    -- Return an empty string if score is nil or empty to avoid errors
    if not score or score:match("^%s*$") then
        return ''
    end

    -- Replace wiki links
    score = score:gsub("%[%[.-%]%]", replaceLink)

    -- Remove MediaWiki's unique placeholder sequences for references
    score = score:gsub('\127%\'"`UNIQ.-QINU`"%\'\127', '')

    -- Remove superscript tags and their contents
    score = score:gsub('<sup.->.-</sup>', '')

    -- Strip all characters except numbers, dashes and parentheses
    return score:gsub('[^0-9%-()]+', '')
end

-- Function to determine the winner based on scores within parentheses (first) or regular format (second)
local function determineWinner(cleanAggregate, team1, team2, boldWinner, colorWinner, aggregate, isFBRStyle, legs, leg1Score, leg2Score, disableAwayGoals, skipAutoWinner, aggFormat)
    local team1Winner, team2Winner = false, false
    local score1, score2
    local manualBold = false
    local manualColor = false
    local isDraw = false

    -- Handling for manual bolding
    if team1 and type(team1) == 'string' then
        manualBold1 = team1:find("'''") and not (team1:gsub("'''", ""):match("^%s*$"))
        team1 = team1:gsub("'''", "")
    end
    if team2 and type(team2) == 'string' then
        manualBold2 = team2:find("'''") and not (team2:gsub("'''", ""):match("^%s*$"))
        team2 = team2:gsub("'''", "")
    end

    if manualBold1 then
        team1Winner = true
        manualBold = true
    end
    if manualBold2 then
        team2Winner = true
        manualBold = true
    end

    -- Handling for manual coloring of team or aggregate cells
    if team1 and type(team1) == 'string' then
        manualColor1 = team1:find("''") and not (team1:gsub("''", ""):match("^%s*$"))
        team1 = team1:gsub("''", "")
    end
    if team2 and type(team2) == 'string' then
        manualColor2 = team2:find("''") and not (team2:gsub("''", ""):match("^%s*$"))
        team2 = team2:gsub("''", "")
    end
    if aggregate then
        if aggFormat == 'bold' or aggFormat == 'both' then
            aggregate = "<b>" .. aggregate .. "</b>"
        end
        manualColorDraw = aggFormat == 'italic' or aggFormat == 'both'
    end

    if manualColor1 then
        if not team1Winner then
            team1Winner = true
        end
        manualColor = true
    end
    if manualColor2 then
        if not team2Winner then
            team2Winner = true
        end
        manualColor = true
    end
    if manualColorDraw then
        isDraw = true
        manualColor = true
    end

    -- Regular winner determination logic if manual bolding or coloring is not conclusive
    if not team1Winner and not team2Winner and not isDraw and not skipAutoWinner and (boldWinner or colorWinner or isFBRStyle) then
        local parenthetical = cleanAggregate:match('%((%d+%-+%d+)%)')
        local outsideParenthetical = cleanAggregate:match('^(%d+%-+%d+)')
        if parenthetical then -- Prioritize checking score inside parenthetical
            score1, score2 = parenthetical:match('(%d+)%-+(%d+)')
        elseif outsideParenthetical then
            score1, score2 = outsideParenthetical:match('(%d+)%-+(%d+)')
        end

        if score1 and score2 then
            score1 = tonumber(score1)
            score2 = tonumber(score2)

            if score1 > score2 then
                team1Winner = true
            elseif score1 < score2 then
                team2Winner = true
            elseif score1 == score2 and legs == 2 and not disableAwayGoals then
                -- Apply away goals rule
                local cleanLeg1 = cleanScore(leg1Score):gsub('[()]', '')
                local cleanLeg2 = cleanScore(leg2Score):gsub('[()]', '')
                local _, team2AwayGoals = cleanLeg1:match('(%d+)%-+(%d+)')
                local team1AwayGoals = cleanLeg2:match('(%d+)%-+(%d+)')

                if team1AwayGoals and team2AwayGoals then
                    team1AwayGoals, team2AwayGoals = tonumber(team1AwayGoals), tonumber(team2AwayGoals)

                    if team1AwayGoals > team2AwayGoals then
                        team1Winner = true
                    elseif team2AwayGoals > team1AwayGoals then
                        team2Winner = true
                    end
                end
            end

            if (colorWinner or isFBRStyle) and legs == 0 then
                isDraw = not team1Winner and not team2Winner
            end
        end
    end

    return team1, team2, team1Winner, team2Winner, manualBold, manualColor, isDraw, aggregate
end

-- Function to process score bold/italic formatting
function processScore(s)
    if not s or s == "" then
        return "", false
    end

    local scoreFormat = false

    -- Check for 5+ apostrophes (both bold and italic)
    if s:match("'''''+") then
        scoreFormat = "both"
        s = s:gsub("''+", "")
        return s, scoreFormat
    end

    -- Check for 3+ apostrophes (bold)
    if s:match("'''+") then
        scoreFormat = "bold"
        s = s:gsub("''+", "")
        return s, scoreFormat
    end

    -- Check for 2 apostrophes (italic)
    if s:match("''") then
        scoreFormat = "italic"
        s = s:gsub("''+", "")
        return s, scoreFormat
    end

    -- If no matches found, return original string and false
    return s, scoreFormat
end

-- Function to check if any parameter in a given row is non-nil and non-empty
local function anyParameterPresent(startIndex, step, args)
    -- Check regular parameters
    for index = startIndex, startIndex + step - 1 do
        if args[index] and args[index]:match("^%s*(.-)%s*$") ~= "" then
            return true
        end
    end

    -- Check aggregate note
    local rowIndex = math.floor((startIndex - 1) / step) + 1
    local aggNote = args['note_agg_' .. rowIndex]
    if aggNote and aggNote:match("^%s*(.-)%s*$") ~= "" then
        return true
    end

    -- Check leg notes
    local numLegs = step - (noFlagIcons and 3 or 5)  -- Calculate number of legs
    for leg = 1, numLegs do
        local legNote = args['note_leg' .. leg .. '_' .. rowIndex]
        if legNote and legNote:match("^%s*(.-)%s*$") ~= "" then
            return true
        end
    end

    return false
end

-- Function to check whether to reduce font size for upcoming matches
local function checkSmallText(str)
    -- Check for font size or small/big HTML tags
    if str:match("font%s?%-?size") or str:match("<small>") or str:match("<big>") then
        return false
    end

    -- Remove MediaWiki's unique placeholder sequences for references
    str = str:gsub('\127%\'"`UNIQ.-QINU`"%\'\127', '')

    -- Remove superscript tags and their contents
    str = str:gsub('<sup.->.-</sup>', '')

    -- Check for walkover-related strings (never shown in small text)
    if str:lower():match("walkover") or str:lower():match("w%.o%.") or str:lower():match("w/o") or str:lower():match("bye") then
        return false
    end

    -- Replace wiki links with their display text or link text
    str = str:gsub("%[%[.-%]%]", replaceLink)

    -- Remove all text inside parentheses
    str = str:gsub("%b()", "")

    -- Exit if string contains only en/em dash
    if str == "—" or str == "–" then
        return false
    end

    -- Convert dashes to a standard format
    str = str:gsub('[–—―‒−]+', '-')

    -- Remove opening and closing HTML tags
    str = str:gsub("</?%w+[^>]*>", "")

    -- Remove apostrophes
    str = str:gsub("''+", "")

    -- Remove all whitespace
    str = str:gsub("%s+", "")

    -- Check if the string matches only a scoreline
    if str:match("^%d+-%d+$") then
        return false
    else
        return true
    end
end

-- Function to rewrite anchor links in a string
local function rewriteAnchorLinks(str, baselink, currentPageTitle)
    if not str or str == "" then
        return str
    end
    
    -- Add the base link to anchor links when the module is transcluded on another page
    if baselink ~= '' then
        str = mw.ustring.gsub(str, '(%[%[)(#[^%[%]]*%|)', '%1' .. baselink .. '%2')
    end
    
    -- Remove redundant page references when viewing anchors on the current page
    if currentPageTitle and currentPageTitle ~= "" then
        local escapedTitle = currentPageTitle:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
        local titlePattern = '%[%[' .. escapedTitle .. '(#[^%[%]]*%|)'
        str = mw.ustring.gsub(str, titlePattern, '[[%1')
    end
    
    return str
end

-- Function to format the dashes and winning notes for aggregate/leg score parameters, and divide the score from references/notes/superscripts
local function format_and_extract_score(s, addSpan)
    if not s then return '', '' end -- Return empty strings if input is nil

    -- Handle walkovers
    if s:match("^%s*[Ww]%s*[/.]%s*[Oo]%s*%.?%s*$") then
        return "без игра", ""
    end

    local function format_dash(pattern)
        s = mw.ustring.gsub(s, '^' .. pattern, '%1:%2')
        s = mw.ustring.gsub(s, '%(' .. pattern, '(%1:%2')
    end

    -- Format dashes
    format_dash('%s*([%d%.]+)%s*:%s*([%d%.]+)')

    -- Extract end text
    local supStart = s:find('<sup')
    local placeholderStart = s:find('\127%\'"`UNIQ')

    -- Function to find the first parenthesis outside of wikilinks
    local function find_paren_outside_wikilinks(s)
        local pos = 1
        while true do
            pos = s:find('%(', pos)
            if not pos then break end
            
            local beforeParen = s:sub(1, pos - 1)
            local openLinks = select(2, beforeParen:gsub('%[%[', '')) - select(2, beforeParen:gsub('%]%]', ''))
            
            if openLinks == 0 then
                return pos
            end
            
            pos = pos + 1
        end
        return nil
    end

    local parenStart = find_paren_outside_wikilinks(s)

    local startPositions = {}
    if supStart then table.insert(startPositions, supStart) end
    if placeholderStart then table.insert(startPositions, placeholderStart) end
    if parenStart then table.insert(startPositions, parenStart) end

    local scoreMatch, endText
    if #startPositions > 0 then
        local startPos = math.min(unpack(startPositions))
        
        -- Find the last non-whitespace character before startPos
        local scoreEnd = s:sub(1, startPos - 1):match(".*%S") or ""
        scoreEnd = #scoreEnd

        -- Extract the score and endText
        scoreMatch = s:sub(1, scoreEnd)
        endText = s:sub(scoreEnd + 1)
    else
        -- If no match found, return the entire score
        scoreMatch = s
        endText = ""
    end

    -- Format winning notes in brackets (only if endText is not empty)
    if endText ~= "" then
        if addSpan then
            endText = mw.ustring.gsub(endText, '(%(%d+%s*–%s*%d+)%s*[Pp]%.?[EeSs]?%.?[NnOo]?%.?%)', '<span class="nowrap">%1 [[дузпа|д.]])</span>')
            endText = mw.ustring.gsub(endText, '%([Aa]%.?[Ee]%.?[Tt]%.?%)', '<span class="nowrap">([[След добавено време|сдв]])</span>')
        else
            endText = mw.ustring.gsub(endText, '(%(%d+%s*–%s*%d+)%s*[Pp]%.?[EeSs]?%.?[NnOo]?%.?%)', '%1 [[дузпа|д.]])')
            endText = mw.ustring.gsub(endText, '%([Aa]%.?[Ee]%.?[Tt]%.?%)', '([[След добавено време|сдв]])')
        end
        endText = mw.ustring.gsub(endText, '%([Aa]%.?[Gg]?%.?[Rr]?%.?%)', '(гчт)')
    end

    return scoreMatch, endText
end

-- Function to clean team names and generate links
local function cleanAndGenerateLinks(team1, team2, score, isSecondLeg)
    local function cleanTeam(str, defaultName)
        if str and str ~= "" then
            str = str:gsub('<sup.->.-</sup>', '')
            str = str:gsub("</?%w+[^>]*>", "")
            str = str:gsub('\127%\'"`UNIQ.-QINU`"%\'\127', '')
            str = str:gsub("%[%[[Ff]ile:[^%]]+%]%]", "")
            str = str:gsub("%[%[[Ii]mage:[^%]]+%]%]", "")
            str = str:gsub("%[%[.-%]%]", replaceLink)
            str = str:gsub("%s*&nbsp;%s*", "")
            str = str:match("^%s*(.-)%s*$")  -- Remove leading and trailing whitespace
            return str ~= "" and str or defaultName
        end
        return defaultName
    end

    team1 = cleanTeam(team1, "Team 1")
    team2 = cleanTeam(team2, "Team 2")

    if score and score:match("%S") then
        local linkScore = score
        if score:find('%[') then
            linkScore = score:match('^([%d%.]+–[%d%.]+)')
            if not linkScore then
                return score
            end
        end

        if linkScore then
            local link
            if isSecondLeg then
                link = "[[#" .. team2 .. " — " .. team1 .. "|" .. linkScore .. "]]"
            else
                link = "[[#" .. team1 .. " — " .. team2 .. "|" .. linkScore .. "]]"
            end
            
            return link .. score:sub(#linkScore + 1)
        end
    end

    return score
end

-- Function to process notes for aggregate and leg scores
local function processNote(frame, notes, noteKey, noteText, endText, rowIndex, rand_val, noteGroup, baselink, currentPageTitle)
    if not noteText then return endText, notes end
    if noteText:match("^%s*<sup") or noteText:match("^\127%\'%\"`UNIQ") then
        return noteText .. endText, notes
    end

    local function createInlineNote(name)
        return frame:extensionTag{
            name = 'ref',
            args = {
                name = name,
                group = noteGroup
            }
        }
    end

    -- Check if noteText is a reference to another note
    local referenced_note = noteText:match("^(agg_%d+)$") or noteText:match("^(leg%d+_%d+)$")
    if referenced_note then
        local referenced_note_id = '"table_note_' .. referenced_note .. '_' .. rand_val .. '"'
        return endText .. createInlineNote(referenced_note_id), notes
    end

    -- Process anchor links in noteText before storing
    if noteText:find("%[%[") then
        noteText = rewriteAnchorLinks(noteText, baselink, currentPageTitle)
    end

    local note_id = '"table_note_' .. noteKey .. '_' .. rowIndex .. '_' .. rand_val .. '"'
    if not notes[note_id] then
        notes[note_id] = noteText
    end

    return endText .. createInlineNote(note_id), notes
end

-- Function to generate the footer if necessary
local function createFooter(frame, notes, noteGroup, isFBRStyle, displayNotes, externalNotes, legs)
    local needFooter = (isFBRStyle and legs == 0) or displayNotes or (next(notes) ~= nil)

    if not needFooter then
        return ''  -- Return an empty string if no footer is needed
    end

    local divContent = mw.html.create('div')
        :addClass('sports-series-notes')

    if isFBRStyle and legs == 0 then
        divContent:wikitext("Легенда: Синьо = победа за домакините; Жълто = равенство; Червено = победа за гостите.")
    end

    if (next(notes) ~= nil and not externalNotes) or displayNotes then
        divContent:wikitext((isFBRStyle and legs == 0) and "<br>Бележки:" or "Бележки:")
    end

    local footer = tostring(divContent)

    if next(notes) ~= nil or displayNotes then
        local noteDefinitions = {}
        for noteId, noteText in pairs(notes) do
            if type(noteId) == 'string' and noteId:match('^"table_note') then
                table.insert(noteDefinitions, frame:extensionTag{
                    name = 'ref',
                    args = {
                        name = noteId,
                        group = noteGroup
                    },
                    content = noteText
                })
            end
        end

        if externalNotes then
            local hiddenRefs = mw.html.create('span')
                :addClass('sports-series-hidden')
                :wikitext(table.concat(noteDefinitions))
            if isFBRStyle and legs == 0 then
                footer = footer .. tostring(hiddenRefs)
            else
                footer = tostring(hiddenRefs)
            end
        else
            local reflistArgs = {
                refs = table.concat(noteDefinitions),
                group = noteGroup
            }
            footer = footer .. frame:expandTemplate{
                title = 'reflist',
                args = reflistArgs
            }
        end
    end

    return footer
end

-- Main function that processes input and returns the wikitable
function p.main(frame)
    local args = require('Module:Arguments').getArgs(frame, {trim = true})
    local yesno = require('Module:Yesno')

    -- Check for section transclusion
    local tsection = frame:getParent().args['transcludesection'] or frame:getParent().args['section'] or ''
    local bsection = args['section'] or ''
    if tsection ~= '' and bsection ~= '' then
        if tsection ~= bsection then
            return ''  -- Return an empty string if sections don't match
        end
    end

    local root = mw.html.create()
    local templatestyles = frame:extensionTag{
    	name = 'templatestyles',
    	args = { src = 'Screen reader-only/styles.css' }
    } .. frame:extensionTag{
        name = 'templatestyles',
        args = { src = 'Module:Sports series/styles.css' }
    }
    root:wikitext(templatestyles)

    local flagYesno = yesno(args.flag)
    local showFlags = flagYesno ~= false
    local noFlagIcons = not showFlags
    local fillBlanks = yesno(args.fill_blanks)
    local generateLinks = yesno(args.generate_links)
    local solidCell = yesno(args.solid_cell) or args.solid_cell == 'grey' or args.solid_cell == 'gray'
    local baselink = frame:getParent():getTitle()
    local currentPageTitle = mw.title.getCurrentTitle().fullText
    if currentPageTitle == baselink then baselink = '' end
    local notes = {}
    local noteGroup = args.note_group or 'lower-alpha'
    local noteListValue = yesno(args.note_list)
    local displayNotes = noteListValue == true
    local externalNotes = noteListValue == false
    math.randomseed(os.clock() * 10^8)  -- Initialize random number generator
    local rand_val = math.random()

    -- Process the font size parameter
    local fontSize
    if args.font_size then
        -- Remove trailing '%' if present and convert to number
        fontSize = tonumber((args.font_size:gsub('%s*%%$', '')))
        if fontSize then
            fontSize = math.max(fontSize, 85)  -- Ensure font size is at least 85
        end
    end

    -- Process flag parameter to determine flag template and variant
    local flagTemplate = 'флагче'
    local flagSize = args.flag_size
    if showFlags then
        if args.flag and args.flag ~= '' and not flagYesno then
            flagTemplate = args.flag:gsub('^Шаблон:', '')
            if not templateExists(flagTemplate) then
                flagTemplate = 'flag icon'
            end
        end
        
        if flagSize and not flagSize:match('px$') then
            flagSize = flagSize .. 'px'
        end
    end

    -- Determine whether line should be displayed
    local showCountry = args.show_country
    local function shouldShowRow(team1Icon, team2Icon)
        if not showCountry or noFlagIcons then
            return true
        end
        return team1Icon == showCountry or team2Icon == showCountry
    end

    local legs = 2
    if args.legs then
        if yesno(args.legs) == false or args.legs == '1' then
            legs = 0
        else
            legs = tonumber(args.legs) and math.max(tonumber(args.legs), 2) or 2
        end
    end
    local teamWidth = (tonumber(args['team_width']) and args['team_width'] .. 'px') or '250px'
    local scoreWidth = (tonumber(args['score_width']) and args['score_width'] .. 'px') or '80px'
    local boldWinner = args.bold_winner == nil or yesno(args.bold_winner, true)
    local colorWinner = yesno(args.color_winner)
    local matchesStyle = args.matches_style
    local isFBRStyle = matchesStyle and matchesStyle:upper() == "FBR"
    local isHA = yesno(args.h_a) or (isFBRStyle and legs == 0)
    local disableAwayGoals = yesno(args.away_goals) == false
    local disableSmallText = yesno(args.small_text) == false
    local noWrapValue = yesno(args.nowrap)
    local noWrap = noWrapValue == true
    local disableNoWrap = noWrapValue == false
    local aggFormat

    local tableClass = 'wikitable sports-series'
    local doCollapsed = yesno(args.collapsed)
    if doCollapsed then
        tableClass = tableClass .. ' mw-collapsible mw-collapsed'
    end
    if yesno(args.center_table) and not doCollapsed then
        tableClass = tableClass .. ' center-table'
    end
    if fontSize then
        table:css('font-size', fontSize .. '%')
    end

    -- Create the table element
    local table = root:tag('table')
        :addClass(tableClass)
        :cssText(tableStyle)
    if args.id then
        table:attr('id', args.id)  -- Optional id parameter to allow anchor to table
    end
    if noWrap then
        table:attr('data-nowrap', 'y')
    elseif not disableNoWrap then
        table:attr('data-nowrap', 'n')
    end

    -- Add a caption to table if the "caption" parameter is passed
    if args.caption then
        table:tag('caption'):wikitext(args.caption)
    end

    -- Count number of columns
    local colCount = 3 + legs

    -- Add a title row above column headings if the "title" parameter is passed
    if args.title then
        local titleRow = table:tag('tr'):addClass('title-row')
        titleRow:tag('th')
            :attr('colspan', colCount)
            :attr('scope', 'colgroup')
            :wikitext(args.title)
    end

    -- Create the header row with team and score columns
    local header = table:tag('tr')
    local defaultTeam1 = isHA and 'Домакин' or 'Отбор 1'
    local defaultTeam2 = isHA and 'Гост' or 'Отбор 2'
    header:tag('th'):attr('scope', 'col'):css('width', teamWidth):wikitext(args['team1'] or defaultTeam1)
    header:tag('th'):attr('scope', 'col'):css('width', scoreWidth):wikitext(args['aggregate'] or legs == 0 and 'Резултат' or 'Общ<br />резултат')
    header:tag('th'):attr('scope', 'col'):css('width', teamWidth):wikitext(args['team2'] or defaultTeam2)

    -- Add columns for each leg if applicable
    if legs > 0 then
        for leg = 1, legs do
            local legHeading = args['Мач' .. leg]

            -- Check if "legN" parameter is present
            if not legHeading then
                if args.leg_prefix then
                    legHeading = yesno(args.leg_prefix) and ('Мач ' .. leg) or (args.leg_prefix .. ' ' .. leg)
                elseif args.leg_suffix and not yesno(args.leg_suffix) then
                    legHeading = ordinalbg[leg] .. ' ' .. args.leg_suffix
                else
                    legHeading = ordinalbg[leg] .. ' мач'
                end
            end

            header:tag('th'):attr('scope', 'col'):css('width', scoreWidth):wikitext(legHeading)
        end
    end

    local step = (noFlagIcons and 3 or 5) + legs  -- Determine the step size based on the presence of flag icons
    local i = 1
    while anyParameterPresent(i, step, args) do
        local rowIndex = math.floor((i - 1) / step) + 1
        local aggNote = args['note_agg_' .. rowIndex]
        local headingParam = args['heading' .. rowIndex]

        local team1, team2, aggregateScore, aggregateEndText, legEndText, team1Icon, team2Icon, team1Variant, team2Variant
        local team1Winner, team2Winner, manualBold, manualColor, isDraw = false, false, false, false, false
        local leg1Score, leg2Score = false, false

        -- Process rows from input
        team1 = args[i]
        if noFlagIcons then
            aggregateScore = args[i+1]
            team2 = args[i+2]
        else
            team1Icon, team1Variant = processIcon(args[i+1])
            aggregateScore = args[i+2]
            team2 = args[i+3]
            team2Icon, team2Variant = processIcon(args[i+4])
        end

        -- Check if the line should be shown based on both teams
        if shouldShowRow(team1Icon, team2Icon) then
            -- Add a heading above a given row in the table
            if headingParam and not showCountry then
                local headingRow = table:tag('tr'):addClass('heading-row')
                headingRow:tag('td')
                    :attr('colspan', colCount)
                    :wikitext('<strong>' .. headingParam .. '</strong>')
            end

            local row = table:tag('tr')

            -- Name the 1st/2nd leg scores for two-legged ties
            if legs == 2 then
                if noFlagIcons then
                    leg1Score = args[i+3]
                    leg2Score = args[i+4]
                else
                    leg1Score = args[i+5]
                    leg2Score = args[i+6]
                end
            end

            -- Clean the aggregate score
            local cleanAggregate = cleanScore(aggregateScore)
            aggregateScore, aggFormat = processScore(aggregateScore)
            -- Format anchor links for aggregate score
            local aggParen = cleanAggregate:match("%(.*%(")
            local aggSpan = (disableNoWrap or (not noWrap and not disableNoWrap and aggParen))
            aggregateScore, aggregateEndText = format_and_extract_score(aggregateScore, aggSpan)
            -- Apply link rewriting to note text before creating the note
            aggregateEndText, notes = processNote(frame, notes, 'agg', aggNote, aggregateEndText, rowIndex, rand_val, noteGroup, baselink, currentPageTitle)
            if generateLinks and legs == 0 then
                -- Skip link generation for "Bye" entries
                local isBye = aggregateScore:match("^%s*[Bb][Yy][Ee]%s*$") or aggregateScore:match("|[Bb][Yy][Ee]%]%]")
                if not isBye then
                    aggregateScore = cleanAndGenerateLinks(team1, team2, aggregateScore, false)
                end
            end

            local skipAutoWinner = legs == 0 and aggregateScore ~= '' and checkSmallText(aggregateScore)

            -- Determine the winning team on aggregate
            team1, team2, team1Winner, team2Winner, manualBold, manualColor, isDraw, aggregateScore = determineWinner(cleanAggregate, team1, team2, boldWinner, colorWinner, aggregateScore, isFBRStyle, legs, leg1Score, leg2Score, disableAwayGoals, skipAutoWinner, aggFormat)

            -- Function to create flag template parameters
            local function getFlagParams(icon, variant)
                local params = {icon, variant = variant}
                if flagSize then
                    params.size = flagSize
                end
                return params
            end

            -- Generate text to display for each team
            local team1Text = noFlagIcons and (team1 or '') or ((team1Icon ~= "" and team1Icon ~= nil) and ((team1 or '') .. '&nbsp;' .. expandTemplate(frame, flagTemplate, getFlagParams(team1Icon, team1Variant))) or (team1 or ''))
            local team2Text = noFlagIcons and (team2 or '') or ((team2Icon ~= "" and team2Icon ~= nil) and (expandTemplate(frame, flagTemplate, getFlagParams(team2Icon, team2Variant)) .. '&nbsp;' .. (team2 or '')) or (team2 or ''))

            -- When set by user, adds blank flag placeholder next to team names
            if fillBlanks and showFlags then
                local flagDimensions = flagSize or "25x17px"
                local placeholderFlag = string.format('<span class="flagicon">[[File:Flag placeholder.svg|%s|link=]]</span>', flagDimensions)
                if not team1Icon or team1Icon == "" then
                    team1Text = team1Text .. '&nbsp;' .. placeholderFlag
                end
                if not team2Icon or team2Icon == "" then
                    team2Text = placeholderFlag .. '&nbsp;' .. team2Text
                end
            end

            local aggregateContent
            if not disableSmallText and skipAutoWinner then
                aggregateContent = '<span class="sports-series-small">' .. aggregateScore .. '</span>' .. aggregateEndText
            else
                aggregateContent = aggregateScore .. aggregateEndText
            end

            -- Create aggregate score cell with conditional styling
            local aggregateClass = ''
            if isFBRStyle and legs == 0 then
                if team1Winner then
                    aggregateClass = 'fbr-home-win'
                elseif team2Winner then
                    aggregateClass = 'fbr-away-win'
                elseif isDraw then
                    aggregateClass = 'draw'
                end
            elseif isDraw then
                aggregateClass = 'draw'
            end
            if not disableNoWrap and (not noWrap and aggParen) then
                aggregateClass = (aggregateClass ~= '' and aggregateClass .. ' ' or '') .. 'allow-wrap'
            end

            -- Create rows for aggregate score and team names, bolded if set by user
            row:tag('td'):addClass(team1Winner and (colorWinner or manualColor) and 'winner' or nil):wikitext((team1Winner and (boldWinner or manualBold) and team1Text ~= '') and ('<strong>' .. team1Text .. '</strong>') or team1Text)
            row:tag('td'):addClass(aggregateClass ~= '' and aggregateClass or nil):wikitext(aggregateContent)
            row:tag('td'):addClass(team2Winner and (colorWinner or manualColor) and 'winner' or nil):wikitext((team2Winner and (boldWinner or manualBold) and team2Text ~= '') and ('<strong>' .. team2Text .. '</strong>') or team2Text)

            -- Add columns for each leg score if applicable
            if legs > 0 then
                for leg = 1, legs do
                    local legIndex = i + 4 + leg + (noFlagIcons and -2 or 0)
                    local legScore = args[legIndex]
                    local legNote = args['note_leg' .. leg .. '_' .. rowIndex]
                    if legScore ~= "nil" then
                        if legScore == "null" then
                            if solidCell then
                                row:tag('td'):addClass('solid-cell')
                            else
                                legScore = '—'
                            end
                        end

                        if legScore ~= "null" then
                            -- Format anchor links for leg scores
                            local cleanLeg = cleanScore(legScore)
                            local legFormat
                            legScore, legFormat = processScore(legScore)
                            local legParen = cleanLeg:match("%(.*%(")
                            local legSpan = (disableNoWrap or (not noWrap and not disableNoWrap and legParen))
                            legScore, legEndText = format_and_extract_score(legScore, legSpan)
                            -- Apply link rewriting to note text before creating the note
                            legEndText, notes = processNote(frame, notes, 'leg' .. leg, legNote, legEndText, rowIndex, rand_val, noteGroup, baselink, currentPageTitle)
                            if generateLinks and not aggregateContent:lower():find("bye") then
                                if leg == 1 then
                                    legScore = cleanAndGenerateLinks(team1, team2, legScore, false)
                                elseif leg == 2 then
                                    legScore = cleanAndGenerateLinks(team1, team2, legScore, true)
                                end
                            end
                            if legFormat == 'bold' or legFormat == 'both' then legScore = '<b>' .. legScore .. '</b>' end
                            if legFormat == 'italic' or legFormat == 'both' then legScore = '<i>' .. legScore .. '</i>' end
                            local legContent
                            if not disableSmallText and legScore ~= '' and checkSmallText(legScore) then
                                legContent = '<span class="sports-series-small">' .. legScore .. '</span>' .. legEndText
                            else
                                legContent = legScore .. legEndText
                            end
                            local legClass = ''
                            if not disableNoWrap and (not noWrap and legParen) then
                                legClass = 'allow-wrap'
                            end
                            -- Write cells for legs
                            row:tag('td'):addClass(legClass ~= '' and legClass or nil):wikitext(legContent)
                        end
                    end
                end
            end
        end

        i = i + step
    end

    -- Generate footer text
    local footerText = createFooter(frame, notes, noteGroup, isFBRStyle, displayNotes, externalNotes, legs)
    root:wikitext(footerText)

    local tableCode = tostring(root)

    -- Rewrite anchor links for the entire table (except for notes which were handled separately)
    tableCode = rewriteAnchorLinks(tableCode, baselink, currentPageTitle)

    -- Return the completed table with rewritten links
    return tableCode
end

return p
