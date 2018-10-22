-- Inputs:
--    image - Can either be a bare filename (with or without the File:/Image: prefix) or a fully formatted image link
--    size - size to display the image
--    maxsize - maximum size for image
--    sizedefault - default size to display the image if size param is blank
--    alt - alt text for image
--    title - title text for image
--    border - set to yes if border
--    center - set to yes, if the image has to be centered
--    upright - upright image param
--    suppressplaceholder - if yes then checks to see if image is a placeholder and suppresses it
-- Outputs:
--    Formatted image.
-- More details available at the "Module:InfoboxImage/doc" page

local i = {};

local placeholder_image = {
    "Blue - Replace this image female.svg",
    "Blue - Replace this image male.svg",
    "Female no free image yet.png",
    "Flag of None (square).svg",
    "Flag of None.svg",
    "Flag of.svg",
    "Green - Replace this image female.svg",
    "Green - Replace this image male.svg",
    "Image is needed female.svg",
    "Image is needed male.svg",
    "Location map of None.svg",
    "Male no free image yet.png",
    "Missing flag.png",
    "No flag.svg",
    "No free portrait.svg",
    "No portrait (female).svg",
    "No portrait (male).svg",
    "Red - Replace this image female.svg",
    "Red - Replace this image male.svg",
    "Replace this image female (blue).svg",
    "Replace this image female.svg",
    "Replace this image male (blue).svg",
    "Replace this image male.svg",
    "Silver - Replace this image female.svg",
    "Silver - Replace this image male.svg",
}

function i.IsPlaceholder(image)
    -- change underscores to spaces
    image = mw.ustring.gsub(image, "_", " ");
    -- if image starts with [[ then remove that and anything after |
    if mw.ustring.sub(image,1,2) == "[[" then
        image = mw.ustring.sub(image,3);
        image = mw.ustring.gsub(image, "([^|]*)|.*", "%1");
    end
    -- Trim spaces
    image = mw.ustring.gsub(image, '^[ ]*(.-)[ ]*$', '%1');
    -- remove file: or image: prefix if exists
    if mw.ustring.lower(mw.ustring.sub(image,1,5)) == "file:" then
        image = mw.ustring.sub(image,6);
    end
    if mw.ustring.lower(mw.ustring.sub(image,1,6)) == "image:" then
        image = mw.ustring.sub(image,7);
    end
    -- Trim spaces
    image = mw.ustring.gsub(image, '^[ ]*(.-)[ ]*$', '%1');
    -- capitalise first letter
    image = mw.ustring.upper(mw.ustring.sub(image,1,1)) .. mw.ustring.sub(image,2);

    for i,j in pairs(placeholder_image) do
        if image == j then
            return true
        end
    end
    return false
end

function i.InfoboxImage(frame)
    local image = frame.args["image"];
    
    if image == "" or image == nil then
        return "";
    end
    if image == "&nbsp;" then
        return image;
    end
    if frame.args["suppressplaceholder"] == "yes" then
        if i.IsPlaceholder(image) == true then
            return "";
        end
    end

    if mw.ustring.lower(mw.ustring.sub(image,1,5)) == "http:" then
        return "";
    end
    if mw.ustring.lower(mw.ustring.sub(image,1,6)) == "[http:" then
        return "";
    end
    if mw.ustring.lower(mw.ustring.sub(image,1,7)) == "[[http:" then
        return "";
    end
    if mw.ustring.lower(mw.ustring.sub(image,1,6)) == "https:" then
        return "";
    end
    if mw.ustring.lower(mw.ustring.sub(image,1,7)) == "[https:" then
        return "";
    end
    if mw.ustring.lower(mw.ustring.sub(image,1,8)) == "[[https:" then
        return "";
    end

    if mw.ustring.sub(image,1,2) == "[[" then
        -- search for thumbnail images and add to tracking cat if found
        if mw.title.getCurrentTitle().namespace == 0 and (mw.ustring.find(image, "|%s*thumb%s*[|%]]") or mw.ustring.find(image, "|%s*thumbnail%s*[|%]]")) then
            return image .. "[[Category:Pages using infoboxes with thumbnail images]]";
        else
            return image;
        end
    elseif mw.ustring.sub(image,1,2) == "{{" and mw.ustring.sub(image,1,3) ~= "{{{" then
        return image;
    elseif mw.ustring.sub(image,1,1) == "<" then
        return image;
    elseif mw.ustring.sub(image,1,5) == mw.ustring.char(127).."UNIQ" then
        -- Found strip marker at begining, so pass don't process at all
        return image;
    else
        local result = "";
        local size = frame.args["size"];
        local maxsize = frame.args["maxsize"];
        local sizedefault = frame.args["sizedefault"];
        local alt = frame.args["alt"];
        local title = frame.args["title"];
        local border = frame.args["border"];
        local upright = frame.args["upright"] or "";
        local center= frame.args["center"];
        
        -- remove file: or image: prefix if exists
        if mw.ustring.lower(mw.ustring.sub(image,1,5)) == "file:" then
            image = mw.ustring.sub(image,6);
        end
        if mw.ustring.lower(mw.ustring.sub(image,1,6)) == "image:" then
            image = mw.ustring.sub(image,7);
        end
        
        if maxsize ~= "" and maxsize ~= nil then
            -- if no sizedefault then set to maxsize
            if sizedefault == "" or sizedefault == nil then
                sizedefault = maxsize
            end
            -- check to see if size bigger than maxsize
            if size ~= "" and size ~= nil then
                local sizenumber = tonumber(mw.ustring.match(size,"%d*")) or 0;
                local maxsizenumber = tonumber(mw.ustring.match(maxsize,"%d*"));
                if sizenumber>maxsizenumber and maxsizenumber>0 then
                    size = maxsize;
                end
            end
        end
        -- add px to size if just a number
        if (tonumber(size) or 0) > 0 then
            size = size .. "px";
        end
        
        result = "[[File:" .. image;
        if size ~= "" and size ~= nil then
            result = result .. "|" .. size;
        elseif sizedefault ~= "" and sizedefault ~= nil then
            result = result .. "|" .. sizedefault;
        else
            result = result .. "|frameless";
        end
        if center == "yes" then
            result = result .. "|center"
        end
        if alt ~= "" and alt ~= nil then
            result = result .. "|alt=" .. alt;
        end
        if border == "yes" then
            result = result .. "|border";
        end
        if upright ~= "" then
            result = result .. "|upright=" .. upright;
        end
        if title ~= "" and title ~= nil then
            result = result .. "|" .. title;
        elseif alt ~= "" and alt ~= nil then
            result = result .. "|" .. alt;
        end
        result = result .. "]]";
        
        return result;
    end
end

return i;