local p = {}

local STUBCAT = 'Категория:Мъничета'

local THEMES = {
	-- ТЕРИТОРИЯ
	{ 'Австралия', 'Flag of Australia.svg' },
	{ 'Австрия', 'Flag of Austria.svg' },
	{ 'Адигея', 'Adygea-geo-stub.svg' },
	{ 'Азербайджан', 'Flag of Azerbaijan.svg' },
	{ 'Азия', 'TinyAsia.png' },
	{ 'Айдахо', 'Flag of Idaho.svg' },
	{ 'Айова', 'Flag of Iowa.svg' },
	{ 'Алабама', 'Flag of Alabama.svg' },
	{ 'Албания', 'Flag of Albania.svg' },
	{ 'Алжир', 'Flag of Algeria.svg' },
	{ 'Алтайски край', 'Altai-kr-geo-stub.png' },
	{ 'Аляска', 'Flag of Alaska.svg' },
	{ 'Англия', 'Flag of England.svg|border' },
	{ 'Ангола', 'Flag of Angola.svg' },
	{ 'Андора', 'Flag of Andorra.svg' },
	{ 'Антарктика', 'Proposed flag of Antarctica (Graham Bartram).svg' },
	{ 'Аржентина', 'Flag of Argentina.svg' },
	{ 'Аризона', 'Flag of Arizona.svg' },
	{ 'Арканзас', 'Flag of Arkansas.svg' },
	{ 'Армения', 'Flag of Armenia - Coat of Arms.svg' },
	{ 'Афганистан', 'Flag of Afghanistan.svg' },
	{ 'Африка', 'Africa_ico.png' },
	{ 'Бангладеш', 'Flag of Bangladesh.svg' },
	{ 'Барбадос', 'Flag of Barbados.svg' },
	{ 'Бахрейн', 'Flag of Bahrain.svg' },
	{ 'Башкирия', 'Bashkir-geo-stub.svg' },
	{ 'Беларус', 'Flag of Belarus.svg' },
	{ 'Белгия', 'Flag of Belgium.svg' },
	{ 'Белиз', 'Flag of Belize.svg' },
	{ 'Бенин', 'Flag of Benin.svg' },
	{ 'Бермудските острови|Бермудски острови', 'Flag of Bermuda.svg' },
	{ 'Боливия', 'Flag of Bolivia.svg' },
	{ 'Босна и Херцеговина|Босна', 'Flag of Bosnia and Herzegovina.svg' },
	{ 'Ботевград', 'BUL Botevgrad COA.svg' },
	{ 'Ботсвана', 'Flag of Botswana.svg' },
	{ 'Бразилия', 'Flag of Brazil.svg' },
	{ 'Бруней', 'Flag of Brunei.svg' },
	{ 'Бургас', 'Burgas-coat-of-arms.svg' },
	{ 'Буркина Фасо', 'Flag of Burkina Faso.svg' },
	{ 'Бурунди', 'Flag of Burundi.svg' },
	{ 'Бутан', 'Flag of Bhutan.svg' },
	{ 'България', 'Flag of Bulgaria.svg|border' },
	{ 'ВМОРО', 'Flag of the IMARO.svg' },
	{ 'Вануату', 'Flag of Vanuatu.svg' },
	{ 'Варна', 'Gerb_varna.jpg' },
	{ 'Ватикана|Ватикан', 'Flag of the Vatican City.svg'},
	{ 'Вашингтон', 'Flag of Washington.svg' },
	{ 'Венецуела', 'Flag of Venezuela.svg' },
	{ 'Виетнам', 'Flag of Vietnam.svg' },
	{ 'Византия', 'Byzantine Palaiologos Eagle.svg' },
	{ 'Вирджиния', 'Flag of Virginia.svg' },
	{ 'Върмонт|Вермонт', 'Flag of Vermont.svg' },
	{ 'Габон', 'Flag of Gabon.svg' },
	{ 'Гамбия', 'Flag of The Gambia.svg' },
	{ 'Гана', 'Flag of Ghana.svg' },
	{ 'Гватемала', 'Flag of Guatemala.svg' },
	{ 'Гвиана', 'Flag of Guyana.svg' },
	{ 'Гвинея', 'Flag of Guinea.svg' },
	{ 'Гвинея-Бисау', 'Flag of Guinea-Bissau.svg' },
	{ 'Германия', 'Flag of Germany.svg|border' },
	{ 'Гренада', 'Flag of Grenada.svg' },
	{ 'Гренландия', 'Flag of Greenland.svg|border' },
	{ 'Грузия', 'Flag of Georgia.svg' },
	{ 'Гърция', 'Flag-map of Greece.svg' },
	{ 'Дакия', 'Dacian symbols.png' },
	{ 'Дания', 'Flag of Denmark.svg' },
	{ 'Делауеър', 'Flag of Delaware.svg' },
	{ 'Демократична република Конго|ДР Конго', 'Flag of the Democratic Republic of the Congo.svg' },
	{ 'Джибути', 'Flag of Djibouti.svg' },
	{ 'Джорджия', 'Flag of Georgia (U.S. state).svg' },
	{ 'Доминика', 'Flag of Dominica.svg' },
	{ 'Доминиканската република|Доминиканска република', 'Flag of the Dominican Republic.svg' },
	{ 'Древен Египет', 'Head of the Great Sphinx (icon).png' },
	{ 'Древен Рим', 'She-wolf suckles Romulus and Remus.jpg' },
	{ 'Древна Гърция', 'ParthenonRekonstruktion.jpg' },
	{ 'Европа', 'Europe map.png' },
	{ 'Европейския съюз|ЕС', 'Flag of Europe.svg' },
	{ 'Егейска Македония', 'Flag of Greek Macedonia.svg' },
	{ 'Египет', 'Flag of Egypt.svg' },
	{ 'Еквадор', 'Flag of Ecuador.svg' },
	{ 'Екваториална Гвинея', 'Flag of Equatorial Guinea.svg' },
	{ 'Еритрея', 'Flag of Eritrea.svg' },
	{ 'Есватини', 'Flag of Eswatini.svg' },
	{ 'Естония', 'Flag of Estonia.svg' },
	{ 'Етиопия', 'Flag of Ethiopia.svg' },
	{ 'Замбия', 'Flag of Zambia.svg' },
	{ 'Западна Африка', 'africa-countries-western.png' },
	{ 'Западна Вирджиния', 'Flag of West Virginia.svg' },
	{ 'Западна Сахара', 'Flag_of_the_Sahrawi_Arab_Democratic_Republic.svg' },
	{ 'Зимбабве', 'Flag of Zimbabwe.svg' },
	{ 'Израел', 'Flag of Israel.svg' },
	{ 'Източен Тимор', 'Flag of East Timor.svg' },
	{ 'Източна Африка', 'africa-countries-eastern.png' },
	{ 'Илинойс', 'Flag of Illinois.svg|border' },
	{ 'Индиана', 'Flag of Indiana.svg' },
	{ 'Индия', 'Flag of India.svg' },
	{ 'Индонезия', 'Flag_of_Indonesia.svg' },
	{ 'Ирак', 'Flag of Iraq.svg' },
	{ 'Иран', 'Flag of Iran.svg' },
	{ 'Ирландия|Република Ирландия|Ейре', 'Flag of Ireland.svg' },
	{ 'Исландия', 'Flag of Iceland.svg' },
	{ 'Испания', 'Flag of Spain.svg' },
	{ 'Италия', 'Flag of Italy.svg' },
	{ 'Йемен', 'Flag of Yemen.svg' },
	{ 'Йордания', 'Flag_of_Jordan.svg' },
	{ 'Кабо Верде', 'Flag of Cape Verde.svg' },
	{ 'Казахстан', 'Kazachstán-pahýl-obrázek.svg' },
	{ 'Калифорния', 'Flag of California.svg' },
	{ 'Калмикия', 'Kalmyk-geo-stub.svg' },
	{ 'Камбоджа', 'Flag of Cambodia.svg' },
	{ 'Камерун', 'Flag of Cameroon.svg' },
	{ 'Канада', 'Flag of Canada.svg' },
	{ 'Канзас', 'Flag of Kansas.svg' },
	{ 'Катар', 'Flag of Qatar.svg' },
	{ 'Квебек', 'Flag of Quebec.svg' },
	{ 'Кения', 'Flag of Kenya.svg' },
	{ 'Кентъки', 'Flag of Kentucky.svg' },
	{ 'Кипър', 'Flag of Cyprus.svg' },
	{ 'Киргизстан', 'Flag of Kyrgyzstan.svg' },
	{ 'Кирибати', 'Flag of Kiribati.svg' },
	{ 'Китай|китаец|китайци', 'Flag of China.svg' },
	{ 'Колорадо', 'Flag of Colorado.svg' },
	{ 'Колумбия', 'Flag of Colombia.svg' },
	{ 'Коми', 'Komi-geo-stub.svg' },
	{ 'Коморските острови|Коморски острови', 'Flag of the Comoros.svg' },
	{ 'Косово', 'Flag of Kosovo.svg' },
	{ 'Коста Рика', 'Flag of Costa Rica.svg' },
	{ 'Кот д\'Ивоар', 'Flag of Cote d\'Ivoire.svg' },
	{ 'Краснодарски край', 'Krasnodar-kr-geo-stub.png' },
	{ 'Крим', 'Flag of Crimea.svg|border' },
	{ 'Куба', 'Flag of Cuba.svg' },
	{ 'Кувейт', 'Flag of Kuwait.svg' },
	{ 'Кънектикът', 'Flag of Connecticut.svg' },
	{ 'Лаос', 'Flag of Laos.svg' },
	{ 'Латвия', 'Flag of Latvia.svg' },
	{ 'Лесото', 'Flag of Lesotho.svg' },
	{ 'Либерия', 'Flag of Liberia.svg' },
	{ 'Либия', 'Flag of Libya.svg' },
	{ 'Ливан', 'Flag of Lebanon.svg' },
	{ 'Литва', 'Flag of Lithuania.svg' },
	{ 'Лихтенщайн', 'Flag of Liechtenstein.svg' },
	{ 'Лондон', 'Coat_of_Arms_of_The_City_of_London.svg' },
	{ 'Люксембург', 'Flag of Luxembourg.svg' },
	{ 'Мавритания', '1959-2017 Flag of Mauritania.svg' },
	{ 'Мавриций', 'Flag of Mauritius.svg' },
	{ 'Мадагаскар', 'Flag of Madagascar.svg' },
	{ 'Мадрид', 'Flag of the Community of Madrid.svg' },
	{ 'Малави', 'Flag of Malawi.svg' },
	{ 'Малайзия', 'Flag of Malaysia.svg' },
	{ 'Малдивите|Малдиви', 'Flag of Maldives.svg' },
	{ 'Мали', 'Flag of Mali.svg' },
	{ 'Малта', 'Flag of Malta.svg' },
	{ 'Марий Ел', 'Mari-El-geo-stub.svg' },
	{ 'Мароко', 'Flag of Morocco.svg' },
	{ 'Марс', 'Mars (white background).jpg' },
	{ 'Масачузетс', 'Flag of Massachusetts.svg|border' },
	{ 'Мейн', 'Flag of Maine.svg' },
	{ 'Мексико', 'Flag of Mexico.svg' },
	{ 'Мериленд', 'Flag of Maryland.svg' },
	{ 'Мианмар', 'Flag of Myanmar.svg' },
	{ 'Минесота', 'Flag of Minnesota.svg' },
	{ 'Мисисипи', 'Flag of Mississippi.svg' },
	{ 'Мисури', 'Flag of Missouri.svg' },
	{ 'Мичиган', 'Flag of Michigan.svg' },
	{ 'Мозамбик', 'Flag of Mozambique.svg' },
	{ 'Молдова', 'Flag of Moldova.svg' },
	{ 'Монако', 'Flag of Monaco.svg' },
	{ 'Монголия', 'Flag of Mongolia.svg' },
	{ 'Мордовия', 'Mordov-geo-stub.svg' },
	{ 'НРБ', 'Flag of Bulgaria (1971-1990).svg' },
	{ 'Намибия', 'Flag of Namibia.svg' },
	{ 'Науру', 'Flag of Nauru.svg' },
	{ 'Небраска', 'Flag of Nebraska.svg' },
	{ 'Невада', 'Flag of Nevada.svg' },
	{ 'Непал', 'Flag of Nepal.svg' },
	{ 'Нигер', 'Flag of Niger.svg' },
	{ 'Нигерия', 'Flag of Nigeria.svg' },
	{ 'Нидерландия|Холандия', 'Flag of the Netherlands.svg' },
	{ 'Никарагуа', 'Flag of Nicaragua.svg' },
	{ 'Нова Зеландия', 'Flag of New Zealand.svg' },
	{ 'Норвегия', 'Flag of Norway.svg' },
	{ 'Ню Джърси', 'Flag of New Jersey.svg' },
	{ 'Ню Мексико', 'Flag of New Mexico.svg' },
	{ 'Ню Хампшър', 'Flag of New Hampshire.svg' },
	{ 'ОАЕ', 'Flag of the United Arab Emirates.svg' },
	{ 'ООН', 'Flag of the United Nations.svg' },
	{ 'Обединеното кралство|Великобритания|ОК', 'Flag of the United Kingdom.svg' },
	{ 'Община-България', 'Bulgaria stub.svg' },
	{ 'Океания', 'Oceania.jpg' },
	{ 'Оклахома', 'Flag of Oklahoma.svg' },
	{ 'Оман', 'Flag of Oman.svg' },
	{ 'Орегон', 'Flag of Oregon.svg' },
	{ 'Османската империя|Османска империя', 'Flag of the Ottoman Empire (1453-1844).svg' },
	{ 'остров Възнесение', 'Flag_of_Ascension_Island.svg' },
	{ 'Охайо', 'Flag of Ohio.svg' },
	{ 'Пакистан', 'Flag of Pakistan.svg' },
	{ 'Палау', 'Flag of Palau.svg' },
	{ 'Палестина', 'Flag of Palestine.svg' },
	{ 'Панама', 'Flag of Panama.svg' },
	{ 'Папуа Нова Гвинея', 'Flag of Papua New Guinea.svg' },
	{ 'Парагвай', 'Flag of Paraguay.svg' },
	{ 'Пенсилвания', 'Flag of Pennsylvania.svg' },
	{ 'Пермски край', 'Flag-map of Perm Krai.svg' },
	{ 'Перу', 'Flag of Peru.svg' },
	{ 'Пловдив', 'Plovdiv-coat-of-arms.svg' },
	{ 'Полша', 'Poland map flag.svg|border' },
	{ 'Португалия', 'Flag of Portugal.svg' },
	{ 'Пуерто Рико', 'Flag of Puerto Rico.svg' },
	{ 'РЮА|ЮАР', 'Flag of South Africa.svg' },
	{ 'Република Карелия', 'Coat_of_Arms_of_Republic_of_Karelia.svg|border' },
	{ 'Република Конго', 'Flag of the Republic of the Congo.svg' },
	{ 'Република Сръбска|Сръбска', 'Flag of the Republika Srpska.svg|border' },
	{ 'Род Айлънд', 'Flag of Rhode Island.svg' },
	{ 'Руанда', 'Flag of Rwanda.svg' },
	{ 'Румъния', 'Flag of Romania.svg' },
	{ 'Русе', 'emblema_na_grad_ruse.jpg' },
	{ 'Русия', 'Flag of Russia.svg|border' },
	{ 'САЩ', 'Flag of the USA.svg' },
	{ 'Салвадор|Ел Салвадор', 'Flag of El Salvador.svg' },
	{ 'Самоа', 'Flag of Samoa.svg' },
	{ 'Сан Марино', 'Flag of San Marino.svg' },
	{ 'Сао Томе и Принсипи', 'Flag of Sao Tome and Principe.svg' },
	{ 'Саудитска Арабия', 'Flag_of_Saudi_Arabia.svg' },
	{ 'Северна Америка', 'TinyNorthAmerica.png' },
	{ 'Северна Африка', 'Africa-countries-northern.svg' },
	{ 'Северна Дакота', 'Flag of North Dakota.svg' },
	{ 'Северна Ирландия', 'Ni smaller.png' },
	{ 'Северна Каролина', 'Flag of North Carolina.svg' },
	{ 'Северна Корея|КНДР', 'Flag of North Korea.svg' },
	{ 'Северна Македония|Република Македония|Македония', 'Flag map of North Macedonia.svg' },
	{ 'Сейшелските острови|Сейшелски острови', 'Flag of the Seychelles.svg' },
	{ 'Сенегал', 'Flag of Senegal.svg' },
	{ 'Сиера Леоне', 'Flag of Sierra Leone.svg' },
	{ 'Сингапур', 'Flag of Singapore.svg' },
	{ 'Сирия', 'Flag of the United Arab Republic.svg' },
	{ 'Словакия', 'Flag of Slovakia.svg|border' },
	{ 'Словения', 'Flag of Slovenia.svg' },
	{ 'Соломоновите острови|Соломонови острови', 'Flag of the Solomon Islands.svg' },
	{ 'Сомалиленд', 'Flag_of_Somaliland.svg' },
	{ 'Сомалия', 'Flag of Somalia.svg' },
	{ 'София', 'BG Sofia coa.svg' },
	{ 'Судан', 'Flag of Sudan.svg' },
	{ 'Суринам', 'Flag of Suriname.svg' },
	{ 'Съветския съюз|Съветски съюз|СССР', 'Flag of the Soviet Union.svg' },
	{ 'Сърбия', 'Flag of Serbia.svg|border' },
	{ 'Таджикистан', 'Flag of Tajikistan.svg' },
	{ 'Тайван', 'Flag of Taiwan.svg' },
	{ 'Тайланд', 'Flag_of_Thailand.svg' },
	{ 'Танзания', 'Flag of Tanzania.svg' },
	{ 'Татарстан', 'Tatar-geo-stub.svg' },
	{ 'Тексас', 'Flag of Texas.svg' },
	{ 'Тенеси', 'Flag of Tennessee.svg' },
	{ 'Того', 'Flag of Togo.svg' },
	{ 'Тонга', 'Flag of Tonga.svg' },
	{ 'Тунис', 'Flag of Tunisia.svg' },
	{ 'Туркменистан', 'Flag of Turkmenistan.svg' },
	{ 'Турция', 'Flag-map of Turkey.svg' },
	{ 'Търговище', 'Gerba_targovishte.jpg' },
	{ 'Уайоминг', 'Flag of Wyoming.svg' },
	{ 'Уганда', 'Flag of Uganda.svg' },
	{ 'Удмуртия', 'Flag of Udmurtia.svg|border' },
	{ 'Уелс', 'Flag of Wales.svg' },
	{ 'Узбекистан', 'Flag of Uzbekistan.svg' },
	{ 'Уисконсин', 'Flag of Wisconsin.svg' },
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
	{ 'Хаваи', 'Flag of Hawaii.svg' },
	{ 'Хаити', 'Flag_of_Haiti.svg' },
	{ 'Хакасия', 'Khakas-geo-stub.svg' },
	{ 'Хондурас', 'Flag of Honduras.svg' },
	{ 'Хонконг', 'Flag of Hong Kong.svg' },
	{ 'Хърватия', 'Flag of Croatia.svg' },
	{ 'Централноафриканската република|ЦАР', 'Flag of the Central African Republic.svg' },
	{ 'Чад', 'Flag of Chad.svg' },
	{ 'Черна гора', 'Flag of Montenegro.svg' },
	{ 'Чехия', 'Flag of the Czech Republic.svg' },
	{ 'Чехословакия', 'Flag of Czechoslovakia.svg' },
	{ 'Чили', 'Flag of Chile.svg' },
	{ 'Чувашия', 'Chuvash-geo-stub.svg' },
	{ 'Швейцария', 'Flag of Switzerland.svg' },
	{ 'Швеция', 'Flag of Sweden.svg' },
	{ 'Шотландия', 'Flag of Scotland.svg' },
	{ 'Шри Ланка', 'Flag of Sri Lanka.svg' },
	{ 'Шумен', 'Emblem of Shumen.png' },
	{ 'щата Монтана|Монтана', 'Flag of Montana.svg', 'Монтана' },
	{ 'щата Ню Йорк|Ню Йорк', 'Flag of New York.svg', 'Ню Йорк' },
	{ 'Южна Америка', 'TinySouthAmerica.png' },
	{ 'Южна Африка', 'africa-countries-southern.png' },
	{ 'Южна Дакота', 'Flag of South Dakota.svg' },
	{ 'Южна Каролина', 'Flag of South Carolina.svg' },
	{ 'Южна Корея', 'Flag of South Korea.svg|border' },
	{ 'Южна Осетия', 'South-Osseia-contur.png' },
	{ 'Юта', 'Flag of Utah.svg' },
	{ 'Ямайка', 'Flag of Jamaica.svg' },
	{ 'Ямало-Ненецки автономен окръг', 'Flag-map of Yamalo-Nenets Autonomous Okrug.svg' },
	{ 'Япония', 'Flag of Japan.svg|border' },

	-- област
	{ 'Архангелска област', 'Arkhangel-obl-geo-stub.png' },
	{ 'Астраханска област', 'Astr-obl-geo-stub.svg' },
	{ 'Белгородска област', 'Belg-obl-geo-stub.png' },
	{ 'Брянска област', 'Bryansk-obl-geo-stub.png' },
	{ 'Владимирска област', 'Vladimir-obl-geo-stub.png' },
	{ 'Волгоградска област', 'Volgograd-obl-geo-stub.png' },
	{ 'Вологодска област', 'Vologod-obl-geo-stub.svg' },
	{ 'Воронежка област', 'Voronezh-obl-geo-stub.png' },
	{ 'Ивановска област', 'Ivan-obl-geo-stub.png' },
	{ 'Калининградска област', 'Kalinin-obl-geo-stub.png' },
	{ 'Калужка област', 'Flag-map of Kaluga Oblast.svg' },
	{ 'Кемеровска област', 'Kemer-obl-geo-stub.svg' },
	{ 'Кировска област', 'Kirov-obl-geo-stub.svg' },
	{ 'Костромска област', 'Kostrom-obl-geo-stub.png' },
	{ 'Курганска област', 'Kurgan-obl-geo-stub.svg' },
	{ 'Курска област', 'Kursk-obl-geo-stub.png' },
	{ 'Ленинградска област', 'Flag-map of Leningrad Oblast.svg' },
	{ 'Липецка област', 'Flag-map of Lipetsk Oblast.svg' },
	{ 'Московска област', 'Flag-map of Moscow Oblast.svg' },
	{ 'Мурманска област', 'Murman-obl-geo-stub.svg' },
	{ 'Нижегородска област', 'Flag-map of Nizhny Novgorod Oblast.svg' },
	{ 'Новгородска област', 'Flag-map of Novgorod Oblast.svg' },
	{ 'Новосибирска област', 'Новосибирскгуб.png' },
	{ 'Одеска област', 'Одесская область.png' },
	{ 'Омска област', 'Omsk-obl-geo-stub.svg' },
	{ 'Оренбургска област', '' },
	{ 'Орловска област', 'Orlov-obl-geo-stub.png' },
	{ 'Пензенска област', 'Penzagubernobl.png' },
	{ 'Псковска област', 'Coat of Arms of Pskov Oblast.svg' },
	{ 'Ростовска област', 'Flag-map of Rostov Oblast.svg' },
	{ 'Рязанска област', 'Ryazan-obl-geo-stub.png' },
	{ 'Самарска област', 'Flag-map of Samara Oblast.svg' },
	{ 'Саратовска област', 'Sarat-obl-geo-stub.png' },
	{ 'Свердловска област', 'Sverdl-obl-geo-stub.svg' },
	{ 'Смоленска област', 'Flag of Smolensk oblast.svg' },
	{ 'Тамбовска област', 'Tambov-obl-geo-stub.svg' },
	{ 'Тверска област', 'Flag-map of Tver Oblast.svg' },
	{ 'Томска област', 'Tomskayagubernoblagub.png' },
	{ 'Тулска област', 'Tula-obl-geo-stub.svg' },
	{ 'Тюменска област', 'Tyumen-obl-geo-stub.svg' },
	{ 'Уляновска област', 'Ulyan-obl-geo-stub.png' },
	{ 'Челябинска област', 'Chelyab-obl-geo-stub.svg' },
	{ 'Ярославска област', 'Flag-map of Yaroslavl Oblast.svg' },
	
	-- гео
	{ 'географски обект|място', 'Geographylogo.svg' },
	{ 'място в Малави|Малави-гео', 'Flag-map of Malawi.svg' },
	{ 'място в Мали|Мали-гео', 'Flag-map of Mali.svg' },
	{ 'място в Северна Корея|Северна Корея-гео|КНДР-гео', 'Flag-map of North Korea.svg' },
	{ 'място в Сомалия|Сомалия-гео', 'Flag-map of Somalia.svg' },
	{ 'място в Турция|Турция-гео', 'Flag-map of Turkey.svg' },
	{ 'място в Чад|Чад-гео', 'Flag-map of Chad.svg' },
	{ 'място в Швеция|Швеция-гео', 'Sverige FlaggKarta.svg' },

	-- окръг
	{ 'окръг Аламида', 'California map showing Alameda County.png' },
	{ 'окръг Контра Коста', 'California map showing Contra Costa County.png' },
	{ 'окръг Марин', 'California map showing Marin County.png' },
	{ 'окръг Напа', 'California map showing Napa County.png' },
	{ 'окръг Сан Матео', 'California map showing San Mateo County.png' },
	{ 'окръг Сан Франциско', 'California map showing San Francisco County.png' },
	{ 'окръг Санта Клара', 'California map showing Santa Clara County.png' },
	{ 'окръг Санта Круз', 'California map showing Santa Cruz County.png' },
	{ 'окръг Солано', 'California map showing Solano County.png' },
	{ 'окръг Сонома', 'California map showing Sonoma County.png' },
	
	-- селище
	{ 'селище в България|Селище-България', 'Bulgaria stub.svg', 'селища в България' },
	{ 'селище в Русия|Селище-Русия', 'Flag-map of Russia.svg', 'селища в Русия' },
	
	-- НАУКА
	{ 'авиация', 'Aero-stub img.svg' },
	{ 'алгология', 'Algae Graphic.svg' },
	{ 'анатомия', 'Gray188.png' },
	{ 'анимация', 'Animhorse.gif' },
	{ 'антропология', 'Neutered kokopelli.svg' },
	{ 'археология', 'Farm-Fresh vase.png' },
	{ 'архитектура|архитект', 'Corinthian_capital.png' },
	{ 'астрология', 'Mercury symbol.svg' },
	{ 'астрономията|астрономия', 'Pleiades small.jpg', 'астрономия' },
	{ 'африканска култура', 'Queen Mother Pendant Mask- Iyoba MET DP231460.jpg' },
	{ 'биология', 'Butterfly_template.png' },
	{ 'биохимия', 'AlphaHelixSection (yellow).svg' },
	{ 'ботаника', 'Leaf.png' },
	{ 'будизъм', 'Dharma Wheel.svg' },
	{ 'военна история на България', 'Bulgaria war flag.png' },
	{ 'военна история', 'Distintivo avanzamento merito di guerra ufficiali superiori (forze armate italiane).svg' },
	{ 'география|географ', 'Geographylogo.svg' },
	{ 'геология', 'Geological hammer.svg' },
	{ 'дентална медицина', 'Lower wisdom tooth.jpg' },
	{ 'древногръцката митология|гръцка митология', 'Minotaur.jpg', 'древногръцка митология' },
	{ 'екология', 'Forestry Leśnictwo (Beentree).svg' },
	{ 'електроника', 'Transistor stub.svg' },
	{ 'електротехника', 'Transformer-hightolow-ironcore.png' },
	{ 'ембриология', 'Anatomy of an egg unlabeled horizontal.svg' },
	{ 'енергетика', 'Rostock Steinkohlekraftwerk 2.jpg' },
	{ 'етика', 'Sanzio_01_Plato_Aristotle.jpg' },
	{ 'етнография', 'Divotino-traditional-embroidery-1.jpg' },
	{ 'етнология|етнолог', 'A shrunken head Wellcome M0000158.jpg' },
	{ 'етология', 'Chicken on a skateboard.JPG' },
	{ 'земеделие', 'Yorkshire Country Views (26).JPG' },
	{ 'изкуство', 'David face.png' },
	{ 'икономика', 'TwoCoins.svg' },
	{ 'имунология', 'Antibody with CDRs.svg' },
	{ 'индуизъм', 'AUM symbol, the primary (highest) name of the God as per the Vedas.svg' },
	{ 'инженерство', 'Nuvola apps kfig.svg' },
	{ 'информатика', 'Computer-blue.svg' },
	{ 'история', 'P history yellow.png' },
	{ 'история на България|История-България', 'BG His.jpg' },
	{ 'история на Германия|Германия-история', 'Berlin Brandenburger Tor BW 2 Ausschnitt.jpg' },
	{ 'история на САЩ|САЩ-история', 'Washington_Crossing_the_Delaware_by_Emanuel_Leutze,_MMA-NYC,_1851.jpg' },
	{ 'класическа-музика', 'Classical music icon.svg' },
	{ 'комуникационна техника и технологии', 'Radio Telescope Icon.png' },
	{ 'криптозоология|криптиди', 'Mammouth.png' },
	{ 'култура', 'Art template.gif' },
	{ 'лингвистика|език', 'Linguistics stub.svg' },
	{ 'логика', 'logic.svg' },
	{ 'математика', 'e-to-the-i-pi.svg' },
	{ 'медицина', 'Medistub.svg' },
	{ 'метеорология', 'Cyclone Catarina from the ISS on March 26 2004.JPG' },
	{ 'микробиология', 'Ecoli colonies.png' },
	{ 'митология', 'Draig.svg' },
	{ 'мода|манекен', 'Signorina in viola.svg' },
	{ 'музика', 'Eighth notes and rest.png' },
	{ 'нанотехнология', 'Graphane.png' },
	{ 'наука', 'Science-symbol-2.svg' },
	{ 'науки за Земята', 'Terrestrial globe.svg' },
	{ 'неврология', 'Neuro-stub.png' },
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
	{ 'сеизмология|земетресение', 'Seismographs.jpg' },
	{ 'социология', 'People icon.svg' },
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
	{ 'хералдика', 'Azure,_a_bend_Or.svg' },
	{ 'химия', 'Nuvola apps edu science.svg' },
	{ 'ядрена енергетика', 'Nuclear power plant.svg' },
	{ 'ядрена физика', 'Gammadecay-1.jpg' },
	
	-- ХОРА
	{ 'австрийски актьор', 'Austria film clapperboard.png', 'австрийски актьори' },
	{ 'немски писател|Германия-писател', 'Flag of Germany.svg', 'немски писатели' },
	{ 'актьор', 'Ausuebende Audiovision.png', 'актьори' },
	{ 'алпинист', 'Climber silhouette.svg', 'алпинисти' },
	{ 'американец|американци', 'USA-people-stub-icon.png', 'американци' },
	{ 'арумъните|арумъни|армъни', 'Aromanian flag.svg', 'арумъни' },
	{ 'астроном', 'Astronomer.svg', 'астрономи' },
	{ 'барабанист', 'Trixon Tom.jpg', 'музиканти' },
	{ 'баскетболист', 'Basketball Clipart.svg' },
	{ 'бизнесмен', 'Crystal kchart.png', 'бизнесмени' },
	{ 'благородник', 'Coat of arms of Brabant.svg', 'благородници' },
	{ 'британци', 'Flag of the United Kingdom.svg' },
	{ 'българин|българи', 'Bulgaria people stub icon.svg', 'българи' },
	{ 'български актьор', 'Bulgaria film clapperboard.svg', 'български актьори' },
	{ 'български владетел', 'Crown of Bulgaria.svg', 'български владетели' },
	{ 'български футболист', 'Football pictogram.svg', 'български футболисти' },
	{ 'викинги', 'Vikingshipshortened.png' },
	{ 'военен', 'Army-personnel-icon.png', 'военни личности' },
	{ 'германец', 'Flag of Germany.svg', 'германци' },
	{ 'грък', 'Greece people stub icon.png', 'гърци' },
	{ 'дипломат', 'Crystal_personal.png', 'дипломати' },
	{ 'журналист', 'Trondhjems Adresseavis 17. mai 1905 - framside.JPG', 'журналисти' },
	{ 'изследовател', 'Marco Polo portrait.jpg', 'изследователи' },
	{ 'индианци', 'NSRW Sitting Bull.jpg' },
	{ 'инженер', 'Engineering.png', 'инженери' },
	{ 'канадец', 'Flag of Canada.svg', 'канадци' },
	{ 'китарист', 'RockNRollGuitarist.svg', 'музиканти' },
	{ 'космонавт', 'Astronaut-EVA edit3.png', 'космонавти' },
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
	{ 'режисьор', 'Filmreel-icon.svg', 'режисьори' },
	{ 'робот', 'Cartoon Robot.svg', 'роботи' },
	{ 'руснак', 'Flag of Russia.svg', 'руснаци' },
	{ 'светец', 'Saint-stub-icon.jpg', 'светци' },
	{ 'северномакедонец|македонец|Северна Македония-личност|РМ-личност', 'Republic-Macedonia-people-stub-icon.png', 'северномакедонци' },
	{ 'скиор', 'Skiicon.svg', 'спортисти' },
	{ 'скулптор', 'Auguste Rodin - Penseur.png', 'скулптори' },
	{ 'спортист', 'Crystal Clear app clicknrun.png', 'спортисти' },
	{ 'състезател', 'Motorsport stub.svg' },
	{ 'тамплиери', 'Cross templars.svg' },
	{ 'танцьор', 'Ballerina-icon.jpg', 'танцьори' },
	{ 'тевтонци', 'CHE Köniz COA.svg' },
	{ 'турски актьор', 'Turkey film clapperboard.svg', 'турски актьори' },
	{ 'учен', 'Einstein_template.png', 'учени' },
	{ 'фараон', 'Pharaoh with Blue crown mirror.svg' },
	{ 'физик', 'Albert_Einstein_Head.jpg', 'физици' },
	{ 'философ', 'Head Platon Glyptothek Munich 548.jpg', 'философи' },
	{ 'французин', 'Crystal Clear app Login Manager.png', 'французи' },
	{ 'футболист', 'Football pictogram.svg', 'футболисти' },
	{ 'химик', 'AlfredNobel adjusted.jpg', 'химици' },
	{ 'художник', 'Vincent Willem van Gogh 107.jpg', 'художници' },
	{ 'човек|личност', 'Crystal Clear app Login Manager.png', 'хора' },
	{ 'шахматист', 'Chess.svg', 'шахматисти' },
	{ 'юрист', 'Scale of justice.svg', 'юристи' },
	
	-- ДРУГИ
	{ 'Cartoon Network', 'Cartoon_Network_box_device.svg' },
	{ 'ГНУ|линукс', 'Heckert GNU white.png' },
	{ 'ЛГБТ', 'Gay flag.svg' },
	{ 'НЛО', 'Nuvola apps konquest.png' },
	{ 'Нацистка Германия', 'Reichsadler.svg' },
	{ 'ПФК Светкавица', 'Svetkavitza.png' },
	{ 'Руска-военна', 'Flag of the Ministry of Defence of the Russian Federation.svg' },
	{ 'ТНО-К', '(253) mathilde crop.jpg' },
	{ 'Ханти-Мансийски автономен окръг', 'Khanty-mansi-geo-stub.svg' },
	{ 'Хари Потър', 'HP1 template.gif' },
	{ 'ЦСКА (София)|ЦСКА', 'CSKA Sofia logo.svg', 'ЦСКА' },
	{ 'Че Гевара', 'Che por Jim Fitzpatrick.svg' },
	{ 'автомобил', 'Red Gallardo icon.png', 'автомобили' },
	{ 'албум', 'Gnome-dev-cdrom-audio.svg', 'музикални албуми' },
	{ 'аниманга', 'Anime stub 2.svg' },
	{ 'антибиотик', 'Capsule, gélule.svg', 'антибиотици' },
	{ 'артилерия', 'P military green.png' },
	{ 'астероид', '951 Gaspra.jpg', 'астероиди' },
	{ 'библиотека', 'Nuvola_apps_bookcase.svg' },
	{ 'Библията|библия', 'Decalogue parchment by Jekuthiel Sofer 1768.jpg' },
	{ 'бойна ракета', 'Agm119_penguin.png', 'бойни ракети' },
	{ 'бомбардировач', 'B-2 icon.svg', 'бомбардировачи' },
	{ 'бронирани', 'Panzer aus Zusatzzeichen 1049-12.svg' },
	{ 'броня', 'Late medieval armour complete (gothic plate armour).jpg' },
	{ 'вестник', 'newspaper.svg', 'вестници' },
	{ 'викинги', 'Vikingshipshortened.png' },
	{ 'вино', 'Red_Wine_Glass.jpg' },
	{ 'Властелинът на пръстените', 'Unico Anello.png' },
	{ 'водопад', 'Reichenbach.JPG' },
	{ 'военно дело|военна', 'Distintivo avanzamento merito di guerra ufficiali superiori (forze armate italiane).svg' },
	{ 'военно звание|звание', 'Army-USA-OR-04a.svg', 'военни звания' },
	{ 'военно отличие|отличие', 'Орден „За Военна Заслуга“ I степен (без шарф и без звезда).jpg', 'военни отличия' },
	{ 'вулкан', 'Noto Project Volcano Emoji.svg', 'вулкани' },
	{ 'галактика', 'Artist’s impression of the Milky Way.jpg', 'галактики' },
	{ 'генетика', 'DNA Overview.png' },
	{ 'градоустройство', 'Burgess model.svg' },
	{ 'гробище', 'Cemetery template.svg' },
	{ 'грозде', 'Grape icon.png' },
	{ 'гъба|гъби', 'Karl_Johanssvamp,_Iduns_kokbok.jpg', 'гъби' },
	{ 'даоизъм', 'Yin and Yang symbol.svg' },
	{ 'десерт', 'Cassata.jpg', 'десерти' },
	{ 'дзен', 'Enso2.png' },
	{ 'долина', 'Kanyon belbek view.JPG' },
	{ 'еволюция', 'Human evolution scheme.svg' },
	{ 'езеро', 'Roundtanglelake.JPG' },
	{ 'електронна игра|компютърна игра', 'Nuvola apps package games.png', 'електронни игри' },
	{ 'железопътен транспорт', 'Aiga railtransportation 25.svg' },
	{ 'железопътна гара', 'Template Railway Stop.svg' },
	{ 'животно|животни', 'Crystal Clear app babelfish vector.svg', 'животни' },
	{ 'заболяване', 'Esculaap4.svg', 'заболявания' },
	{ 'замък', 'Icone chateau fort.svg', 'замъци' },
	{ 'защитена територия', 'Rayskoto-pruskalo-waterfall-2.jpg', 'защитени територии' },
	{ 'звезда', 'Sirius A and B Hubble photo.jpg', 'звезди' },
	{ 'здраве', 'Heart template.svg' },
	{ 'игра', 'Tic tac toe.svg', 'игри' },
	{ 'играчка', 'Rubiks cube scrambled.jpg', 'играчки' },
	{ 'изкуствен спътник', 'Nasa swift satellite.jpg', 'изкуствени спътници' },
	{ 'изчислителна техника|компютър|компютри|комп', 'Nuvola apps mycomputer.svg' },
	{ 'Интернет', 'Gtk-dialog-info.svg' },
	{ 'Интернет домейн|домейн', 'Crystal Clear app browser.png', 'Интернет домейни' },
	{ 'име', 'IPA Unicode 0x026E.svg', 'имена' },
	{ 'ислям', 'Allah-green.svg' },
	{ 'келти', 'Celtic carre chien.jpg' },
	{ 'книга', 'Books-aj.svg aj ashton 01.svg', 'книги' },
	{ 'комикси|комикс', 'Speech balloon.svg' },
	{ 'компания', 'Factory 1.png' },
	{ 'комуникация', 'Telecom-icon.svg' },
	{ 'конни надбягвания', 'Horseracingicon.svg' },
	{ 'конфуцианство', 'Black Confucian symbol.PNG' },
	{ 'корабоплаване', 'ShipClipart.png' },
	{ 'космос', 'Gas giants in the solar system.jpg' },
	{ 'криптовалута', 'Bitcoin Digital Currency Logo.png', 'криптовалути' },
	{ 'кръстоносни', 'Modlicisekrizak.jpg' },
	{ 'куче|кинология', 'Dog.svg', 'кучета' },
	{ 'ледник', 'Franz_Josef_glacier.JPG' },
	{ 'летище', 'Airport symbol.svg' },
	{ 'литература', 'Book template.svg' },
	{ 'локомотив', 'Train template.gif' },
	{ 'обзавеждане|мебел', 'Furniture template.svg' },
	{ 'Междузвездни войни', 'Star_wars2.svg' },
	{ 'международни организации', 'Regional Organizations Map.png' },
	{ 'международни отношения', 'Society.png' },
	{ 'метеорит', 'Bolide.jpg' },
	{ 'минерал', 'Topaze Brésil2.jpg', 'минерали' },
	{ 'мистерии', 'Wikipedia-logo-ca-Misteri d\'Elx.png' },
	{ 'море', 'India Landscape.jpg' },
	{ 'мост', 'Bridge drawing.svg' },
	{ 'мотоциклет', 'Motorsport stub.svg', 'мотоциклети' },
	{ 'музей', 'David face.png', 'музеи' },
	{ 'музикален инструмент', 'Saxophone-icon.svg', 'музикални инструменти' },
	{ 'мъглявина', 'Ring Nebula.jpg' },
	{ 'награда', 'Cup of Gold.svg', 'отличия' },
	{ 'напитка', 'Emojione BW 1F378.svg', 'напитки' },
	{ 'облекло', 'Signorina in viola.svg' },
	{ 'образование', 'Nuvola apps bookcase.png' },
	{ 'обсерватория', 'Rohzen 2m Telescope dome.jpg' },
	{ 'околна среда', 'Leaf.svg' },
	{ 'опера', 'RongeTurandot.jpg' },
	{ 'опорно-двигателна система', 'Gray188.png' },
	{ 'организация', 'Handshake (Workshop Cologne \'06).jpeg', 'организации' },
	{ 'оръжие', 'SIG220-Morges.jpg' },
	{ 'остров', 'Emoji u1f3dd.svg' },
	{ 'папство', 'Emblem of the Papacy.svg' },
	{ 'парична единица', '5000 Tugriks - Recto.jpg', 'парични единици' },
	{ 'парк', 'Forestry Leśnictwo (Beentree)2.svg' },
	{ 'парламент', 'Bulgarie Assemblee 2017.svg' },
	{ 'партия', 'Political_template.gif' },
	{ 'песен', 'Musical notes.svg', 'песни' },
	{ 'планина', 'Refuge icone.svg', 'география' },
	{ 'подводница', 'Orzel.svg', 'подводници' },
	{ 'покер', '11g poker chips.jpg' },
	{ 'православие', 'Cross of the Russian Orthodox Church 01.svg' },
	{ 'праистория', 'Combarelles-mammouth.png' },
	{ 'природа', 'N nature.svg' },
	{ 'първата световна война|псв', 'Vickers machine gun in the Battle of Passchendaele - September 1917.jpg' },
	{ 'птици', 'Ruddy-turnstone-icon.png' },
	{ 'пустиня', 'Emojione 1F42B.svg', 'пустини' },
	{ 'пчеларство', 'Wappen Frankfurt-Bockenheim.png' },
	{ 'пътища', 'CH-Hinweissignal-Autobahn.svg' },
	{ 'радио', 'Radio icon.png' },
	{ 'радиолюбителство', 'International amateur radio symbol.svg ' },
	{ 'размножаване', 'ChromosomeArt.jpg' },
	{ 'ракета|ракети', 'Shuttle.svg', 'ракетна техника и космически апарати' },
	{ 'растение|растения', 'Dahlia redoute.JPG', 'растения' },
	{ 'революция', 'Fist .svg' },
	{ 'река', 'Eugène Galien-Laloue Village on a River.jpg', 'реки' },
	{ 'религия', 'P religion world.svg' },
	{ 'риболов', 'Fishing.svg' },
	{ 'руска-военна', 'Flag of the Ministry of Defence of the Russian Federation.svg' },
	{ 'секс', 'Sexuality icon.svg' },
	{ 'сладкиш', 'Emoji u1f36d.svg', 'сладкарски изделия' },
	{ 'софтуер', 'Crystal Clear app kpackage.png' },
	{ 'списание', 'Magazine.svg', 'списания' },
	{ 'стадион', 'Colosseum-2003-07-09.jpg', 'стадиони' },
	{ 'строителство', 'P building.png' },
	{ 'счетоводство', 'Crystal kchart.png' },
	{ 'съдебен процес', 'Society.png' },
	{ 'танц', 'Ballerina-icon.jpg', 'танци' },
	{ 'театър', 'P culture.svg' },
	{ 'телевизия', 'Television icon.svg' },
	{ 'трамвай', 'Sinnbild Straßenbahn.svg' },
	{ 'транспорт', 'Swedish road sign 11 13 12.svg' },
	{ 'тунел', 'AB-Tunnel.svg' },
	{ 'уайърлес', 'Network-wireless.png' },
	{ 'уебсайт', 'Crystal Clear mimetype html.png', 'уебсайтове' },
	{ 'Уикипедия', 'Wikipedia-logo-v2.svg' },
	{ 'университет|висше училище', 'Graduation hat.svg', 'университети' },
	{ 'ураган', 'WPTC Meteo task force.png' },
	{ 'училище', 'Lectura crítica.jpg', 'училища' },
	{ 'фантастика', 'Nuvola apps konquest.png' },
	{ 'феминизъм', 'FemalePink.png' },
	{ 'фентъзи', 'Dwarf.jpg' },
	{ 'филм', 'Sound mp3.png', 'филми' },
	{ 'Формула 1|Ф1', 'Ferrari stub.gif' },
	{ 'хардуер', 'Nuvola apps kcmprocessor.png' },
	{ 'хранително-вкусовата промишленост|хвп', 'Factory Automation Robotics Palettizing Bread.jpg' },
	{ 'химичен елемент', 'Stylised atom with three Bohr model orbits and stylised nucleus.png', 'химични елементи' },
	{ 'храм', 'Religion 07.svg', 'храмове' },
	{ 'храна', 'Foodlogo2.svg', 'храна и напитки' },
	{ 'християнство', 'Gold cross.png ' },
	{ 'че гевара', 'Che por Jim Fitzpatrick.svg' },
	{ 'шинтоизъм', 'Black Shintoist symbol.PNG' },
	{ 'юдаизъм', 'Star of David2.svg' },
	{ 'язовир', 'Presa de contraforts.svg', 'язовири' },
	
	------
	
	{ 'балет', 'Jessica Mezey.jpg' },
	{ 'баскетбол', 'Basketball.png' },
	{ 'бойно изкуство', 'Yin and Yang symbol.svg', 'бойни изкуства' },
	{ 'бокс|боксьор', 'Icon-boxing-gloves.jpg' },
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
		if plural then
			themeText = ' за [[' .. theme .. ']]'
		else
			themeText = ', свързана ' .. (mw.ustring.match(toLower(theme), '^[сз]') and 'със' or 'с') .. ' [[' .. theme .. ']],'
		end
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
