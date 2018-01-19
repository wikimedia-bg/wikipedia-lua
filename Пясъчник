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

local function flagAtTime(flagliststr, time)
        local flaglist = mw.text.split(flagliststr, ";");
        local flagitemstr = "";
        local flagitem = {};

	for i, j in pairs(flaglist) do
          flagitemstr = mw.text.trim(j);
          if (flagitemstr ~= '') then
            flagitem = mw.text.split(flagitemstr, "/");
            for key, value in pairs(flagitem) do
              flagitem[key] = mw.text.trim(value);
            end
            if ((flagitem[2] == nil) or (flagitem[2] == '')) then
              flagitem[2] = '0000-00-00';
            end
            if ((flagitem[3] == nil) or (flagitem[3] == '')) then
              flagitem[3] = '9999-99-99';
            end
            if ((time >= flagitem[2]) and (time <= flagitem[3])) then
              return flagitem[1]
            end
          end
	end

	return '';
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
      local image = '';
      if (link == '') then
        link = wd._title({qid});
      end

      if ((time ~= nil) and (time ~= '')) then
        image = flagAtTime(wd._properties({"raw", "qualifier", "raw", "qualifier", "raw", "normal+", qid, "P41", "P580", "P582", format="%p/[%q1]/[%q2];"}), time);
      end
      if (image == '') then
        image = wd._property({"raw", qid, "P41"});
      end
  
      return '<span class="flagicon">' ..
                '[[Файл:' .. image .. '|' .. width ..'px|border|' .. 'link='..link..'|'..link ..']]' ..
            '</span>';
    end;
    return '';
end

return flag