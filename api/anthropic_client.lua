--[[============================================================================
api/anthropic_client.lua
============================================================================]]--

-- Anthropic Claude API client

local https_client = require("http.https_client")
local phrase_utils = require("utils.phrase_utils")

local anthropic_client = {}

--------------------------------------------------------------------------------
-- API Configuration
--------------------------------------------------------------------------------

local API_BASE_URL = "https://api.anthropic.com/v1/messages"
local API_VERSION = "2023-06-01"

--------------------------------------------------------------------------------
-- Client Class
--------------------------------------------------------------------------------

local AnthropicClient = {}
AnthropicClient.__index = AnthropicClient

function AnthropicClient:new(api_key, model)
  local client = {
    api_key = api_key,
    model = model or "claude-3-5-sonnet-20241022"
  }
  setmetatable(client, AnthropicClient)
  return client
end

--------------------------------------------------------------------------------
-- Code Generation
--------------------------------------------------------------------------------

function AnthropicClient:generate_code(prompt, timeout)
  if not self.api_key or self.api_key == "" then
    return nil, "API key not configured"
  end

  timeout = timeout or 30

  -- Build enhanced prompt with Renoise context
  local enhanced_prompt = phrase_utils.build_context_prompt(prompt)

  -- Build request body
  local request_body = {
    model = self.model,
    max_tokens = 2048,
    messages = {
      {
        role = "user",
        content = enhanced_prompt
      }
    },
    system = "You are an expert Renoise phrase script programmer. " ..
             "Generate only Lua code without any explanations, comments, or markdown formatting. " ..
             "The code should be ready to use directly in Renoise's phrase script editor."
  }

  -- Build headers
  local headers = {
    ["x-api-key"] = self.api_key,
    ["anthropic-version"] = API_VERSION,
    ["content-type"] = "application/json"
  }

  -- Make API request
  local response, err = https_client.post(API_BASE_URL, headers, request_body, timeout)

  if err then
    return nil, "API request failed: " .. err
  end

  if not response then
    return nil, "Empty response from API"
  end

  -- Check for API errors
  if response.error then
    local error_msg = "API error"
    if response.error.message then
      error_msg = response.error.message
    end
    return nil, error_msg
  end

  -- Extract code from response
  local code, extract_err = self:extract_code(response)

  if extract_err then
    return nil, extract_err
  end

  return code, nil
end

--------------------------------------------------------------------------------
-- Response Parsing
--------------------------------------------------------------------------------

function AnthropicClient:extract_code(response)
  -- Check if response has content
  if not response.content then
    return nil, "No content in API response"
  end

  if type(response.content) ~= "table" or #response.content == 0 then
    return nil, "Invalid content format in API response"
  end

  -- Get the first content block
  local first_block = response.content[1]

  if not first_block.text then
    return nil, "No text in content block"
  end

  local text = first_block.text

  -- Extract code blocks if present
  local code = phrase_utils.extract_code_blocks(text)

  if not code then
    -- If no code blocks found, assume the entire response is code
    code = text
  end

  -- Format the code
  code = phrase_utils.format_code(code)

  if not code or code == "" then
    return nil, "No code found in response"
  end

  -- Validate Lua syntax
  local valid, err = phrase_utils.validate_lua_code(code)

  if not valid then
    return nil, "Generated code has syntax errors: " .. err
  end

  return code, nil
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function anthropic_client.create(api_key, model)
  return AnthropicClient:new(api_key, model)
end

return anthropic_client
