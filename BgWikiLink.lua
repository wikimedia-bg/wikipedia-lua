local str = {}

function str.replace( frame )
    local new_args = str._getParameters( frame.args, {'text'} ); 
    local source_str = new_args['text'] or '';
 
    if source_str == '' then
        return source_str;
    end    
 
    local case1 = mw.ustring.gsub( source_str, '%[%[([^%|]+)%|([^%|]*)%]%]', '[[:bg:%1|%2]]' );  
    local case2 = mw.ustring.gsub( case1, '%[%[([^%|]+)%]%]', '[[:bg:%1|]]' );
 
    return case2;
end

function str._getParameters( frame_args, arg_list )
    local new_args = {};
    local index = 1;
    local value;
 
    for i,arg in ipairs( arg_list ) do
        value = frame_args[arg]
        if value == nil then
            value = frame_args[index];
            index = index + 1;
        end
        new_args[arg] = value;
    end
 
    return new_args;
end        

return str