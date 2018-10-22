--
-- This module implements {{URL}}
--
-- See unit tests at [[Module:URL/tests]]

local p = {}
 
function trim(s)
    return (mw.ustring.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function safeUri(s)
    local success, uri = pcall(function()
        return mw.uri.new(s)
    end)
    if success then
        return uri
    end
end

function p._url(url, text)
    url = trim(url or '')
    text = trim(text or '')
    
    if url == '' then
        if text == '' then
            return mw.getCurrentFrame():expandTemplate{ title = 'tlx', args = { 'URL', "''example.com''", "''optional display text''" } }
        else
            return text
        end
    end
    
    -- If the URL contains any unencoded spaces, encode them, because MediaWiki will otherwise interpret a space as the end of the URL.
    url = mw.ustring.gsub(url, '%s', function(s) return mw.uri.encode(s, 'PATH') end)
    
    -- If there is an empty query string or fragment id, remove it as it will cause mw.uri.new to throw an error
    url = mw.ustring.gsub(url, '#$', '')
    url = mw.ustring.gsub(url, '%?$', '')
    
    -- If it's an HTTP[S] URL without the double slash, fix it.
    url = mw.ustring.gsub(url, '^[Hh][Tt][Tt][Pp]([Ss]?):(/?)([^/])', 'http%1://%3')
    
    local uri = safeUri(url)
    
    -- Handle URL's without a protocol, e.g. www.example.com/foo or www.example.com:8080/foo
    if uri and (not uri.protocol or (uri.protocol and not uri.host)) then
        url = 'http://' .. url
        uri = safeUri(url)
    end
    
    if text == '' then
        if uri then
            if uri.path == '/' then uri.path = '' end
            
            local port = ''
            if uri.port then port = ':' .. uri.port end
            
            text = mw.ustring.lower(uri.host or '') .. port .. (uri.relativePath or '')
        else -- URL is badly-formed, so just display whatever was passed in
            text = url
        end
    end

    return mw.ustring.format('<span class="url">[%s %s]</span>', url, text)
end

function p.url(frame)
    local templateArgs = frame.args
    local url = templateArgs[1] or ''
    local text = templateArgs[2] or ''
    return p._url(url, text)
end

return p