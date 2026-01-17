--[[  

Визуализация на картинките и описанията им в Шаблон:Картинка на деня в Общомедия/Описания

]]

local p = {}

function splitLines(str)
    local lines = {}
    for line in (str .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    return lines
end

function p.preview( frame )
    local name = "Шаблон:Картинка на деня в Общомедия/Описания"
    local title = mw.title.new(name)
    if title and title.exists then
        local startTag = '<gallery widths=400px heights=400px>'
        local endTag = '</gallery>'
        local text = title:getContent()
        text = string.gsub(text, "\n|", "\n")
        text = string.gsub(text, "=", "|")
        local rows = splitLines(text)
        for i, v in ipairs(rows) do
            rows[i] = v:match("^%s*(.-)%s*$")
            if i == 1 then
                rows[i] = startTag
            elseif rows[i] == "}}" then
                rows[i] = endTag
            elseif rows[i] == "" then
                rows[i] = endTag .. "\n----\n" .. startTag
            end
        end
        text = table.concat(rows, "\n")
        return frame:preprocess(text)
    else
        return "Не е открит " .. name
    end
end

return p
