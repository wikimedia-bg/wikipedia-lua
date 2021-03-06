local p = {}

local CATEGORY = ''
local STUBCAT = 'Категория:Мъничета'

local THEMES = {
	-- МЪНИЧЕТА ЗА ТЕРИТОРИЯ
	{ 'Азия', 'TinyAsia.png' },
		{ 'Азербайджан', 'Flag of Azerbaijan.svg|border' },
		{ 'Армения', 'Flag of Armenia - Coat of Arms.svg' },
		{ 'Афганистан', 'Flag of Afghanistan.svg' },
		{ 'Бангладеш', 'Flag of Bangladesh.svg' },
		{ 'Бахрейн', 'Flag of Bahrain.svg|border' },
		{ 'Бруней', 'Flag of Brunei.svg' },
		{ 'Бутан', 'Flag of Bhutan.svg' },
		{ 'Виетнам', 'Flag of Vietnam.svg' },
		{ 'Византия', 'Byzantine Palaiologos Eagle.svg' },
		{ 'Грузия', 'Flag of Georgia.svg' },
			{ 'Южна Осетия', 'South-Osseia-contur.png' },
		{ 'Израел', 'Flag of Israel.svg|border' },
		{ 'Източен Тимор', 'Flag of East Timor.svg' },
		{ 'Индия', 'Flag of India.svg|border' },
		{ 'Индонезия', 'Flag_of_Indonesia.svg|border' },
		{ 'Ирак', 'Flag of Iraq.svg|border' },
		{ 'Иран', 'Flag of Iran.svg|border' },
		{ 'Йемен', 'Flag of Yemen.svg' },
		{ 'Йордания', 'Flag_of_Jordan.svg' },
		{ 'Казахстан', 'Kazachstán-pahýl-obrázek.svg' },
		{ 'Камбоджа', 'Flag of Cambodia.svg' },
		{ 'Катар', 'Flag of Qatar.svg' },
		{ 'Кипър', 'Flag of Cyprus.svg|border' },
		{ 'Киргизстан', 'Flag of Kyrgyzstan.svg' },
		{ 'Китай|китаец|китайци', 'Flag of China.svg' },
			{ 'Хонконг', 'Flag of Hong Kong.svg' },
		{ 'Кувейт', 'Flag of Kuwait.svg' },
		{ 'Лаос', 'Flag of Laos.svg' },
		{ 'Ливан', 'Flag of Lebanon.svg' },
		{ 'Малайзия', 'Flag of Malaysia.svg|border' },
		{ 'Малдивите|Малдиви', 'Flag of Maldives.svg|border' },
		{ 'Мианмар', 'Flag of Myanmar.svg|border' },
		{ 'Монголия', 'Flag of Mongolia.svg' },
		{ 'Непал', 'Flag of Nepal.svg' },
		{ 'ОАЕ', 'Flag of the United Arab Emirates.svg|border' },
		{ 'Оман', 'Flag of Oman.svg|border' },
		{ 'Османската империя|Османска империя', 'Flag of the Ottoman Empire (1453-1844).svg' },
		{ 'Пакистан', 'Flag of Pakistan.svg|border' },
		{ 'Палестина', 'Flag of Palestine.svg' },
		{ 'Русия', 'Flag of Russia.svg|border' },
			{ 'Адигея', 'Adygea-geo-stub.svg' },
			{ 'Алтайски край', 'Altai-kr-geo-stub.png' },
			{ 'Архангелска област', 'Arkhangel-obl-geo-stub.png' },
			{ 'Астраханска област', 'Astr-obl-geo-stub.svg' },
			{ 'Башкирия', 'Bashkir-geo-stub.svg' },
			{ 'Белгородска област', 'Belg-obl-geo-stub.png' },
			{ 'Брянска област', 'Bryansk-obl-geo-stub.png' },
			{ 'Владимирска област', 'Vladimir-obl-geo-stub.png' },
			{ 'Волгоградска област', 'Volgograd-obl-geo-stub.png' },
			{ 'Вологодска област', 'Vologod-obl-geo-stub.svg' },
			{ 'Воронежка област', 'Voronezh-obl-geo-stub.png' },
			{ 'Ивановска област', 'Ivan-obl-geo-stub.png' },
			{ 'Калининградска област', 'Kalinin-obl-geo-stub.png' },
			{ 'Калмикия', 'Kalmyk-geo-stub.svg' },
			{ 'Калужка област', 'Flag-map of Kaluga Oblast.svg' },
			{ 'Кемеровска област', 'Kemer-obl-geo-stub.svg' },
			{ 'Кировска област', 'Kirov-obl-geo-stub.svg' },
			{ 'Коми', 'Komi-geo-stub.svg' },
			{ 'Костромска област', 'Kostrom-obl-geo-stub.png' },
			{ 'Краснодарски край', 'Krasnodar-kr-geo-stub.png' },
			{ 'Крим', 'Flag of Crimea.svg|border' },
			{ 'Курганска област', 'Kurgan-obl-geo-stub.svg' },
			{ 'Курска област', 'Kursk-obl-geo-stub.png' },
			{ 'Ленинградска област', 'Flag-map of Leningrad Oblast.svg' },
			{ 'Липецка област', 'Flag-map of Lipetsk Oblast.svg' },
			{ 'Марий Ел', 'Mari-El-geo-stub.svg' },
			{ 'Мордовия', 'Mordov-geo-stub.svg' },
			{ 'Московска област', 'Flag-map of Moscow Oblast.svg' },
			{ 'Мурманска област', 'Murman-obl-geo-stub.svg' },
			{ 'Нижегородска област', 'Flag-map of Nizhny Novgorod Oblast.svg' },
			{ 'Новгородска област', 'Flag-map of Novgorod Oblast.svg' },
			{ 'Новосибирска област', 'Новосибирскгуб.png' },
			{ 'Омска област', 'Omsk-obl-geo-stub.svg' },
			{ 'Оренбургска област', '' },
			{ 'Орловска област', 'Orlov-obl-geo-stub.png' },
			{ 'Пензенска област', 'Penzagubernobl.png' },
			{ 'Пермски край', 'Flag-map of Perm Krai.svg' },
			{ 'Псковска област', 'Coat of Arms of Pskov Oblast.svg' },
			{ 'Ростовска област', 'Flag-map of Rostov Oblast.svg' },
			{ 'Рязанска област', 'Ryazan-obl-geo-stub.png' },
			{ 'Самарска област', 'Flag-map of Samara Oblast.svg' },
			{ 'Саратовска област', 'Sarat-obl-geo-stub.png' },
			{ 'Свердловска област', 'Sverdl-obl-geo-stub.svg' },
			{ 'селище в Русия|Селище-Русия', 'Flag-map of Russia.svg', 'селища в Русия' },
			{ 'Смоленска област', 'Flag of Smolensk oblast.svg' },
			{ 'Тамбовска област', 'Tambov-obl-geo-stub.svg' },
			{ 'Татарстан', 'Tatar-geo-stub.svg' },
			{ 'Тверска област', 'Flag-map of Tver Oblast.svg' },
			{ 'Томска област', 'Tomskayagubernoblagub.png' },
			{ 'Тулска област', 'Tula-obl-geo-stub.svg' },
			{ 'Тюменска област', 'Tyumen-obl-geo-stub.svg' },
			{ 'Удмуртия', 'Flag of Udmurtia.svg|border' },
			{ 'Уляновска област', 'Ulyan-obl-geo-stub.png' },
			{ 'Хакасия', 'Khakas-geo-stub.svg' },	
			{ 'Ханти-Мансийски автономен окръг', 'Khanty-mansi-geo-stub.svg' },
			{ 'Челябинска област', 'Chelyab-obl-geo-stub.svg' },
			{ 'Чувашия', 'Chuvash-geo-stub.svg' },
			{ 'Ямало-Ненецки автономен окръг', 'Flag-map of Yamalo-Nenets Autonomous Okrug.svg' },
			{ 'Ярославска област', 'Flag-map of Yaroslavl Oblast.svg' },
		{ 'Саудитска Арабия', 'Flag_of_Saudi_Arabia.svg' },
		{ 'Северна Корея|КНДР', 'Flag of North Korea.svg' },
			{ 'място в Северна Корея|Северна Корея-гео|КНДР-гео', 'Flag-map of North Korea.svg' },
		{ 'Сингапур', 'Flag of Singapore.svg' },
		{ 'Сирия', 'Flag of the United Arab Republic.svg' },
		{ 'Съветския съюз|Съветски съюз|СССР', 'Flag of the Soviet Union.svg' },
		{ 'Таджикистан', 'Flag of Tajikistan.svg' },
		{ 'Тайван', 'Flag of Taiwan.svg' },
		{ 'Тайланд', 'Flag_of_Thailand.svg' },
		{ 'Туркменистан', 'Flag of Turkmenistan.svg' },
		{ 'Турция', 'Flag of Turkey.svg' },
			{ 'място в Турция|Турция-гео', 'Flag-map of Turkey.svg' },
		{ 'Узбекистан', 'Flag of Uzbekistan.svg' },
		{ 'Филипини', 'Flag of the Philippines.svg' },
		{ 'Шри Ланка', 'Flag of Sri Lanka.svg' },
		{ 'Южна Корея', 'Flag of South Korea.svg|border' },
		{ 'Япония', 'Flag of Japan.svg|border' },
	{ 'Антарктика', 'Proposed flag of Antarctica (Graham Bartram).svg' },
	{ 'Африка', 'Africa_ico.png' },
		{ 'Западна Африка', 'africa-countries-western.png' },
			{ 'Бенин', 'Flag of Benin.svg' },
			{ 'Буркина Фасо', 'Flag of Burkina Faso.svg' },
			{ 'Габон', 'Flag of Gabon.svg' },
			{ 'Гамбия', 'Flag of The Gambia.svg' },
			{ 'Гана', 'Flag of Ghana.svg' },
			{ 'Гвинея', 'Flag of Guinea.svg' },
			{ 'Гвинея-Бисау', 'Flag of Guinea-Bissau.svg' },
			{ 'Западна Сахара', 'Flag_of_the_Sahrawi_Arab_Democratic_Republic.svg' },
			{ 'Кабо Верде', 'Flag of Cape Verde.svg' },
			{ 'Кот д\'Ивоар', 'Flag of Cote d\'Ivoire.svg' },
			{ 'Либерия', 'Flag of Liberia.svg' },
			{ 'Мавритания', 'Flag of Mauritania.svg' },
			{ 'Мали', 'Flag of Mali.svg|border' },
				{ 'място в Мали|Мали-гео', 'Flag-map of Mali.svg' },
			{ 'Нигер', 'Flag of Niger.svg|border' },
			{ 'Нигерия', 'Flag of Nigeria.svg|border' },
			{ 'Сао Томе и Принсипи', 'Flag of Sao Tome and Principe.svg' },
			{ 'Сенегал', 'Flag of Senegal.svg' },
			{ 'Сиера Леоне', 'Flag of Sierra Leone.svg' },
			{ 'Того', 'Flag of Togo.svg' },
			{ 'Чад', 'Flag of Chad.svg' },
				{ 'място в Чад|Чад-гео', 'Flag-map of Chad.svg' },
		{ 'Източна Африка', 'africa-countries-eastern.png' },
			{ 'Джибути', 'Flag of Djibouti.svg' },
			{ 'Еритрея', 'Flag of Eritrea.svg' },
			{ 'Етиопия', 'Flag of Ethiopia.svg' },
			{ 'Кения', 'Flag of Kenya.svg' },
			{ 'Коморските острови|Коморски острови', 'Flag of the Comoros.svg' },
			{ 'Сейшелските острови|Сейшелски острови', 'Flag of the Seychelles.svg' },
			{ 'Сомалия', 'Flag of Somalia.svg' },
				{ 'място в Сомалия|Сомалия-гео', 'Flag-map of Somalia.svg' },
			{ 'Танзания', 'Flag of Tanzania.svg' },
			{ 'Уганда', 'Flag of Uganda.svg' },
		{ 'Северна Африка', 'Africa-countries-northern.svg' },
			{ 'Алжир', 'Flag of Algeria.svg|border' },
			{ 'Египет', 'Flag of Egypt.svg' },
				{ 'Древен Египет', 'Head of the Great Sphinx (icon).png' },
			{ 'Либия', 'Flag of Libya.svg' },
			{ 'Мароко', 'Flag of Morocco.svg' },
			{ 'Судан', 'Flag of Sudan.svg' },
			{ 'Тунис', 'Flag of Tunisia.svg' },
		{ 'Централна Африка', 'Africa-countries-central.svg' },
			{ 'Бурунди', 'Flag of Burundi.svg' },
			{ 'Демократична република Конго|ДР Конго', 'Flag of the Democratic Republic of the Congo.svg' },
			{ 'Екваториална Гвинея', 'Flag of Equatorial Guinea.svg' },
			{ 'Камерун', 'Flag of Cameroon.svg' },
			{ 'Република Конго', 'Flag of the Republic of the Congo.svg' },
			{ 'Руанда', 'Flag of Rwanda.svg' },
			{ 'Централноафриканската република|ЦАР', 'Flag of the Central African Republic.svg' },
		{ 'Южна Африка', 'africa-countries-southern.png' },
			{ 'Ангола', 'Flag of Angola.svg' },
			{ 'Ботсвана', 'Flag of Botswana.svg|border' },
			{ 'Есватини', 'Flag of Eswatini.svg' },
			{ 'Замбия', 'Flag of Zambia.svg' },
			{ 'Зимбабве', 'Flag of Zimbabwe.svg' },
			{ 'Лесото', 'Flag of Lesotho.svg' },
			{ 'Мавриций', 'Flag of Mauritius.svg' },
			{ 'Мадагаскар', 'Flag of Madagascar.svg|border' },
			{ 'Майот', 'Flag of Mayotte (local).svg|border' },
			{ 'Малави', 'Flag of Malawi.svg' },
				{ 'място в Малави|Малави-гео', 'Flag-map of Malawi.svg' },
			{ 'Мозамбик', 'Flag of Mozambique.svg|border' },
			{ 'Намибия', 'Flag of Namibia.svg|border' },
			{ 'Реюнион', 'Armoiries Réunion.svg' },
			{ 'РЮА|ЮАР', 'Flag of South Africa.svg' },
			{ 'Света Елена, Възнесение и Тристан да Куня|Света Елена|Възнесение|остров Възнесение|Тристан да Куня', 'Flag of Saint Helena.svg' },
	{ 'Европа', 'Europe map.png' },
		{ 'Австрия', 'Flag of Austria.svg|border' },
		{ 'Албания', 'Flag of Albania.svg' },
		{ 'Андора', 'Flag of Andorra.svg' },
		{ 'Беларус', 'Flag of Belarus.svg' },
		{ 'Белгия', 'Flag of Belgium.svg' },
		{ 'Босна и Херцеговина|Босна', 'Flag of Bosnia and Herzegovina.svg' },
			{ 'Република Сръбска|Сръбска', 'Flag of the Republika Srpska.svg|border' },
			{ 'Югославия', 'Flag of Yugoslavia (1918–1941).svg' },
		{ 'България', 'Flag of Bulgaria.svg|border' },
			{ 'селище в България|Селище-България', 'Bulgaria stub.svg', 'селища в България' },
				{ 'Ботевград', 'BUL Botevgrad COA.svg' },
				{ 'Бургас', 'Burgas-coat-of-arms.svg' },
				{ 'Варна', 'Gerb_varna.jpg' },
				{ 'Пловдив', 'Plovdiv-coat-of-arms.svg' },
				{ 'Русе', 'emblema_na_grad_ruse.jpg' },
				{ 'Сливен', 'Updated coat of arms of Sliven.png' },
				{ 'София', 'BG Sofia coa.svg' },
				{ 'Търговище', 'Gerba_targovishte.jpg' },
				{ 'Шумен', 'Emblem of Shumen.png' },
		{ 'Ватикана|Ватикан', 'Flag of the Vatican City.svg'},
		{ 'Германия', 'Flag of Germany.svg|border' },
			{ 'Нацистка Германия', 'Reichsadler.svg' },
		{ 'Гърция', 'Flag of Greece.svg' },
			{ 'ВМОРО', 'Flag of the IMARO.svg' },
			{ 'Егейска Македония', 'Flag of Greek Macedonia.svg' },
		{ 'Дания', 'Flag of Denmark.svg' },
		{ 'Древна Гърция', 'ParthenonRekonstruktion.jpg' },
		{ 'Древен Рим', 'She-wolf suckles Romulus and Remus.jpg' },
		{ 'Европейския съюз|Европейски съюз|ЕС', 'Flag of Europe.svg' },
		{ 'Естония', 'Flag of Estonia.svg|border' },
		{ 'Ирландия|Република Ирландия|Ейре', 'Flag of Ireland.svg|border' },
		{ 'Исландия', 'Flag of Iceland.svg' },
		{ 'Испания', 'Flag of Spain.svg' },
			{ 'Мадрид', 'Flag of the Community of Madrid.svg' },
		{ 'Италия', 'Flag of Italy.svg' },
		{ 'Косово', 'Flag of Kosovo.svg' },
		{ 'Латвия', 'Flag of Latvia.svg' },
		{ 'Литва', 'Flag of Lithuania.svg' },
		{ 'Лихтенщайн', 'Flag of Liechtenstein.svg' },
		{ 'Люксембург', 'Flag of Luxembourg.svg' },
		{ 'Малта', 'Flag of Malta.svg|border' },
		{ 'Молдова', 'Flag of Moldova.svg' },
		{ 'Монако', 'Flag of Monaco.svg|border' },
		{ 'Нидерландия|Холандия', 'Flag of the Netherlands.svg|border' },
		{ 'Норвегия', 'Flag of Norway.svg' },
		{ 'Обединеното кралство|Великобритания|ОК', 'Flag of the United Kingdom.svg' },
			{ 'Англия', 'Flag of England.svg|border' },
				{ 'Лондон', 'Coat_of_Arms_of_The_City_of_London.svg' },
			{ 'Северна Ирландия', 'Ni smaller.png' },
			{ 'Уелс', 'Flag of Wales.svg' },
			{ 'Шотландия', 'Flag of Scotland.svg' },
		{ 'Полша', 'Poland map flag.svg' },
		{ 'Португалия', 'Flag of Portugal.svg' },
		{ 'Румъния', 'Flag of Romania.svg' },
		{ 'Сан Марино', 'Flag of San Marino.svg' },
		{ 'Северна Македония|Република Македония|Македония', 'Flag map of North Macedonia.svg' },
		{ 'Словакия', 'Flag of Slovakia.svg|border' },
		{ 'Словения', 'Flag of Slovenia.svg' },
		{ 'Сърбия', 'Flag of Serbia.svg|border' },
		{ 'Украйна', 'Flag of Ukraine.svg' },
			{ 'Одеска област', 'Одесская область.png' },
		{ 'Унгария', 'Flag of Hungary.svg' },
		{ 'Финландия', 'Flag of Finland.svg|border' },
		{ 'Франция', 'Flag of France.svg' },
		{ 'Хърватия', 'Flag of Croatia.svg' },
		{ 'Черна гора', 'Flag of Montenegro.svg' },
		{ 'Чехия', 'Flag of the Czech Republic.svg|border' },
		{ 'Чехословакия', 'Flag of Czechoslovakia.svg|border' },
		{ 'Швейцария', 'Flag of Switzerland.svg' },
		{ 'Швеция', 'Flag of Sweden.svg' },
			{ 'място в Швеция|Швеция-гео', 'Sverige FlaggKarta.svg' },
	{ 'Океания', 'Oceania.jpg' },
		{ 'Австралия', 'Flag of Australia.svg' },
		{ 'Вануату', 'Flag of Vanuatu.svg' },
		{ 'Кирибати', 'Flag of Kiribati.svg' },
		{ 'Маршаловите острови|Маршалови острови', 'Flag of the Marshall Islands.svg' },
		{ 'Науру', 'Flag of Nauru.svg|border' },
		{ 'Нова Зеландия', 'Flag of New Zealand.svg' },
		{ 'Нова Каледония', 'Flag of FLNKS.svg' },
		{ 'Палау', 'Flag of Palau.svg' },
		{ 'Папуа Нова Гвинея', 'Flag of Papua New Guinea.svg' },
		{ 'Питкерн', 'Flag of the Pitcairn Islands.svg' },
		{ 'Самоа', 'Flag of Samoa.svg' },
		{ 'Соломоновите острови|Соломонови острови', 'Flag of the Solomon Islands.svg' },
		{ 'Тонга', 'Flag of Tonga.svg' },
		{ 'Фиджи', 'Flag of Fiji.svg' },
		{ 'Френска Полинезия', 'Flag of French Polynesia.svg' },
	{ 'Северна Америка', 'TinyNorthAmerica.png' },
		{ 'Американските Вирджински острови|Американски Вирджински острови', 'Flag of the United States Virgin Islands.svg|border' },
		{ 'Ангила', 'Flag of Anguilla.svg' },
		{ 'Антигуа и Барбуда|Антигуа|Барбуда', 'Flag of Antigua and Barbuda.svg' },
		{ 'Барбадос', 'Flag of Barbados.svg|border' },
		{ 'Бахамските острови|Бахамски острови|Бахами', 'Flag of the Bahamas.svg|border'},
		{ 'Белиз', 'Flag of Belize.svg' },
		{ 'Бермудските острови|Бермудски острови', 'Flag of Bermuda.svg' },
		{ 'Гваделупа', 'Coat of arms of Guadeloupe.svg' },
		{ 'Гватемала', 'Flag of Guatemala.svg' },
		{ 'Гренада', 'Flag of Grenada.svg' },
		{ 'Гренландия', 'Flag of Greenland.svg|border' },
		{ 'Доминика', 'Flag of Dominica.svg' },
		{ 'Доминиканската република|Доминиканска република', 'Flag of the Dominican Republic.svg' },
		{ 'Канада', 'Flag of Canada.svg|border' },
			{ 'Квебек', 'Flag of Quebec.svg' },
		{ 'Коста Рика', 'Flag of Costa Rica.svg' },
		{ 'Куба', 'Flag of Cuba.svg' },
		{ 'Мексико', 'Flag of Mexico.svg|border' },
		{ 'Никарагуа', 'Flag of Nicaragua.svg|border' },
		{ 'Панама', 'Flag of Panama.svg|border' },
		{ 'Пуерто Рико', 'Flag of Puerto Rico.svg' },
		{ 'Салвадор|Ел Салвадор', 'Flag of El Salvador.svg' },
		{ 'САЩ', 'Flag of the USA.svg' },
			{ 'Айдахо', 'Flag of Idaho.svg' },
			{ 'Айова', 'Flag of Iowa.svg' },
			{ 'Алабама', 'Flag of Alabama.svg|border' },
			{ 'Аляска', 'Flag of Alaska.svg' },
			{ 'Аризона', 'Flag of Arizona.svg' },
			{ 'Арканзас', 'Flag of Arkansas.svg' },
			{ 'Вашингтон', 'Flag of Washington.svg' },
			{ 'Вирджиния', 'Flag of Virginia.svg' },
			{ 'Върмонт|Вермонт', 'Flag of Vermont.svg' },
			{ 'Делауеър', 'Flag of Delaware.svg' },
			{ 'Джорджия', 'Flag of Georgia (U.S. state).svg' },
			{ 'Западна Вирджиния', 'Flag of West Virginia.svg' },
			{ 'Илинойс', 'Flag of Illinois.svg|border' },
			{ 'Индиана', 'Flag of Indiana.svg' },
			{ 'Калифорния', 'Flag of California.svg|border' },
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
			{ 'Канзас', 'Flag of Kansas.svg' },
			{ 'Кентъки', 'Flag of Kentucky.svg' },
			{ 'Колорадо', 'Flag of Colorado.svg' },
			{ 'Кънектикът', 'Flag of Connecticut.svg' },
			{ 'Луизиана', 'Flag of Louisiana.svg' },
			{ 'Масачузетс', 'Flag of Massachusetts.svg|border' },
			{ 'Мейн', 'Flag of Maine.svg' },
			{ 'Мериленд', 'Flag of Maryland.svg' },
			{ 'Минесота', 'Flag of Minnesota.svg' },
			{ 'Мисисипи', 'Flag of Mississippi.svg' },
			{ 'Мисури', 'Flag of Missouri.svg' },
			{ 'Мичиган', 'Flag of Michigan.svg' },
			{ 'щата Монтана|Монтана', 'Flag of Montana.svg', 'Монтана' },
			{ 'Небраска', 'Flag of Nebraska.svg' },
			{ 'Невада', 'Flag of Nevada.svg' },
			{ 'Ню Джърси', 'Flag of New Jersey.svg' },
			{ 'щата Ню Йорк|Ню Йорк', 'Flag of New York.svg', 'Ню Йорк' },
			{ 'Ню Мексико', 'Flag of New Mexico.svg' },
			{ 'Ню Хампшър', 'Flag of New Hampshire.svg' },
			{ 'Оклахома', 'Flag of Oklahoma.svg' },
			{ 'Орегон', 'Flag of Oregon.svg' },
			{ 'Охайо', 'Flag of Ohio.svg' },
			{ 'Пенсилвания', 'Flag of Pennsylvania.svg' },
			{ 'Род Айлънд', 'Flag of Rhode Island.svg' },
			{ 'Северна Дакота', 'Flag of North Dakota.svg' },
			{ 'Северна Каролина', 'Flag of North Carolina.svg' },
			{ 'Тексас', 'Flag of Texas.svg' },
			{ 'Тенеси', 'Flag of Tennessee.svg' },
			{ 'Уайоминг', 'Flag of Wyoming.svg' },
			{ 'Уисконсин', 'Flag of Wisconsin.svg' },
			{ 'Флорида', 'Flag of Florida.svg' },
			{ 'Хаваи', 'Flag of Hawaii.svg' },
			{ 'Южна Дакота', 'Flag of South Dakota.svg' },
			{ 'Южна Каролина', 'Flag of South Carolina.svg' },
			{ 'Юта', 'Flag of Utah.svg' },
		{ 'Сейнт Китс и Невис', 'Flag of Saint Kitts and Nevis.svg' },
		{ 'Сейнт Лусия', 'Flag of Saint Lucia.svg' },
		{ 'Тринидад и Тобаго|Тринидад', 'Flag of Trinidad and Tobago.svg' },
		{ 'Хаити', 'Flag_of_Haiti.svg' },
		{ 'Хондурас', 'Flag of Honduras.svg' },
		{ 'Ямайка', 'Flag of Jamaica.svg' },
	{ 'Южна Америка', 'TinySouthAmerica.png' },
		{ 'Аржентина', 'Flag of Argentina.svg|border' },
		{ 'Боливия', 'Flag of Bolivia.svg' },
		{ 'Бразилия', 'Flag of Brazil.svg' },
		{ 'Венецуела', 'Flag of Venezuela.svg' },
		{ 'Гвиана', 'Flag of Guyana.svg' },
		{ 'Еквадор', 'Flag of Ecuador.svg' },
		{ 'Колумбия', 'Flag of Colombia.svg' },
		{ 'Парагвай', 'Flag of Paraguay.svg' },
		{ 'Перу', 'Flag of Peru.svg' },
		{ 'Суринам', 'Flag of Suriname.svg' },
		{ 'Уругвай', 'Flag of Uruguay.svg' },
		{ 'Фолкландските острови|Фолкландски острови', 'Flag of the Falkland Islands.svg' },
		{ 'Чили', 'Flag of Chile.svg' },
	
	-- МЪНИЧЕТА ЗА НАУКА
	{ 'наука', 'Science-symbol-2.svg' },
		{ 'антропология', 'Neutered kokopelli.svg' },
			{ 'етнография', 'Divotino-traditional-embroidery-1.jpg' },
			{ 'етнос|етническа група|народ', 'Logo sociology.svg', 'етноси' },
		{ 'астрономията|астрономия|космос', 'Pleiades small.jpg', 'астрономия' },
			{ 'астрономически обект', 'Pleiades small.jpg', 'астрономически обекти' },
				{ 'астероид', '951 Gaspra.jpg', 'астероиди' },
				{ 'галактика', 'Artist’s impression of the Milky Way.jpg', 'галактики' },
				{ 'звезда', 'Sirius A and B Hubble photo.jpg', 'звезди' },
				{ 'изкуствен спътник', 'Nasa swift satellite.jpg', 'изкуствени спътници' },
				{ 'Марс', 'Mars (white background).jpg' },
		{ 'биология', 'Butterfly_template.png' },
			{ 'анатомия', 'Gray188.png' },
			{ 'биохимия', 'AlphaHelixSection (yellow).svg' },
			{ 'вирус|вируси', 'Polio.jpg', 'вируси' },
			{ 'генетика', 'DNA Overview.png' },
			{ 'гъба|гъби', 'Karl_Johanssvamp,_Iduns_kokbok.jpg', 'гъби' },
			{ 'еукариот|еукариоти', 'Cronoflagelado2.svg', 'еукариоти' },
			{ 'животно|животни', 'Crystal Clear app babelfish vector.svg', 'животни' },
				{ 'влечуги|влечуго', 'Tortoise (PSF).png'},
				{ 'етология', 'Chicken on a skateboard.JPG' },
				{ 'куче|кинология', 'Dog.svg', 'кучета' },
				{ 'птици', 'Ruddy-turnstone-icon.png' },
			{ 'микробиология', 'Ecoli colonies.png' },
			{ 'прокариот|прокариоти|археи', 'Prokaryote cell diagram.svg', 'прокариоти' },
			{ 'протист|протисти', 'Cronoflagelado2.svg', 'протисти' },
			{ 'растение|растения', 'Dahlia redoute.JPG', 'растения' },
				{ 'ботаника', 'Leaf.png' },
					{ 'алгология', 'Algae Graphic.svg' },
			{ 'физиология', 'Semipermeable membrane (svg).svg' },
				{ 'размножаване', 'ChromosomeArt.jpg' },
					{ 'ембриология', 'Anatomy of an egg unlabeled horizontal.svg' },
		{ 'здраве', 'Heart template.svg' },
			{ 'медицина', 'Medistub.svg' },
				{ 'дентална медицина', 'Lower wisdom tooth.jpg' },
				{ 'заболяване', 'Esculaap4.svg', 'заболявания' },
				{ 'неврология', 'Neuro-stub.png' },
				{ 'офталмология', 'Blue eye.svg' },
				{ 'паразитология', 'Ixodes hexagonus (aka).jpg' },
				{ 'психология', 'Psi2.svg' },
				{ 'фармакология', 'Emoji u1f48a.svg' },
					{ 'антибиотик', 'Capsule, gélule.svg', 'антибиотици' },
		{ 'информатика', 'Computer-blue.svg' },
		{ 'космически изследвания', 'Gas giants in the solar system.jpg' },
			{ 'ракета|ракети', 'Shuttle.svg', 'ракетна техника и космически апарати' },
		{ 'лингвистика|езикознание|фонетика', 'Linguistics stub.svg' },
			{ 'име', 'IPA Unicode 0x026E.svg', 'имена' },
				{ 'титла|пост|длъжност', 'Crown of Italy.svg', 'титли' },
			{ 'език|диалект|езикова група|езиково семейство|говор', 'Noun project 1822.svg', 'езици', link = 'език (лингвистика)' },
		{ 'математика', 'e-to-the-i-pi.svg' },
			{ 'статистика', 'Bellcurve.svg' },
		{ 'етика', 'Sanzio_01_Plato_Aristotle.jpg' },
		{ 'логика', 'logic.svg' },
		{ 'науки за Земята', 'Terrestrial globe.svg' },
			{ 'география|географ', 'Geographylogo.svg' },
				{ 'географски обект', 'Geographylogo.svg' },
					{ 'административна единица|окръг|община|провинция|щат|департамент|област', 'Rajasthan-stub.svg', 'административни единици' },
					{ 'вид място', 'Geographylogo.svg', 'видове места' },
					{ 'водоем|море|язовир|езеро|река', 'Roundtanglelake.JPG', 'водоеми' },
						{ 'язовир', 'Presa de contraforts.svg', 'язовири' },
					{ 'вулкан', 'Noto Project Volcano Emoji.svg', 'вулкани' },
					{ 'измислено място', 'Crystal Clear app wp.png', 'измислени места' },
					{ 'историческа област|историческа държава', 'Map icon.svg', 'исторически области' },
					{ 'място', 'Geographylogo.svg', 'места' },
					{ 'планина', 'Refuge icone.svg', 'планини' },
					{ 'пустиня', 'Emojione 1F42B.svg', 'пустини' },
					{ 'селище|населено място|град|село', 'Pictograma Poblado.PNG', 'селища' },
					{ 'сграда]] или [[съоръжение|сграда|съоръжение|мост', 'Hangar.svg', 'сгради и съоръжения' },
						{ 'археологически обект', 'Noun Project Archaeology icon 1616685 cc.svg', 'археологически обекти' },
						{ 'замък', 'Icone chateau fort.svg', 'замъци' },
						{ 'път|пътища', 'CH-Hinweissignal-Autobahn.svg', 'пътища' },
				{ 'физическа география', 'Orografia.jpg' },
			{ 'геология', 'Geological hammer.svg' },
				{ 'минерал', 'Topaze Brésil2.jpg', 'минерали' },
				{ 'палеонтология', 'Anning plesiosaur.jpg' },
				{ 'сеизмология|земетресение', 'Seismographs.jpg' },
			{ 'екология', 'Forestry Leśnictwo (Beentree).svg' },
				{ 'защитена територия|резерват|национален парк', 'Rayskoto-pruskalo-waterfall-2.jpg', 'защитени територии' },
			{ 'метеорология', 'Cyclone Catarina from the ISS on March 26 2004.JPG' },
		{ 'философия', 'Philosophy_template.gif' },
			{ 'конфуцианство', 'Black Confucian symbol.PNG' },
		{ 'социология', 'People icon.svg' },
		{ 'физика|ядрена физика', 'Science.jpg' },
			{ 'физикохимия', 'Anode effect steel.jpg' },
		{ 'химия', 'Nuvola apps edu science.svg' },
			{ 'неорганична химия', 'Phosphonium-3D-balls.png' },
				{ 'химичен елемент', 'Stylised atom with three Bohr model orbits and stylised nucleus.png', 'химични елементи' },
			{ 'органична химия', 'Cyclooctatetraene-3D-vdW.png' },

		-- други
		{ 'авиация', 'Aero-stub img.svg' },
		{ 'анимация', 'Animhorse.gif' },
		{ 'археология', 'Farm-Fresh vase.png' },
		{ 'архитектура|архитект|градоустройство', 'Corinthian_capital.png' },
		{ 'астрология', 'Mercury symbol.svg' },
		{ 'будизъм', 'Dharma Wheel.svg' },
		{ 'военен конфликт|битка|война|бой|сражение|революция|бунт|въстание', 'Belegeringen 2.svg', 'военни конфликти' },
		{ 'военна история на България', 'Bulgaria war flag.png' },
		{ 'военна история', 'Distintivo avanzamento merito di guerra ufficiali superiori (forze armate italiane).svg' },
		{ 'далекосъобщения|телекомуникации|комуникация', 'Radio Telescope Icon.png' },
		{ 'движение|течение', 'Society.png', 'движения' },
		{ 'древногръцката митология|гръцка митология', 'Minotaur.jpg', 'древногръцка митология' },
		{ 'електроника', 'Transistor stub.svg' },
		{ 'електротехника', 'Transformer-hightolow-ironcore.png' },
		{ 'енергетика', 'Rostock Steinkohlekraftwerk 2.jpg' },
		{ 'земеделие', 'Yorkshire Country Views (26).JPG' },
		{ 'изкуство|фотография', 'David face.png' },
		{ 'икономика', 'TwoCoins.svg' },
		{ 'индуизъм', 'AUM symbol, the primary (highest) name of the God as per the Vedas.svg' },
		{ 'исторически период|епоха|ера', 'P writing icon.svg', 'исторически периоди' },
		{ 'историческо събитие|събитие', 'HSHistory.svg', 'събития' },
		{ 'история', 'P history yellow.png' },
		{ 'история на България|История-България', 'BG His.jpg' },
		{ 'криптозоология|криптиди', 'Mammouth.png' },
		{ 'култура', 'Art template.gif' },
		{ 'митология', 'Draig.svg' },
		{ 'мода|манекен', 'Signorina in viola.svg' },
		{ 'музика', 'Eighth notes and rest.png' },
		{ 'общество', 'Society.png' },
		{ 'политика', 'Society.png' },
		{ 'политология', 'Society.png' },
		{ 'право', 'Scale of justice 2.svg' },
		{ 'псевдонаука', 'Outline-body-Aura.png' },
		{ 'род|династия|семейство|фамилия', 'OOjs UI-like kinship-progressive-black.svg', 'родове' },
		{ 'свойство', 'Hoejde.png', 'свойства' },
		{ 'социална група|общност', 'Society.png', 'социални групи' },
		{ 'техника|технология|инженерство', 'Spur Gear 12mm, 18t.svg' },
		{ 'търговия', 'CashRegister.svg' },
		{ 'устройство|машина|апарат|уред|инструмент', 'Spur Gear 12mm, 18t.svg', 'устройства' },
		{ 'хералдика', 'Azure,_a_bend_Or.svg' },
		{ 'ядрена енергетика', 'Nuclear power plant.svg' },
	
	-- МЪНИЧЕТА ЗА СПОРТ
	{ 'спорт', 'Crystal Clear app clicknrun.png' },
		{ 'баскетбол', 'Basketball.png' },
		{ 'бойно изкуство', 'Yin and Yang symbol.svg', 'бойни изкуства' },
		{ 'бокс|боксьор', 'Icon-boxing-gloves.jpg' },
		{ 'волейбол', 'Volley ball angelo gelmi 01.svg' },
		{ 'колоездене|колоездач', 'Pictgram bicycle man.svg' },
		{ 'покер', '11g poker chips.jpg' },
		{ 'тенис|тенисист', 'Tennis icon.png' },
		{ 'Формула 1|Ф1', 'Ferrari stub.gif' },
		{ 'футбол', 'Soccerball.svg' },
			{ 'ПФК Светкавица', 'Svetkavitza.png' },
			{ 'ЦСКА (София)|ЦСКА', 'CSKA Sofia logo.svg', 'ЦСКА' },
		{ 'шахмат', 'Chess.svg' },
	
	-- КИНО
	{ 'кино', 'Movie template.gif' },
	{ 'американско кино', 'United States film.png' },
	{ 'британско кино', 'UK film clapperboard.svg' },
	{ 'българско кино', 'Movie template.gif' },
	{ 'германско кино', 'Flag of Germany.svg' },
	{ 'италианско кино', 'Flag of Italy.svg' },
	{ 'френско кино', 'Flag of France.svg' },
	
	-- МЪНИЧЕТА ЗА ХОРА
	{ 'човек|личност', 'Crystal Clear app Login Manager.png', 'хора' },
		-- по занятие
		{ 'актьор', 'Ausuebende Audiovision.png', 'актьори' },
			{ 'порно актьор', 'Pink silhouette.svg', 'порно актьори' },
			{ 'танцьор', 'Ballerina-icon.jpg', 'танцьори' },
			{ 'турски актьор', 'Turkey film clapperboard.svg', 'турски актьори' },
		{ 'бизнесмен', 'Crystal kchart.png', 'бизнесмени' },
		{ 'военен', 'Army-personnel-icon.png', 'военни личности' },
		{ 'журналист', 'Trondhjems Adresseavis 17. mai 1905 - framside.JPG', 'журналисти' },
		{ 'изследовател', 'Marco Polo portrait.jpg', 'изследователи' },
		{ 'инженер', 'Engineering.png', 'инженери' },
		{ 'космонавт', 'Astronaut-EVA edit3.png', 'космонавти' },
		{ 'медик|лекар', 'Stethoscope-2.png', 'медици' },
		{ 'музикант|певец|певица|композитор', 'Musical notes.svg', 'музиканти' },
			{ 'китарист', 'Crystal Clear app kguitar gray.svg', 'китаристи' },
		{ 'оператор', 'Filmreel-icon.svg', 'оператори' },
		{ 'писател', 'Quill and ink-wikipedia.png', 'писатели' },
			{ 'немски писател|Германия-писател', 'Flag of Germany.svg', 'немски писатели' },
		{ 'политик', 'People Politician.png', 'политици' },
			{ 'дипломат', 'Crystal_personal.png', 'дипломати' },
		{ 'престъпник', 'Anthonygaggi.jpg', 'престъпници' },
			{ 'пират', 'Pirate Flag of Rack Rackham.svg', 'пирати' },
		{ 'психолог', 'Sigmund freud um 1905.jpg', 'психолози' },
		{ 'режисьор', 'Filmreel-icon.svg', 'режисьори' },
		{ 'спортист', 'Crystal Clear app clicknrun.png', 'спортисти' },
			{ 'алпинист', 'Climber silhouette.svg', 'алпинисти' },
			{ 'футболист', 'Football pictogram.svg', 'футболисти' },
				{ 'български футболист', 'Football pictogram.svg', 'български футболисти' },
			{ 'шахматист', 'Chess.svg', 'шахматисти' },
		{ 'учен', 'Einstein_template.png', 'учени' },
			{ 'астроном', 'Astronomer.svg', 'астрономи' },
			{ 'физик', 'Albert_Einstein_Head.jpg', 'физици' },
			{ 'философ', 'Head Platon Glyptothek Munich 548.jpg', 'философи' },
			{ 'химик', 'AlfredNobel adjusted.jpg', 'химици' },
		{ 'художник|фотограф', 'Vincent Willem van Gogh 107.jpg', 'художници' },
			{ 'скулптор', 'Auguste Rodin - Penseur.png', 'скулптори' },
		{ 'юрист', 'Scale of justice.svg', 'юристи' },
		
		-- по националност
		{ 'американец|американци', 'USA-people-stub-icon.png', 'американци' },
		{ 'арумъните|арумъни|армъни', 'Aromanian flag.svg', 'арумъни' },
		{ 'британец', 'Flag of the United Kingdom.svg', 'британци' },
		{ 'българин|българи', 'Bulgaria people stub icon.svg', 'българи' },
		{ 'германец', 'Flag of Germany.svg', 'германци' },
		{ 'грък', 'Greece people stub icon.png', 'гърци' },
		{ 'канадец', 'Flag of Canada.svg', 'канадци' },
		{ 'руснак', 'Flag of Russia.svg', 'руснаци' },
		{ 'северномакедонец|македонец|Северна Македония-личност|РМ-личност', 'Republic-Macedonia-people-stub-icon.png', 'северномакедонци' },
		{ 'французин', 'Crystal Clear app Login Manager.png', 'французи' },

		-- други
		{ 'благородник|аристократ', 'Coat of arms of Brabant.svg', 'благородници' },
		{ 'български владетел', 'Crown of Bulgaria.svg', 'български владетели' },
		{ 'индианец', 'NSRW Sitting Bull.jpg', 'индианци' },
		{ 'монарх', 'Earlkrona, Nordisk familjebok.png', 'монарси' },
		{ 'светец', 'Saint-stub-icon.jpg', 'светци' },
		{ 'тамплиери', 'Cross templars.svg' },
		{ 'тевтонци', 'CHE Köniz COA.svg' },
		{ 'християнски духовник|епископ|игумен', 'Coa Illustration Cross Greek.svg ', 'християнски духовници' },		
			{ 'папа', 'Emblem of the Papacy SE.svg', 'папи' },
	
	-- ДРУГИ
	{ 'ГНУ|линукс', 'Heckert GNU white.png' },
	{ 'ЛГБТ', 'Gay flag.svg' },
	{ 'НЛО', 'Nuvola apps konquest.png' },
	{ 'Хари Потър', 'HP1 template.gif' },
	{ 'автомобил', 'Red Gallardo icon.png', 'автомобили' },
	{ 'музикален албум|албум', 'Gnome-dev-cdrom-audio.svg', 'музикални албуми' },
	{ 'аниманга', 'Anime stub 2.svg' },
	{ 'артилерия', 'P military green.png' },
	{ 'Библията|библия', 'Decalogue parchment by Jekuthiel Sofer 1768.jpg' },
	{ 'бойна ракета', 'Agm119_penguin.png', 'бойни ракети' },
	{ 'бронирана бойна машина|бронирани|танк', 'Panzer aus Zusatzzeichen 1049-12.svg', 'бронирани бойни машини' },
	{ 'вестник', 'newspaper.svg', 'вестници' },
	{ 'вино', 'Red_Wine_Glass.jpg' },
	{ 'Властелинът на пръстените', 'Unico Anello.png' },
	{ 'военно дело|военна', 'Distintivo avanzamento merito di guerra ufficiali superiori (forze armate italiane).svg' },
	{ 'даоизъм', 'Yin and Yang symbol.svg' },
	{ 'десерт', 'Cassata.jpg', 'десерти' },
	{ 'дзен', 'Enso2.png' },
	{ 'документ|договор|стандарт', 'Crystal Clear mimetype document2.png', 'документи' },
	{ 'вещество|материал', 'Nuvola apps kalzium.png', 'вещества' },
	{ 'електронна игра|компютърна игра|видеоигра', 'Nuvola apps package games.png', 'електронни игри' },
	{ 'железопътен транспорт', 'Aiga railtransportation 25.svg' },
	{ 'игра', 'Tic tac toe.svg', 'игри' },
	{ 'играчка', 'Rubiks cube scrambled.jpg', 'играчки' },
	{ 'изчислителна техника|компютър|компютри|комп', 'Nuvola apps mycomputer.svg' },
	{ 'Интернет', 'Gtk-dialog-info.svg' },
	{ 'Интернет домейн|домейн', 'Crystal Clear app browser.png', 'Интернет домейни' },
	{ 'ислям', 'Allah-green.svg' },
	{ 'книга', 'Books-aj.svg aj ashton 01.svg', 'книги' },
	{ 'комикси|комикс', 'Speech balloon.svg' },
	{ 'предприятие|компания|фирма', 'Factory 1.png', 'предприятия' },
	{ 'корабоплаване|кораб', 'ShipClipart.png' },
	{ 'криптовалута', 'Bitcoin Digital Currency Logo.png', 'криптовалути' },
	{ 'летателен апарат|самолет|хеликоптер|бомбардировач', 'Aero-stub img.svg', 'летателни апарати' },
	{ 'литература', 'Book template.svg' },
	{ 'мебел|обзавеждане', 'Furniture template.svg', 'мебели' },
	{ 'маркетинг', 'Human-emblem-marketing.svg' },
	{ 'Междузвездни войни', 'Star_wars2.svg' },
	{ 'международни отношения', 'Society.png' },
	{ 'мотоциклет', 'Motorsport stub.svg', 'мотоциклети' },
	{ 'музей', 'David face.png', 'музеи' },
	{ 'музикален инструмент', 'Saxophone-icon.svg', 'музикални инструменти' },
	{ 'награда|отличие', 'Cup of Gold.svg', 'отличия' },
	{ 'напитка', 'Emojione BW 1F378.svg', 'напитки' },
	{ 'облекло', 'Signorina in viola.svg' },
	{ 'образование', 'Nuvola apps bookcase.png' },
	{ 'околна среда', 'Leaf.svg' },
	{ 'ООН', 'Flag of the United Nations.svg' },
	{ 'опера', 'RongeTurandot.jpg' },
	{ 'опорно-двигателна система', 'Gray188.png' },
	{ 'вид организация', 'Handshake (Workshop Cologne \'06).jpeg', 'видове организации' },
	{ 'организация', 'Handshake (Workshop Cologne \'06).jpeg', 'организации' }, 
	{ 'оръжие', 'SIG220-Morges.jpg' },
	{ 'парична единица|валута', '5000 Tugriks - Recto.jpg', 'парични единици' },
	{ 'партия', 'Political_template.gif', 'партии' },
	{ 'песен', 'Musical notes.svg', 'песни' },
	{ 'пиеса', 'Comedy and tragedy masks.svg', 'пиеси' },
	{ 'подводница', 'Orzel.svg', 'подводници' },
	{ 'православие', 'Cross of the Russian Orthodox Church 01.svg' },
	{ 'празник', 'Calendar icon.svg', 'празници' },
	{ 'произведение', 'Deus Drawing.png', 'произведения' },
	{ 'произведение на изкуството|творба|скулптура|картина', 'P Art2 green1.png', 'произведения на изкуството' },
	{ 'процес|дейност', 'Noun Project process icon 2796062.svg', 'процеси' },
	{ 'пчеларство', 'Wappen Frankfurt-Bockenheim.png' },
	{ 'радио', 'Radio icon.png' },
	{ 'религия', 'P religion world.svg' },
	{ 'риболов', 'Fishing.svg' },
	{ 'секс', 'Sexuality icon.svg' },
	{ 'сериал', 'Television icon.svg', 'сериали' },
	{ 'софтуер', 'Crystal Clear app kpackage.png' },
	{ 'списание', 'Magazine.svg', 'списания' },
	{ 'стадион', 'Colosseum-2003-07-09.jpg', 'стадиони' },
	{ 'строителство', 'P building.png' },
	{ 'счетоводство', 'Crystal kchart.png' },
	{ 'танц', 'Ballerina-icon.jpg', 'танци' },
	{ 'театър', 'P culture.svg' },
	{ 'телевизионно предаване', 'Television icon.svg', 'телевизионни предавания' },
	{ 'телевизия', 'Television icon.svg' },
	{ 'транспорт', 'Swedish road sign 11 13 12.svg' },
	{ 'уебсайт', 'Crystal Clear mimetype html.png', 'уебсайтове' },
	{ 'Уикипедия', 'Wikipedia-logo-v2.svg' },
	{ 'университет|висше училище', 'Graduation hat.svg', 'университети' },
	{ 'училище', 'Lectura crítica.jpg', 'училища' },
	{ 'фантастика', 'Nuvola apps konquest.png' },
	{ 'феминизъм', 'FemalePink.png' },
	{ 'фентъзи', 'Dwarf.jpg' },
	{ 'филм', 'Sound mp3.png', 'филми' },
	{ 'финанси', '5000 Tugriks - Recto.jpg' },
	{ 'хардуер', 'Nuvola apps kcmprocessor.png' },
	{ 'храм', 'Religion 07.svg', 'храмове' },
	{ 'храна', 'Foodlogo2.svg', 'храна и напитки' },
	{ 'християнство', 'Coa Illustration Cross Greek.svg ' },
	{ 'шинтоизъм', 'Black Shintoist symbol.PNG' },
	{ 'юдаизъм', 'Star of David2.svg' },
	{ 'явление', 'Noun Big Bang Icon 58857.svg', 'явления' },
}

local function toLower(str)
	return mw.language.getContentLanguage():lc(str)
end

local function printStub(theme, image, plural, pagelink)
	local editLink = tostring(mw.uri.canonicalUrl(mw.title.getCurrentTitle().fullText, 'action=edit'))
	
	local themeText = ''
	if theme then
		if pagelink then theme = pagelink .. '|' .. theme end
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

local function checkStubSize()
	local content = mw.title.getCurrentTitle():getContent()
	if content then
		local size = content:len()
		local temp
		content = mw.ustring.lower(content)

		-- без шаблони и уикитаблици
		content = mw.ustring.gsub(content, '%b{}', function(cap)
			if mw.ustring.match(cap, '^{[{|]') and mw.ustring.match(cap, '[|}]}$') then
				cap = ''
			end
			return cap
		end)
		
		-- без източници
		content = mw.ustring.gsub(content, '<%f[%w]ref%f[%W][^>]*/>', '') -- премахване на самозатварящи се ref тагове
		content = mw.ustring.gsub(content, '<%f[%w]ref%f[%W][^>]*>.-</%f[%w]ref%f[%W][^>]*>', '')
		
		-- без галерии
		content = mw.ustring.gsub(content, '<%f[%w]gallery%f[%W][^>]*>.-</%f[%w]gallery%f[%W][^>]*>', '')
		
		-- без файлове и категории; обикновен текст вместо препратки
		content = mw.ustring.gsub(content, '%b[]', function(cap)
			local prefix = mw.ustring.match(cap, '^%[%[%s*([a-zа-я]+):')
			
			if prefix and (prefix == 'файл' or prefix == 'картинка' or prefix == 'категория' or
							prefix == 'file' or prefix == 'image' or prefix == 'category') then
				return ''
			end
			
			-- [B A] => A
			cap = mw.ustring.gsub(cap, '%[https?://[^%s%[%]]+([^%[%]]*)%]', '%1')
			cap = mw.ustring.gsub(cap, '%[//[^%s%[%]]+([^%[%]]*)%]', '%1')
			
			-- [[A]] => A
			cap = mw.ustring.gsub(cap, '%[%[([^%|%[%]]+)%]%]', '%1')
			
			-- [[B|A]] => A
			cap = mw.ustring.gsub(cap, '%[%[[^%|%[%]]+%|([^%[%]]*)%]%]', '%1')
			
			return cap
		end)
		
		-- без съдържание в клетки на неуикифицирани таблици
		repeat
			temp = content
			content = mw.ustring.gsub(content, '<%f[%w]t[dh]%f[%W][^>]*>.-(</?%f[%w]t[dhr]%f[%W][^>]*>)', '%1')
			content = mw.ustring.gsub(content, '<%f[%w]t[dh]%f[%W][^>]*>.-(</?%f[%w]table%f[%W][^>]*>)', '%1')
		until content == temp
		
		-- без тагове
		content = mw.ustring.gsub(content, '</?%f[%w][a-z]+%f[%W][^>]*>', '')
		
		-- без коментари
		content = mw.ustring.gsub(content, '<!%-%-.-%-%->', '')
		
		-- без раздели
		repeat
			temp = content
			content = mw.ustring.gsub(content, '\n(=+)[^\n]+%1%s*\n', '\n')
		until content == temp
		
		-- поне 4 букви в дума на кирилица
		local _, words = mw.ustring.gsub(content, '[а-я][а-я][а-я][а-я]+', '')
		if words >= 500 then
			-- мъниче с над 500 думи
			CATEGORY = CATEGORY .. '[[Категория:Мъничета с над 500 думи]]'
		elseif size >= 10000 then
			-- мъниче с размер над 10kb
			CATEGORY = CATEGORY .. '[[Категория:Мъничета над 10kb]]'
		end
	end
end

function p.get(frame)
	local stub = ''
	if frame.args[1] and frame.args[1] ~= '' then
		for i, theme in pairs(frame.args) do
			if theme ~= '' then
				local found = false
				for i=1, #THEMES do
					local themes = mw.text.split(THEMES[i][1], '|')
					for j=1, #themes do
						if toLower(theme) == toLower(themes[j]) then
							local plural = THEMES[i][3]
							stub = stub .. printStub(themes[1], THEMES[i][2], plural, THEMES[i]['link'])
							CATEGORY = string.format('%s[[%s за %s]]', CATEGORY, STUBCAT, plural and plural or themes[1])
							found = true
							break
						end
					end
				end
				
				if not found then
					stub = stub .. '<div><strong class="error">Грешка в записа: Неразпозната тема "' .. frame.args[i] .. '"</strong></div>'
					CATEGORY = CATEGORY .. '[[Категория:Страници с грешки]]'
				end
			end
		end
	else
		stub = printStub(nil, 'M Puzzle.png')
		CATEGORY = string.format('[[%s]]', STUBCAT)
	end
	
	if mw.title.getCurrentTitle().namespace == 0 then
		checkStubSize()
		stub = stub .. CATEGORY
	end
	
	return stub
end

return p
