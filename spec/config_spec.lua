--[[============================================================================
spec/config_spec.lua
============================================================================]]--

-- Tests for configuration management

-- Load mock Renoise API
require("spec.mock_renoise")

-- Load the module to test
local config = require("utils.config")

describe("Config", function()

  before_each(function()
    -- Initialize preferences for each test
    config.initialize_preferences()
  end)

  describe("get_provider", function()

    it("should return default provider", function()
      local provider = config.get_provider()

      assert_equals(provider, "anthropic")
    end)

  end)

  describe("set_provider", function()

    it("should set provider", function()
      config.set_provider("openai")

      assert_equals(config.get_provider(), "openai")
    end)

  end)

  describe("API key management", function()

    it("should set and get Anthropic API key", function()
      config.set_api_key("anthropic", "sk-ant-test123")

      assert_equals(config.get_api_key("anthropic"), "sk-ant-test123")
    end)

    it("should set and get OpenAI API key", function()
      config.set_api_key("openai", "sk-test456")

      assert_equals(config.get_api_key("openai"), "sk-test456")
    end)

    it("should set and get DeepSeek API key", function()
      config.set_api_key("deepseek", "ds-test789")

      assert_equals(config.get_api_key("deepseek"), "ds-test789")
    end)

  end)

  describe("validate_api_key", function()

    it("should validate Anthropic key format", function()
      config.set_api_key("anthropic", "sk-ant-test123")

      local valid, err = config.validate_api_key("anthropic")

      assert_true(valid)
      assert_nil(err)
    end)

    it("should reject invalid Anthropic key format", function()
      config.set_api_key("anthropic", "invalid-key")

      local valid, err = config.validate_api_key("anthropic")

      assert_false(valid)
      assert_not_nil(err)
    end)

    it("should validate OpenAI key format", function()
      config.set_api_key("openai", "sk-test123")

      local valid, err = config.validate_api_key("openai")

      assert_true(valid)
      assert_nil(err)
    end)

    it("should reject invalid OpenAI key format", function()
      config.set_api_key("openai", "invalid-key")

      local valid, err = config.validate_api_key("openai")

      assert_false(valid)
      assert_not_nil(err)
    end)

    it("should reject empty API key", function()
      config.set_api_key("anthropic", "")

      local valid, err = config.validate_api_key("anthropic")

      assert_false(valid)
      assert_not_nil(err)
    end)

  end)

  describe("get_masked_key", function()

    it("should mask API key showing only last 4 characters", function()
      config.set_api_key("anthropic", "sk-ant-test123456")

      local masked = config.get_masked_key("anthropic")

      assert_equals(masked, "****3456")
    end)

    it("should show (not set) for empty key", function()
      config.set_api_key("anthropic", "")

      local masked = config.get_masked_key("anthropic")

      assert_equals(masked, "(not set)")
    end)

  end)

  describe("model management", function()

    it("should get default Anthropic model", function()
      local model = config.get_model("anthropic")

      assert_equals(model, "claude-3-5-sonnet-20241022")
    end)

    it("should set custom model", function()
      config.set_model("anthropic", "claude-custom")

      assert_equals(config.get_model("anthropic"), "claude-custom")
    end)

  end)

  describe("timeout settings", function()

    it("should get default timeout", function()
      local timeout = config.get_timeout()

      assert_equals(timeout, 30)
    end)

    it("should enforce minimum timeout", function()
      config.preferences.timeout_seconds.value = 5
      config.initialize_preferences()

      assert_true(config.get_timeout() >= 10)
    end)

    it("should enforce maximum timeout", function()
      config.preferences.timeout_seconds.value = 200
      config.initialize_preferences()

      assert_true(config.get_timeout() <= 120)
    end)

  end)

  describe("prompt history", function()

    it("should add prompts to history", function()
      config.add_to_history("prompt 1")
      config.add_to_history("prompt 2")

      local history = config.get_history()

      assert_equals(#history, 2)
      assert_equals(history[1], "prompt 2")
      assert_equals(history[2], "prompt 1")
    end)

    it("should not add empty prompts", function()
      config.add_to_history("")
      config.add_to_history(nil)

      local history = config.get_history()

      assert_equals(#history, 0)
    end)

    it("should remove duplicates and move to front", function()
      config.add_to_history("prompt 1")
      config.add_to_history("prompt 2")
      config.add_to_history("prompt 1")

      local history = config.get_history()

      assert_equals(#history, 2)
      assert_equals(history[1], "prompt 1")
      assert_equals(history[2], "prompt 2")
    end)

  end)

end)
