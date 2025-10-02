--[[============================================================================
spec/phrase_utils_spec.lua
============================================================================]]--

-- Tests for phrase utilities

-- Load mock Renoise API
require("spec.mock_renoise")

-- Load the module to test
local phrase_utils = require("utils.phrase_utils")

describe("Phrase Utils", function()

  describe("extract_code_blocks", function()

    it("should extract code from lua code fence", function()
      local text = "```lua\nlocal x = 1\nprint(x)\n```"
      local code = phrase_utils.extract_code_blocks(text)

      assert_not_nil(code)
      assert_match(code, "local x = 1")
      assert_match(code, "print%(x%)")
    end)

    it("should extract code from generic code fence", function()
      local text = "```\nfunction test()\n  return true\nend\n```"
      local code = phrase_utils.extract_code_blocks(text)

      assert_not_nil(code)
      assert_match(code, "function test%(%)")
    end)

    it("should extract code that looks like Lua", function()
      local text = "function hello()\n  print('world')\nend"
      local code = phrase_utils.extract_code_blocks(text)

      assert_not_nil(code)
      assert_match(code, "function hello%(%)")
    end)

    it("should return nil for non-code text", function()
      local text = "This is just some regular text without any code."
      local code = phrase_utils.extract_code_blocks(text)

      assert_nil(code)
    end)

    it("should extract the largest code block when multiple exist", function()
      local text = "```lua\nlocal x = 1\n```\n\nSome text\n\n```lua\nfunction big()\n  local a = 1\n  local b = 2\n  return a + b\nend\n```"
      local code = phrase_utils.extract_code_blocks(text)

      assert_not_nil(code)
      assert_match(code, "function big%(%)")
      assert_match(code, "return a %+ b")
    end)

  end)

  describe("format_code", function()

    it("should trim whitespace", function()
      local code = "  \n  local x = 1  \n  "
      local formatted = phrase_utils.format_code(code)

      assert_equals(formatted, "local x = 1\n")
    end)

    it("should add trailing newline if missing", function()
      local code = "local x = 1"
      local formatted = phrase_utils.format_code(code)

      assert_equals(formatted, "local x = 1\n")
    end)

    it("should handle nil input", function()
      local formatted = phrase_utils.format_code(nil)

      assert_equals(formatted, "")
    end)

  end)

  describe("validate_lua_code", function()

    it("should validate correct Lua code", function()
      local code = "local x = 1\nreturn x"
      local valid, err = phrase_utils.validate_lua_code(code)

      assert_true(valid)
      assert_nil(err)
    end)

    it("should detect syntax errors", function()
      local code = "local x = \nthis is not valid lua"
      local valid, err = phrase_utils.validate_lua_code(code)

      assert_false(valid)
      assert_not_nil(err)
    end)

    it("should validate function definitions", function()
      local code = "function test()\n  return true\nend"
      local valid, err = phrase_utils.validate_lua_code(code)

      assert_true(valid)
      assert_nil(err)
    end)

  end)

  describe("get_phrase_info", function()

    it("should return phrase properties", function()
      local info = phrase_utils.get_phrase_info()

      assert_not_nil(info)
      assert_equals(info.number_of_lines, 16)
      assert_equals(info.visible_note_columns, 12)
      assert_equals(info.visible_effect_columns, 8)
    end)

    it("should return nil when no phrase selected", function()
      -- Temporarily clear selected phrase
      local song = renoise.song()
      local original = song.selected_phrase
      song.selected_phrase = nil

      local info = phrase_utils.get_phrase_info()

      assert_nil(info)

      -- Restore
      song.selected_phrase = original
    end)

  end)

  describe("build_context_prompt", function()

    it("should enhance prompt with phrase context", function()
      local user_prompt = "create an arpeggio"
      local context = phrase_utils.build_context_prompt(user_prompt)

      assert_not_nil(context)
      assert_match(context, "16 lines")
      assert_match(context, "12 note columns")
      assert_match(context, "create an arpeggio")
    end)

    it("should return original prompt when no phrase selected", function()
      local song = renoise.song()
      local original = song.selected_phrase
      song.selected_phrase = nil

      local user_prompt = "create an arpeggio"
      local context = phrase_utils.build_context_prompt(user_prompt)

      assert_equals(context, user_prompt)

      song.selected_phrase = original
    end)

  end)

  describe("has_selected_phrase", function()

    it("should return true when phrase is selected", function()
      assert_true(phrase_utils.has_selected_phrase())
    end)

    it("should return false when no phrase selected", function()
      local song = renoise.song()
      local original = song.selected_phrase
      song.selected_phrase = nil

      assert_false(phrase_utils.has_selected_phrase())

      song.selected_phrase = original
    end)

  end)

end)
