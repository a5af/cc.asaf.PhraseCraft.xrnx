#!/usr/bin/env lua
--[[============================================================================
run_tests.lua
============================================================================]]--

-- Test runner script

-- Add current directory to package path
package.path = package.path .. ";./?.lua;./?/init.lua"

-- Load test runner
local test_runner = require("spec.test_runner")

-- List of test files
local test_files = {
  "spec/phrase_utils_spec.lua",
  "spec/config_spec.lua",
}

-- Run tests
local success = test_runner.run(test_files)

-- Exit with appropriate code
os.exit(success and 0 or 1)
