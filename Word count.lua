local p = {}

function p.count(frame)
    local title = frame.args.title
    
    local articleText = mw.title.new(title):getContent()
    
    local words = 0
    for _ in articleText:gmatch("%S+") do
        words = words + 1
    end
    
    return words
end

return p
