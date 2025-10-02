--[[============================================================================
utils/config.lua
============================================================================]]--

-- Configuration and preferences management

local config = {}

--------------------------------------------------------------------------------
-- Preferences
--------------------------------------------------------------------------------

config.preferences = renoise.Document.create("LLMComposerPreferences") {
  -- Provider selection
  provider = "gemini", -- "gemini" | "openrouter" | "anthropic" | "openai" | "deepseek"

  -- API Keys (stored as observable strings)
  gemini_api_key = "",
  openrouter_api_key = "",
  anthropic_api_key = "",
  openai_api_key = "",
  deepseek_api_key = "",

  -- Model configurations
  model_gemini = "gemini-1.5-flash",
  model_openrouter = "meta-llama/llama-3.3-70b-instruct:free",
  model_anthropic = "claude-3-5-sonnet-20241022",
  model_openai = "gpt-4-turbo-preview",
  model_deepseek = "deepseek-coder",

  -- Behavior settings
  auto_insert = false, -- If false, show preview before inserting
  show_preview = true, -- Show generated code in dialog
  timeout_seconds = 30, -- HTTP request timeout

  -- UI preferences
  dialog_width = 600,
  dialog_height = 400,
  prompt_history_size = 10,
}

-- Store prompt history separately (not in preferences doc)
config.prompt_history = {}

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function config.initialize_preferences()
  -- Load preferences from Renoise's preference system
  renoise.tool().preferences = config.preferences

  -- Validate preferences
  if config.preferences.timeout_seconds.value < 10 then
    config.preferences.timeout_seconds.value = 10
  end
  if config.preferences.timeout_seconds.value > 120 then
    config.preferences.timeout_seconds.value = 120
  end
end

--------------------------------------------------------------------------------
-- Getters
--------------------------------------------------------------------------------

function config.get_provider()
  return config.preferences.provider.value
end

function config.get_api_key(provider)
  provider = provider or config.get_provider()

  if provider == "gemini" then
    return config.preferences.gemini_api_key.value
  elseif provider == "openrouter" then
    return config.preferences.openrouter_api_key.value
  elseif provider == "anthropic" then
    return config.preferences.anthropic_api_key.value
  elseif provider == "openai" then
    return config.preferences.openai_api_key.value
  elseif provider == "deepseek" then
    return config.preferences.deepseek_api_key.value
  end

  return ""
end

function config.get_model(provider)
  provider = provider or config.get_provider()

  if provider == "gemini" then
    return config.preferences.model_gemini.value
  elseif provider == "openrouter" then
    return config.preferences.model_openrouter.value
  elseif provider == "anthropic" then
    return config.preferences.model_anthropic.value
  elseif provider == "openai" then
    return config.preferences.model_openai.value
  elseif provider == "deepseek" then
    return config.preferences.model_deepseek.value
  end

  return ""
end

function config.get_timeout()
  return config.preferences.timeout_seconds.value
end

function config.should_auto_insert()
  return config.preferences.auto_insert.value
end

function config.should_show_preview()
  return config.preferences.show_preview.value
end

--------------------------------------------------------------------------------
-- Setters
--------------------------------------------------------------------------------

function config.set_provider(provider)
  config.preferences.provider.value = provider
end

function config.set_api_key(provider, key)
  if provider == "gemini" then
    config.preferences.gemini_api_key.value = key
  elseif provider == "openrouter" then
    config.preferences.openrouter_api_key.value = key
  elseif provider == "anthropic" then
    config.preferences.anthropic_api_key.value = key
  elseif provider == "openai" then
    config.preferences.openai_api_key.value = key
  elseif provider == "deepseek" then
    config.preferences.deepseek_api_key.value = key
  end
end

function config.set_model(provider, model)
  if provider == "gemini" then
    config.preferences.model_gemini.value = model
  elseif provider == "openrouter" then
    config.preferences.model_openrouter.value = model
  elseif provider == "anthropic" then
    config.preferences.model_anthropic.value = model
  elseif provider == "openai" then
    config.preferences.model_openai.value = model
  elseif provider == "deepseek" then
    config.preferences.model_deepseek.value = model
  end
end

--------------------------------------------------------------------------------
-- Validation
--------------------------------------------------------------------------------

function config.validate_api_key(provider)
  local key = config.get_api_key(provider)

  if not key or key == "" then
    return false, "API key not configured for " .. provider
  end

  -- Basic format validation
  if provider == "gemini" then
    if not key:match("^AIza") then
      return false, "Invalid Gemini API key format (should start with 'AIza')"
    end
  elseif provider == "openrouter" then
    if not key:match("^sk%-") then
      return false, "Invalid OpenRouter API key format (should start with 'sk-')"
    end
  elseif provider == "anthropic" then
    if not key:match("^sk%-ant%-") then
      return false, "Invalid Anthropic API key format (should start with 'sk-ant-')"
    end
  elseif provider == "openai" then
    if not key:match("^sk%-") then
      return false, "Invalid OpenAI API key format (should start with 'sk-')"
    end
  end

  return true, nil
end

function config.is_configured(provider)
  provider = provider or config.get_provider()
  local valid, error = config.validate_api_key(provider)
  return valid
end

--------------------------------------------------------------------------------
-- Key Display (for UI)
--------------------------------------------------------------------------------

function config.get_masked_key(provider)
  local key = config.get_api_key(provider)

  if not key or key == "" then
    return "(not set)"
  end

  if #key < 8 then
    return "****"
  end

  -- Show only last 4 characters
  return "****" .. key:sub(-4)
end

--------------------------------------------------------------------------------
-- Prompt History
--------------------------------------------------------------------------------

function config.add_to_history(prompt)
  if not prompt or prompt == "" then
    return
  end

  -- Remove if already exists
  for i, p in ipairs(config.prompt_history) do
    if p == prompt then
      table.remove(config.prompt_history, i)
      break
    end
  end

  -- Add to beginning
  table.insert(config.prompt_history, 1, prompt)

  -- Trim to max size
  local max_size = config.preferences.prompt_history_size.value
  while #config.prompt_history > max_size do
    table.remove(config.prompt_history)
  end
end

function config.get_history()
  return config.prompt_history
end

return config
