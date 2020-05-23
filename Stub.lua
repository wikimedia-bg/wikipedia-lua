local p = {}

local STUBCAT = 'Категория:Мъничета'

local THEMES = {
	-- ТЕРИТОРИЯ
	{ 'Австралия-гео', 'Australia orange.gif' },
	{ 'Австралия', 'Flag of Australia.svg' },
	{ 'Австрия', 'Flag of Austria.svg' },
	{ 'Азербайджан', 'Flag of Azerbaijan.svg' },
	{ 'Азия', 'TinyAsia.png' },
	{ 'Алабама', 'Flag of Alabama.svg' },
	{ 'Албания', 'Flag of Albania.svg' },
	{ 'Алжир', 'Flag of Algeria.svg' },
	{ 'Англия', 'Flag of England.svg|border' },
	{ 'Ангола', 'Flag of Angola.svg' },
	{ 'Андора', 'Flag of Andorra.svg' },
	{ 'Антарктика', 'Proposed flag of Antarctica (Graham Bartram).svg' },
	{ 'Аржентина', 'Flag of Argentina.svg' },
	{ 'Армения', 'Flag of Armenia - Coat of Arms.svg' },
	{ 'Армъни', 'Aromanian flag.svg' },
	{ 'Афганистан', 'Flag of Afghanistan.svg' },
	{ 'Африка', 'Africa_ico.png‎ ' },
	{ 'Бангладеш', 'Flag of Bangladesh.svg' },
	{ 'Барбадос', 'Flag of Barbados.svg' },
	{ 'Бахрейн', 'Flag of Bahrain.svg' },
	{ 'Беларус', 'Flag of Belarus.svg' },
	{ 'Белгия', 'Flag of Belgium.svg' },
	{ 'Белиз', 'Flag of Belize.svg' },
	{ 'Бенин', 'Flag of Benin.svg' },
	{ 'Бермудските острови|Бермудски острови', 'Flag of Bermuda.svg' },
	{ 'Боливия', 'Flag of Bolivia.svg' },
	{ 'Босна и Херцеговина|Босна', 'Flag of Bosnia and Herzegovina.svg' },
	{ 'Ботсвана', 'Flag of Botswana.svg' },
	{ 'Бразилия', 'Flag of Brazil.svg' },
	{ 'Буркина Фасо', 'Flag of Burkina Faso.svg' },
	{ 'Бурунди', 'Flag of Burundi.svg' },
	{ 'България', 'Flag of Bulgaria.svg|border' },
	{ 'Вануату', 'Flag of Vanuatu.svg' },
	{ 'Варна', 'Gerb_varna.jpg' },
	{ 'Ватикан', 'Flag of the Vatican City.svg', 'Ватикана'},
	{ 'Великобритания', 'Flag of the United Kingdom.svg' },
	{ 'Венецуела', 'Flag of Venezuela.svg' },
	{ 'Виетнам', 'Flag of Vietnam.svg' },
	{ 'Габон', 'Flag of Gabon.svg' },
	{ 'Гамбия', 'Flag of The Gambia.svg' },
	{ 'Гана', 'Flag of Ghana.svg' },
	{ 'Гватемала', 'Flag of Guatemala.svg' },
	{ 'Гвиана', 'Flag of Guyana.svg' },
	{ 'Гвинея-Бисау', 'Flag of Guinea-Bissau.svg' },
	{ 'Гвинея', 'Flag of Guinea.svg' },
	{ 'Германия', 'Flag of Germany.svg|border' },
	{ 'Гренада', 'Flag of Grenada.svg' },
	{ 'Гренландия', 'Flag of Greenland.svg|border' },
	{ 'Грузия', 'Flag of Georgia.svg' },
	{ 'Гърция', 'Flag-map of Greece.svg' },
	{ 'Демократична република Конго|ДР Конго', 'Flag of the Democratic Republic of the Congo.svg' },
	{ 'Дакия', 'Dacian symbols.png' },
	{ 'Дания', 'Flag of Denmark.svg' },
	{ 'Джибути', 'Flag of Djibouti.svg' },
	{ 'Доминика', 'Flag of Dominica.svg' },
	{ 'Доминиканска република', 'Flag of the Dominican Republic.svg' },
	{ 'ЕС', 'Flag of Europe.svg' },
	{ 'Европа', 'Europe map.png' },
	{ 'Египет', 'Flag of Egypt.svg' },
	{ 'Еквадор', 'Flag of Ecuador.svg' },
	{ 'Екваториална Гвинея', 'Flag of Equatorial Guinea.svg' },
	{ 'Еритрея', 'Flag of Eritrea.svg' },
	{ 'Есватини', 'Flag of Eswatini.svg' },
	{ 'Естония', 'Flag of Estonia.svg' },
	{ 'Етиопия', 'Flag of Ethiopia.svg' },
	{ 'Замбия', 'Flag of Zambia.svg' },
	{ 'Западна Африка', 'africa-countries-western.png' },
	{ 'Западна Сахара', 'Flag_of_the_Sahrawi_Arab_Democratic_Republic.svg' },
	{ 'Зимбабве', 'Flag of Zimbabwe.svg' },
	{ 'Израел', 'Flag of Israel.svg' },
	{ 'Източна Африка', 'africa-countries-eastern.png' },
	{ 'Индия', 'Flag of India.svg' },
	{ 'Индонезия', 'Flag_of_Indonesia.svg' },
	{ 'Ирак', 'Flag of Iraq.svg' },
	{ 'Иран', 'Flag of Iran.svg' },
	{ 'Исландия', 'Flag of Iceland.svg' },
	{ 'Испания', 'Flag of Spain.svg' },
	{ 'Италия', 'Flag of Italy.svg' },
	{ 'Йемен', 'Flag of Yemen.svg' },
	{ 'Йордания', 'Flag_of_Jordan.svg' },
	{ 'Кабо Верде', 'Flag of Cape Verde.svg' },
	{ 'Казахстан', 'Kazachstán-pahýl-obrázek.svg' },
	{ 'Камбоджа', 'Flag of Cambodia.svg' },
	{ 'Камерун', 'Flag of Cameroon.svg' },
	{ 'Канада', 'Flag of Canada.svg' },
	{ 'Катар', 'Flag of Qatar.svg' },
	{ 'Кения', 'Flag of Kenya.svg' },
	{ 'Кипър', 'Flag of Cyprus.svg' },
	{ 'Киргизстан', 'Flag of Kyrgyzstan.svg' },
	{ 'Кирибати', 'Flag of Kiribati.svg' },
	{ 'Китай|китаец|китайци', 'Flag of China.svg' },
	{ 'Колумбия', 'Flag of Colombia.svg' },
	{ 'Коморските острови|Коморски острови', 'Flag of the Comoros.svg' },
	{ 'Косово', 'Flag of Kosovo.svg' },
	{ 'Коста Рика', 'Flag of Costa Rica.svg' },
	{ 'Кот д\'Ивоар', 'Flag of Cote d\'Ivoire.svg' },
	{ 'Куба', 'Flag of Cuba.svg' },
	{ 'Лаос', 'Flag of Laos.svg' },
	{ 'Латвия', 'Flag of Latvia.svg' },
	{ 'Лесото', 'Flag of Lesotho.svg' },
	{ 'Либерия', 'Flag of Liberia.svg' },
	{ 'Либия', 'Flag of Libya.svg' },
	{ 'Ливан', 'Flag of Lebanon.svg' },
	{ 'Литва', 'Flag of Lithuania.svg' },
	{ 'Лихтенщайн', 'Flag of Liechtenstein.svg' },
	{ 'Люксембург', 'Flag of Luxembourg.svg' },
	{ 'Мавритания', '1959-2017 Flag of Mauritania.svg' },
	{ 'Мавриций', 'Flag of Mauritius.svg' },
	{ 'Мадагаскар', 'Flag of Madagascar.svg' },
	{ 'Мадрид', 'Flag of the Community of Madrid.svg' },
	{ 'Малави-гео', 'Flag-map of Malawi.svg' },
	{ 'Малави', 'Flag of Malawi.svg' },
	{ 'Малайзия', 'Flag of Malaysia.svg' },
	{ 'Мали-гео', 'Flag-map of Mali.svg' },
	{ 'Мали', 'Flag of Mali.svg' },
	{ 'Малта', 'Flag of Malta.svg' },
	{ 'Мароко', 'Flag of Morocco.svg' },
	{ 'Марс', 'Mars (white background).jpg' },
	{ 'Мексико', 'Flag of Mexico.svg' },
	{ 'Мианмар', 'Flag of Myanmar.svg' },
	{ 'Мозамбик', 'Flag of Mozambique.svg' },
	{ 'Молдова', 'Flag of Moldova.svg' },
	{ 'Монако', 'Flag of Monaco.svg' },
	{ 'Монголия', 'Flag of Mongolia.svg' },
	{ 'Намибия', 'Flag of Namibia.svg' },
	{ 'Науру', 'Flag of Nauru.svg' },
	{ 'Непал', 'Flag of Nepal.svg' },
	{ 'Нигер-гео', 'Flag-map of Niger.svg' },
	{ 'Нигер', 'Flag of Niger.svg' },
	{ 'Нигерия', 'Flag of Nigeria.svg' },
	{ 'Нидерландия|Холандия', 'Flag of the Netherlands.svg' },
	{ 'Никарагуа', 'Flag of Nicaragua.svg' },
	{ 'Нова Зеландия', 'Flag of New Zealand.svg' },
	{ 'Норвегия', 'Flag of Norway.svg' },
	{ 'ОАЕ', 'Flag of the United Arab Emirates.svg' },
	{ 'ОК', 'Flag of the United Kingdom.svg' },
	{ 'ООН', 'Flag of the United Nations.svg' },
	{ 'Океания', 'Oceania.jpg' },
	{ 'Оман', 'Flag of Oman.svg' },
	{ 'Османска империя', 'Flag of the Ottoman Empire (1453-1844).svg', 'Османската империя' },
	{ 'Пакистан', 'Flag of Pakistan.svg' },
	{ 'Палау', 'Flag of Palau.svg' },
	{ 'Палестина', 'Flag of Palestine.svg' },
	{ 'Панама', 'Flag of Panama.svg' },
	{ 'Папуа Нова Гвинея', 'Flag of Papua New Guinea.svg' },
	{ 'Парагвай', 'Flag of Paraguay.svg' },
	{ 'Перу', 'Flag of Peru.svg' },
	{ 'Полша', 'Poland map flag.svg|border' },
	{ 'Португалия', 'Flag of Portugal.svg' },
	{ 'Пуерто Рико', 'Flag of Puerto Rico.svg' },
	{ 'РЮА|ЮАР', 'Flag of South Africa.svg' },
	{ 'Ирландия|Република Ирландия|Ейре', 'Flag of Ireland.svg' },
	{ 'Република Конго', 'Flag of the Republic of the Congo.svg' },
	{ 'Република Сръбска|Сръбска', 'Flag of the Republika Srpska.svg|border' },
	{ 'Руанда', 'Flag of Rwanda.svg' },
	{ 'Румъния', 'Flag of Romania.svg' },
	{ 'Русия', 'Flag of Russia.svg|border' },
	{ 'САЩ', 'Flag of the USA.svg' },
	{ 'Съветския съюз|Съветски съюз|СССР', 'Flag of the Soviet Union.svg' },
	{ 'Салвадор|Ел Салвадор', 'Flag of El Salvador.svg' },
	{ 'Самоа', 'Flag of Samoa.svg' },
	{ 'Сан Марино', 'Flag of San Marino.svg' },
	{ 'Сао Томе и Принсипи', 'Flag of Sao Tome and Principe.svg' },
	{ 'Саудитска Арабия', 'Flag_of_Saudi_Arabia.svg' },
	{ 'Северна Америка', 'TinyNorthAmerica.png' },
	{ 'Северна Африка', 'Africa-countries-northern.svg' },
	{ 'Северна Ирландия', 'Ni smaller.png' },
	{ 'Северна Корея-гео', 'Flag-map of North Korea.svg' },
	{ 'Северна Корея', 'Flag of North Korea.svg' },
	{ 'Северна Македония|Република Македония|Македония', 'Flag map of North Macedonia.svg' },
	{ 'Сейшелските острови|Сейшелски острови', 'Flag of the Seychelles.svg' },
	{ 'Селище-Русия', 'Flag-map of Russia.svg' },
	{ 'Сенегал', 'Flag of Senegal.svg' },
	{ 'Сиера Леоне', 'Flag of Sierra Leone.svg' },
	{ 'Сингапур', 'Flag of Singapore.svg' },
	{ 'Сирия', 'Flag of the United Arab Republic.svg' },
	{ 'Словакия', 'Flag of Slovakia.svg|border' },
	{ 'Словения', 'Flag of Slovenia.svg' },
	{ 'Соломоновите острови|Соломонови острови', 'Flag of the Solomon Islands.svg' },
	{ 'Сомалия-гео', 'Flag-map of Somalia.svg' },
	{ 'Сомалия', 'Flag of Somalia.svg' },
	{ 'Судан', 'Flag of Sudan.svg' },
	{ 'Суринам', 'Flag of Suriname.svg' },
	{ 'Сърбия', 'Flag of Serbia.svg|border' },
	{ 'Таджикистан', 'Flag of Tajikistan.svg' },
	{ 'Тайван', 'Flag of Taiwan.svg' },
	{ 'Тайланд', 'Flag_of_Thailand.svg' },
	{ 'Танзания', 'Flag of Tanzania.svg' },
	{ 'Того', 'Flag of Togo.svg' },
	{ 'Тонга', 'Flag of Tonga.svg' },
	{ 'Тунис', 'Flag of Tunisia.svg' },
	{ 'Туркменистан', 'Flag of Turkmenistan.svg' },
	{ 'Турция-гео', 'Flag-map of Turkey.svg' },
	{ 'Турция', 'Flag-map of Turkey.svg' },
	{ 'Уганда-гео', 'UgandaFlagColors.svg' },
	{ 'Уганда', 'Flag of Uganda.svg' },
	{ 'Уелс', 'Flag of Wales.svg' },
	{ 'Узбекистан', 'Flag of Uzbekistan.svg' },
	{ 'Украйна', 'Flag of Ukraine.svg' },
	{ 'Унгария', 'Flag of Hungary.svg' },
	{ 'Уругвай', 'Flag of Uruguay.svg' },
	{ 'Фиджи', 'Flag of Fiji.svg' },
	{ 'Филипини', 'Flag of the Philippines.svg' },
	{ 'Финландия', 'Flag of Finland.svg|border' },
	{ 'Флорида', 'Flag of Florida.svg' },
	{ 'Фолкландските острови|Фолкландски острови', 'Flag of the Falkland Islands.svg' },
	{ 'Франция', 'Flag of France.svg' },
	{ 'Френска Полинезия', 'Flag of French Polynesia.svg' },
	{ 'Хаити', 'Flag_of_Haiti.svg' },
	{ 'Хондурас', 'Flag of Honduras.svg' },
	{ 'Хонконг', 'Flag of Hong Kong.svg' },
	{ 'Хърватия-гео', 'Flag_map_of_Croatia.svg' },
	{ 'Хърватия', 'Flag of Croatia.svg' },
	{ 'ЦАР', 'Flag of the Central African Republic.svg' },
	{ 'Чад-гео', 'Flag-map of Chad.svg' },
	{ 'Чад', 'Flag of Chad.svg' },
	{ 'Черна гора', 'Flag of Montenegro.svg' },
	{ 'Чехия', 'Flag of the Czech Republic.svg' },
	{ 'Чили', 'Flag of Chile.svg' },
	{ 'Швейцария', 'Flag of Switzerland.svg' },
	{ 'Швеция', 'Flag of Sweden.svg' },
	{ 'Шотландия', 'Flag of Scotland.svg' },
	{ 'Шри Ланка', 'Flag of Sri Lanka.svg' },
	{ 'Южна Америка', 'TinySouthAmerica.png' },
	{ 'Южна Африка', 'africa-countries-southern.png' },
	{ 'Южна Корея', 'Flag of South Korea.svg|border' },
	{ 'Ямайка', 'Flag of Jamaica.svg' },
	{ 'Япония', 'Flag of Japan.svg|border' },
	
	-- НАУКА
	{ 'алгология', 'Algae Graphic.svg' },
	{ 'анатомия', 'Gray188.png' },
	{ 'анимация', 'Animhorse.gif' },
	{ 'антропология', 'Neutered kokopelli.svg' },
	{ 'археология', 'Farm-Fresh vase.png' },
	{ 'архитектура', 'Corinthian_capital.png' },
	{ 'астрономия', 'Pleiades small.jpg' },
	{ 'астрология', 'Mercury symbol.svg' },
	{ 'африканска култура', 'Queen Mother Pendant Mask- Iyoba MET DP231460.jpg' },
	{ 'биология', 'Butterfly_template.png' },
	{ 'биохимия', 'AlphaHelixSection (yellow).svg' },
	{ 'бойно изкуство', 'Yin and Yang symbol.svg', 'бойни изкуства' },
	{ 'ботаника', 'Leaf.png' },
	{ 'будизъм', 'Dharma Wheel.svg' },
	{ 'география|географ', 'Geographylogo.svg' },
	{ 'геология', 'Geological hammer.svg' },
	{ 'дентална медицина', 'Lower wisdom tooth.jpg' },
	{ 'екология', 'Forestry Leśnictwo (Beentree).svg' },
	{ 'електроника', 'Transistor stub.svg' },
	{ 'електротехника', 'Transformer-hightolow-ironcore.png' },
	{ 'етика', 'Sanzio_01_Plato_Aristotle.jpg' },
	{ 'етнография', 'Divotino-traditional-embroidery-1.jpg' },
	{ 'етнология', 'A shrunken head Wellcome M0000158.jpg' },
	{ 'етология', 'Chicken on a skateboard.JPG' },
	{ 'земеделие', 'Yorkshire Country Views (26).JPG' },
	{ 'изкуство', 'David face.png' },
	{ 'икономика', 'TwoCoins.svg' },
	{ 'имунология', 'Antibody with CDRs.svg' },
	{ 'индуизъм', 'AUM symbol, the primary (highest) name of the God as per the Vedas.svg' },
	{ 'инженерство', 'Nuvola apps kfig.svg' },
	{ 'информатика', 'Computer-blue.svg' },
	{ 'история', 'P history yellow.png' },
	{ 'класическа-музика', 'Classical music icon.svg' },
	{ 'комуникационна техника и технологии', 'Radio Telescope Icon.png' },
	{ 'култура', 'Art template.gif' },
	{ 'лингвистика', 'Linguistics stub.svg' },
	{ 'логика', 'logic.svg' },
	{ 'математика', 'e-to-the-i-pi.svg' },
	{ 'медицина', 'Medistub.svg' },
	{ 'микробиология', 'Ecoli colonies.png' },
	{ 'митология', 'Draig.svg' },
	{ 'мода', 'Signorina in viola.svg' },
	{ 'музика', 'Eighth notes and rest.png' },
	{ 'нанотехнология', 'Graphane.png' },
	{ 'наука', 'Science-symbol-2.svg' },
	{ 'науки за земята', 'Terrestrial globe.svg' },
	{ 'неорганична химия', 'Phosphonium-3D-balls.png' },
	{ 'органична химия', 'Cyclooctatetraene-3D-vdW.png' },
	{ 'офталмология', 'Blue eye.svg' },
	{ 'палеонтология', 'Anning plesiosaur.jpg' },
	{ 'паразитология', 'Ixodes hexagonus (aka).jpg' },
	{ 'политика', 'Society.png' },
	{ 'политология', 'Society.png' },
	{ 'право', 'Scale of justice 2.svg' },
	{ 'програмиране', 'Software spanner.png' },
	{ 'психология', 'Psi2.svg' },
	{ 'сеизмология', 'Seismographs.jpg' },
	{ 'статистика', 'Bellcurve.svg' },
	{ 'телекомуникации', 'Mobiel1.GIF' },
	{ 'техника', 'Spur Gear 12mm, 18t.svg' },
	{ 'технология', 'N icon technology.png' },
	{ 'търговия', 'CashRegister.svg' },
	{ 'фармакология', 'Emoji u1f48a.svg' },
	{ 'физика', 'Science.jpg' },
	{ 'физикохимия', 'Anode effect steel.jpg' },
	{ 'физиология', 'Semipermeable membrane (svg).svg' },
	{ 'физическа география', 'Orografia.jpg' },
	{ 'филология', 'Feather writing.svg' },
	{ 'философия', 'Philosophy_template.gif' },
	{ 'фонетика', 'Linguistics stub.svg' },
	{ 'фотография', 'Crystal Clear device camera.png' },
	{ 'химия', 'Nuvola apps edu science.svg' },
	
	-- ХОРА
	{ 'актьор', 'Ausuebende Audiovision.png', 'актьори' },
	{ 'алпинист', 'Climber silhouette.svg', 'алпинисти' },
	{ 'американец|американци', 'USA-people-stub-icon.png', 'американци' },
	{ 'астроном', 'Astronomer.svg', 'астрономи' },
	{ 'барабанист', 'Trixon Tom.jpg', 'музиканти' },
	{ 'баскетболист', 'Basketball Clipart.svg' },
	{ 'бизнесмен', 'Crystal kchart.png', 'бизнесмени' },
	{ 'благородник', 'Coat of arms of Brabant.svg', 'благородници' },
	{ 'боксьор', 'Icon-boxing-gloves.jpg' },
	{ 'британци', 'Flag of the United Kingdom.svg' },
	{ 'български актьор', 'Bulgaria film clapperboard.svg', 'български актьори' },
	{ 'български владетел', 'Crown of Bulgaria.svg', 'български владетели' },
	{ 'български футболист', 'Football pictogram.svg', 'български футболисти' },
	{ 'българин|българи', 'Bulgaria people stub icon.svg', 'българи' },
	{ 'викинги', 'Vikingshipshortened.png' },
	{ 'военен', 'Army-personnel-icon.png', 'военни личности' },
	{ 'германец', 'Flag of Germany.svg', 'германци' },
	{ 'грък', 'Greece people stub icon.png', 'гърци' },
	{ 'дипломат', 'Crystal_personal.png', 'дипломати' },
	{ 'етнолог', 'Tree diagram_en.svg' },
	{ 'журналист', 'Trondhjems Adresseavis 17. mai 1905 - framside.JPG', 'журналисти' },
	{ 'индианци', 'NSRW Sitting Bull.jpg' },
	{ 'инженер', 'Engineering.png', 'инженери' },
	{ 'канадец', 'Flag of Canada.svg', 'канадци' },
	{ 'китарист', 'RockNRollGuitarist.svg', 'музиканти' },
	{ 'космонавт', 'Astronaut-EVA edit3.png', 'космонавти' },
	{ 'манекен', 'Topmodel.svg' },
	{ 'медик', 'Stethoscope-2.png', 'медици' },
	{ 'монарх', 'Earlkrona, Nordisk familjebok.png', 'монарси' },
	{ 'музикант', 'Musical notes.svg', 'музиканти' },
	{ 'папа', 'Emblem of the Papacy SE.svg', 'папи' },
	{ 'пират', 'Pirate Flag of Rack Rackham.svg', 'пирати' },
	{ 'писател', 'Quill and ink-wikipedia.png', 'писатели' },
	{ 'политик', 'People Politician.png', 'политици' },
	{ 'порно актьор', 'Pink silhouette.svg', 'порно актьори' },
	{ 'престъпник', 'Anthonygaggi.jpg', 'престъпници' },
	{ 'психолог', 'Sigmund freud um 1905.jpg', 'психолози' },
	{ 'революционер', 'Cheguvara Art.svg' },
	{ 'режисьор', 'Filmreel-icon.svg', 'режисьори' },
	{ 'робот', 'Cartoon Robot.svg' },
	{ 'руснак', 'Flag of Russia.svg', 'руснаци' },
	{ 'светец', 'Saint-stub-icon.jpg', 'светци' },
	{ 'скиор', 'Skiicon.svg', 'спортисти' },
	{ 'скулптор', 'Auguste Rodin - Penseur.png', 'скулптори' },
	{ 'спортист', 'Crystal Clear app clicknrun.png', 'спортисти' },
	{ 'състезател', 'Motorsport stub.svg' },
	{ 'танцьор', 'Ballerina-icon.jpg', 'танцьори' },
	{ 'турски актьор', 'Turkey film clapperboard.svg', 'турски актьори' },
	{ 'учен', 'Einstein_template.png', 'учени' },
	{ 'фараон', 'Pharaoh with Blue crown mirror.svg' },
	{ 'физик', 'Albert_Einstein_Head.jpg', 'физици' },
	{ 'французин', 'Crystal Clear app Login Manager.png', 'французи' },
	{ 'футболист', 'Football pictogram.svg', 'футболисти' },
	{ 'художник', 'Vincent Willem van Gogh 107.jpg', 'художници' },
	{ 'човек|личност', 'Crystal Clear app Login Manager.png', 'хора' },
	{ 'шахматист', 'Chess.svg', 'шахматисти' },
	{ 'юрист', 'Scale of justice.svg', 'юристи' },
	
	-- ДРУГИ
	{ 'авиация', 'Aero-stub img.svg' },
	{ 'автомобил', 'Red Gallardo icon.png', 'автомобили' },
	{ 'албум', 'Gnome-dev-cdrom-audio.svg', 'музикални албуми' },
	{ 'аниманга', 'Anime stub 2.svg' },
	{ 'артилерия', 'P military green.png' },
	{ 'астероид', '951 Gaspra.jpg', 'астероиди' },
	{ 'библиотека', 'Nuvola_apps_bookcase.svg' },
	{ 'библия', 'Decalogue parchment by Jekuthiel Sofer 1768.jpg' },
	{ 'бойна-ракета', 'Agm119_penguin.png' },
	{ 'бомбардировач', 'B-2 icon.svg' },
	{ 'бронирани', 'Panzer aus Zusatzzeichen 1049-12.svg' },
	{ 'броня', 'Late medieval armour complete (gothic plate armour).jpg' },
	{ 'вестник', 'newspaper.svg', 'вестници' },
	{ 'вино', 'Red_Wine_Glass.jpg' },
	{ 'висше училище', 'Graduation hat.svg' },
	{ 'властелинът на пръстените', 'Unico Anello.png' },
	{ 'военна', 'Distintivo avanzamento merito di guerra ufficiali superiori (forze armate italiane).svg' },
	{ 'военна история на България', 'Bulgaria war flag.png' },
	{ 'военно отличие', 'Орден „За Военна Заслуга“ I степен (без шарф и без звезда).jpg' },
	{ 'въглеводород', 'Cyclopropane-3D-vdW.png' },
	{ 'галактика', 'Artist’s impression of the Milky Way.jpg', 'галактики' },
	{ 'гну', 'Heckert GNU white.png' },
	{ 'гробище', 'Cemetery template.svg' },
	{ 'грозде', 'Grape icon.png' },
	{ 'гъба|гъби', 'Karl_Johanssvamp,_Iduns_kokbok.jpg', 'гъби' },
	{ 'даоизъм', 'Yin and Yang symbol.svg' },
	{ 'десерт', 'Cassata.jpg', 'десерти' },
	{ 'дзен', 'Enso2.png' },
	{ 'домейн', 'Crystal Clear app browser.png' },
	{ 'език', 'Globe of letters.svg' },
	{ 'електронна игра', 'Nuvola apps package games.png' },
	{ 'железопътен транспорт', 'Aiga railtransportation 25.svg' },
	{ 'железопътна гара', 'Template Railway Stop.svg' },
	{ 'животно|животни', 'Crystal Clear app babelfish vector.svg', 'животни' },
	{ 'заболяване', 'Esculaap4.svg' },
	{ 'защитена територия', 'Rayskoto-pruskalo-waterfall-2.jpg' },
	{ 'звание', 'Army-USA-OR-04a.svg' },
	{ 'звезда', 'Sirius A and B Hubble photo.jpg' },
	{ 'здраве', 'Heart template.svg' },
	{ 'земетресение', 'SanFranHouses06.JPG' },
	{ 'игра', 'Tic tac toe.svg' },
	{ 'играчка', 'Rubiks cube scrambled.jpg' },
	{ 'име', 'IPA Unicode 0x026E.svg', 'имена' },
	{ 'Интернет', 'Gtk-dialog-info.svg' },
	{ 'ислям', 'Allah-green.svg' },
	{ 'келти', 'Celtic carre chien.jpg' },
	{ 'книга', 'Books-aj.svg aj ashton 01.svg' },
	{ 'комикси|комикс', 'Speech balloon.svg' },
	{ 'комп', 'Nuvola apps mycomputer.svg' },
	{ 'компания', 'Factory 1.png' },
	{ 'комуникация', 'Telecom-icon.svg' },
	{ 'конфуцианство', 'Black Confucian symbol.PNG' },
	{ 'конни надбягвания', 'Horseracingicon.svg' },
	{ 'корабоплаване', 'ShipClipart.png' },
	{ 'космос', 'Gas giants in the solar system.jpg' },
	{ 'криптовалута', 'Bitcoin Digital Currency Logo.png' },
	{ 'кръстоносни', 'Modlicisekrizak.jpg' },
	{ 'куче|кинология', 'Dog.svg', 'кучета' },
	{ 'лгбт', 'Gay flag.svg' },
	{ 'линукс', 'Tux.svg' },
	{ 'литература', 'Book template.svg' },
	{ 'локомотив', 'Train template.gif' },
	{ 'мебел', 'Furniture template.svg' },
	{ 'междузвездни войни', 'Star_wars2.svg' },
	{ 'международни организации', 'Regional Organizations Map.png' },
	{ 'международни отношения', 'Society.png' },
	{ 'метеорит', 'Bolide.jpg' },
	{ 'мистерии', 'Wikipedia-logo-ca-Misteri d\'Elx.png' },
	{ 'мост', 'Bridge drawing.svg' },
	{ 'мотоциклет', 'Motorsport stub.svg' },
	{ 'музей', 'David face.png' },
	{ 'мъглявина', 'Ring Nebula.jpg' },
	{ 'награда', 'Cup of Gold.svg', 'отличия' },
	{ 'напитка', 'Emojione BW 1F378.svg' },
	{ 'нацистка германия', 'Reichsadler.svg' },
	{ 'нло', 'Nuvola apps konquest.png' },
	{ 'облекло', 'Signorina in viola.svg' },
	{ 'образование', 'Nuvola apps bookcase.png' },
	{ 'обсерватория', 'Rohzen 2m Telescope dome.jpg' },
	{ 'опера', 'RongeTurandot.jpg' },
	{ 'опорно-двигателна система', 'Gray188.png' },
	{ 'организация', 'Handshake (Workshop Cologne \'06).jpeg', 'организации' },
	{ 'оръжие', 'SIG220-Morges.jpg' },
	{ 'папство', 'Emblem of the Papacy.svg' },
	{ 'парична единица', '5000 Tugriks - Recto.jpg' },
	{ 'парламент', 'Bulgarie Assemblee 2017.svg' },
	{ 'партия', 'Political_template.gif' },
	{ 'песен', 'Musical notes.svg', 'песни' },
	{ 'планина', 'Refuge icone.svg', 'география' },
	{ 'подводница', 'Orzel.svg', 'подводници' },
	{ 'покер', '11g poker chips.jpg' },
	{ 'православие', 'Cross of the Russian Orthodox Church 01.svg' },
	{ 'праистория', 'Combarelles-mammouth.png' },
	{ 'природа', 'N nature.svg' },
	{ 'псв', 'Vickers machine gun in the Battle of Passchendaele - September 1917.jpg' },
	{ 'птици', 'Ruddy-turnstone-icon.png' },
	{ 'пчеларство', 'Wappen Frankfurt-Bockenheim.png' },
	{ 'пътища', 'CH-Hinweissignal-Autobahn.svg' },
	{ 'радио', 'Radio icon.png' },
	{ 'радиолюбителство', 'International amateur radio symbol.svg ' },
	{ 'размножаване', 'ChromosomeArt.jpg' },
	{ 'ракети', 'Shuttle.svg' },
	{ 'растение|растения', 'Dahlia redoute.JPG', 'растения' },
	{ 'революция', 'Fist .svg' },
	{ 'религия', 'P religion world.svg' },
	{ 'ролева игра', 'Ten_sided_die_45px_transparent_bg.png' },
	{ 'руска-военна', 'Flag of the Ministry of Defence of the Russian Federation.svg' },
	{ 'секс', 'Sexuality icon.svg' },
	{ 'софтуер', 'Crystal Clear app kpackage.png' },
	{ 'списание', 'Magazine.svg', 'списания' },
	{ 'стадион', 'Colosseum-2003-07-09.jpg' },
	{ 'съдебен процес', 'Society.png' },
	{ 'тамплиери', 'Cross templars.svg' },
	{ 'танц', 'Ballerina-icon.jpg' },
	{ 'театър', 'P culture.svg' },
	{ 'тевтонци', 'CHE Köniz COA.svg' },
	{ 'телевизия', 'Television icon.svg' },
	{ 'трамвай', 'Sinnbild Straßenbahn.svg' },
	{ 'транспорт', 'Swedish road sign 11 13 12.svg' },
	{ 'тунел', 'AB-Tunnel.svg' },
	{ 'уайърлес', 'Network-wireless.png' },
	{ 'уебсайт', 'Crystal Clear mimetype html.png', 'уебсайтове' },
	{ 'уикипедия', 'Wikipedia-logo-v2.svg' },
	{ 'ураган', 'WPTC Meteo task force.png' },
	{ 'училище', 'Lectura crítica.jpg' },
	{ 'фантастика', 'Nuvola apps konquest.png' },
	{ 'феминизъм', 'FemalePink.png' },
	{ 'фенол', 'Aurantiacin 3D spacefill.png' },
	{ 'фентъзи', 'Dwarf.jpg' },
	{ 'филм', 'Sound mp3.png', 'филми' },
	{ 'формула 1', 'Ferrari stub.gif' },
	{ 'хардуер', 'Nuvola apps kcmprocessor.png' },
	{ 'хари потър', 'HP1 template.gif' },
	{ 'хвп', 'Factory Automation Robotics Palettizing Bread.jpg' },
	{ 'хералдика', 'Azure,_a_bend_Or.svg' },
	{ 'химичен елемент', 'Stylised atom with three Bohr model orbits and stylised nucleus.png' },
	{ 'храм', 'Religion 07.svg' },
	{ 'храна', 'Foodlogo2.svg', 'храна и напитки' },
	{ 'християнство', 'Gold cross.png ' },
	{ 'че гевара', 'Che por Jim Fitzpatrick.svg' },
	{ 'шинтоизъм', 'Black Shintoist symbol.PNG' },
	{ 'юдаизъм', 'Star of David2.svg' },
	{ 'язовир', 'Presa de contraforts.svg' },
	
	------
	
	{ 'балет', 'Jessica Mezey.jpg' },
	{ 'баскетбол', 'Basketball.png' },
	{ 'волейбол', 'Volley ball angelo gelmi 01.svg' },
	{ 'колоездене|колоездач', 'Pictgram bicycle man.svg' },
	{ 'спорт', 'Crystal Clear app clicknrun.png' },
	{ 'тенис|тенисист', 'Tennis icon.png' },
	{ 'футбол', 'Soccerball.svg' },
	{ 'шахмат', 'Chess.svg' },
	
	------
	
	{ 'кино', 'Movie template.gif' },
	{ 'американско кино', 'United States film.png' },
	{ 'британско кино', 'UK film clapperboard.svg' },
	{ 'българско кино', 'Movie template.gif' },
	{ 'германско кино', 'Flag of Germany.svg' },
	{ 'италианско кино', 'Flag of Italy.svg' },
	{ 'френско кино', 'Flag of France.svg' },
}

local function toLower(str)
	return mw.language.getContentLanguage():lc(str)
end

local function printStub(theme, image, plural)
	local editLink = tostring(mw.uri.canonicalUrl(mw.title.getCurrentTitle().fullText, 'action=edit'))
	
	local themeText = ''
	if theme then
		themeText = plural and ' за' or (', свързана ' .. (mw.ustring.match(toLower(theme), '^[сз]') and 'със' or 'с'))
		themeText = string.format('%s [[%s]]', themeText, theme)
	end
	
	local text = string.format("''Тази статия%s все още е [[Уикипедия:Мъниче|мъниче]]. Помогнете на Уикипедия, като я [%s редактирате] и разширите.''", themeText, editLink)
	local stub = mw.html.create()
		:tag('div')
			:addClass('plainlinks')
			:css('margin-top', '1em')
			:css('display', 'table')
			:tag('div')
				:css('float', 'left')
				:css('width', '32px')
				:css('overflow', 'hidden')
				:wikitext(string.format('[[File:%s|30x60п]]', image))
				:done()
			:tag('div')
				:css('margin-left', '37px')
				:wikitext(text)
				:allDone()
	
	return tostring(stub)
end

function p.get(frame)
	local stub = ''
	local category = ''
	if frame.args[1] and frame.args[1] ~= '' then
		for i, theme in pairs(frame.args) do
			if theme ~= '' then
				local found = false
				for i=1, #THEMES do
					local themes = mw.text.split(THEMES[i][1], '|')
					for j=1, #themes do
						if toLower(theme) == toLower(themes[j]) then
							local plural = THEMES[i][3]
							stub = stub .. printStub(themes[1], THEMES[i][2], plural)
							category = string.format('%s[[%s за %s]]', category, STUBCAT, plural and plural or themes[1])
							found = true
							break
						end
					end
				end
				
				if not found then
					stub = stub .. '<div><strong class="error">Грешка в записа: Неразпозната тема "' .. frame.args[i] .. '"</strong></div>'
					category = category .. '[[Категория:Страници с грешки]]'
				end
			end
		end
	else
		stub = printStub(nil, 'M Puzzle.png')
		category = string.format('[[%s]]', STUBCAT)
	end
		
	if mw.title.getCurrentTitle().namespace == 0 then
		stub = stub .. category
	end
	
	return stub
end

return p
