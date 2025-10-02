--[[============================================================================
spec/mock_renoise.lua
============================================================================]]--

-- Mock Renoise API for testing

local mock_renoise = {}

-- Mock renoise global
_G.renoise = {
  Document = {
    create = function(name)
      return function(defaults)
        local doc = {}
        for key, value in pairs(defaults) do
          doc[key] = {
            value = value,
            add_notifier = function() end,
            remove_notifier = function() end
          }
        end
        return doc
      end
    end
  },

  tool = function()
    return {
      preferences = {},
      parse_json = function(self, str)
        -- Very basic JSON parser for testing
        return mock_renoise.parse_json(str)
      end
    }
  end,

  song = function()
    -- Return a proxy that allows setting selected_phrase
    return setmetatable({}, {
      __index = function(t, k)
        if k == "selected_phrase" then
          return mock_renoise.selected_phrase
        end
        return nil
      end,
      __newindex = function(t, k, v)
        if k == "selected_phrase" then
          mock_renoise.selected_phrase = v
        end
      end
    })
  end,

  app = function()
    return {
      show_warning = function(msg)
        print("WARNING: " .. msg)
      end,
      show_message = function(msg)
        print("MESSAGE: " .. msg)
      end,
      show_status = function(msg)
        print("STATUS: " .. msg)
      end,
      show_custom_dialog = function(title, content)
        return { visible = true, show = function() end }
      end
    }
  end,

  ViewBuilder = function()
    return mock_renoise.view_builder
  end,

  InstrumentPhrase = {
    KEY_TRACKING_NONE = 1,
    SCRIPT_MODE_CUSTOM = 2
  }
}

-- Mock phrase
mock_renoise.selected_phrase = {
  number_of_lines = 16,
  visible_note_columns = 12,
  visible_effect_columns = 8,
  key_tracking = 1,
  base_note = 48,
  samples_per_line = 256,
  phrase_script_mode = 2,
  script_code = ""
}

-- Mock view builder
mock_renoise.view_builder = {
  column = function(self, props) return props end,
  row = function(self, props) return props end,
  text = function(self, props) return props end,
  button = function(self, props) return props end,
  textfield = function(self, props) return props end,
  multiline_textfield = function(self, props) return props end,
  popup = function(self, props) return props end,
  space = function(self, props) return props end,
  horizontal_aligner = function(self, props) return props end
}

-- Simple JSON parser for testing
function mock_renoise.parse_json(str)
  if not str or str == "" then
    return nil
  end

  -- Very basic parser for test responses
  local obj = {}

  -- Anthropic-style response
  if str:match('"content"') then
    local text = str:match('"text"%s*:%s*"([^"]*)"')
    if text then
      obj.content = {{text = text}}
    end
  end

  -- OpenAI-style response
  if str:match('"choices"') then
    local content = str:match('"content"%s*:%s*"([^"]*)"')
    if content then
      obj.choices = {{message = {content = content}}}
    end
  end

  -- Error response
  if str:match('"error"') then
    local msg = str:match('"message"%s*:%s*"([^"]*)"')
    if msg then
      obj.error = {message = msg}
    end
  end

  return obj
end

-- Reset mock state
function mock_renoise.reset()
  mock_renoise.selected_phrase = {
    number_of_lines = 16,
    visible_note_columns = 12,
    visible_effect_columns = 8,
    key_tracking = 1,
    base_note = 48,
    samples_per_line = 256,
    phrase_script_mode = 2,
    script_code = ""
  }
end

return mock_renoise
