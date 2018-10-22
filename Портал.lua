local p = {}
local math_mod = require( "Модул:Math" )

--Chargement de la liste En/Au/Aux/A
local gdata
local success, resultat = pcall (mw.loadData, "Модул:Flag/Data" )
if success then
    gdata = resultat
else
    -- Banque de données à minima en cas de bogue dans le Module:Langue/Data
    gdata={}
    gdata.data={};
    gdata.data[142]={qid="Q142", label="France", genre="fs"}
end
--Aide:Fonction_genre
local genre={
 ms=  {le="le " ,du="du "   ,de="du "   ,au="au "   ,en="au "}
,msa= {le="l'"	,du="de l'"	,de="d'"	,au="à l'"	,en="en "}
,msi= {le=""    ,du="de "	,de="de "	,au="à "	,en="à "}
,msia={le=""	,du="d'"	,de="d'"	,au="à "	,en="à "}
,msiae={le=""   ,du="d'"    ,de="d'"    ,au="à "    ,en="en "}
,fs=  {le="la "	,du="de la ",de="de "   ,au="à la "	,en="en "}
,fsa= {le="l'"	,du="de l'"	,de="d'"	,au="à l'"	,en="en "}
,fsi= {le=""	,du="de "	,de="de "	,au="à "	,en="à "}
,fsia={le=""	,du="d'"	,de="d'"	,au="à "	,en="à "}
,mp=  {le="les ",du="des "	,de="des "	,au="aux "	,en="aux "}
,fp=  {le="les ",du="des "	,de="des "	,au="aux "	,en="aux "}
}
function _latinise_letters(tmparg)
            --2>--remove case
            tmparg=mw.ustring.lower(tmparg);
            --2>--remove acccent
            tmparg=mw.ustring.gsub(tmparg, "[áàâäãå]", "a");
            tmparg=mw.ustring.gsub(tmparg, "[æ]", "ae");
            tmparg=mw.ustring.gsub(tmparg, "[ç]", "c");
            tmparg=mw.ustring.gsub(tmparg, "[éèêë]", "e");
            tmparg=mw.ustring.gsub(tmparg, "[íìîï]", "i");
            tmparg=mw.ustring.gsub(tmparg, "[ñ]", "n");
            tmparg=mw.ustring.gsub(tmparg, "[óòôöõ]", "o");
            tmparg=mw.ustring.gsub(tmparg, "[œ]", "oe");
            tmparg=mw.ustring.gsub(tmparg, "[úùûü]", "u");
            tmparg=mw.ustring.gsub(tmparg, "[ýÿ]", "y");

            return tmparg;
end

function _latinise(tmparg)
            --2>--remove case and accents
            tmparg=_latinise_letters(tmparg);
            --3>--remove ponct
            tmparg=mw.ustring.gsub(tmparg, "[' -_]", "");
            
            return tmparg;
end

function pagesInCategoryGlobal(country,portal) 
	local i = {}
 	if (portal == nil) then
 		portal=country
 	end
 	i['portal']=portal
 	
	local catportal='Портал:' .. portal .. '/Тематични статии'
	i['catportal']='Категория:'..catportal
	i['articles']=mw.site.stats.pagesInCategory( catportal, 'pages'  )
	
	
	local l='on earth'
	
	local catgeo ='Локализирани статии ' .. l
	local catgeoQ1 ='Локализирани статии с етикет ' .. l
	local catgeoQ2 ='Локализирани добри статии ' .. l
	i['catGeo']='Категория:'..catgeo
	if mw.title.new('категория:'..catgeo).exists then
		i['geo']=mw.site.stats.pagesInCategory( catgeo, 'pages'  )+mw.site.stats.pagesInCategory( catgeoQ1, 'pages'  )+mw.site.stats.pagesInCategory( catgeoQ2, 'pages'  )
		i['geoRatio']=	'';
		i['geoQ']=mw.site.stats.pagesInCategory( catgeoQ1, 'pages'  )+mw.site.stats.pagesInCategory( catgeoQ2, 'pages'  )
		
	else
		i['geo']=0;i['geoRatio']=0;i['geoQ']=0
	end
		
	
	
	return i
end

function pagesInCategory(country,portal) 
	local i = {}
 	if (portal == nil) then
 		portal=country
 	end
 	i['portal']=portal
 	
	local countryId = gdata.idByName[_latinise(country)]
	local countryData =gdata.data[countryId]
	
	local catportal='Портал:' .. portal .. '/Тематични статии'
	i['catportal']='категория:'..catportal
	i['articles']=mw.site.stats.pagesInCategory( catportal, 'pages'  )
	
	local l=countryData.label
	--cas spéciaux
	if(countryId==148) then
		l=portal
	end
	
	local catgeo ='Локализирани статии ' .. genre[countryData.genre].en .. ' ' .. l
	local catgeoQ1 ='Локализирани статии с етикет ' .. genre[countryData.genre].en .. ' ' .. l
	local catgeoQ2 ='Локализирани добри статии ' .. genre[countryData.genre].en .. ' ' .. l
	i['catGeo']='Категория:'..catgeo
	if mw.title.new('категория:'..catgeo).exists then
		i['geo']=mw.site.stats.pagesInCategory( catgeo, 'pages'  )+mw.site.stats.pagesInCategory( catgeoQ1, 'pages'  )+mw.site.stats.pagesInCategory( catgeoQ2, 'pages'  )
		i['geoRatio']= math.floor(10000*i['geo']/i['articles'])/100
		i['geoQ']=mw.site.stats.pagesInCategory( catgeoQ1, 'pages'  )+mw.site.stats.pagesInCategory( catgeoQ2, 'pages'  )
		
	else
		i['geo']=0;i['geoRatio']=0;i['geoQ']=0
	end
		
	
	
	return i
end

function p.row(frame) 
	local args = frame.args
	local i = {}
	
	if(args[1] == nil) then
		--entete
		return '! Портал !! Общ брой !! Локализирани страници !! % !! Локализирани статии с етикет\n'
	end
	
	local tab
	if(args[1]=='Earth') then
		tab=pagesInCategoryGlobal(args[1],args[2])
	else
		tab=pagesInCategory(args[1],args[2])
	end
		
	return '|'
		..'|  [[Портал:'..tab['portal']..']]*'
		..'|| [[:'..tab['catportal'] .. '|' .. tab['articles'] ..']]'
		..'|| [[:'..tab['catGeo'] .. '|' .. tab['geo'] ..']]'
		..'|| '.. tab['geoRatio'] .. '%'
		..'|| '.. tab['geoQ'] .. '\n'
end
return p