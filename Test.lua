--[[  

]]

local p = {}

function split(str, sep)
    local result = {}
    sep = sep or "%s"  -- default separator: whitespace
    for part in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(result, part)
    end
    return result
end

--[[
TODO
]]
function p.test( frame )
    local name = "Шаблон:Картинка на деня в Общомедия/Описания"
    local title = mw.title.new(name)
    if title and title.exists then
        local rawText = title:getContent()
        local text = string.gsub(rawText, "<includeonly>{{#switch:{{{1}}}</includeonly>", '<gallery>')
        text = string.gsub(text, "\n|", "\n")
        text = string.gsub(text, "=", "|")
        text = string.gsub(text, "}}", "</gallery>")
        local rows = split(text, "\n")
        for i, v in ipairs(rows) do
            rows[i] = v:match("^%s*(.-)%s*$")
        end
        text = table.concat(rows, "\n")
        return frame:preprocess(text)
    else
        return "Не е открит " .. name
    end
end

return p
