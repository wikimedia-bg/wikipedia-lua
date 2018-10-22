local p = {}

function p.test( frame )
    if frame.args.id then
        a = mw.wikibase.getEntity( frame.args.id )
    else
        a = mw.wikibase.getEntity()
    end
    return a.title
end

return p