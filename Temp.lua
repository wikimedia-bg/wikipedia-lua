local p = {}

local function queryWikidata()
    local query = [[
        SELECT ?item ?itemLabel ?coordinates WHERE {
          ?item wdt:P31 wd:Q34038 .
          ?item wdt:P2048 ?height .
          FILTER(?height > 10) .
          ?item wdt:P625 ?coordinates .
          ?item wdt:P17 wd:Q219 .
          SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
        }
    ]]

    local url = 'https://query.wikidata.org/sparql?query=' .. mw.uri.encode(query)
    local headers = {
        ["Accept"] = "application/json"
    }

    local response = mw.ext.externalData.getJSON({
        url = url,
        method = 'GET',
        headers = headers
    })

    if response and response.status == 200 then
        return response.data
    end

    return nil
end

local function formatGeoJSON(data)
    local geojson = {
        type = "FeatureCollection",
        features = {}
    }

    for _, item in ipairs(data.results.bindings) do
        local coordinates = mw.text.split(item.coordinates.value:gsub("Point%(", ""):gsub("%)", ""), " ")
        table.insert(geojson.features, {
            type = "Feature",
            properties = {
                name = item.itemLabel.value
            },
            geometry = {
                type = "Point",
                coordinates = { tonumber(coordinates[1]), tonumber(coordinates[2]) }
            }
        })
    end

    return mw.text.jsonEncode(geojson)
end

function p.getGeoJSON()
    local data = queryWikidata()
    if data then
        return formatGeoJSON(data)
    else
        return nil
    end
end

return p
