-- Experimental module for building complex HTML (e.g. infoboxes, navboxes) using a fluent interface

local HtmlBuilder = {}

local metatable = {}

metatable.__index = function(t, key)
    local ret = rawget(t, key)
    if ret then
        return ret
    end
    
    ret = metatable[key]
    if type(ret) == 'function' then
        return function(...) 
            return ret(t, ...) 
        end 
    else
        return ret
    end
end

metatable.__tostring = function(t)
    local ret = {}
    t._build(ret)
    return table.concat(ret, '')
end

metatable._build = function(t, ret)
    if t.tagName then 
        table.insert(ret, '<' .. t.tagName)
        for i, attr in ipairs(t.attributes) do
            table.insert(ret, ' ' .. attr.name .. '="' .. attr.val .. '"') 
        end
        if #t.styles > 0 then
            table.insert(ret, ' style="')
            for i, prop in ipairs(t.styles) do
                if type(prop) == 'string' then -- added with cssText()
                    table.insert(ret, prop .. ';')
                else -- added with css()
                    table.insert(ret, prop.name .. ':' .. prop.val .. ';')
                end
            end
            table.insert(ret, '"')
        end
        if t.selfClosing then
            table.insert(ret, ' /')
        end
        table.insert(ret, '>') 
    end
    for i, node in ipairs(t.nodes) do
        if node then
            if type(node) == 'table' then
                node._build(ret)
            else
                table.insert(ret, tostring(node))
            end
        end
    end
    if t.tagName and not t.unclosed and not t.selfClosing then
        table.insert(ret, '</' .. t.tagName .. '>')
    end
end
   
metatable.node = function(t, builder)
    if builder then
        table.insert(t.nodes, builder)
    end
    return t
end

metatable.wikitext = function(t, ...) 
    local vals = {...}
    for i = 1, #vals do
        if vals[i] then
            table.insert(t.nodes, vals[i])
        end
    end
    return t
end

metatable.newline = function(t)
    table.insert(t.nodes, '\n')
    return t
end

metatable.tag = function(t, tagName, args)
    args = args or {}
    args.parent = t
    local builder = HtmlBuilder.create(tagName, args)
    table.insert(t.nodes, builder)
    return builder
end

function getAttr(t, name)
    for i, attr in ipairs(t.attributes) do
        if attr.name == name then
            return attr
        end
    end
end

metatable.attr = function(t, name, val)
    -- if caller sets the style attribute explicitly, then replace all styles previously added with css() and cssText()
    if name == 'style' then
        t.styles = {val}
        return t
    end
    
    local attr = getAttr(t, name)
    if attr then
        attr.val = val
    else
        table.insert(t.attributes, {name = name, val = val})
    end
    
    return t
end

metatable.addClass = function(t, class)
    if class then
        local attr = getAttr(t, 'class')
        if attr then
            attr.val = attr.val .. ' ' .. class
        else
            t.attr('class', class)
        end
    end

    return t
end

metatable.css = function(t, name, val)
    if type(val) == 'string' or type(val) == 'number' then
        for i, prop in ipairs(t.styles) do
            if prop.name == name then
                prop.val = val
                return t
            end
        end
        
        table.insert(t.styles, {name = name, val = val})
    end
    
    return t
end

metatable.cssText = function(t, css)
    if css then
        table.insert(t.styles, css)
    end
    return t
end

metatable.done = function(t)
    return t.parent or t
end

metatable.allDone = function(t)
    while t.parent do
        t = t.parent
    end
    return t
end

function HtmlBuilder.create(tagName, args)
    args = args or {}
    local builder = {}
    setmetatable(builder, metatable)
    builder.nodes = {}
    builder.attributes = {}
    builder.styles = {}
    builder.tagName = tagName
    builder.parent = args.parent
    builder.unclosed = args.unclosed or false
    builder.selfClosing = args.selfClosing or false
    return builder
end

return HtmlBuilder