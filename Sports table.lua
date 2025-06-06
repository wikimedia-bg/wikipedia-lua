-- Module to build tables for standings in Sports
-- See documentation for details

require('strict')

local p = {}

-- Main function
function p.main(frame)
	-- Declare locals
	local getArgs = require('Модул:Arguments').getArgs
	local Args = getArgs(frame, {parentFirst = true})
	local ii_start, ii_end, N_rows_res = 0
	local text_field_result
	local notes_exist = false
	local t = {}
	local t_footer = {}
	local t_return = {}
	local team_list = {}
	local jj, jjj
	local table_anchor = mw.ustring.gsub(Args['section'] and 'sports-table-' .. Args['section'] or '', ' ', '_')
	
	-- Exit early if we are using section transclusion for a different section
	local tsection = frame:getParent().args['transcludesection'] or frame:getParent().args['section'] or ''
	local bsection = frame.args['section'] or ''
	if( tsection ~= '' and bsection ~= '' ) then
		if( tsection ~= bsection ) then
			return ''
		end
	end

	local templatestyles = frame:extensionTag{
		name = 'templatestyles', args = { src = 'Модул:Sports table/styles.css' }
	}
	
	-- Edit links if requested
	local baselink = frame:getParent():getTitle()
	if baselink == 'Модул:Excerpt' then baselink = '' end
	if mw.title.getCurrentTitle().fullText == baselink then	baselink = '' end
	local template_name = (baselink ~= '' and (':' .. baselink .. (table_anchor ~= '' and '#' .. table_anchor or '')))
		or ''

	-- Get the custom start point for the table (most will start by default at 1)
	local top_pos = tonumber(Args['highest_pos']) or 1
	-- Get the custom end point for the table (unrestricted if bottom_pos is < top_pos)
	local bottom_pos = tonumber(Args['lowest_pos']) or 0
	local N_teams = top_pos - 1 -- Default to 0 at start, but higher number needed to skip certain entries
	
	-- Load modules
	local yesno = require('Модул:Yesno')
	-- Load style and (sub) modules
	local style_def = Args['style'] or 'WDL'
	-- Historically 'football' exists as style, this is now forwarded to WDL
	if style_def == 'football' then style_def = 'WDL' end
	local p_style = require('Модул:Sports table/'..style_def)
	local p_sub = require('Модул:Sports table/sub')
	
	-- Random value used for uniqueness
	math.randomseed( os.clock() * 10^8 )
	local rand_val = math.random()
	
	-- Declare colour scheme
	local result_col = {}
	result_col = {green1='#BBF3BB', green2='#CCF9CC', green3='#DDFCDD', green4='#EEFFEE',
		blue1='#BBF3FF', blue2='#CCF9FF', blue3='#DDFCFF', blue4='#EEFFFF',
		yellow1='#FFFFBB', yellow2='#FFFFCC', yellow3='#FFFFDD', yellow4='#FFFFEE',
		red1='#FFBBBB', red2='#FFCCCC', red3='#FFDDDD', red4='#FFEEEE',
		black1='#BBBBBB', black2='#CCCCCC', black3='#DDDDDD', black4='#EEEEEE',
		orange1='#FEDCBA', orange2='#FEEAD5',
		white1='inherit',['']='inherit'
	}
	
	-- Show all stats in table or just matches played and points
	local full_table = true
	local hide_results = yesno(Args['hide_results'] or 'no')
	local hide_footer = yesno(Args['hide_footer'] or 'no')
	local pld_pts_val = string.lower(Args['only_pld_pts'] or 'no')
	local show_class_rules = yesno(Args['show_class_rules'] or 'yes') and true or false
	-- True if par doesn't exist, false otherwise
	if yesno(pld_pts_val) then
		full_table = false
	elseif pld_pts_val=='no_hide_class_rules' then
		full_table = true
		show_class_rules = false
	end
	
	-- Declare results column header
	local results_header = {}
	results_header = {
		Q='Квалификация',
		QR='Квалификация или отпадане',
		P='Класиране',
		PQR='Класиране, квалификация или отпадне',
		PR='Класиране или отпадне',
		PQ='Класиране или квалификация', 
		R='Отпадане'}
	local results_defined = false -- Check whether this would be needed
	-- Possible prefix for result fields
	local respre = (Args['result_prefix'] or '') .. '_'
	respre = (respre == '_') and '' or respre
	-- Now define line for column header (either option or custom)
	local local_res_header = results_header[Args[respre..'res_col_header']] or Args[respre..'res_col_header']  or ''
	-- Check whether it includes a note
	local res_head_note = Args['note_header_res']
	local res_head_note_text = ''
	if full_table and res_head_note then
		notes_exist = true
		res_head_note_text = frame:expandTemplate{ title = 'efn', args = { group='lower-alpha',  res_head_note} }
	end
	local results_header_txt = '! scope="col" |'..local_res_header..res_head_note_text..'\n'
	
	-- Get status option
	local t_status = p_style.status(Args)
	
	-- Alternative syntax for team list
	if Args['team_order'] and Args['team_order'] ~= '' then
		local team_order_offset = (tonumber(Args['team_order_start']) or 1) - 1
		local tlist = mw.text.split(Args['team_order'], '%s*[;,]%s*')
		for k, tname in ipairs(tlist) do
			if tname ~= '' then
				Args['team' .. (k + team_order_offset)] = tname
			end
		end
	end
	
	-- Read in number of consecutive teams (ignore entries after skipping a spot)
	while Args['team'..N_teams+1] ~= nil and (bottom_pos < top_pos or N_teams < bottom_pos) do
		N_teams = N_teams+1
		-- Sneakily add it twice to the team_list parameter, once for the actual
		-- ranking, the second for position lookup in sub-tables
		-- This is possible because Lua allows both numbers and strings as indices.
		team_list[N_teams] = Args['team'..N_teams] -- i^th entry is team X
		team_list[Args['team'..N_teams]] = N_teams -- team X entry is position i
	end

	-- Optional totals
	local total_row_name = 'SPORTS_TABLE_TOTAL'
	if yesno(Args['show_totals'] or 'no') then
		N_teams = N_teams+1
		Args['team' .. N_teams] = total_row_name
		Args['name_' .. total_row_name] = 'Total'
		Args['result' .. N_teams] = total_row_name
		Args['col_' .. total_row_name] = '#eee'
		team_list[N_teams] = Args['team' .. N_teams]
		team_list[Args['team'..N_teams]] = N_teams
	end

	-- Show position
	local position_col = yesno(Args['show_positions'] or 'yes') and true or false
	
	-- Show groups or note
	local group_col = yesno(Args['show_groups'] or 'no') and true or false

	-- Show match_table or not
	local match_table = yesno(Args['show_matches'] or 'no') and true or false
	local p_matches = match_table and 
		(style_def == 'Chess' and require('Модул:Sports results/'..style_def) or require('Модул:Sports results'))
	
	-- Custom position column label or note
	local pos_label = Args['postitle'] or '<abbr title="Позиция">Поз</abbr>'
	if position_col == false then pos_label = nil end
	
	-- Show status or not
	local show_status = yesno(Args['show_status'] or 'yes') and true or false

	-- Get VTE button text (but only for non-empty text)
	local VTE_text = ''
	if (template_name ~= '') then
		VTE_text = require('Модул:Navbar')._navbar({
			template_name,
			mini=1,
			style='float:right',
			brackets=1
		})
		
		-- remove the next part if https://en.wikipedia.org/w/index.php?oldid=832717047#Sortable_link_disables_navbar_links?
		-- is ever fixed
		if yesno(Args['sortable_table'] or 'no') then
			VTE_text = mw.ustring.gsub(VTE_text, '<%/?abbr[^<>]*>', ' ')
		end
	end
	
	-- Add source to title if specified and possible
	local title_source = false
	if Args['title'] and Args['title_source'] then
		Args['title'] = Args['title'] .. Args['title_source']
		title_source = true
	elseif Args['table_header'] and Args['table_header_source'] then
		Args['table_header'] = Args['table_header'] .. Args['table_header_source']
		title_source = true
	end

	-- Add a table anchor
	if table_anchor ~= '' then
		table.insert(t, '<span class="anchor" id="' .. table_anchor .. '"></span>\n')
	end

	-- Write column headers
	t_return = p_style.header(t,Args,p_sub,pos_label,group_col,VTE_text,full_table,results_header_txt)
	if match_table then
		-- Add empty column header
		t_return.count = t_return.count+1
		table.insert(t_return.tab_text,'! scope="row" class="unsortable" style="background-color:white;border-top:white;border-bottom:white;line-width:3pt;"| \n')
		
		-- Add rest of header
		t_return = p_matches.header(t_return,Args,p_sub,N_teams,team_list,tonumber(Args['legs']) or 1)
	end
	t = t_return.tab_text
	local N_cols = t_return.count
	
	-- Determine what entries go into table
	-- Find out which team to show (if any)
	local ii_show = team_list[Args['showteam'] or nil] -- nil if non-existant
	-- Start and end positions to show
	local n_to_show = tonumber(Args['show_limit']) or N_teams
	-- Check for "legal value", if not legal (or non declared), then show all
	local check_n = ((n_to_show>=(N_teams-top_pos+1)) or (n_to_show<=1) or (n_to_show~=math.floor(n_to_show)))
	-- Also check whether there is a valid ii_show
	if check_n or (not ii_show) then
		ii_start = top_pos
		ii_end = N_teams
	else
		-- It's a proper integer between top_pos+1 and N_teams-1
		-- If it is in the middle show the same number above and below
		-- If it is in the top or bottom, show the exact number
		-- How many to show on the side
		local n_show_side = math.floor(n_to_show/2)
		if (ii_show-top_pos+1)<=n_show_side then
			-- Top team
			ii_start = top_pos
			ii_end = top_pos+n_to_show-1
		elseif ii_show>=(N_teams+1-n_show_side) then
			-- Bottom team
			ii_start = N_teams+1-n_to_show
			ii_end = N_teams
		else
			-- Normal case
			ii_start = ii_show-n_show_side
			ii_end = ii_show+n_show_side
		end
	end
	
	-- For results column
	local new_res_ii = ii_start
	-- Pre-check for existence of column
	if not hide_results then
		for ii = ii_start, ii_end do
			if Args[respre..'result'..ii] and Args[respre..'text_' .. Args[respre..'result'..ii]] then results_defined = true end
		end
	end
	-- Remove results header if it is unused
	if full_table and not results_defined then
		-- First get it as one string, then use string replace to replace that header by empty string
		local t_str = tostring(table.concat(t))
		t_str = mw.ustring.gsub( t_str, results_header_txt, '' )
		N_cols = N_cols-1 -- There is actually one column less
		t = {}
		table.insert(t, t_str)
	end
	
	-- Write rows
	local team_name, team_code_ii, team_code_jj, pos_num, group_txt, note_local
	local note_string, note_local, note_local_num, note_id
	local note_id_list = {}
	local hth_id_list = {}
	for ii = ii_start, ii_end do
		-- First get code
		team_code_ii = team_list[ii]
		-- Now read values
		pos_num = Args['pos_'..team_code_ii]			or ii
		group_txt = Args['group_'..team_code_ii]		or ' '
		team_name = Args['name_'..team_code_ii]		 	or team_code_ii
		note_local = Args['note_'..team_code_ii] 		or nil
		
		-- Does it need a promotion/qualification/relegation tag
		local result_local = Args[respre..'result'..ii] or nil
		local bg_col = nil
		-- Get local background colour
		if result_local then
			bg_col = result_col[Args[respre..'col_'..result_local]] or Args[respre..'col_'..result_local] or 'inherit'
            if bg_col == 'inherit' then bg_col = bg_col .. '; color: inherit' end
			bg_col = 'background-color:'..bg_col..';' 	-- Full style tag
		end
		if not bg_col then bg_col = 'background-color:transparent; color: inherit;' end -- Becomes default if undefined
		
		-- Bold this line or not
		local ii_fw = ii == ii_show and 'font-weight: bold;' or 'font-weight: normal;'
		if yesno(Args['show_totals'] or 'no') and team_code_ii == total_row_name then
			ii_fw = 'font-weight: bold;'
		end
		
		-- Check whether there is a note or not, if so get text ready for it
		if note_local and full_table then
			-- Set global check for notes to true
			notes_exist = true
			-- There are now 3 options for notes
			-- 1) It is a full note
			-- 2) It is a referal to another note (i.e. it's just a team code; e.g. note_AAA=Text, note_BBB=AAA) in which the note for BBB should link to the same footnote as AAA, with
			-- 2a) The other linked note exist in the part of the table shown
			-- 2b) The part of the note does not exist in the part of the table shown
			if not Args['note_'..note_local] then
				-- Option 1
				-- Now define the identifier for this
				note_id = '"table_note_'..team_code_ii..rand_val..'"' -- Add random end for unique ID if more tables are present on article (which might otherwise share an ID)
				note_id_list[team_code_ii] = note_id
				
				-- Call refn template
				note_string = frame:expandTemplate{ title = 'efn', args = { group='lower-alpha',  name=note_id, note_local} }
			else 
				-- Option 2
				-- It is option 2a in either one if either the main note is inside the sub-table
				--                                  or another ref to that note is inside the sub-table
				-- Basically when it either has been defined, or the main link will be in the table
				note_local_num = team_list[note_local]
				if note_id_list[note_local] or ((note_local_num >= ii_start) and (note_local_num <= ii_end)) then
					-- Option 2a
					note_id = '"table_note_'..note_local..rand_val..'"'
					note_string = frame:extensionTag{ name = 'ref', args = { group = 'lower-alpha', name = note_id} }
				else
					-- Option 2b
					-- Now define the identifier for this
					note_id = '"table_note_'..note_local..rand_val..'"' -- Add random end for unique ID
					note_id_list[note_local] = note_id
					
					-- Call refn template
					note_string = frame:expandTemplate{ title = 'efn', args = { group='lower-alpha',  name=note_id, Args['note_'..note_local]} }
				end
			end
		else
			note_string = '';
		end
		
		-- Insert status when needed
		local status_string = ''
		local status_local = show_status and Args[respre .. 'status_'..team_code_ii] or nil
		local status_let_first = true
		local curr_letter
		-- Only if it is defined
		if status_local then
			-- Take it letter by letter
			for jjj = 1,mw.ustring.len(status_local) do
				curr_letter = mw.ustring.upper(mw.ustring.sub(status_local,jjj,jjj))
				-- See whether it exist
				if t_status.code[curr_letter] then
					-- Depending on whether it is the first letter of not
					if status_let_first then
						status_string = curr_letter
						t_status.called[curr_letter] = true
						status_let_first = false
					else
						status_string = status_string..', '..curr_letter
						t_status.called[curr_letter] = true
					end
				end
			end
			-- Only add brackets/dash and bolding if it exist
			if not status_let_first then 
				if t_status.position == 'before' then
					status_string = '<span style="font-weight:bold">'..string.lower(status_string)..' &ndash;</span> ' 
				else
					status_string = ' <span style="font-weight:bold">('..status_string..')</span>' 
				end
			end
		end
		
		-- Now build the rows
		if yesno(Args['show_totals'] or 'no') and team_code_ii == total_row_name then
			table.insert(t,'|- class="sortbottom"\n')											-- New row
		else
			table.insert(t,'|- \n')																-- New row
		end
		if position_col then
			table.insert(t,'| style="text-align: center;'..ii_fw..bg_col..'"| '..pos_num..'\n')	-- Position number
		end
		if full_table and group_col then
			table.insert(t,'| style="'..ii_fw..bg_col..'" |'..group_txt..'\n') 							-- Group number/name
		end
		-- Build the team string order based on status position
		local team_string
		if t_status.position == 'before' then
			team_string = status_string..team_name..note_string
		else
			team_string = team_name..note_string..status_string
		end
		table.insert(t,'! scope="row" style="text-align: left; white-space:nowrap;'..ii_fw..bg_col..'"| '..team_string..'\n')-- Team (with possible note)
		-- Call to subfunction
		t_return = p_style.row(frame,t,Args,p_sub,notes_exist,hth_id_list,full_table,rand_val,team_list,team_code_ii,ii_start,ii_end,ii_fw,bg_col,N_teams,ii,ii_show)
		t = t_return.t
		notes_exist = t_return.notes_exist
		hth_id_list = t_return.hth_id_list
		
		-- Now check what needs to be added inside the results column
		if full_table then
			local res_jjj
			if ii == new_res_ii then
				-- First check how many rows you need for this
				N_rows_res = 1
				jjj = ii+1
				result_local = Args[respre..'result'..ii] or ''
				local cont_loop = true
				while (jjj<=ii_end) and cont_loop do
					if Args['split'..tostring(jjj-1)] then
						cont_loop = false
						new_res_ii = jjj
					else
						res_jjj = Args[respre..'result'..jjj] or ''
						if result_local == res_jjj then 
							N_rows_res = N_rows_res+1 
						else
							cont_loop = false
							new_res_ii = jjj
						end
					end
					jjj = jjj+1
				end
				-- Now create this field (reuse ii_fw and bg_col)
				-- Bold (if in range) or not
				if ii_show and (ii_show>=ii) and (ii_show<=(ii+N_rows_res-1)) then
					ii_fw = 'font-weight: bold;'
				else
					ii_fw = 'font-weight: normal;'
				end
				-- Get background colour
				bg_col = nil
				if Args[respre..'result'..ii] then
					bg_col = result_col[Args[respre..'col_'..result_local]] or Args[respre..'col_'..result_local] or 'inherit'
					if bg_col == 'inherit' then bg_col = bg_col .. '; color: inherit' end
					bg_col = 'background-color:'..bg_col..';' 	-- Full style tag
				end
				if not bg_col then bg_col = 'background-color:transparent; color: inherit;' end -- Becomes default if undefined
				-- Check for notes
				local note_res_string, note_ref, note_text = '', '', ''
				if Args['note_res_'..result_local] then
					notes_exist = true
					local note_res_local = Args['note_res_'..result_local]
					
					-- Split the note_res_local into a table if all the entries are valid
					local multiref = 1
					local note_res_local_table = mw.text.split(note_res_local, '%s*,%s*')
					if (#note_res_local_table > 1) then
						for k, note_res_loc in ipairs(note_res_local_table) do
							multiref = multiref * (Args['note_res_' .. note_res_loc] and 1 or 0)
						end
					else
						multiref = 0
					end

					-- Split failed, so make a single entry table with hth_local inside
					if multiref < 1 then
						note_res_local_table = { note_res_local }
					end

					for k,note_res_local in ipairs(note_res_local_table) do
						if not Args['note_res_'..note_res_local] then
							-- It does not point to another result note
							note_ref = respre..'res_'..result_local
							note_id = '"table_note_res_'..result_local..rand_val..'"' -- Identifier
							note_text = note_res_local
						else
							-- It does point to another result note
							note_ref = respre..'res_'..note_res_local
							note_id = '"table_note_res_'..note_res_local..rand_val..'"' -- Identifier
							note_text = Args['note_res_'..note_res_local]
						end
						-- Check whether it is already printed
						if not note_id_list[note_ref] then
							-- Print it
							note_id_list[note_ref] = note_id
							note_res_string = note_res_string .. frame:expandTemplate{ title = 'efn', args = { group='lower-alpha',  name=note_id, note_text} }
						else
							-- Refer to it
							note_res_string = note_res_string .. frame:extensionTag{ name = 'ref', args = { group = 'lower-alpha', name = note_id} }
						end
					end
				end
				-- Get text
				local text_result = Args[respre..'text_'..result_local] or ''
				if text_result:match('fbmulticomp') then
					ii_fw = 'padding:0;' .. ii_fw
					if text_result:match('fbmulticompefn') then
						notes_exist = true
					end
				end
				text_field_result = '| style="'..ii_fw..bg_col..'" rowspan="'..tostring(N_rows_res)..'" |'..text_result..note_res_string..'\n'
				-- See whether it is needed (only when blank for all entries)
				if results_defined then table.insert(t,text_field_result) end
			end
		end
	
		-- Insert match row if needed
		if match_table then
			local legs = tonumber(Args['legs']) or 1
			-- Add empty cell
			table.insert(t,'| style="background-color:white;border-top:white;border-bottom:white;"| \n')
			
			-- Now include note to match results if needed 
			for jj=top_pos,N_teams do
				team_code_jj = team_list[jj]
				if ii == jj then
					-- Nothing
				else
					for l=1,legs do
						local m = (legs == 1) and 'match_' or 'match' .. l .. '_'
						local match_note = Args[m..team_code_ii..'_'..team_code_jj..'_note']
						if match_note then
							notes_exist = true
							-- Only when it exist
							-- First check for existence of reference for note
							if not (Args['note_'..match_note] or Args[m..match_note..'_note']) then
								-- It's the entry
								note_id = '"table_note_'..team_code_ii..'_'..team_code_jj..rand_val..'"' -- Add random end for unique ID if more tables are present on article (which might otherwise share an ID)
								note_id_list[team_code_ii..'_'..team_code_jj] = note_id
								
								note_string = frame:expandTemplate{ title = 'efn', args = { group='lower-alpha', name=note_id,  match_note} }
							else 
								-- Check for existence elsewhere
								note_local_num = team_list[match_note] or ii_end + 1
								if note_id_list[match_note] or ((note_local_num >= ii_start) and (note_local_num <= ii_end)) then
									-- It exists
									note_id = '"table_note_'..match_note..rand_val..'"' -- Identifier
									note_string = frame:extensionTag{ name = 'ref', args = { group = 'lower-alpha', name = note_id} }
								else
									-- Now define the identifier for this
									note_id = '"table_note_'..match_note..rand_val..'"' -- Add random end for unique ID
									note_id_list[match_note] = note_id
									-- Call refn template
									note_string = frame:expandTemplate{ title = 'efn', args = { group='lower-alpha', name=note_id, Args['note_'..match_note]} }
								end
							end

							-- Now append this to the match result string
							Args[m..team_code_ii..'_'..team_code_jj] = (Args[m..team_code_ii..'_'..team_code_jj] or '')..note_string
						end
					end
				end
			end
			
			-- Add rest of match row
			t = p_matches.row(t,Args,N_teams,team_list,ii,ii_show,legs)
		end
	
		-- Now, if needed, insert a split (solid line to indicate split in standings, but only when it is not at the last shown position)
		if Args['split'..ii] and (ii<ii_end) then
			-- Base size on N_cols (it needs 2*N_cols |)
			table.insert(t,'|- style="background-color:'..result_col['black1']..'; line-height:3pt;"\n')
			table.insert(t,string.rep('|',2*N_cols)..'\n')
		end
	end
	
	-- Close table
	table.insert(t, '|}')
	
	-- Get info for footer
	local update = Args['update']			or '(датата е неизвестна)'
	local start_date = Args['start_date'] 	or '(датата е неизвестна)'
	local source = Args['source']			or (title_source == true and '')
		or frame:expandTemplate{ title = 'липсва източник', args = { reason='Липсва зададен източник', date=os.date('%B %Y') } }
	local class_rules = Args['class_rules']	or nil
	
	-- Create footer text
	-- Date updating
	local matches_text = Args['matches_text'] or 'match(es)'
	if string.lower(update)=='приключил' or hide_footer then
		-- Do nothing
	elseif update=='' then
		-- Empty parameter
		table.insert(t_footer,'Обновен до '..matches_text..', игран на. ')
	elseif string.lower(update)=='future' then
		-- Future start date
		table.insert(t_footer,'Първите срещи ще се изиграят на '..start_date..'. ')
	else
		table.insert(t_footer,'Обновен до '..matches_text..', игран на '..update..'. ')
	end
	
	-- Stack footer or not
	local footer_break = yesno(Args['stack_footer'] or 'no') and true or false
	
	-- Variable for linebreak
	local stack_string = '<br>'
	
	if footer_break and (not (string.lower(update)=='complete')) and not hide_footer then table.insert(t_footer,stack_string) end
	
	if source ~= '' and not hide_footer then
		table.insert(t_footer,'Източник: '..source)
	end
	if class_rules and full_table and show_class_rules and not hide_footer then
		if (#t_footer > 0) then table.insert(t_footer,'<br>') end
		table.insert(t_footer,'Правила за класиране: '..class_rules)
	end
	
	-- Now for the named status
	local status_exist = false
	local status_string = ''
	local curr_letter
	for jjj = 1,mw.ustring.len(t_status.letters) do
		curr_letter = mw.ustring.upper(mw.ustring.sub(t_status.letters,jjj,jjj))
		if t_status.called[curr_letter] then
			if (footer_break and status_exist) then
				status_string = status_string..stack_string
			end
			if t_status.position == 'before' then
				status_string = status_string..'<span style="font-weight:bold">'..string.lower(curr_letter)..' &ndash;</span> '..t_status.code[curr_letter]..'; '
			else
				status_string = status_string..'<span style="font-weight:bold">('..curr_letter..')</span> '..t_status.code[curr_letter]..'; '
			end
			status_exist = true
		end
	end
	-- Now if it contains entries the '; ' needs to be removed
	if status_exist and not hide_footer then
		if (#t_footer > 0) then table.insert(t_footer,'<br>') end
		status_string = mw.ustring.sub(status_string,1,mw.ustring.len(status_string)-2)
		table.insert(t_footer,status_string)
	end
	
	-- Add notes (if applicable)
	if notes_exist then
		if (#t_footer > 0) then table.insert(t_footer,'<br>') end
		table.insert(t_footer,'Бележки:')
		-- As reflist size text
		t_footer = '<div class="sports-table-notes">'..table.concat(t_footer)..'</div>'
		t_footer = t_footer..frame:expandTemplate{ title = 'Коментари', args = { group='lower-alpha'} }
	else
		-- As reflist size text
		t_footer = '<div class="sports-table-notes">'..table.concat(t_footer)..'</div>'
	end
	
	-- Add footer to main text table
	table.insert(t,t_footer)
	
	-- Rewrite anchor links
	for k=1,#t do
		if t[k]:match('%[%[#[^%[%]]*%|') then
			t[k] = mw.ustring.gsub(t[k], '(%[%[)(#[^%[%]]*%|)', '%1' .. baselink .. '%2')
		end
	end
	
	-- Generate tracking
	if not Args['notracking'] then
		local getTracking = require('Модул:Sports table/argcheck').check
		local warning_categories, tracking_categories = getTracking(Args, frame:getParent().args)
		if #warning_categories > 0 then
			if frame:preprocess( "{{REVISIONID}}" ) == "" then
				for k=1,#warning_categories do
					warning_categories[k] = mw.ustring.gsub(warning_categories[k], '^%[%[Категория:Страници използващи спортни таблици с (.*)|(.*)%]%]$', '<div style="color:red">Предупреждение: %1 = %2</div>')
				end
			end
		end
		for k=1,#warning_categories do
				table.insert(t, warning_categories[k])
		end
		for k=1,#tracking_categories do
				table.insert(t, tracking_categories[k])
		end
		
		if(Args['showteam'] == nil) then
			local getWarnings = require('Модул:Sports table/totalscheck').check
			local total_warnings = getWarnings(Args, team_list, ii_start, ii_end)
			if #total_warnings > 0 then
				if frame:preprocess( "{{REVISIONID}}" ) == "" then
					for k=1,#total_warnings do
						table.insert(t, '<div style="color:green">Възможен проблем: ' .. total_warnings[k] .. '</div>')
					end
				end
			end
		end
	else
		table.insert(t, '[[Категория:Страници използващи без трейсинг]]')
	end
	
	if Args['float'] then
		return frame:expandTemplate{ title = 'stack begin', args = {clear = 'true', margin = '1', float = Args['float']} }
			.. templatestyles .. '\n' .. table.concat(t) .. frame:expandTemplate{ title = 'stack end'}
	end

	return templatestyles .. '\n' .. table.concat(t)
end
 
return p
