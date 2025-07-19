-------------------------------------------------------------------------------
-- Unit tests for Scribunto.
-------------------------------------------------------------------------------
require('strict')

local DebugHelper = {}
local ScribuntoUnit = {}

-- The cfg table contains all localisable strings and configuration, to make it
-- easier to port this module to another wiki.
local cfg = mw.loadData('Module:ScribuntoUnit/config')

-------------------------------------------------------------------------------
-- Concatenates keys and values, ideal for displaying a template or parser function argument table.
-- @param keySeparator glue between key and value (defaults to " = ")
-- @param separator glue between different key-value pairs (defaults to ", ")
-- @example concatWithKeys({a = 1, b = 2, c = 3}, ' => ', ', ') => "a => 1, b => 2, c => 3"
-- 
function DebugHelper.concatWithKeys(table, keySeparator, separator)
    keySeparator = keySeparator or ' = '
    separator = separator or ', '
    local concatted = ''
    local i = 1
    local first = true
    local unnamedArguments = true
    for k, v in pairs(table) do
        if first then
            first = false
        else
            concatted = concatted .. separator
        end
        if k == i and unnamedArguments then
            i = i + 1
            concatted = concatted .. tostring(v)
        else
            unnamedArguments = false
            concatted = concatted .. tostring(k) .. keySeparator .. tostring(v)
        end
    end
    return concatted
end

-------------------------------------------------------------------------------
-- Compares two tables recursively (non-table values are handled correctly as well).
-- @param ignoreMetatable if false, t1.__eq is used for the comparison
-- 
function DebugHelper.deepCompare(t1, t2, ignoreMetatable)
    local type1 = type(t1)
    local type2 = type(t2)

    if type1 ~= type2 then 
        return false 
    end
    if type1 ~= 'table' then 
        return t1 == t2 
    end

    local metatable = getmetatable(t1)
    if not ignoreMetatable and metatable and metatable.__eq then 
        return t1 == t2 
    end

    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not DebugHelper.deepCompare(v1, v2) then 
            return false 
        end
    end
    for k2, v2 in pairs(t2) do
        if t1[k2] == nil then 
            return false 
        end
    end

    return true
end

-------------------------------------------------------------------------------
-- Raises an error with stack information
-- @param details a table with error details
--        - should have a 'text' key which is the error message to display
--        - a 'trace' key will be added with the stack data
--        - and a 'source' key with file/line number
--        - a metatable will be added for error handling
-- 
function DebugHelper.raise(details, level)
    level = (level or 1) + 1
    details.trace = debug.traceback('', level)
    details.source = string.match(details.trace, '^%s*stack traceback:%s*(%S*: )')

--    setmetatable(details, {
--        __tostring: function() return details.text end
--    })

    error(details, level)
end

-------------------------------------------------------------------------------
-- when used in a test, that test gets ignored, and the skipped count increases by one.
-- 
function ScribuntoUnit:markTestSkipped()
    DebugHelper.raise({ScribuntoUnit = true, skipped = true}, 3)
end

-------------------------------------------------------------------------------
-- Unconditionally fail a test
-- @param message optional description of the test
-- 
function ScribuntoUnit:fail(message)
    DebugHelper.raise({ScribuntoUnit = true, text = "Test failed", message = message}, 2)
end

-------------------------------------------------------------------------------
-- Checks that the input is true
-- @param message optional description of the test
-- 
function ScribuntoUnit:assertTrue(actual, message)
    if not actual then
        DebugHelper.raise({ScribuntoUnit = true, text = string.format("Failed to assert that %s is true", tostring(actual)), message = message}, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that the input is false
-- @param message optional description of the test
-- 
function ScribuntoUnit:assertFalse(actual, message)
    if actual then
        DebugHelper.raise({ScribuntoUnit = true, text = string.format("Failed to assert that %s is false", tostring(actual)), message = message}, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks an input string contains the expected string
-- @param message optional description of the test
-- @param plain search is made with a plain string instead of a ustring pattern
-- 
function ScribuntoUnit:assertStringContains(pattern, s, plain, message)
	if type(pattern) ~= 'string' then
		DebugHelper.raise({
			ScribuntoUnit = true,
			text = mw.ustring.format("Pattern type error (expected string, got %s)", type(pattern)),
			message = message
		}, 2)
	end
	if type(s) ~= 'string' then
		DebugHelper.raise({
			ScribuntoUnit = true,
			text = mw.ustring.format("String type error (expected string, got %s)", type(s)),
			message = message
		}, 2)
	end
	if not mw.ustring.find(s, pattern, nil, plain) then
		DebugHelper.raise({
			ScribuntoUnit = true,
			text = mw.ustring.format('Failed to find %s "%s" in string "%s"', plain and "plain string" or "pattern", pattern, s),
			message = message
		}, 2)
	end
end

-------------------------------------------------------------------------------
-- Checks an input string doesn't contain the expected string
-- @param message optional description of the test
-- @param plain search is made with a plain string instead of a ustring pattern
-- 
function ScribuntoUnit:assertNotStringContains(pattern, s, plain, message)
	if type(pattern) ~= 'string' then
		DebugHelper.raise({
			ScribuntoUnit = true,
			text = mw.ustring.format("Pattern type error (expected string, got %s)", type(pattern)),
			message = message
		}, 2)
	end
	if type(s) ~= 'string' then
		DebugHelper.raise({
			ScribuntoUnit = true,
			text = mw.ustring.format("String type error (expected string, got %s)", type(s)),
			message = message
		}, 2)
	end
	local i, j = mw.ustring.find(s, pattern, nil, plain)
	if i then
		local match = mw.ustring.sub(s, i, j)
		DebugHelper.raise({
			ScribuntoUnit = true,
			text = mw.ustring.format('Found match "%s" for %s "%s"', match, plain and "plain string" or "pattern", pattern),
			message = message
		}, 2)
	end
end

-------------------------------------------------------------------------------
-- Checks that an input has the expected value.
-- @param message optional description of the test
-- @example assertEquals(4, add(2,2), "2+2 should be 4")
-- 
function ScribuntoUnit:assertEquals(expected, actual, message)
	if type(expected) == 'number' and type(actual) == 'number' then
        self:assertWithinDelta(expected, actual, 1e-8, message)
	elseif expected ~= actual then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s equals expected %s", tostring(actual), tostring(expected)), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that an input does not have the expected value.
-- @param message optional description of the test
-- @example assertNotEquals(5, add(2,2), "2+2 should not be 5")
-- 
function ScribuntoUnit:assertNotEquals(expected, actual, message)
	if type(expected) == 'number' and type(actual) == 'number' then
        self:assertNotWithinDelta(expected, actual, 1e-8, message)
	elseif expected == actual then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s does not equal expected %s", tostring(actual), tostring(expected)), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Validates that both the expected and actual values are numbers
-- @param message optional description of the test
-- 
local function validateNumbers(expected, actual, message)
    if type(expected) ~= "number" then
        DebugHelper.raise({
            ScribuntoUnit = true,
            text = string.format("Expected value %s is not a number", tostring(expected)),
            actual = actual,
            expected = expected,
            message = message,
        }, 3)
    end
    if type(actual) ~= "number" then
        DebugHelper.raise({
            ScribuntoUnit = true,
            text = string.format("Actual value %s is not a number", tostring(actual)),
            actual = actual,
            expected = expected,
            message = message,
        }, 3)
    end
end

-------------------------------------------------------------------------------
-- Checks that 'actual' is within 'delta' of 'expected'.
-- @param message optional description of the test
-- @example assertWithinDelta(1/3, 3/9, 0.000001, "3/9 should be 1/3")
function ScribuntoUnit:assertWithinDelta(expected, actual, delta, message)
    validateNumbers(expected, actual, message)
    local diff = expected - actual
    if diff < 0 then diff = - diff end  -- instead of importing math.abs
    if diff > delta then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %f is within %f of expected %f", actual, delta, expected), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that 'actual' is not within 'delta' of 'expected'.
-- @param message optional description of the test
-- @example assertNotWithinDelta(1/3, 2/3, 0.000001, "1/3 should not be 2/3")
function ScribuntoUnit:assertNotWithinDelta(expected, actual, delta, message)
    validateNumbers(expected, actual, message)
    local diff = expected - actual
    if diff < 0 then diff = - diff end  -- instead of importing math.abs
    if diff <= delta then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %f is not within %f of expected %f", actual, delta, expected), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a table has the expected value (including sub-tables).
-- @param message optional description of the test
-- @example assertDeepEquals({{1,3}, {2,4}}, partition(odd, {1,2,3,4}))
function ScribuntoUnit:assertDeepEquals(expected, actual, message)
    if not DebugHelper.deepCompare(expected, actual) then
        if type(expected) == 'table' then
            expected = mw.dumpObject(expected)
        end
        if type(actual) == 'table' then
            actual = mw.dumpObject(actual)
        end
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s equals expected %s", tostring(actual), tostring(expected)), 
            actual = actual,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a wikitext gives the expected result after processing.
-- @param message optional description of the test
-- @example assertResultEquals("Hello world", "{{concat|Hello|world}}")
function ScribuntoUnit:assertResultEquals(expected, text, message)
    local frame = self.frame
    local actual = frame:preprocess(text)
    if expected ~= actual then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s equals expected %s after preprocessing", text, tostring(expected)), 
            actual = actual,
            actualRaw = text,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that two wikitexts give the same result after processing.
-- @param message optional description of the test
-- @example assertSameResult("{{concat|Hello|world}}", "{{deleteLastChar|Hello world!}}")
function ScribuntoUnit:assertSameResult(text1, text2, message)
    local frame = self.frame
    local processed1 = frame:preprocess(text1)
    local processed2 = frame:preprocess(text2)
    if processed1 ~= processed2 then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s equals expected %s after preprocessing", processed1, processed2), 
            actual = processed1,
            actualRaw = text1,
            expected = processed2,
            expectedRaw = text2,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a parser function gives the expected output.
-- @param message optional description of the test
-- @example assertParserFunctionEquals("Hello world", "msg:concat", {"Hello", " world"})
function ScribuntoUnit:assertParserFunctionEquals(expected, pfname, args, message)
    local frame = self.frame
    local actual = frame:callParserFunction{ name = pfname, args = args}
    if expected ~= actual then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s with args %s equals expected %s after preprocessing", 
                                 DebugHelper.concatWithKeys(args), pfname, expected),
            actual = actual,
            actualRaw = pfname,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks that a template gives the expected output.
-- @param message optional description of the test
-- @example assertTemplateEquals("Hello world", "concat", {"Hello", " world"})
function ScribuntoUnit:assertTemplateEquals(expected, template, args, message)
    local frame = self.frame
    local actual = frame:expandTemplate{ title = template, args = args}
    if expected ~= actual then
        DebugHelper.raise({
            ScribuntoUnit = true, 
            text = string.format("Failed to assert that %s with args %s equals expected %s after preprocessing", 
                                 DebugHelper.concatWithKeys(args), template, expected),
            actual = actual,
            actualRaw = template,
            expected = expected,
            message = message,
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks whether a function throws an error
-- @param fn the function to test
-- @param expectedMessage optional the expected error message
-- @param message optional description of the test
function ScribuntoUnit:assertThrows(fn, expectedMessage, message)
    local succeeded, actualMessage = pcall(fn)
    if succeeded then
        DebugHelper.raise({
            ScribuntoUnit = true,
            text = 'Expected exception but none was thrown',
            message = message,
        }, 2)
    end
	-- For strings, strip the line number added to the error message
    actualMessage = type(actualMessage) == 'string' 
    	and string.match(actualMessage, 'Module:[^:]*:[0-9]*: (.*)')
    	or actualMessage
    local messagesMatch = DebugHelper.deepCompare(expectedMessage, actualMessage)
    if expectedMessage and not messagesMatch then
        DebugHelper.raise({
            ScribuntoUnit = true,
            expected = expectedMessage,
            actual = actualMessage,
            text = string.format('Expected exception with message %s, but got message %s', 
                tostring(expectedMessage), tostring(actualMessage)
            ),
            message = message
        }, 2)
    end
end

-------------------------------------------------------------------------------
-- Checks whether a function doesn't throw an error
-- @param fn the function to test
-- @param message optional description of the test
function ScribuntoUnit:assertDoesNotThrow(fn, message)
	local succeeded, actualMessage = pcall(fn)
	if succeeded then
	    return
	end
	-- For strings, strip the line number added to the error message
	actualMessage = type(actualMessage) == 'string' 
		and string.match(actualMessage, 'Module:[^:]*:[0-9]*: (.*)')
		or actualMessage
	DebugHelper.raise({
		ScribuntoUnit = true,
		actual = actualMessage,
		text = string.format('Expected no exception, but got exception with message %s',
			tostring(actualMessage)
		),
		message = message
	}, 2)
end

-------------------------------------------------------------------------------
-- Creates a new test suite.
-- @param o a table with test functions (alternatively, the functions can be added later to the returned suite)
-- 
function ScribuntoUnit:new(o)
    o = o or {}
    o._tests = {}
    setmetatable(o, {
    	__index = self,
    	__newindex = function (t, k, v)
    		if type(k) == "string" and k:find('^test') and type(v) == "function" then
    			-- Store test functions in the order they were defined
    			table.insert(o._tests, {name = k, test = v})
    		else
    			rawset(t, k, v)
    		end
    	end
    })
    o.run = function(frame) return self:run(o, frame) end
    return o
end

-------------------------------------------------------------------------------
-- Resets global counters
-- 
function ScribuntoUnit:init(frame)
    self.frame = frame or mw.getCurrentFrame()
    self.successCount = 0
    self.failureCount = 0
    self.skipCount = 0
    self.results = {}
end

-------------------------------------------------------------------------------
-- Runs a single testcase
-- @param name test nume
-- @param test function containing assertions
-- 
function ScribuntoUnit:runTest(suite, name, test)
    local success, details = pcall(test, suite)
    
    if success then
        self.successCount = self.successCount + 1
        table.insert(self.results, {name = name, success = true})
    elseif type(details) ~= 'table' or not details.ScribuntoUnit then -- a real error, not a failed assertion
        self.failureCount = self.failureCount + 1
        table.insert(self.results, {name = name, error = true, message = 'Lua error -- ' .. tostring(details)})
    elseif details.skipped then
        self.skipCount = self.skipCount + 1
        table.insert(self.results, {name = name, skipped = true})
    else
        self.failureCount = self.failureCount + 1
        local message = details.source or ""
        if details.message then
            message = message .. details.message .. "\n"
        end
        message = message .. details.text
        table.insert(self.results, {name = name, error = true, message = message, expected = details.expected, actual = details.actual, testname = details.message})
    end
end

-------------------------------------------------------------------------------
-- Runs all tests and displays the results.
-- 
function ScribuntoUnit:runSuite(suite, frame)
    self:init(frame)
	for i, testDetails in ipairs(suite._tests) do
		self:runTest(suite, testDetails.name, testDetails.test)
	end
    return {
        successCount = self.successCount,
        failureCount = self.failureCount,
        skipCount = self.skipCount,
        results = self.results,
    }
end

-------------------------------------------------------------------------------
-- #invoke entry point for running the tests.
-- Can be called without a frame, in which case it will use mw.log for output
-- @param displayMode see displayResults()
-- 
function ScribuntoUnit:run(suite, frame)
    local testData = self:runSuite(suite, frame)
    if frame and frame.args then
        return self:displayResults(testData, frame.args.displayMode or 'table')
    else
        return self:displayResults(testData, 'log')
    end
end

-------------------------------------------------------------------------------
-- Displays test results 
-- @param displayMode: 'table', 'log' or 'short'
-- 
function ScribuntoUnit:displayResults(testData, displayMode)
    if displayMode == 'table' then
        return self:displayResultsAsTable(testData)
    elseif displayMode == 'log' then
        return self:displayResultsAsLog(testData)
    elseif displayMode == 'short' then
        return self:displayResultsAsShort(testData)
    else
        error('unknown display mode')
    end
end

function ScribuntoUnit:displayResultsAsLog(testData)
    if testData.failureCount > 0 then
        mw.log('FAILURES!!!')
    elseif testData.skipCount > 0 then
        mw.log('Some tests could not be executed without a frame and have been skipped. Invoke this test suite as a template to run all tests.')
    end
    mw.log(string.format('Assertions: success: %d, error: %d, skipped: %d', testData.successCount, testData.failureCount, testData.skipCount))
    mw.log('-------------------------------------------------------------------------------')
    for _, result in ipairs(testData.results) do
        if result.error then
            mw.log(string.format('%s: %s', result.name, result.message))
        end
    end
end

function ScribuntoUnit:displayResultsAsShort(testData)
    local text = string.format(cfg.shortResultsFormat, testData.successCount, testData.failureCount, testData.skipCount)
    if testData.failureCount > 0 then
        text = '<span class="error">' .. text .. '</span>'
    end
    return text
end

function ScribuntoUnit:displayResultsAsTable(testData)
    local successIcon, failIcon = self.frame:preprocess(cfg.successIndicator), self.frame:preprocess(cfg.failureIndicator)
    local text = ''
	if testData.failureCount > 0 then
		local msg = mw.message.newRawMessage(cfg.failureSummary, testData.failureCount):plain()
		msg = self.frame:preprocess(msg)
		if cfg.failureCategory then
			msg = cfg.failureCategory .. msg
		end
		text = text .. failIcon .. ' ' .. msg .. '\n'
	else
		text = text .. successIcon .. ' ' .. cfg.successSummary .. '\n'
	end
    text = text .. '{| class="wikitable scribunto-test-table"\n'
    text = text .. '!\n! ' .. cfg.nameString .. '\n! ' .. cfg.expectedString .. '\n! ' .. cfg.actualString .. '\n'
    for _, result in ipairs(testData.results) do
        text = text .. '|-\n'
        if result.error then
            text = text .. '| ' .. failIcon .. '\n| '
            if (result.expected and result.actual) then
            	local name = result.name
            	if result.testname then
            		name = name .. ' / ' .. result.testname
            	end
                text = text .. mw.text.nowiki(name) .. '\n| ' .. mw.text.nowiki(tostring(result.expected)) .. '\n| ' .. mw.text.nowiki(tostring(result.actual)) .. '\n'
            else
                text = text .. mw.text.nowiki(result.name) .. '\n| ' .. ' colspan="2" | ' .. mw.text.nowiki(result.message) .. '\n'
            end
        else
            text = text .. '| ' .. successIcon .. '\n| ' .. mw.text.nowiki(result.name) .. '\n|\n|\n'
        end
    end
    text = text .. '|}\n'
    return text
end

return ScribuntoUnit
