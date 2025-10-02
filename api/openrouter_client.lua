--[[============================================================================
api/openrouter_client.lua
============================================================================]]--

-- OpenRouter API client for phrase script generation
-- Provides access to multiple free and paid models through a unified API

local https_client = require("http.https_client")

local OpenRouterClient = {}
OpenRouterClient.__index = OpenRouterClient

-- API Configuration
local API_BASE_URL = "https://openrouter.ai/api/v1/chat/completions"
local DEFAULT_MODEL = "meta-llama/llama-3.3-70b-instruct:free"

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

function OpenRouterClient.new(api_key, model)
  local self = setmetatable({}, OpenRouterClient)

  self.api_key = api_key or ""
  self.model = model or DEFAULT_MODEL

  return self
end

--------------------------------------------------------------------------------
-- Code Generation
--------------------------------------------------------------------------------

function OpenRouterClient:generate_code(prompt, timeout)
  timeout = timeout or 30

  if not self.api_key or self.api_key == "" then
    return nil, "API key not configured"
  end

  if not prompt or prompt == "" then
    return nil, "No prompt provided"
  end

  -- Build system prompt for Renoise phrase scripting
  local system_prompt = [[You are an expert Renoise phrase script programmer. Generate Lua code for Renoise phrase scripts based on user requests.

IMPORTANT:
- Return ONLY the Lua code, no explanations, no markdown formatting
- Do NOT wrap code in ```lua or ``` blocks
- The code will be directly inserted into a Renoise phrase script
- Use the Renoise Phrase API: phrase.lines[line_index].note_columns[column_index]
- Available properties: note_value, instrument_value, volume_value, panning_value, delay_value
- Note values: 0-119 (C-0 to B-9), 120 = OFF, 121 = empty
- Generate clean, efficient, well-commented code]]

  -- Build OpenAI-compatible request body
  local request_body = {
    model = self.model,
    messages = {
      {
        role = "system",
        content = system_prompt
      },
      {
        role = "user",
        content = prompt
      }
    },
    temperature = 0.7,
    max_tokens = 2048,
  }

  -- Headers for OpenRouter API
  local headers = {
    ["Content-Type"] = "application/json",
    ["Authorization"] = "Bearer " .. self.api_key,
    ["HTTP-Referer"] = "https://github.com/asafe/LLMComposer.xrnx",
    ["X-Title"] = "LLM Composer for Renoise",
  }

  -- Make the request
  local response, err = https_client.post(API_BASE_URL, headers, request_body, timeout)

  if err then
    return nil, "API request failed: " .. err
  end

  -- Parse OpenRouter response (OpenAI-compatible format)
  return self:parse_response(response)
end

--------------------------------------------------------------------------------
-- Response Parsing
--------------------------------------------------------------------------------

function OpenRouterClient:parse_response(response)
  if not response then
    return nil, "Empty response from API"
  end

  -- Check for API errors
  if response.error then
    local error_message = response.error.message or "Unknown API error"
    local error_code = response.error.code or response.error.type or "unknown"
    return nil, string.format("OpenRouter API error (%s): %s", error_code, error_message)
  end

  -- Extract generated text from OpenAI-compatible response format
  if response.choices and
     response.choices[1] and
     response.choices[1].message and
     response.choices[1].message.content then

    local generated_text = response.choices[1].message.content

    -- Clean up the response (remove markdown code blocks if present)
    generated_text = generated_text:gsub("^%s*```lua%s*\n", "")
    generated_text = generated_text:gsub("^%s*```%s*\n", "")
    generated_text = generated_text:gsub("\n```%s*$", "")

    return generated_text, nil
  end

  return nil, "Unexpected response format from OpenRouter API"
end

--------------------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------------------

function OpenRouterClient:validate()
  if not self.api_key or self.api_key == "" then
    return false, "API key is required"
  end

  if not self.api_key:match("^sk%-") then
    return false, "Invalid OpenRouter API key format (should start with 'sk-')"
  end

  return true, nil
end

--------------------------------------------------------------------------------
-- Available Free Models
--------------------------------------------------------------------------------

function OpenRouterClient.get_free_models()
  return {
    "meta-llama/llama-3.3-70b-instruct:free",
    "deepseek/deepseek-r1:free",
    "qwen/qwen-2.5-72b-instruct:free",
    "mistralai/mistral-7b-instruct:free",
  }
end

return OpenRouterClient
