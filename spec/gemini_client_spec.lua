--[[============================================================================
spec/gemini_client_spec.lua
============================================================================]]--

-- Load mock Renoise API
require("spec.mock_renoise")

-- Mock https_client BEFORE loading the API client
package.loaded["http.https_client"] = {
  post = function(url, headers, body, timeout)
    -- Mock successful response
    if url:match("gemini%-1%.5%-flash") then
      return {
        candidates = {
          {
            content = {
              parts = {
                { text = "-- Generated code\nprint('Hello from Gemini')" }
              }
            }
          }
        }
      }, nil
    end

    -- Mock error response
    if url:match("error") then
      return {
        error = {
          code = 400,
          message = "Invalid request"
        }
      }, nil
    end

    return nil, "Connection failed"
  end
}

-- Load the module to test AFTER mocking
local GeminiClient = require("api.gemini_client")

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

describe("Gemini Client", function()

it("should create a client with default model", function()
  local client = GeminiClient.new("AIzaSyTest123", nil)
  assert_not_nil(client)
end)

it("should create a client with custom model", function()
  local client = GeminiClient.new("AIzaSyTest123", "gemini-1.5-pro")
  assert_not_nil(client)
end)

it("should validate API key format", function()
  local client = GeminiClient.new("AIzaSyTest123", "gemini-1.5-flash")
  local valid, err = client:validate()
  assert_true(valid)
  assert_nil(err)
end)

it("should reject invalid API key format", function()
  local client = GeminiClient.new("invalid-key", "gemini-1.5-flash")
  local valid, err = client:validate()
  assert_false(valid)
  assert_match(err, "Invalid Gemini API key")
end)

it("should reject empty API key", function()
  local client = GeminiClient.new("", "gemini-1.5-flash")
  local valid, err = client:validate()
  assert_false(valid)
  assert_match(err, "API key is required")
end)

it("should generate code successfully", function()
  local client = GeminiClient.new("AIzaSyTest123", "gemini-1.5-flash")
  local code, err = client:generate_code("Create a simple melody", 30)

  assert_nil(err)
  assert_not_nil(code)
  assert_match(code, "Hello from Gemini")
end)

it("should return error when API key is missing", function()
  local client = GeminiClient.new("", "gemini-1.5-flash")
  local code, err = client:generate_code("Create a simple melody", 30)

  assert_nil(code)
  assert_not_nil(err)
  assert_match(err, "API key not configured")
end)

it("should return error when prompt is empty", function()
  local client = GeminiClient.new("AIzaSyTest123", "gemini-1.5-flash")
  local code, err = client:generate_code("", 30)

  assert_nil(code)
  assert_not_nil(err)
  assert_match(err, "No prompt provided")
end)

it("should handle API errors gracefully", function()
  local client = GeminiClient.new("AIzaSyTest123", "error")
  local code, err = client:generate_code("Test", 30)

  assert_nil(code)
  assert_not_nil(err)
  assert_match(err, "Gemini API error")
end)

it("should clean markdown code blocks from response", function()
  -- Mock response with markdown
  package.loaded["http.https_client"].post = function(url, headers, body, timeout)
    return {
      candidates = {
        {
          content = {
            parts = {
              { text = "```lua\nprint('test')\n```" }
            }
          }
        }
      }
    }, nil
  end

  local client = GeminiClient.new("AIzaSyTest123", "gemini-1.5-flash")
  local code, err = client:generate_code("Test", 30)

  assert_nil(err)
  assert_not_nil(code)
  assert_equals(code, "print('test')")
end)

end)
