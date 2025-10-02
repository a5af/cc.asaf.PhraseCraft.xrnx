--[[============================================================================
utils/phrase_utils.lua
============================================================================]]--

-- Phrase editor integration utilities

local phrase_utils = {}

-- Lua 5.1 / 5.2+ compatibility
local loadstring = loadstring or load

--------------------------------------------------------------------------------
-- Phrase Detection
--------------------------------------------------------------------------------

function phrase_utils.has_selected_phrase()
  local song = renoise.song()
  return song.selected_phrase ~= nil
end

function phrase_utils.get_selected_phrase()
  local song = renoise.song()
  return song.selected_phrase
end

--------------------------------------------------------------------------------
-- Code Insertion
--------------------------------------------------------------------------------

function phrase_utils.insert_code(code)
  if not code or code == "" then
    return false, "No code to insert"
  end

  local song = renoise.song()

  -- Check if we're in phrase edit mode
  if not song.selected_phrase then
    return false, "No phrase selected. Please select a phrase in the Instrument Phrase Editor first."
  end

  local phrase = song.selected_phrase

  -- Set phrase to script mode if not already
  if phrase.key_tracking ~= renoise.InstrumentPhrase.KEY_TRACKING_NONE then
    -- Preserve key tracking setting
  end

  -- Insert the generated code
  -- Note: In Renoise API, phrase scripts are not directly editable via API
  -- This is a limitation. We'll need to instruct users to copy-paste
  -- OR if the API supports it in newer versions, use that

  -- For now, we'll return the code and let the UI handle display
  return true, code
end

function phrase_utils.validate_lua_code(code)
  -- Basic Lua syntax validation
  local func, err = loadstring(code)

  if not func then
    return false, "Lua syntax error: " .. tostring(err)
  end

  return true, nil
end

--------------------------------------------------------------------------------
-- Code Extraction from LLM Response
--------------------------------------------------------------------------------

function phrase_utils.extract_code_blocks(text)
  if not text then
    return nil
  end

  -- Try to find code blocks marked with ```lua or ```
  local code_blocks = {}

  -- Pattern 1: ```lua ... ```
  for code in text:gmatch("```lua%s*\n(.-)```") do
    table.insert(code_blocks, code)
  end

  -- Pattern 2: ``` ... ``` (without language specifier)
  if #code_blocks == 0 then
    for code in text:gmatch("```%s*\n(.-)```") do
      table.insert(code_blocks, code)
    end
  end

  -- Pattern 3: Look for lines that appear to be Lua code
  if #code_blocks == 0 then
    -- Check if the entire response looks like code
    if text:match("^%s*function%s+") or
       text:match("^%s*local%s+") or
       text:match("^%s*return%s+") or
       text:match("^%s*for%s+") or
       text:match("^%s*if%s+") then
      table.insert(code_blocks, text)
    end
  end

  if #code_blocks == 0 then
    return nil
  end

  -- Return the first (or largest) code block
  if #code_blocks == 1 then
    return code_blocks[1]
  end

  -- Return the largest code block
  local largest = ""
  for _, code in ipairs(code_blocks) do
    if #code > #largest then
      largest = code
    end
  end

  return largest
end

--------------------------------------------------------------------------------
-- Code Formatting
--------------------------------------------------------------------------------

function phrase_utils.format_code(code)
  if not code then
    return ""
  end

  -- Trim leading/trailing whitespace
  code = code:match("^%s*(.-)%s*$")

  -- Ensure it ends with a newline
  if not code:match("\n$") then
    code = code .. "\n"
  end

  return code
end

--------------------------------------------------------------------------------
-- Phrase Information
--------------------------------------------------------------------------------

function phrase_utils.get_phrase_info()
  local phrase = phrase_utils.get_selected_phrase()

  if not phrase then
    return nil
  end

  local info = {
    number_of_lines = phrase.number_of_lines,
    visible_note_columns = phrase.visible_note_columns,
    visible_effect_columns = phrase.visible_effect_columns,
    key_tracking = phrase.key_tracking,
    base_note = phrase.base_note,
    samples_per_line = phrase.samples_per_line,
  }

  return info
end

function phrase_utils.build_context_prompt(user_prompt)
  local info = phrase_utils.get_phrase_info()

  if not info then
    return user_prompt
  end

  -- Build enhanced prompt with context
  local context = string.format(
    "Generate a Renoise phrase script (Lua code) for the following request. " ..
    "The phrase has %d lines, %d note columns, and %d effect columns. " ..
    "Return ONLY the Lua code, no explanations.\n\nRequest: %s",
    info.number_of_lines,
    info.visible_note_columns,
    info.visible_effect_columns,
    user_prompt
  )

  return context
end

return phrase_utils
