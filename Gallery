-- This module implements {{gallery}}

local p = {}

local HtmlBuilder = require('Module:HtmlBuilder')

function trim(s)
    return (mw.ustring.gsub(s, "^%s*(.-)%s*$", "%1"))
end

local function _gallery(args)
    local tbl = HtmlBuilder.create('table')
    
    if args.style then
        tbl.cssText(args.style)
    else
        tbl
            .css('background', 'transparent')
            .css('border', '1px solid #f0f0f0')
            .css('margin-top', '0.5em')
    end
    
    if args.align then
        tbl.attr('align', args.align)
    end
    
    if args.title then
        tbl
            .tag('tr')
                .tag('td')
                    .attr('colspan', 10)
                    .css('text-align', 'center')
                    .css('font-weight', 'bold')
                    .wikitext(args.title)
    end
    
    local mainCell = tbl.tag('tr').tag('td')
    
    local imageCount = math.ceil(#args / 2)
    local cellWidth = tonumber(args.cellwidth) or tonumber(args.width) or 180
    local imgHeight = tonumber(args.height) or 180
    local lines = tonumber(args.lines) or 2
    
    for i = 1, imageCount do
        local img = trim(args[i*2 - 1] or '')
        local caption = trim(args[i*2] or '')
        local imgWidth = tonumber(args['width' .. i]) or tonumber(args.width) or 180
        local alt = args['alt' .. i] or ''
        
        local textWidth
        if cellWidth < 30 then
            textWidth = imgHeight + 27
        else
            textWidth = cellWidth + 7
        end

        if img ~= '' then
            local imgTbl = mainCell.tag('table')
            
            imgTbl
                .css('width', (cellWidth + 20) .. 'px')
                .css('float', 'left')
                .css('border-collapse', 'collapse')
                .css('margin', '3px')
                .tag('tr')
                    .tag('td')
                        .css('height', (imgHeight + 20) .. 'px')
                        .css('border', '1px solid #CCCCCC')
                        .css('background-color', '#F8F8F8')
                        .css('padding', '0px')
                        .css('text-align', 'center')
                        .wikitext(mw.ustring.format('[[%s|center|border|%dx%dpx|alt=%s|%s]]', img, imgWidth, imgHeight, alt, caption))
                        .done()
                    .done()
                .tag('tr')
                    .css('vertical-align', 'top')
                    .tag('td')
                        .css('display', 'block')
                        .css('font-size', '1em')
                        .css('height', (0.2 + 1.5*lines) .. 'em')
                        .css('padding', '0px')
                        .tag('div')
                            .addClass('gallerytext')
                            .css('height', (0.1 + 1.5*lines) .. 'em')
                            .css('width', textWidth .. 'px')
                            .css('line-height', '1.3em')
                            .css('padding', '2px 6px 1px 6px')
                            .css('overflow-y', 'auto')
                            .css('margin', '0px')
                            .css('border', 'none')
                            .css('border-width', '0px')
                            .wikitext(caption .. '&nbsp;')
        end
    end
    
    if args.footer then
        tbl
            .tag('tr')
                .tag('td')
                    .attr('colspan', 10)
                    .css('text-align', 'right')
                    .css('font-size', '80%')
                    .css('line-height', '1em')
                    .wikitext(args.footer)
    end
    
    return tostring(tbl)
end

function p.gallery(frame)
    local origArgs
    -- If called via #invoke, use the args passed into the invoking template.
    -- Otherwise, for testing purposes, assume args are being passed directly in.
    if frame == mw.getCurrentFrame() then
        origArgs = frame:getParent().args
    else
        origArgs = frame
    end
    
    -- ParserFunctions considers the empty string to be false, so to preserve the previous 
    -- behavior of {{gallery}}, change any empty arguments to nil, so Lua will consider
    -- them false too.
    local args = {}
    for k, v in pairs(origArgs) do
        if v ~= '' then
            args[k] = v
        end
    end

    return _gallery(args)
end

return p