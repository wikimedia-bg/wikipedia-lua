-- Настоящия модул внедрява {{съкр}}.

-- Инициализиране на константи
local CONFIG_MODULE = 'Модул:Shortcut/config'

-- Зареждане на нужните модули
local checkType = require('libraryUtil').checkType
local yesno = require('Модул:Yesno')

local p = {}

local function message(msg, ...)
	return mw.message.newRawMessage(msg, ...):plain()
end

local function makeCategoryLink(cat)
	return string.format('[[%s:%s]]', mw.site.namespaces[14].name, cat)
end

function p._main(shortcuts, options, frame, cfg)
	checkType('_main', 1, shortcuts, 'table')
	checkType('_main', 2, options, 'table', true)
	options = options or {}
	frame = frame or mw.getCurrentFrame()
	cfg = cfg or mw.loadData(CONFIG_MODULE)
	local isCategorized = yesno(options.category) ~= false

	-- Валидиране на съкращенията
	for i, shortcut in ipairs(shortcuts) do
		if type(shortcut) ~= 'string' or #shortcut < 1 then
			error(message(cfg['invalid-shortcut-error'], i), 2)
		end
	end

	-- Създаване на списък. Съдържа съкращенията плюс всякакви допълнителни
	-- редове като например options.msg.
	local listItems = {}
	for i, shortcut in ipairs(shortcuts) do
		listItems[i] = string.format('[[%s]]', shortcut)
	end
	table.insert(listItems, options.msg)

	-- Върни грешка в случай, че няма какво да покаже
	if #listItems < 1 then
		local msg = cfg['no-content-error']
		msg = string.format('<strong class="error">%s</strong>', msg)
		if isCategorized and cfg['no-content-error-category'] then
			msg = msg .. makeCategoryLink(cfg['no-content-error-category'])
		end
		return msg
	end

	local root = mw.html.create()

	-- Котви
	local anchorDiv = root
		:tag('div')
			:css('position', 'relative')
			:css('top', '-3em')
	for i, shortcut in ipairs(shortcuts) do
		local anchor = mw.uri.anchorEncode(shortcut)
		anchorDiv:tag('span'):attr('id', anchor)
	end

	root:newline() -- За съчетаване със стария [[Шаблон:Съкр]]

	-- Заглавие на съкращението
	local shortcutHeading
	do
		local nShortcuts = #shortcuts
		if nShortcuts > 0 then
			shortcutHeading = message(cfg['shortcut-heading'], nShortcuts)
			shortcutHeading = frame:preprocess(shortcutHeading)
			shortcutHeading = shortcutHeading .. '\n'
		end
	end

	-- Каре за съкращенията
	local shortcutList = root
		:tag('div')
			:addClass('shortcutbox plainlist noprint')
			:attr('role', 'note')
			:css('float', 'right')
			:css('border', '1px solid #aaa')
			:css('background', '#fff')
			:css('margin', '.3em .3em .3em 1em')
			:css('padding', '.4em .6em')
			:css('text-align', 'center')
			:css('font-size', 'smaller')
			:css('line-height', '2em')
			:css('font-weight', 'bold')
			:wikitext(shortcutHeading)
				:tag('ul')
	for i, item in ipairs(listItems) do
		shortcutList:tag('li'):wikitext(item)
	end

	-- Върни категория грешка ако първото съкращение не съществува
	if isCategorized
		and shortcuts[1]
		and cfg['first-parameter-error-category']
	then
		local title = mw.title.new(shortcuts[1])
		if not title or not title.exists then
			root:wikitext(makeCategoryLink(cfg['first-parameter-error-category']))
		end
	end

	return tostring(root)
end

function p.main(frame)
	local args = require('Модул:Arguments').getArgs(frame, {
		wrappers = { 'Шаблон:Съкр', 'Шаблон:Ombox/shortcut' }
	})

	-- Разделяне на съкращенията от опциите
	local shortcuts, options = {}, {}
	for k, v in pairs(args) do
		if type(k) == 'number' then
			shortcuts[k] = v
		else
			options[k] = v
		end
	end

	-- Компресиране на масива от съкращения, може да съдържа нулеви стойности
	local function compressArray(t)
		local nums, ret = {}, {}
		for k in pairs(t) do
			nums[#nums + 1] = k
		end
		table.sort(nums)
		for i, num in ipairs(nums) do
			ret[i] = t[num]
		end
		return ret
	end
	shortcuts = compressArray(shortcuts)

	return p._main(shortcuts, options, frame)
end

return p
