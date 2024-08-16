local p = {}

local function getListItem( data )
    if not type( data ) == 'string' then
        return ''
    end
    return mw.ustring.format( '<li style="line-height: inherit; margin: 0">%s</li>', data )
end

-- Returns an array containing the keys of all positional arguments
-- that contain data (i.e. non-whitespace values).
local function getArgNums( args )
    local nums = {}
    for k, v in pairs( args ) do
        if type( k ) == 'number' and
            k >= 1 and
            math.floor( k ) == k and
            type( v ) == 'string' and
            mw.ustring.match( v, '%S' ) then
                table.insert( nums, k )
        end
    end
    table.sort( nums )
    return nums
end

-- Formats a list of classes, styles or other attributes.
local function formatAttributes( attrType, ... )
    local attributes = { ... }
    local nums = getArgNums( attributes )
    local t = {}
    for i, num in ipairs( nums ) do
        table.insert( t, attributes[ num ] )
    end
    if #t == 0 then
        return '' -- Return the blank string so concatenation will work.
    end
    return mw.ustring.format( ' %s="%s"', attrType, table.concat( t, ' ' ) )
end

-- TODO: use Module:List. Since the update for this comment is routine,
-- this is blocked without a consensus discussion by
-- [[MediaWiki_talk:Common.css/Archive_15#plainlist_+_hlist_indentation]]
-- if we decide hlist in plainlist in this template isn't an issue, we can use
-- module:list directly
-- [https://en.wikipedia.org/w/index.php?title=Module:Collapsible_list/sandbox&oldid=1130172480]
-- is an implementation (that will code rot slightly I expect)
local function buildList( args )
    -- Get the list items.
    local listItems = {}
    local argNums = getArgNums( args )
    for i, num in ipairs( argNums ) do
        table.insert( listItems, getListItem( args[ num ] ) )
    end
    if #listItems == 0 then
        return ''
    end
    listItems = table.concat( listItems )

	-- hack around mw-collapsible show/hide jumpiness by looking for text-alignment
	-- by setting a margin if centered
	local textAlignmentCentered = 'text%-align%s*:%s*center'
	local centeredTitle = (args.title_style and args.title_style:lower():match(textAlignmentCentered)
		or args.titlestyle and args.titlestyle:lower():match(textAlignmentCentered))
	local centeredTitleSpacing
	if centeredTitle then
		centeredTitleSpacing = 'margin: 0 4em'
	else
		centeredTitleSpacing = ''
	end

    -- Get class, style and title data.
    local collapsibleContainerClass = formatAttributes(
    	'class',
    	'collapsible-list',
    	'mw-collapsible',
    	not args.expand and 'mw-collapsed'
    )
    local collapsibleContainerStyle = formatAttributes(
        'style',
         -- mostly work around .infobox-full-data defaulting to centered
        'text-align: left;',
        args.frame_style,
        args.framestyle
    )
    local collapsibleTitleStyle = formatAttributes(
        'style',
        'line-height: 1.6em; font-weight: bold;',
        args.title_style,
        args.titlestyle
    )
    local jumpyTitleStyle = formatAttributes(
        'style',
        centeredTitleSpacing
    )
    local title = args.title or 'Списък'
    local ulclass = formatAttributes( 'class', 'mw-collapsible-content', args.hlist and 'hlist' )
    local ulstyle = formatAttributes( 
        'style',
        'margin-top: 0; margin-bottom: 0; line-height: inherit;',
        not args.bullets and 'list-style: none; margin-left: 0;',
        args.list_style,
        args.liststyle
    )
    
    local hlist_templatestyles = ''
    if args.hlist then
    	hlist_templatestyles = mw.getCurrentFrame():extensionTag{
    		name = 'templatestyles', args = { src = 'Hlist/styles.css' }
    	}
    end
    
    -- Build the list.
    return mw.ustring.format( 
        '%s<div%s%s>\n<div%s><div%s>%s</div></div>\n<ul%s%s>%s</ul>\n</div>',
        hlist_templatestyles, collapsibleContainerClass, collapsibleContainerStyle,
        collapsibleTitleStyle, jumpyTitleStyle, title, ulclass, ulstyle, listItems
    )
end

function p.main( frame )
    local origArgs
    if frame == mw.getCurrentFrame() then
        origArgs = frame:getParent().args
        for k, v in pairs( frame.args ) do
            origArgs = frame.args
            break
        end
    else
        origArgs = frame
    end
    
    local args = {}
    for k, v in pairs( origArgs ) do
        if type( k ) == 'number' or v ~= '' then
            args[ k ] = v
        end
    end
    return buildList( args )
end

return p
