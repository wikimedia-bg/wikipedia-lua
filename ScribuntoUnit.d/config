-- The cfg table, created by this module, contains all localisable strings and
-- configuration, to make it easier to port this module to another wiki.
local cfg = {} -- Do not edit this line.

-- The successIndicator and failureIndicator are in the first column of the
-- wikitable produced as output and indicate whether the test passed.  These two
-- strings are preprocessed by frame.preprocess.
-- successIndicator: if the test passes
-- failureIndicator: if the test fails
cfg.successIndicator = "{{tick}}"
cfg.failureIndicator = "{{cross}}"

-- The names of the columns Name, Expected and Actual (the other three columns,
-- in this order)
cfg.nameString = "Name"
cfg.expectedString = "Expected"
cfg.actualString = "Actual"

-- The string at the top used to indicate all tests passed.
cfg.successSummary = "All tests passed."
-- The string at the top used to indicate one or more tests failed. $1 is
-- replaced by the number of tests that failed.  This string is preprocessed by
-- frame.preprocess.
cfg.failureSummary = "'''$1 {{PLURAL:$1|test|tests}} failed'''."

-- Format string for a short display of the tests in displayResultsAsShort.
-- This format string is passed directly to string.format.
cfg.shortResultsFormat = "success: %d, error: %d, skipped: %d"

-- Category added to pages that fail one or more tests. Set to nil to disable
-- categorisation of pages that fail one or more tests.
cfg.failureCategory = "[[Category:Failed Lua testcases using Module:ScribuntoUnit]]"

-- Finally, return the configuration table.
return cfg -- Do not edit this line.
