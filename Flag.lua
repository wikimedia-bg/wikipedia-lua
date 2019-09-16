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
        image = wd._property({"raw", qid, "P41", date=time});
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
