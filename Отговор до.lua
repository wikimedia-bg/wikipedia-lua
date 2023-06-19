local p = {}

local function makeError(msg)
	msg ='Грешка в [[Шаблон:Отговор до]]: ' .. msg
	return mw.text.tag('strong', {['class']='error'}, msg)
end

function p.replyto(frame)
	local origArgs = frame:getParent().args
	local args = {}
	local maxArg = 1
	local usernames = 0
	for k, v in pairs(origArgs) do
		if type(k) == 'number' then
			if mw.ustring.match(v,'%S') then
				if k > maxArg then maxArg = k end
				usernames = usernames + 1
				local title = mw.title.new(v)
				if not title then return makeError('Въведеното съдържа забранени знаци.') end
				args[k] = title.rootText
			end
		elseif v == '' and k:sub(0,5) == 'label' then
			args[k] = '&#x200B;'
		else
			args[k] = v
		end
	end

	if usernames > (tonumber(frame.args.max) or 50) then
		return makeError(string.format(
			'Посочени са над %s имена.',
			tostring(frame.args.max or 50)
		))
	else
		if usernames < 1 then
			if frame.args.example then args[1] = frame.args.example else return makeError('Потребителското име не е дадено.') end
		end
		args['label1'] = args['label1'] or args['label']
		local isfirst = true
		local outStr = args['prefix'] or '@'
		for i = 1, maxArg do
			if args[i] then
				if isfirst then
					isfirst = false
				else
					if ( (usernames > 2) or ((usernames == 2) and (args['c'] == '')) ) then outStr = outStr..', ' end
					if i == maxArg then outStr = outStr..' '..(args['c'] or 'и') .. ' ' end
				end
				outStr = string.format(
					'%s[[User:%s|%s]]',
					outStr,
					args[i],
					args['label'..tostring(i)] or args[i]
				)
			end
		end
		outStr = outStr..(args['p'] or ':')
		return mw.text.tag('span', {['class']='template-ping'}, outStr)
	end
end

return p
