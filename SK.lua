local sk = {}

sk.error_place="Непознато място."
sk.error_code="Неизвестен код."
sk.decimal_separator=","
sk.thousands_separator=" "

function sk.get_nuts_lua()
	local place_info
	local nuts_lau
	
	code=mw.wikibase.getEntityIdForCurrentPage()
	if code == nil then
		return nill
	end
	
	-- Source of 2 codes: https://commons.wikimedia.org/w/index.php?title=Data:Statistics_of_Slovak_supmunicipalities.tab&oldid=1001162094
	if code == "Q1780"  then return "SK_CAP"	  end
	if code == "Q25409" then return "SK0422_0425" end
	
	if code == "Q214"   then return "SK0" end
	if code == "SK"     then return "SK0" end
	
	while 1 do
		place_info=mw.wikibase.getBestStatements(code,"P605")
		if place_info[1] == nil then
			break
		end
		nuts_lau=place_info[1]["mainsnak"]['datavalue']['value']
		if nuts_lau == nil then
		else
			return nuts_lau
		end
		break
	end
	
	while 1 do
		place_info=mw.wikibase.getBestStatements(code,"P782")
		if place_info[1] == nil then
			break
		end
		nuts_lau=place_info[1]["mainsnak"]['datavalue']['value']
		if nuts_lau == nil then
		else
			return nuts_lau
		end
		break
	end
	
	return nil
end

function sk.is_slovak(args)
	local nuts_lau=args.args[1]
	if nuts_lau == nil or nuts_lau == "" then
		nuts_lau=sk.get_nuts_lua()
		if nuts_lau == nill then
			return ""
		end
	end
	
	if string.sub(nuts_lau, 1, 2) == "SK" then
		return "1"
	end
	return ""
end

function sk.localised_number(number)
	local number2
	local offset
	local offset_end
	local first
	local second
	local first_length
	local Output

	number2=tostring(number)
	offset, offset_end=string.find(number2, "%.")
	if offset == nill then
		first=number
		second=""
	else
		first=string.sub(number2, 1, offset-1)
		second=sk.decimal_separator..string.sub(number2, offset+1, offset+2)
	end

	if first == nill then
		first=""
	end
	
	first_length=string.len(first)

	if(first_length <= 4) then
		return first..second
	end

	Output=string.sub(first, -3, -1)

	if(first_length > 3) then
		Output=string.sub(first, -6, -4)..sk.thousands_separator..Output
	end
	if(first_length > 6) then
		Output=string.sub(first, -9, -7)..sk.thousands_separator..Output
	end
	if(first_length > 9) then
		Output=string.sub(first, -12, -10)..sk.thousands_separator..Output
	end

	if second == nil then
		return Output
	else
		return Output..second
	end
end

function sk.localised_number_strict(number) -- NNNN is as N.NNNN
	local number2
	local offset
	local offset_end
	local first
	local second
	local first_length
	local Output

	number2=tostring(number)
	offset, offset_end=string.find(number2, "%.")
	if offset == nill then
		first=number
		second=""
	else
		first=string.sub(number2, 1, offset-1)
		second=sk.decimal_separator..string.sub(number2, offset+1, offset+2)
	end

	first_length=string.len(first)

	if(first_length <= 3) then
		return first..second
	end

	Output=string.sub(first, -3, -1)

	if(first_length > 3) then
		Output=string.sub(first, -6, -4)..sk.thousands_separator..Output
	end
	if(first_length > 6) then
		Output=string.sub(first, -9, -7)..sk.thousands_separator..Output
	end
	if(first_length > 9) then
		Output=string.sub(first, -12, -10)..sk.thousands_separator..Output
	end

	if second == nil then
		return Output
	else
		return Output..second
	end
end

function sk.delta_progress(count_a, count_b) -- count_a < count_b
	if count_a == 0 or count_b == 0 then
		return "–"
	end
	
	local value
	
	value=tostring(count_b/(count_a/100)-100)
	if string.sub(value, 1, 1) == "-" then
		value_string=string.sub(value, 2)
		value="-"..sk.localised_number(value_string).." %"
	else
		value="+"..sk.localised_number(value).." %"
	end
	return value
end

function sk.get_line_data(data, nuts_lau)
	index=1
	while 1 do
		item=data.data[index]
		if item == nil then
			break
		end
		if item[1] == nuts_lau then
			break
		end
		index=index+1
	end
	
	if item == nil then
		error(sk.error_place)
	end
	
	return item
end

function sk.constant_code(code)
	if code == nil then
		return nil
	end
	
	if string.len(code) == 2 then
		-- Source of 2 codes: https://commons.wikimedia.org/w/index.php?title=Data:Statistics_of_Slovak_supmunicipalities.tab&oldid=1001162094
		if code == "BA"     then return "SK_CAP"      end
		if code == "KE"     then return "SK0422_0425" end
		
		if code == "SK"     then return "SK0" end
	end
	return code
end

-- Reference data are for population
function sk.population_table(args)
	local style=args.args[1] -- format
	local nuts_lau=args.args[2]  -- nuts / LAU, default: automatic
	local count_years
	local count_years_stop
	local data
	local head
	local index
	local item
	local i_start
	local i_end
	local text
	local one_step_year
	local one_step_values
	local value
	local value_string
	local year
	local years={}
	
	nuts_lau=sk.constant_code(nuts_lau)
	
	-- get NUTS/LUA for page
	if nuts_lau == nil or nuts_lau == "" then
		nuts_lau=sk.get_nuts_lua()
		if nuts_lau == nill then
			return ""
		end
	end

	-- select date line
	if string.len(nuts_lau) == 12 then
		data=mw.ext.data.get("Population statistic of Slovak municipalities (some years).tab")
	else
		data=mw.ext.data.get("Population statistic of Slovak supmunicipalities (some years).tab")
	end

	-- get years
	head=""
	text=data.sources
	i_start, i_end=string.find(text, "years: ")
	offset=i_start+7
	count_years=0
	while 1 do 
		year=string.sub(text, offset, offset+3)
		count_years=count_years+1
		years[count_years]=year
		if string.sub(text, offset+4, offset+4) == " " then
		    offset=offset+7
			break
		end
		offset=offset+6
	end
	year=string.sub(text, offset, offset+3)
	count_years=count_years+1
	years[count_years]=year
	count_years_stop=count_years+1
	
	head=""
	for i=2,count_years_stop do
		year_index=i-1
		while 1 do 
			if year_index+1 < count_years_stop then
				if (years[year_index]-years[year_index+1]) == -1 then
					break
				end
			end
			head=head.."<th>"..years[year_index]..".</th>"
			break
		end
	end
	
	if style == "h" then
		return head
	end

	-- values
	item=sk.get_line_data(data, nuts_lau)
	if item == nil then
		error(sk.error_place)
	end
	-- get values
	content=""
	
	if style == "d" or style == "Y" or style == "V" or style == "P" then
		one_step_year=""
		one_step_values=""
		one_step_progress=""
		
		content="<td></td>\n"
		for i=3,count_years_stop do
			year_index=i-1
			while 1 do
				-- check the first item with delta = 1
				if year_index+1 < count_years_stop then
					if (years[year_index]-years[year_index+1]) == -1 then
						one_step_year=one_step_year.."<th>"..years[year_index]..".</th>"
						one_step_values=one_step_values.."<td>"..sk.localised_number(item[i]).."</td>"
						one_step_progress=one_step_progress.."<td></td>"
						break
					end
				end
				
				-- check the second item with delta = 1
				if year_index > 1 then
					if (years[year_index]-years[year_index-1]) == 1 then
						one_step_year=one_step_year.."<th>"..years[year_index]..".</th>"
						one_step_values=one_step_values.."<td>"..sk.localised_number(item[i]).."</td>"
						one_step_progress=one_step_progress.."<td>"..sk.delta_progress(item[i-1], item[i]).."</td>"
						
						content=content.."<td>"..sk.delta_progress(item[i-2], item[i]).."</td>\n"
						break
					end
				end
				
				content=content.."<td>"..sk.delta_progress(item[i-1], item[i]).."</td>\n"
				break
			end
		end
		
		if style == "Y" then
			return one_step_year
		end
		if style == "V" then
			return one_step_values
		end
		if style == "P" then
			return one_step_progress
		end

		
		return content
	end
	
	content=""
	for i=2,count_years_stop do
		year_index=i-1
		while 1 do 
			if year_index+1 < count_years_stop then
				if (years[year_index]-years[year_index+1]) == -1 then
					break
				end
			end
			content=content.."<td>"..sk.localised_number(item[i]).."</td>"
			break
		end
	end
		
	return content
end

function sk.sk(args)
	local style=args.args[1] -- format
	local nuts_lau=args.args[2]  -- nuts / LAU, default: automatic
	local code
	local data
	local index
	local info
	local item
	local i_start
	local i_start2
	local i_end
	local last_acces
	local last_update
	local place_info
	local url_population
	local url_area
	local year
	
	-- select date line
	
	nuts_lau=sk.constant_code(nuts_lau)
	
	if nuts_lau == nil or nuts_lau == "" then
		nuts_lau=sk.get_nuts_lua()
		if nuts_lau == nill then
			return ""
		end
	end
	
	if style == "i" then
		local parameters={args={nuts_lau}}
		return sk.is_slovak(parameters)
	end
	
	if style == "e" then
		i_start, i_end=string.find(nuts_lau, "_")
		if i_start == nil then
			return nuts_lau
		else
			return ""
		end
	end

	-- select date line
	if string.len(nuts_lau) == 12 then
		data=mw.ext.data.get("Statistics of Slovak municipalities.tab")
	else
		data=mw.ext.data.get("Statistics of Slovak supmunicipalities.tab")
	end
	
	-- get NUTS/LUA for page
	if style == "l" or style == "u" or style == "y" then
	else
		item=sk.get_line_data(data, nuts_lau)
		
		if item == nil then
			error(sk.error_place)
		end
	end
	
	
	-- year
	i_start, i_end=string.find(data.sources, "year: ")
	year=string.sub(data.sources, i_start+6, i_start+9)
	
	-- last acces
	i_start, i_end=string.find(data.sources, "acces: ")
	if i_start == nil then
		i_start, i_end=string.find(data.sources, "access: ")
		last_acces=string.sub(data.sources, i_start+8, i_start+17)
	else
		last_acces=string.sub(data.sources, i_start+7, i_start+16)
	end
	
	
	-- last update
	i_start, i_end=string.find(data.sources, "update: ")
	last_update=string.sub(data.sources, i_start+8, i_start+17)
	
	-- url_population
	i_start, i_end=string.find(data.sources, "http")
	i_start2, i_end=string.find(string.sub(data.sources, i_start), " ")
	i_start2=i_start+i_start2-1
	url_population=string.sub(data.sources, i_start, i_start2)
	
	-- url_area
	i_start, i_end=string.find(data.sources, "http")
	info=string.sub(data.sources, i_start+1)
	i_start, i_end=string.find(info, "http")
	i_start2, i_end=string.find(string.sub(info, i_start), " ")
	i_start2=i_start+i_start2-1
	url_area=string.sub(info, i_start, i_start2)
	
	-- population_id
	i_start, i_end=string.find(url_population, "/vbd_dem/")
	info=string.sub(url_population, i_start+9)
	i_start, i_end=string.find(info, "/")
	population_id=string.sub(info, 1, i_start-1)
	
	-- area_id
	i_start, i_end=string.find(url_area, "/vbd_dem/")
	info=string.sub(url_area, i_start+9)
	i_start, i_end=string.find(info, "/")
	area_id=string.sub(info, 1, i_start-1)
	
	-- render
	i_start, i_end = string.find(style, "%%")
	if i_start == nil then
		if style == "p" then return sk.localised_number(item[2]) end
		if style == "P" then return url_population end
		if style == "o" then return sk.localised_number_strict(item[2]) end
		if style == "a" then return sk.localised_number(item[3]) end
		if style == "A" then return url_area end
		if style == "d" then return sk.localised_number(item[2]/item[3]) end
		if style == "y" then return year end
		if style == "l" then return last_acces end
		if style == "u" then return last_update end
		if style == "r" then return population_id end
		if style == "b" then return area_id end
		error(sk.error_code)
	else
		Output=style
		Output=string.gsub(Output, "%%p", sk.localised_number(item[2]))
		Output=string.gsub(Output, "%%P", url_population)
		Output=string.gsub(Output, "%%a", sk.localised_number(item[3]))
		Output=string.gsub(Output, "%%o", sk.localised_number_strict(item[2]))
		Output=string.gsub(Output, "%%A", url_area)
		Output=string.gsub(Output, "%%d", sk.localised_number(item[2]/item[3]))
		Output=string.gsub(Output, "%%y", year)
		Output=string.gsub(Output, "%%l", last_acces)
		Output=string.gsub(Output, "%%u", last_update)
		Output=string.gsub(Output, "%%r", population_id)
		Output=string.gsub(Output, "%%b", area_id)
		
		return Output
	end
end

return sk
