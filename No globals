local mt = getmetatable(_G) or {}
function mt.__index (t, k)
	if k ~= 'arg' then
		error('Опит за четене на празна глобална променлива ' .. tostring(k), 2)
	end
	return nil
end
function mt.__newindex(t, k, v)
	if k ~= 'arg' then
		error('Опит за запис на глобална променлива ' .. tostring(k), 2)
	end
	rawset(t, k, v)
end
setmetatable(_G, mt)