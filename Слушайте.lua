local mFileLink = require('Module:File link')
local mTableTools = require('Module:TableTools')
local mSideBox = require('Module:Side box')
local lang = mw.language.new('en')

local p = {}

local function formatLength(length)
	-- Formats a duration in seconds in "(h:)mm:ss" (minutes are zero-padded
	-- only if there are hours).
	if not length or length == 0 then
		return nil
	end

	-- Add 0.5 to offset the rounding down
	local t = lang:getDurationIntervals(length + 0.5, { 'hours', 'minutes', 'seconds' })
	local s = t.seconds and string.format('%02d', t.seconds) or '00'
	local m = t.minutes or 0

	local span = mw.html.create('span'):addClass('duration')
	if t.hours then
		span
			:tag('span')
				:addClass('h')
				:wikitext(t.hours)
				:done()
			:wikitext(':')
		m = string.format('%02d', m)
	end
	span
		:tag('span')
			:addClass('min')
			:wikitext(m)
			:done()
		:wikitext(':')
		:tag('span')
			:addClass('s')
			:wikitext(s)
			:done()
	return tostring(span)
end

local function renderRow(filename, title, play, alt, description, start, length, hasImage)
	-- Renders the HTML for one file description row.
	if not filename then
		return nil
	end

	length = formatLength(length)
	length = length and string.format(' (%s)', length) or ''

	local root = mw.html.create('')
	root:tag('div')
		:addClass('haudio')
		:newline()
		:tag('div')
			:addClass('listen-file-header')
			:wikitext(string.format(
				'[[:File:%s|%s]]%s',
				filename,
				title or '',
				length
			))
			:done()
		:newline()
		:tag('div')
			:wikitext(play ~= 'no' and mFileLink._main{
					file = filename,
					size = hasImage and '232px' or '215px',
					alt = alt,
					start = start
				}
				or nil
			)
			:done()
		:newline()
		:tag('div')
			:addClass('description')
			:wikitext(description)
			:done()
		:done()
	return tostring(root)
end

local function renderTrackingCategories(isPlain, hasMissing, isEmpty, titleObj)
	-- Renders all tracking categories produced by the template.
	-- isPlain, hasMissing and isEmpty are passed through from p._main,
	-- and the titleObj is only used for testing purposes.
	local cats = {}
	local currentTitle = titleObj or mw.title.getCurrentTitle()
	if currentTitle.namespace == 0 then
		-- We are in mainspace.
		if not isEmpty then
			cats[#cats + 1] = 'Articles with hAudio microformats'
		end
		if hasMissing then
			cats[#cats + 1] = 'Articles with empty listen template'
		end
	end
	if isPlain then
		cats[#cats + 1] = 'Listen template using plain parameter'
	end
	for i, cat in ipairs(cats) do
		cats[i] = string.format('[[Category:%s]]', cat)
	end
	return table.concat(cats)
end

function p._main(args)
	-- Organise the arguments by number.
	local isPlain = args.plain == 'yes'
	local isEmbedded = args.embed and true
	local hasImage = not isPlain and not isEmbedded and args.image ~= 'none'

	local numArgs, missingFiles = {}, {}
	do
		local origNumArgs = mTableTools.numData(args)
		origNumArgs[1] = origNumArgs.other -- Overwrite args.filename1 etc. with args.filename etc.
		origNumArgs = mTableTools.compressSparseArray(origNumArgs)
		for i, t in ipairs(origNumArgs) do
			-- Check if the files exist.
			local obj = t.filename and mw.title.makeTitle(-2, t.filename)
			if obj and obj.exists then
				if t.length == 'yes' or
					-- Show length if the video height would be less than 150px
					obj.file.width / obj.file.height > (hasImage and 1.547 or 1.434)
				then
					t.length = obj.file.length
				else
					t.length = nil
				end
				numArgs[#numArgs + 1] = t
			else
				missingFiles[#missingFiles + 1] = t.filename or i
			end
		end
	end

	-- Render warning
	local hasMissing = #missingFiles ~= 0
	local previewWarning = ''
	if hasMissing then
		for i, v in ipairs(missingFiles) do
			missingFiles[i] = type(v) == 'string'
				and string.format('missing file "%s"', v)
				or string.format('empty filename #%s', v)
		end
		previewWarning = string.format(
			'Page using [[Template:Listen]] with %s',
			mw.text.listToText(missingFiles)
		)
		previewWarning = require('Module:If preview')._warning({previewWarning})
	end

	-- Exit early if none exist.
	if #numArgs == 0 then
		return previewWarning .. renderTrackingCategories(isPlain, hasMissing, true)
	end

	-- Build the arguments for {{side box}}
	local sbArgs = {
		metadata = 'no',
		position = (isPlain or isEmbedded) and 'left' or args.pos,
		style = args.style,
		templatestyles = 'Module:Listen/styles.css'
	}

	-- Class arguments
	do
		local class = {
			'listen',
			'noprint'
		}
		if isPlain then
			table.insert(class, 'listen-plain')
		end
		if isEmbedded then
			table.insert(class, 'listen-embedded')
		end
		if not hasImage then
			table.insert(class, 'listen-noimage')
		end
		if args.pos == 'left' and not isPlain and not isEmbedded then
			table.insert(class, 'listen-left')
		elseif args.pos == 'center' then
			table.insert(class, 'listen-center')
		end

		sbArgs.class = table.concat(class, ' ')
	end

	-- Image
	if not isPlain and not isEmbedded then
		if args.image then
			sbArgs.image = args.image
		else
			local images = {
				speech = 'Audio-input-microphone.svg',
				music = 'Gnome-mime-audio-openclipart.svg',
				default = 'Gnome-mime-sound-openclipart.svg'
			}
			sbArgs.image = mFileLink._main{
				file = args.type and images[args.type] or images.default,
				size = '65x50px',
				location = 'center',
				link = '',
				alt = ''
			}
		end
	end

	-- Text
	do
		local header
		if args.header then
			header = mw.html.create('div')
			header:addClass('listen-header')
				:wikitext(args.header)
			header = tostring(header) .. '\n'
		else
			header = ''
		end
		local text = {}
		for i, t in ipairs(numArgs) do
			text[#text + 1] = renderRow(
				t.filename, t.title, t.play, t.alt, t.description, t.start,
				t.length, hasImage
			)
			if numArgs[i + 1] then
				text[#text + 1] = '<hr/>'
			end
		end
		sbArgs.text = header .. table.concat(text)
	end

	-- Below
	if not isPlain and not isEmbedded and args.help ~= 'no' then
		sbArgs.below = string.format(
			'<hr/><i class="selfreference">Problems playing %s? See [[Help:Media|media help]].</i>',
			#numArgs == 1 and 'this file' or 'these files'
		)
	end

	-- Render the side box.
	local sideBox = mSideBox._main(sbArgs)

	-- Render the tracking categories.
	local trackingCategories = renderTrackingCategories(isPlain, hasMissing)

	return previewWarning .. sideBox .. trackingCategories
end

function p.main(frame)
	local origArgs = frame:getParent().args
	local args = {}
	for k, v in pairs(origArgs) do
		if v ~= '' then
			args[k] = v
		end
	end
	return p._main(args)
end

return p
