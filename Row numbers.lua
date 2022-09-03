require('Module:No globals');

local count;
local hcount;


--[[--------------------------< G E T _ C O U N T >------------------------------------------------------------

returns a counter value according to the keyword extracted from the table; maintains count and hcount.  Inserts
a space character ahead of <count> or <hcount> so that, in the case of negative indexes, the negation operator 
is not mistaken for part of the wikitable markup.  Returns:
	| -<count> – a cell value
instead of:
	|-<count> – row markup with extraneous text

The keywords have the meanings:
	_row_count:			use row counter value (count); the hold counter (hcount) is same as count
	_row_count_hold:	use the value currently assigned to hcount; bump count but do not bump hcount

]]

local function get_count (keyword)
	count = count + 1;															-- always bump the count
	if '_row_count' == keyword then												-- bump hcount, return new count value
		hcount = count;
		return ' ' .. count;													-- insert a leading space ahead of count
	elseif '_row_count_hold' == keyword then									-- current hcount value without increment
		return ' ' .. hcount;													-- insert a leading space ahead of hcount
	end
end


--[[--------------------------< R O W _ N U M B E R S >--------------------------------------------------------

replaces keywords _row_count and _row_count_hold from the table in frame.args[1]

]]

local function row_numbers (frame)
	local args = frame.args[1] and frame.args or frame:getParent().args;
	
	-- Only use if |index is a number; |index= may be omitted (nil), or empty string, or non-digit
	-- We subtract one because the get_count function increments this before use.
	count = (tonumber(args.index) or 1) - 1;

	local tbl_str;
	-- Find out if what we got for input has been wrapped in <nowiki>...</nowiki> tags
	if args[1]:match ('^%s*\127[^\127]*UNIQ%-%-nowiki%-%x%x%x%x%x%x%x%x%-QINU[^\127]*\127%s*$') then
		-- BUG. The <nowiki> trick does not work in VisualEditor, mobile app, or Special:ExpandTemplates.
		-- get the table from the nowiki tags passed as arguments
		tbl_str = mw.text.unstripNoWiki (args[1]);

		-- undo <nowiki>'s escaping of the wikitext (mw.text.decode (tbl_str); is too aggressive)
		tbl_str = tbl_str:gsub('&lt;', '<'):gsub('&gt;', '>');
	else
		-- No MediaWiki bugs here (hopefully), but you need to escape = signs with {{=}} like normal.
		-- It is not possible to circumvent this because named parameters are not passed to Lua in a
		-- defined order, always have whitespace trimmed, etc.
		local parts = {}
		for _, str in ipairs(args) do
			table.insert(parts, str)
		end
		tbl_str = table.concat(parts, '|');
	end
	-- if there is at least one of our special reserved words, replace it with a count
	return frame:preprocess (tbl_str:gsub('_row_count[_%w]*', get_count));
end


--[[--------------------------< E X P O R T E D   F U N C T I O N S >------------------------------------------
]]

return {
	row_numbers = row_numbers
	}
