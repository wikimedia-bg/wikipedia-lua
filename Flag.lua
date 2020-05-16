flag = {};

local wd = require("Модул:Wd");

local gdata;
local success, resultat = pcall (mw.loadData, "Модул:Flag/Data" );
if success then
    gdata = resultat;
else
    gdata={};
    gdata.qidByName={};
    gdata.qidByIso={};
end

function flag.getqid(key)
    local qid = nil;

    if(#key==3) then
      qid = gdata.qidByIso[key];
      if(qid~=nil) then
        qid = 'Q' .. qid;
      end;
    end;

    if((qid==nil) and (key:sub(1,1) == 'Q')) then
      qid = key;
    end

    return qid;
end

-- TODO: трябва да се слее с flag с допълнителни параметри, които да поддържат Шаблон:Флагче с ISO, Шаблон:Флагче с име, Шаблон:Флагче+
function flag.flagwithiso(frame)
    local qid = nil;
    local subject = mw.text.trim(frame.args[1]);
    local time = mw.text.trim(frame.args[2]);
    local width = mw.text.trim(frame.args[3]);
    local link = '';

    qid = gdata.qidByName[mw.ustring.lower(subject)];
    if(qid~=nil) then
      qid = 'Q' .. qid;
      link = subject;
    else
      qid = flag.getqid(subject);
    end

    if(qid~=nil) then
      local image = '';
      if (link == '') then
        link = wd._title({qid});
      end

      if ((time ~= nil) and (time ~= '')) then
        image = wd._property({"raw", qid, "P41", date=time});
      end
      if (image == '') then
        image = wd._property({"raw", qid, "P41"});
      end
  
      return '<span class="flagicon">' ..
                '[[Файл:' .. image .. '|' .. width ..'px|border|' .. 'link='..link..'|'..link ..']]&nbsp;[[' .. link .. '|' .. subject .. ']]' ..
            '</span>';
    end;
    return '';
end

function getrank(rankstring) 
    if rankstring == 'preferred' then
        return 2
    elseif rankstring == 'normal' then
        return 1
    else
        return 0
    end;
end

function parseDate(dateStr, precision)
	precision = precision or "d"
	
	local i, j, index, ptr
	local parts = {nil, nil, nil}
	
	if dateStr == nil then
		return parts[1], parts[2], parts[3]  -- year, month, day
	end
	
	-- 'T' for snak values, '/' for outputs with '/Julian' attached
	i, j = dateStr:find("[T/]")
	
	if i then
		dateStr = dateStr:sub(1, i-1)
	end
	
	local from = 1
	
	if dateStr:sub(1,1) == "-" then
		-- this is a negative number, look further ahead
		from = 2
	end
	
	index = 1
	ptr = 1
	
	i, j = dateStr:find("-", from)
	
	if i then
		-- year
		parts[index] = tonumber(mw.ustring.gsub(dateStr:sub(ptr, i-1), "^\+(.+)$", "%1"), 10)  -- remove '+' sign (explicitly give base 10 to prevent error)
		
		if parts[index] == -0 then
			parts[index] = tonumber("0")  -- for some reason, 'parts[index] = 0' may actually store '-0', so parse from string instead
		end
		
		if precision == "y" then
			-- we're done
			return parts[1], parts[2], parts[3]  -- year, month, day
		end
		
		index = index + 1
		ptr = i + 1
		
		i, j = dateStr:find("-", ptr)
		
		if i then
			-- month
			parts[index] = tonumber(dateStr:sub(ptr, i-1), 10)
			
			if precision == "m" then
				-- we're done
				return parts[1], parts[2], parts[3]  -- year, month, day
			end
			
			index = index + 1
			ptr = i + 1
		end
	end
	
	if dateStr:sub(ptr) ~= "" then
		-- day if we have month, month if we have year, or year
		parts[index] = tonumber(dateStr:sub(ptr), 10)
	end
	
	return parts[1], parts[2], parts[3]  -- year, month, day
end

function datePrecedesDate(aY, aM, aD, bY, bM, bD)
	if aY == nil or bY == nil then
		return nil
	end
	aM = aM or 1
	aD = aD or 1
	bM = bM or 1
	bD = bD or 1
	
	if aY < bY then
		return true
	end
	
	if aY > bY then
		return false
	end
	
	if aM < bM then
		return true
	end
	
	if aM > bM then
		return false
	end
	
	if aD < bD then
		return true
	end
	
	return false
end

function getqt(statement, p)
    if (statement['qualifiers'] == nil) or 
       (statement['qualifiers'][p] == nil) or 
       (statement['qualifiers'][p][1]['datavalue'] == nil) then
        return nil
    else
        return statement['qualifiers'][p][1]['datavalue']['value']['time'];
    end;
end;

function indaterange(aY, aM, aD, startTime, endTime)
	local sY = nil
	local sM = nil
	local sD = nil
	local eY = nil
	local eM = nil
	local eD = nil
	local now = os.date('!*t')

	if aY == nil then
		aY = now['year']
	end
	if aM == nil then
		aM = now['month']
	end
	if aD == nil then
		aD = now['day']
	end
	
	if startTime and startTime ~= "" and startTime ~= " " then
		sY, sM, sD = parseDate(startTime)
	end
	if endTime and endTime ~= "" and endTime ~= " " then
		eY, eM, eD = parseDate(endTime)
	elseif endTime == " " then
		-- end time is 'unknown', assume it is somewhere in the past;
		-- we can do this by taking the current date as a placeholder for the end time
		eY = now['year']
		eM = now['month']
		eD = now['day']
	end
	
	if sY ~= nil and eY ~= nil and datePrecedesDate(eY, eM, eD, sY, sM, sD) then
		-- invalidate end time if it precedes start time
		eY = nil
		eM = nil
		eD = nil
	end

	if (sY == nil or not datePrecedesDate(aY, aM, aD, sY, sM, sD)) and
	   (eY == nil or datePrecedesDate(aY, aM, aD, eY, eM, eD)) then
		return true
	end

	return false
end

function getflagimage(qid, time)
    statements = mw.wikibase.getAllStatements( qid, 'P41' )
    if next(statements) == nil then
       return ''
    end;
    aY, aM, aD = parseDate(time);
    
    local fi = statements[1]['mainsnak']['datavalue']['value'];
    local rank = getrank(statements[1]['rank']);
    local inrange = indaterange(aY, aM, aD, getqt(statements[1], 'P580'), getqt(statements[1], 'P582'));
    local i = 2;
    while i <= table.getn(statements) do
        if indaterange(aY, aM, aD, getqt(statements[i], 'P580'), getqt(statements[i], 'P582')) then
            if not inrange then
                fi = statements[i]['mainsnak']['datavalue']['value'];
                rank = getrank(statements[i]['rank']);
                inrange = true;
            else
                r = getrank(statements[i]['rank']);
                if r > rank then
                    rank = r;
                    fi = statements[i]['mainsnak']['datavalue']['value'];
                end;
            end;
        end;
        i = i + 1;
    end;

    return fi
end

function formatimage(qid, time, width, link)
    local image = '';
    if (link == '') then
      link = wd._title({qid});
    end

    image = getflagimage(qid, time);
 
    return '<span class="flagicon">' ..
              '[[Файл:' .. image .. '|' .. width ..'px|border|' .. 'link='..link..'|'..link ..']]' ..
          '</span>';
end

function flag.flag(frame)
    local qid = nil;
    local subject = mw.text.trim(frame.args[1]);
    local time = mw.text.trim(frame.args[2]);
    local width = mw.text.trim(frame.args[3]);
    local link = '';

    qid = gdata.qidByName[mw.ustring.lower(subject)];
    if(qid~=nil) then
      qid = 'Q' .. qid;
      link = subject;
    else
      qid = flag.getqid(subject);
    end

    if(qid~=nil) then
      return formatimage(qid, time, width, link);
    end;
    return '';
end

return flag
