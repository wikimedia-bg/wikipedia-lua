-- Inputs:
--    image - Can either be a bare filename (with or without the File:/Image: prefix) or a fully formatted image link
--    page - page to display for multipage images (DjVu)
--    size - size to display the image
--    maxsize - maximum size for image
--    sizedefault - default size to display the image if size param is blank
--    alt - alt text for image
--    title - title text for image
--    border - set to yes if border
--    center - set to yes, if the image has to be centered
--    upright - upright image param
--    suppressplaceholder - if yes then checks to see if image is a placeholder and suppresses it
--    link - page to visit when clicking on image
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
    "Replace this image.svg",
	"Cricket no pic.png",
	"CarersLogo.gif",
	"Diagram Needed.svg",
	"Example.jpg",
	"Image placeholder.png",
	"No male portrait.svg",
	"Nocover-upload.png",
	"NoDVDcover copy.png",
	"Noribbon.svg",
	"No portrait-BFD-test.svg",
	"Placeholder barnstar ribbon.png",
	"Project Trains no image.png",
	"Image-request.png",
	"Sin bandera.svg",
	"Sin escudo.svg",
	"Replace this image - temple.png",
	"Replace this image butterfly.png",
	"Replace this image.svg",
	"Replace this image1.svg",
	"Resolution angle.png",
	"Image-No portrait-text-BFD-test.svg",
	"Insert image here.svg",
	"No image available.png",
	"NO IMAGE YET square.png",
	"NO IMAGE YET.png",
	"No Photo Available.svg",
	"No Screenshot.svg",
	"No-image-available.jpg",
	"Null.png",
	"PictureNeeded.gif",
	"Place holder.jpg",
	"Unbenannt.JPG",
	"UploadACopyrightFreeImage.svg",
	"UploadAnImage.gif",
	"UploadAnImage.svg",
	"UploadAnImageShort.svg",
	"CarersLogo.gif",
	"Diagram Needed.svg",
	"No male portrait.svg",
	"NoDVDcover copy.png",
	"Placeholder barnstar ribbon.png",
	"Project Trains no image.png",
	"Image-request.png",
	"Noimage.gif",
}

function i.IsPlaceholder(image)
    -- change underscores to spaces
    image = mw.ustring.gsub(image, "_", " ");
    assert(image ~= nil, 'mw.ustring.gsub(image, "_", " ") must not return nil')
    -- if image starts with [[ then remove that and anything after |
    if mw.ustring.sub(image,1,2) == "[[" then
        image = mw.ustring.sub(image,3);
        image = mw.ustring.gsub(image, "([^|]*)|.*", "%1");
        assert(image ~= nil, 'mw.ustring.gsub(image, "([^|]*)|.*", "%1") must not return nil')
    end
    -- Trim spaces
    image = mw.ustring.gsub(image, '^[ ]*(.-)[ ]*$', '%1');
    assert(image ~= nil, "mw.ustring.gsub(image, '^[ ]*(.-)[ ]*$', '%1') must not return nil")
    -- remove prefix if exists
    local allNames = mw.site.namespaces[6].aliases
    allNames[#allNames + 1] = mw.site.namespaces[6].name
    allNames[#allNames + 1] = mw.site.namespaces[6].canonicalName
    for i, name in ipairs(allNames) do
        if mw.ustring.lower(mw.ustring.sub(image, 1, mw.ustring.len(name) + 1)) == mw.ustring.lower(name .. ":") then
            image = mw.ustring.sub(image, mw.ustring.len(name) + 2);
            break
        end
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
    if frame.args["suppressplaceholder"] ~= "no" then
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
        elseif mw.title.getCurrentTitle().namespace == 0 then
            return image .. "[[Category:Pages using deprecated image syntax]]";
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
    elseif mw.ustring.sub(image,4,9) == "`UNIQ-" then
        -- Found strip marker at begining, so pass don't process at all
        return image;
    else
        local result = "";
        local page = frame.args["page"];
        local size = frame.args["size"];
        local maxsize = frame.args["maxsize"];
        local sizedefault = frame.args["sizedefault"];
        local alt = frame.args["alt"];
        local link = frame.args["link"];
        local title = frame.args["title"];
        local border = frame.args["border"];
        local upright = frame.args["upright"] or "";
        local thumbtime = frame.args["thumbtime"] or "";
        local center= frame.args["center"];
        
        -- remove prefix if exists
        local allNames = mw.site.namespaces[6].aliases
        allNames[#allNames + 1] = mw.site.namespaces[6].name
        allNames[#allNames + 1] = mw.site.namespaces[6].canonicalName
        for i, name in ipairs(allNames) do
            if mw.ustring.lower(mw.ustring.sub(image, 1, mw.ustring.len(name) + 1)) == mw.ustring.lower(name .. ":") then
                image = mw.ustring.sub(image, mw.ustring.len(name) + 2);
                break
            end
        end
        
        if maxsize ~= "" and maxsize ~= nil then
            -- if no sizedefault then set to maxsize
            if sizedefault == "" or sizedefault == nil then
                sizedefault = maxsize
            end
            -- check to see if size bigger than maxsize
            if size ~= "" and size ~= nil then
                local sizenumber = tonumber(mw.ustring.match(size,"%d*")) or 0;
                local maxsizenumber = tonumber(mw.ustring.match(maxsize,"%d*")) or 0;
                if sizenumber>maxsizenumber and maxsizenumber>0 then
                    size = maxsize;
                end
            end
        end
        -- add px to size if just a number
        if (tonumber(size) or 0) > 0 then
            size = size .. "px";
        end
        -- add px to sizedefault if just a number
        if (tonumber(sizedefault) or 0) > 0 then
            sizedefault = sizedefault .. "px";
        end
        
        result = "[[File:" .. image;
        if page ~= "" and page ~= nil then
            result = result .. "|page=" .. page;
        end
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
        if link ~= "" and link ~= nil then
            result = result .. "|link=" .. link;
        end
        if border == "yes" then
            result = result .. "|border";
        end
        if upright == "yes" then
            result = result .. "|upright";
        elseif upright ~= "" then
            result = result .. "|upright=" .. upright;
        end
        if thumbtime ~= "" then
            result = result .. "|thumbtime=" .. thumbtime;
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
