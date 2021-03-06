-- Function allowing for consistent treatment of boolean-like wikitext input.
-- It works similarly to the template {{yesno}}.

return function (val, default)
	val = type(val) == 'string' and val:ulower() or val
	if val == nil then
		return nil
	elseif val == true
		or val == 'да'
		or val == 'д'
		or val == 'yes'
		or val == 'y'
		or val == 'true'
		or val == 'вярно'
		or tonumber(val) == 1
	then
		return true
	elseif val == false
		or val == 'не'
		or val == 'н'
		or val == 'no'
		or val == 'n'
		or val == 'false'
		or val == 'грешно'
		or tonumber(val) == 0
	then
		return false
	else
		return default
	end
end