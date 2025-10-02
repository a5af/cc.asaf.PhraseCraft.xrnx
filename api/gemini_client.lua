--[[============================================================================
api/gemini_client.lua
============================================================================]]--

-- Google Gemini API client for phrase script generation

local https_client = require("http.https_client")

local GeminiClient = {}
GeminiClient.__index = GeminiClient

-- API Configuration
local API_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/"
local DEFAULT_MODEL = "gemini-1.5-flash"

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------

function GeminiClient.new(api_key, model)
  local self = setmetatable({}, GeminiClient)

  self.api_key = api_key or ""
  self.model = model or DEFAULT_MODEL

  return self
end

--------------------------------------------------------------------------------
-- Code Generation
--------------------------------------------------------------------------------

function GeminiClient:generate_code(prompt, timeout)
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

  -- Combine system prompt and user prompt
  local enhanced_prompt = system_prompt .. "\n\nUser request: " .. prompt

  -- Build Gemini API request body
  local request_body = {
    contents = {
      {
        parts = {
          { text = enhanced_prompt }
        }
      }
    },
    generationConfig = {
      temperature = 0.7,
      maxOutputTokens = 2048,
      topP = 0.95,
    }
  }

  -- Build URL with API key (Gemini uses query parameter)
  local url = API_BASE_URL .. self.model .. ":generateContent?key=" .. self.api_key

  -- Headers for Gemini API
  local headers = {
    ["Content-Type"] = "application/json",
  }

  -- Make the request
  local response, err = https_client.post(url, headers, request_body, timeout)

  if err then
    return nil, "API request failed: " .. err
  end

  -- Parse Gemini response
  return self:parse_response(response)
end

--------------------------------------------------------------------------------
-- Response Parsing
--------------------------------------------------------------------------------

function GeminiClient:parse_response(response)
  if not response then
    return nil, "Empty response from API"
  end

  -- Check for API errors
  if response.error then
    local error_message = response.error.message or "Unknown API error"
    local error_code = response.error.code or "unknown"
    return nil, string.format("Gemini API error (%s): %s", error_code, error_message)
  end

  -- Extract generated text from Gemini response format
  if response.candidates and
     response.candidates[1] and
     response.candidates[1].content and
     response.candidates[1].content.parts and
     response.candidates[1].content.parts[1] and
     response.candidates[1].content.parts[1].text then

    local generated_text = response.candidates[1].content.parts[1].text

    -- Clean up the response (remove markdown code blocks if present)
    generated_text = generated_text:gsub("^%s*```lua%s*\n", "")
    generated_text = generated_text:gsub("^%s*```%s*\n", "")
    generated_text = generated_text:gsub("\n```%s*$", "")

    return generated_text, nil
  end

  -- Check for content filtering
  if response.candidates and
     response.candidates[1] and
     response.candidates[1].finishReason == "SAFETY" then
    return nil, "Content was filtered by Gemini safety settings"
  end

  return nil, "Unexpected response format from Gemini API"
end

--------------------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------------------

function GeminiClient:validate()
  if not self.api_key or self.api_key == "" then
    return false, "API key is required"
  end

  if not self.api_key:match("^AIza") then
    return false, "Invalid Gemini API key format (should start with 'AIza')"
  end

  return true, nil
end

return GeminiClient
