--[[============================================================================
spec/test_runner.lua
============================================================================]]--

-- Simple test runner (minimal test framework)

local test_runner = {}

-- Test statistics
local stats = {
  total = 0,
  passed = 0,
  failed = 0,
  errors = {}
}

-- Current test context
local current_suite = ""
local current_test = ""

--------------------------------------------------------------------------------
-- Assertion Functions
--------------------------------------------------------------------------------

function assert_equals(actual, expected, message)
  message = message or string.format("Expected %s, got %s", tostring(expected), tostring(actual))

  if actual ~= expected then
    error(message, 2)
  end
end

function assert_not_nil(value, message)
  message = message or "Expected value to not be nil"

  if value == nil then
    error(message, 2)
  end
end

function assert_nil(value, message)
  message = message or "Expected value to be nil"

  if value ~= nil then
    error(message, 2)
  end
end

function assert_true(value, message)
  message = message or "Expected value to be true"

  if value ~= true then
    error(message, 2)
  end
end

function assert_false(value, message)
  message = message or "Expected value to be false"

  if value ~= false then
    error(message, 2)
  end
end

function assert_match(str, pattern, message)
  message = message or string.format("Expected '%s' to match pattern '%s'", tostring(str), tostring(pattern))

  if not str or not str:match(pattern) then
    error(message, 2)
  end
end

function assert_type(value, expected_type, message)
  local actual_type = type(value)
  message = message or string.format("Expected type %s, got %s", expected_type, actual_type)

  if actual_type ~= expected_type then
    error(message, 2)
  end
end

--------------------------------------------------------------------------------
-- Test Definition
--------------------------------------------------------------------------------

function describe(suite_name, suite_func)
  current_suite = suite_name
  print("\n" .. suite_name)
  print(string.rep("=", #suite_name))

  suite_func()

  current_suite = ""
end

function it(test_name, test_func)
  current_test = test_name
  stats.total = stats.total + 1

  -- Run before_each if defined
  if test_runner._before_each then
    pcall(test_runner._before_each)
  end

  local success, err = pcall(test_func)

  if success then
    stats.passed = stats.passed + 1
    print("  ✓ " .. test_name)
  else
    stats.failed = stats.failed + 1
    print("  ✗ " .. test_name)
    print("    " .. tostring(err))
    table.insert(stats.errors, {
      suite = current_suite,
      test = test_name,
      error = err
    })
  end

  -- Run after_each if defined
  if test_runner._after_each then
    pcall(test_runner._after_each)
  end

  current_test = ""
end

function before_each(func)
  -- Store for future use if needed
  test_runner._before_each = func
end

function after_each(func)
  -- Store for future use if needed
  test_runner._after_each = func
end

--------------------------------------------------------------------------------
-- Test Execution
--------------------------------------------------------------------------------

function test_runner.run(test_files)
  stats = {
    total = 0,
    passed = 0,
    failed = 0,
    errors = {}
  }

  print("\n" .. string.rep("=", 60))
  print("Running Tests")
  print(string.rep("=", 60))

  for _, file in ipairs(test_files) do
    dofile(file)
  end

  print("\n" .. string.rep("=", 60))
  print("Test Results")
  print(string.rep("=", 60))
  print(string.format("Total:  %d", stats.total))
  print(string.format("Passed: %d", stats.passed))
  print(string.format("Failed: %d", stats.failed))

  if stats.failed > 0 then
    print("\nFailed tests:")
    for _, error_info in ipairs(stats.errors) do
      print(string.format("  • %s - %s", error_info.suite, error_info.test))
      print(string.format("    %s", error_info.error))
    end
  end

  print(string.rep("=", 60))

  return stats.failed == 0
end

function test_runner.get_stats()
  return stats
end

-- Export assertion functions globally
_G.assert_equals = assert_equals
_G.assert_not_nil = assert_not_nil
_G.assert_nil = assert_nil
_G.assert_true = assert_true
_G.assert_false = assert_false
_G.assert_match = assert_match
_G.assert_type = assert_type
_G.describe = describe
_G.it = it
_G.before_each = before_each
_G.after_each = after_each

return test_runner
