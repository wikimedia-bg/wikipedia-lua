--[[
AutosortTable: Creates a table which is automatically sorted
 
Usage: (Remove the hidden comments before use)
 
{{#invoke: AutosortTable|create
 
| class = wikitable                            <!-- Class for the entire table -->
| style = width: 50%;                          <!-- CSS for the entire table -->
| sep = --                                     <!-- Separator string used to separate cells -->
| order = 2, 1                                 <!-- Order for sorting preference, takes a coma-separated list of column numbers -->
| nsort = 2                                    <!-- Columns which use numeric sorting. Takes a coma-separated list of column numbers -->
| header =  -- Name -- Age                     <!-- Table header -->
 
| -- Bob -- 20                                 <!-- Row 1 -->
| -- Peter -- 35                               <!-- Row 2 -->
| -- John -- 35                                <!-- Row 3 -->
| -- James -- 50                               <!-- Row 4 -->
| background-color: #FFDDDD -- Henry -- 45     <!-- Row 5, with CSS -->
 
}}
]]
 
local _module = {}
 
_module.create = function(frame)
 
    local args = frame.args
 
    -- Named parameters
 
    local class = args.class
    local style = args.style
    local sep = args.separator
    local order = args.order
    local desc = args.descending or ""
    local nsort = args.numeric or ""
    local hidden = args.hidden or ""
    local header = args.header
    local footer = args.footer
    local colstyle = args.colstyle
 
    -- Frequently-used functions
 
    local strIndexOf = mw.ustring.find
    local strSplit = mw.text.split
    local strSub = mw.ustring.sub
    local strTrim = mw.text.trim
 
    local seplen = #sep
    local nsortLookup, descLookup, hiddenLookup = {}, {}, {}
 
    -- Create the table
 
    local html = mw.html.create()
    local htable = html:tag('table')
    if class then htable:attr('class', class) end
    if style then htable:attr('style', style) end
 
    -- Parses a row string. The key paremter is used to assign a unique key to the result so that equal rows do not cause sort errors.
    local parse = function(s, key)
        local css
        local firstSep = strIndexOf(s, sep, 1, true)
        if firstSep == 1 then  -- no CSS
            css = nil
            s = strSub(s, seplen + 1, -1)
        else   -- CSS before first separator
            css = strSub(s, 1, firstSep - 1)
            s = strSub(s, firstSep + seplen, -1)
        end 
 
        return { key = key, css = css, data = strSplit(s, sep, true) }
    end
 
    --[[
        Writes a row to the table.
        css: CSS to apply to the row.
        data: The data (cells) of the row
        _type: Can be 'header', 'footer' or nil.
    ]]
    local writeHtml = function(css, data, _type)
        local row = htable:tag('tr')
        if css then row:attr('style', strTrim(css)) end
 
        for i, v in ipairs(data) do
            if not hiddenLookup[i] then
                local cell
                if _type == 'header' then
                    -- Header: use the 'th' tag with scope="col"
                    cell = row:tag('th')
                    cell:attr('scope', 'col')
                elseif _type == 'footer' then
                    -- Footer: Mark as 'sortbottom' so that it does not sort whe the table is made user-sortable
                    -- with the 'wikitable sortable' class
                    cell = row:tag('td')
                    cell:class('sortbottom')
                else
                    -- Ordinary cell
                    cell = row:tag('td')
                    local cellCss = colstyle and colstyle[i]
                    if cellCss then cell:attr('style', strTrim(cellCss)) end   -- Apply the column styling, if necessary
                end
                cell:wikitext(strTrim(v))
            end
        end
 
        return row
    end
 
    -- Parse the column styles
    if colstyle then colstyle = parse(colstyle, -1).data end
 
    -- Write the header first
    if header then
        local headerData = parse(header)
        writeHtml(headerData.css, headerData.data, 'header')
    end
 
    -- Parse the data
    local data = {}
    for i, v in ipairs(frame.args) do data[i] = parse(v, i) end
 
    order = strSplit(order, '%s*,%s*')
    nsort = strSplit(nsort, '%s*,%s*')
    desc = strSplit(desc, '%s*,%s*')
    hidden = strSplit(hidden, '%s*,%s*')
 
    for i, v in ipairs(order) do order[i] = tonumber(v) end
    for i, v in ipairs(nsort) do nsortLookup[tonumber(v) or -1] = true end
    for i, v in ipairs(desc) do descLookup[tonumber(v) or -1] = true end
    for i, v in ipairs(hidden) do hiddenLookup[tonumber(v) or -1] = true end
 
    --Sorting comparator function.
    local sortFunc = function(a, b)
        local ad, bd = a.data, b.data
        for i = 1, #order do
            local index = order[i]
            local ai, bi = ad[index], bd[index]
            if nsortLookup[index] then
                -- Numeric sort. Find the first occurence of a number an use it. Decimal points are allowed. Scientific notation not supported.
                ai = tonumber( (ai:find('.', 1, true) and ai:match('[+-]?%d*%.%d+') or ai:match('[+-]?%d+')) or 0 )
                bi = tonumber( (bi:find('.', 1, true) and bi:match('[+-]?%d*%.%d+') or bi:match('[+-]?%d+')) or 0 )
            end
            if ai ~= bi then
                if descLookup[index] then return ai > bi else return ai < bi end
            end
        end
        return a.key < b.key
    end
    table.sort(data, sortFunc)
 
    -- Write the sorted data to the HTML output
    for i, v in ipairs(data) do writeHtml(v.css, v.data, nil) end
 
    -- Write the footer
    if footer then
        local footerData = parse(footer)
        writeHtml(footerData.css, footerData.data, 'footer')
    end
 
    return tostring(html)
 
end
 
return _module
