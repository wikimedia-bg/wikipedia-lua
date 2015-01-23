--------------------------------------------------------------------------------
--            [[Module:Category handler]] configuration data                  --
--       Language-specific parameter names and values can be set here.        --
--       For blacklist config, see [[Module:Category handler/blacklist]].     --
--------------------------------------------------------------------------------

local cfg = {} -- Don't edit this line.

--------------------------------------------------------------------------------
--                       Start configuration data                             --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                              Parameter names                               --
-- These configuration items specify custom parameter names.                  --
-- To add one extra name, you can use this format:                            --
--                                                                            --
-- foo = 'parameter name',                                                    --
--                                                                            --
-- To add multiple names, you can use this format:                            --
--                                                                            --
-- foo = {'parameter name 1', 'parameter name 2', 'parameter name 3'},        --
--------------------------------------------------------------------------------

cfg.parameters = {
	
	-- The nocat and categories parameter suppress
	-- categorisation. They are used with Module:Yesno, and work as follows:
	--
	-- cfg.nocat:
	-- Result of yesno()                        Effect
	-- true                                     Categorisation is suppressed
	-- false                                    Categorisation is allowed, and
	--                                          the blacklist check is skipped
	-- nil                                      Categorisation is allowed
	--
	-- cfg.categories:
	-- Result of yesno()                        Effect
	-- true                                     Categorisation is allowed, and
	--                                          the blacklist check is skipped
	-- false                                    Categorisation is suppressed
	-- nil                                      Categorisation is allowed
	nocat = 'nocat',
	categories = 'categories',
	
	-- The parameter name for the legacy "category2" parameter. This skips the
	-- blacklist if set to the cfg.category2Yes value, and suppresses
	-- categorisation if present but equal to anything other than
	-- cfg.category2Yes or cfg.category2Negative.
	category2 = 'category2',
	
	-- cfg.subpage is the parameter name to specify how to behave on subpages.
	subpage = 'subpage',
	
	-- The parameter for data to return in all namespaces.
	all = 'all',
	
	-- The parameter name for data to return if no data is specified for the
	-- namespace that is detected.
	other = 'other',
	
	-- The parameter name used to specify a page other than the current page;
	-- used for testing and demonstration.
	demopage = 'page',
}

--------------------------------------------------------------------------------
--                              Parameter values                              --
-- These are set values that can be used with certain parameters. Only one    --
-- value can be specified, like this:                                         --
--                                                                            --
-- cfg.foo = 'value name'                                                     --                                               --
--------------------------------------------------------------------------------

-- The following settings are used with the cfg.category2 parameter. Setting
-- cfg.category2 to cfg.category2Yes skips the blacklist, and if cfg.category2
-- is present but equal to anything other than cfg.category2Yes or
-- cfg.category2Negative then it supresses cateogrisation.
cfg.category2Yes = 'yes'
cfg.category2Negative = '¬'

-- The following settings are used with the cfg.subpage parameter.
-- cfg.subpageNo is the value to specify to not categorise on subpages;
-- cfg.subpageOnly is the value to specify to only categorise on subpages.
cfg.subpageNo = 'no'
cfg.subpageOnly = 'only'

--------------------------------------------------------------------------------
--                           Default namespaces                               --
-- This is a table of namespaces to categorise by default. The keys are the   --
-- namespace numbers.                                                         --
--------------------------------------------------------------------------------

cfg.defaultNamespaces = {
	[  0] = true, -- main
	[  6] = true, -- file
	[ 12] = true, -- help
	[ 14] = true, -- category
	[100] = true, -- portal
	[108] = true, -- book
}

--------------------------------------------------------------------------------
--                                Wrappers                                    --
-- This is a wrapper template or a list of wrapper templates to be passed to  --
-- [[Module:Arguments]].                                                      --
--------------------------------------------------------------------------------

cfg.wrappers = 'Template:Category handler'

--------------------------------------------------------------------------------
--                           End configuration data                           --
--------------------------------------------------------------------------------

return cfg -- Don't edit this line.