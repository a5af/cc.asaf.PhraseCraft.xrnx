--[[============================================================================
ui/prompt_panel.lua
============================================================================]]--

-- Main prompt panel UI

local config = require("utils.config")
local phrase_utils = require("utils.phrase_utils")
local anthropic_client = require("api.anthropic_client")

local ui = {}

--------------------------------------------------------------------------------
-- Dialog State
--------------------------------------------------------------------------------

local dialog = nil
local dialog_content = nil
local vb = nil

-- UI elements (stored for access)
local prompt_field = nil
local status_text = nil
local code_preview = nil
local generate_button = nil
local copy_button = nil
local insert_button = nil

-- Current generated code
local current_code = nil

--------------------------------------------------------------------------------
-- UI Helpers
--------------------------------------------------------------------------------

local function update_status(message, is_error)
  if status_text then
    status_text.text = message
    if is_error then
      status_text.font = "bold"
    else
      status_text.font = "normal"
    end
  end
end

local function show_code_preview(code)
  current_code = code

  if code_preview then
    code_preview.text = code
    code_preview.visible = true
  end

  if copy_button then
    copy_button.active = true
  end

  if insert_button then
    insert_button.active = phrase_utils.has_selected_phrase()
  end
end

local function hide_code_preview()
  current_code = nil

  if code_preview then
    code_preview.visible = false
  end

  if copy_button then
    copy_button.active = false
  end

  if insert_button then
    insert_button.active = false
  end
end

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

local function handle_generate()
  local prompt = prompt_field.value

  if not prompt or prompt == "" then
    update_status("Please enter a prompt", true)
    return
  end

  -- Check if provider is configured
  local provider = config.get_provider()

  if not config.is_configured(provider) then
    update_status("API key not configured. Please open Settings.", true)
    ui.show_settings()
    return
  end

  -- Disable generate button during request
  generate_button.active = false
  update_status("Generating code...")
  hide_code_preview()

  -- Add to history
  config.add_to_history(prompt)

  -- Get API client
  local client = nil
  local api_key = config.get_api_key(provider)
  local model = config.get_model(provider)
  local timeout = config.get_timeout()

  if provider == "anthropic" then
    client = anthropic_client.create(api_key, model)
  else
    generate_button.active = true
    update_status("Provider not yet implemented: " .. provider, true)
    return
  end

  -- Generate code
  local code, err = client:generate_code(prompt, timeout)

  -- Re-enable generate button
  generate_button.active = true

  if err then
    update_status("Error: " .. err, true)
    hide_code_preview()
    return
  end

  if not code then
    update_status("No code generated", true)
    hide_code_preview()
    return
  end

  -- Show success
  update_status("Code generated successfully!")
  show_code_preview(code)

  -- Auto-insert if configured
  if config.should_auto_insert() then
    handle_insert()
  end
end

local function handle_copy()
  if not current_code then
    return
  end

  -- Copy to clipboard
  renoise.app().window.active_middle_frame = renoise.ApplicationWindow.MIDDLE_FRAME_PATTERN_EDITOR

  -- In Renoise, we can't directly access clipboard via API
  -- Show the code in a dialog that users can copy from
  renoise.app():show_message(
    "Code generated successfully! Copy the code from the preview area.\n\n" ..
    "To use it: Select a phrase in the Instrument Phrase Editor and paste the code."
  )
end

local function handle_insert()
  if not current_code then
    update_status("No code to insert", true)
    return
  end

  local success, result = phrase_utils.insert_code(current_code)

  if not success then
    update_status("Insert failed: " .. result, true)
    renoise.app():show_warning(
      "Cannot insert code directly via API.\n\n" ..
      "Please:\n" ..
      "1. Select a phrase in the Instrument Phrase Editor\n" ..
      "2. Copy the code from the preview area\n" ..
      "3. Paste it into the phrase script editor\n\n" ..
      "Code is ready in the preview area below."
    )
    return
  end

  update_status("Code ready! Copy from preview and paste into phrase editor.")

  -- Note: Due to Renoise API limitations, we can't directly edit phrase scripts
  -- Users need to manually copy-paste the code
end

--------------------------------------------------------------------------------
-- Settings Dialog
--------------------------------------------------------------------------------

function ui.show_settings()
  local settings_vb = renoise.ViewBuilder()

  -- Get current values
  local provider = config.get_provider()
  local provider_index = 1
  if provider == "openai" then
    provider_index = 2
  elseif provider == "deepseek" then
    provider_index = 3
  end

  local anthropic_key = config.get_api_key("anthropic")
  local openai_key = config.get_api_key("openai")
  local deepseek_key = config.get_api_key("deepseek")

  -- Create UI elements
  local provider_popup = settings_vb:popup {
    items = {"Anthropic Claude", "OpenAI ChatGPT", "DeepSeek"},
    value = provider_index,
    width = 200,
    notifier = function(idx)
      if idx == 1 then
        config.set_provider("anthropic")
      elseif idx == 2 then
        config.set_provider("openai")
      elseif idx == 3 then
        config.set_provider("deepseek")
      end
    end
  }

  local anthropic_field = settings_vb:textfield {
    text = anthropic_key,
    width = 400,
    notifier = function(text)
      config.set_api_key("anthropic", text)
    end
  }

  local openai_field = settings_vb:textfield {
    text = openai_key,
    width = 400,
    notifier = function(text)
      config.set_api_key("openai", text)
    end
  }

  local deepseek_field = settings_vb:textfield {
    text = deepseek_key,
    width = 400,
    notifier = function(text)
      config.set_api_key("deepseek", text)
    end
  }

  local content = settings_vb:column {
    margin = 10,
    spacing = 10,

    settings_vb:text {
      text = "LLM Composer Settings",
      font = "bold"
    },

    settings_vb:horizontal_aligner {
      mode = "justify",
      settings_vb:text {
        text = "Default Provider:",
        width = 120
      },
      provider_popup
    },

    settings_vb:text {
      text = "API Keys:",
      font = "bold",
      style = "strong"
    },

    settings_vb:row {
      spacing = 5,
      settings_vb:text {
        text = "Anthropic:",
        width = 120
      },
      anthropic_field
    },

    settings_vb:row {
      spacing = 5,
      settings_vb:text {
        text = "OpenAI:",
        width = 120
      },
      openai_field
    },

    settings_vb:row {
      spacing = 5,
      settings_vb:text {
        text = "DeepSeek:",
        width = 120
      },
      deepseek_field
    },

    settings_vb:text {
      text = "Get API keys from:\n" ..
             "  • Anthropic: https://console.anthropic.com/\n" ..
             "  • OpenAI: https://platform.openai.com/api-keys\n" ..
             "  • DeepSeek: https://platform.deepseek.com/",
      font = "italic"
    },

    settings_vb:button {
      text = "Close",
      width = 100,
      notifier = function()
        -- Dialog will close automatically
      end
    }
  }

  renoise.app():show_custom_dialog("LLM Composer Settings", content)
end

--------------------------------------------------------------------------------
-- Main Dialog
--------------------------------------------------------------------------------

function ui.show_dialog()
  -- Create or show existing dialog
  if dialog and dialog.visible then
    dialog:show()
    return
  end

  vb = renoise.ViewBuilder()

  -- Create UI elements
  prompt_field = vb:multiline_textfield {
    width = 580,
    height = 80,
    text = "",
    edit_mode = true
  }

  status_text = vb:text {
    text = "Enter your prompt and click Generate",
    width = 580
  }

  code_preview = vb:multiline_textfield {
    width = 580,
    height = 200,
    text = "",
    edit_mode = false,
    visible = false,
    font = "mono"
  }

  generate_button = vb:button {
    text = "Generate",
    width = 100,
    height = 30,
    notifier = handle_generate
  }

  copy_button = vb:button {
    text = "Copy Code",
    width = 100,
    active = false,
    notifier = handle_copy
  }

  insert_button = vb:button {
    text = "Insert",
    width = 100,
    active = false,
    notifier = handle_insert
  }

  -- Build dialog content
  dialog_content = vb:column {
    margin = 10,
    spacing = 5,

    vb:text {
      text = "LLM Composer - Phrase Script Generator",
      font = "bold"
    },

    vb:row {
      spacing = 5,
      vb:text {
        text = "Provider:",
        width = 60
      },
      vb:text {
        text = config.get_provider():upper(),
        font = "bold",
        width = 100
      },
      vb:button {
        text = "Settings",
        width = 80,
        notifier = ui.show_settings
      }
    },

    vb:space { height = 5 },

    vb:text { text = "Prompt:" },
    prompt_field,

    vb:row {
      spacing = 5,
      generate_button,
      copy_button,
      insert_button
    },

    vb:space { height = 5 },

    status_text,

    vb:space { height = 5 },

    vb:text { text = "Generated Code Preview:" },
    code_preview,

    vb:text {
      text = "Note: Due to Renoise API limitations, you'll need to manually copy and paste the code into your phrase editor.",
      font = "italic"
    }
  }

  -- Show dialog
  dialog = renoise.app():show_custom_dialog("LLM Composer", dialog_content)
end

return ui
