--[[============================================================================
spec/openrouter_client_spec.lua
============================================================================]]--

-- Load mock Renoise API
require("spec.mock_renoise")

-- Mock https_client BEFORE loading the API client
package.loaded["http.https_client"] = {
  post = function(url, headers, body, timeout)
    local auth_header = headers["Authorization"] or ""

    -- Mock successful response for valid keys
    if auth_header:match("Bearer sk%-test") then
      return {
        choices = {
          {
            message = {
              content = "-- Generated code\nprint('Hello from OpenRouter')"
            }
          }
        }
      }, nil
    end

    -- Mock error response for "error" key
    if auth_header:match("Bearer error") then
      return {
        error = {
          code = "invalid_api_key",
          message = "Invalid API key"
        }
      }, nil
    end

    return nil, "Connection failed"
  end
}

-- Load the module to test AFTER mocking
local OpenRouterClient = require("api.openrouter_client")

--------------------------------------------------------------------------------
-- Tests
--------------------------------------------------------------------------------

describe("OpenRouter Client", function()

it("should create a client with default model", function()
  local client = OpenRouterClient.new("sk-test123", nil)
  assert_not_nil(client)
end)

it("should create a client with custom model", function()
  local client = OpenRouterClient.new("sk-test123", "deepseek/deepseek-r1:free")
  assert_not_nil(client)
end)

it("should validate API key format", function()
  local client = OpenRouterClient.new("sk-test123", "meta-llama/llama-3.3-70b-instruct:free")
  local valid, err = client:validate()
  assert_true(valid)
  assert_nil(err)
end)

it("should reject invalid API key format", function()
  local client = OpenRouterClient.new("invalid-key", "meta-llama/llama-3.3-70b-instruct:free")
  local valid, err = client:validate()
  assert_false(valid)
  assert_match(err, "Invalid OpenRouter API key")
end)

it("should reject empty API key", function()
  local client = OpenRouterClient.new("", "meta-llama/llama-3.3-70b-instruct:free")
  local valid, err = client:validate()
  assert_false(valid)
  assert_match(err, "API key is required")
end)

it("should generate code successfully", function()
  local client = OpenRouterClient.new("sk-test123", "meta-llama/llama-3.3-70b-instruct:free")
  local code, err = client:generate_code("Create a simple melody", 30)

  assert_nil(err)
  assert_not_nil(code)
  assert_match(code, "Hello from OpenRouter")
end)

it("should return error when API key is missing", function()
  local client = OpenRouterClient.new("", "meta-llama/llama-3.3-70b-instruct:free")
  local code, err = client:generate_code("Create a simple melody", 30)

  assert_nil(code)
  assert_not_nil(err)
  assert_match(err, "API key not configured")
end)

it("should return error when prompt is empty", function()
  local client = OpenRouterClient.new("sk-test123", "meta-llama/llama-3.3-70b-instruct:free")
  local code, err = client:generate_code("", 30)

  assert_nil(code)
  assert_not_nil(err)
  assert_match(err, "No prompt provided")
end)

it("should handle API errors gracefully", function()
  local client = OpenRouterClient.new("error-test", "meta-llama/llama-3.3-70b-instruct:free")
  local code, err = client:generate_code("Test", 30)

  assert_nil(code)
  assert_not_nil(err)
  assert_match(err, "OpenRouter API error")
end)

it("should clean markdown code blocks from response", function()
  -- Mock response with markdown
  package.loaded["http.https_client"].post = function(url, headers, body, timeout)
    return {
      choices = {
        {
          message = {
            content = "```lua\nprint('test')\n```"
          }
        }
      }
    }, nil
  end

  local client = OpenRouterClient.new("sk-test123", "meta-llama/llama-3.3-70b-instruct:free")
  local code, err = client:generate_code("Test", 30)

  assert_nil(err)
  assert_not_nil(code)
  assert_equals(code, "print('test')")
end)

it("should provide list of free models", function()
  local models = OpenRouterClient.get_free_models()
  assert_not_nil(models)
  assert_type(models, "table")
  assert_true(#models > 0)
  assert_match(models[1], ":free")
end)

end)
