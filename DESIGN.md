# LLMComposer - Design Proposal

## Overview

LLMComposer is a Renoise extension that integrates Large Language Model APIs directly into the Phrase Script Editor, allowing users to generate Lua code through natural language prompts. When "Script" mode is selected in the phrase editor, a text input interface appears that sends requests to LLM providers (Anthropic Claude, OpenAI ChatGPT, or DeepSeek) and inserts the generated code directly into the editor.

## Feasibility Assessment

### Technical Feasibility: **HIGH**

The implementation is highly feasible using Renoise's Lua scripting API:

**✓ Supported Capabilities:**
- Renoise Tools API provides full GUI construction via `renoise.ViewBuilder`
- HTTP requests available through `renoise.Socket` (TCP/UDP) or external process calls
- Access to phrase editor and pattern data through `renoise.song()`
- Keybindings, menu entries, and tool preferences system
- Native text input components and custom dialogs

**✗ Limitations:**
- Renoise's Lua environment uses Lua 5.1 (older, but stable)
- No native HTTPS library - requires workarounds (see Implementation)
- Asynchronous operations require manual coroutine management
- Limited to Renoise's sandboxed API surface

**Overall:** All core requirements are achievable within Renoise's scripting constraints.

## Architecture

### Component Structure

```
LLMComposer.xrnx/
├── manifest.xml                 # Tool metadata and configuration
├── main.lua                     # Entry point, tool initialization
├── api/
│   ├── base_client.lua         # Abstract API client interface
│   ├── anthropic_client.lua    # Claude API implementation
│   ├── openai_client.lua       # ChatGPT API implementation
│   └── deepseek_client.lua     # DeepSeek API implementation
├── http/
│   └── https_client.lua        # HTTPS wrapper (curl/wget fallback)
├── ui/
│   ├── prompt_panel.lua        # Bottom panel text input UI
│   ├── settings_dialog.lua     # API key & provider configuration
│   └── view_builder.lua        # GUI component helpers
└── utils/
    ├── config.lua              # Preferences management
    └── phrase_utils.lua        # Phrase script editor integration
```

### Data Flow

```
User Input (Prompt)
    ↓
Prompt Panel UI
    ↓
[Validate & Sanitize]
    ↓
API Client (selected provider)
    ↓
HTTPS Client → LLM API (HTTP POST)
    ↓
[Parse Response]
    ↓
Extract Code Block
    ↓
Insert into Phrase Script Editor
    ↓
Update UI (success/error feedback)
```

## Implementation Details

### 1. Tool Manifest (manifest.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<RenoiseScriptingTool doc_version="0">
  <ApiVersion>6</ApiVersion>
  <Id>cc.asaf.LLMComposer</Id>
  <Version>1.0</Version>
  <Name>LLM Composer</Name>
  <Author>Asaf</Author>
  <Description>Generate phrase scripts using LLM prompts</Description>
  <Category>Pattern Editor</Category>
  <Homepage>https://github.com/asafe/LLMComposer.xrnx</Homepage>
</RenoiseScriptingTool>
```

### 2. UI Integration Strategy

**Approach A: Custom Dialog (Recommended for v1.0)**
- Triggered via keyboard shortcut or menu item
- Modal/modeless dialog with prompt input field
- "Generate" button sends request
- Result preview before insertion
- Less invasive, easier to implement

**Approach B: Pattern Editor Integration (Advanced)**
- Hook into pattern editor's GUI (if accessible)
- Add persistent bottom panel when script mode active
- Requires deeper Renoise GUI knowledge
- May conflict with future Renoise updates

**Recommended:** Start with Approach A, migrate to B if Renoise API permits.

### 3. HTTP/HTTPS Implementation

Renoise Lua doesn't include native HTTPS. Three solutions:

**Option 1: External Process (curl/wget) ⭐ Recommended**
```lua
-- Using os.execute or io.popen
local function https_request(url, headers, body)
  local curl_cmd = string.format(
    'curl -s -X POST "%s" -H "Content-Type: application/json" %s -d %s',
    url, build_headers(headers), escape_json(body)
  )
  local handle = io.popen(curl_cmd)
  local response = handle:read("*a")
  handle:close()
  return response
end
```

**Option 2: LuaSocket + LuaSec**
- Bundle external Lua libraries (if Renoise permits)
- More complex, platform-specific builds required

**Option 3: Pure Lua HTTP + Proxy**
- Use `renoise.Socket` for plain HTTP to local proxy
- Run lightweight HTTPS proxy (nginx/socat)
- Adds deployment complexity

**Decision:** Option 1 (curl) is most practical - widely available on Linux/macOS, included in modern Windows.

### 4. API Client Implementations

#### Anthropic Claude API

```lua
-- api/anthropic_client.lua
local AnthropicClient = {}

function AnthropicClient:new(api_key)
  local client = {
    api_key = api_key,
    base_url = "https://api.anthropic.com/v1/messages",
    model = "claude-3-5-sonnet-20241022"
  }
  setmetatable(client, self)
  self.__index = self
  return client
end

function AnthropicClient:generate_code(prompt)
  local request_body = {
    model = self.model,
    max_tokens = 2048,
    messages = {{
      role = "user",
      content = "Generate Renoise phrase script Lua code for: " .. prompt
    }}
  }

  local headers = {
    ["x-api-key"] = self.api_key,
    ["anthropic-version"] = "2023-06-01",
    ["content-type"] = "application/json"
  }

  local response = https_post(self.base_url, headers, request_body)
  return self:extract_code(response)
end

function AnthropicClient:extract_code(response)
  local data = json.decode(response)
  if data.content and data.content[1] then
    return self:parse_code_blocks(data.content[1].text)
  end
  return nil, "No response content"
end
```

#### OpenAI ChatGPT API

```lua
-- api/openai_client.lua
local OpenAIClient = {}

function OpenAIClient:new(api_key)
  local client = {
    api_key = api_key,
    base_url = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4-turbo-preview"
  }
  setmetatable(client, self)
  self.__index = self
  return client
end

function OpenAIClient:generate_code(prompt)
  local request_body = {
    model = self.model,
    messages = {{
      role = "system",
      content = "You are a Renoise phrase script code generator. Output only Lua code."
    }, {
      role = "user",
      content = prompt
    }},
    temperature = 0.7
  }

  local headers = {
    ["Authorization"] = "Bearer " .. self.api_key,
    ["Content-Type"] = "application/json"
  }

  local response = https_post(self.base_url, headers, request_body)
  return self:extract_code(response)
end
```

#### DeepSeek API

```lua
-- api/deepseek_client.lua (similar to OpenAI structure)
local DeepSeekClient = {}

function DeepSeekClient:new(api_key)
  local client = {
    api_key = api_key or "", -- Free tier may not require key
    base_url = "https://api.deepseek.com/v1/chat/completions",
    model = "deepseek-coder"
  }
  setmetatable(client, self)
  self.__index = self
  return client
end

-- Implementation similar to OpenAI client
```

### 5. Configuration Management

```lua
-- utils/config.lua
local preferences = renoise.Document.create("LLMComposerPreferences") {
  provider = "anthropic", -- "anthropic" | "openai" | "deepseek"
  anthropic_api_key = "",
  openai_api_key = "",
  deepseek_api_key = "",
  model_anthropic = "claude-3-5-sonnet-20241022",
  model_openai = "gpt-4-turbo-preview",
  model_deepseek = "deepseek-coder",
  auto_insert = true, -- Auto-insert or show preview
  timeout_seconds = 30
}

renoise.tool().preferences = preferences
```

### 6. UI Components

```lua
-- ui/prompt_panel.lua
local dialog = nil

function show_llm_prompt_dialog()
  if dialog and dialog.visible then
    dialog:show()
    return
  end

  local vb = renoise.ViewBuilder()

  local prompt_field = vb:multiline_textfield {
    width = 500,
    height = 100,
    text = ""
  }

  local status_text = vb:text {
    text = "Enter your prompt and click Generate"
  }

  local content = vb:column {
    margin = 10,
    spacing = 5,

    vb:text { text = "LLM Phrase Script Generator", font = "bold" },

    vb:row {
      spacing = 5,
      vb:text { text = "Provider:" },
      vb:popup {
        items = {"Anthropic Claude", "OpenAI ChatGPT", "DeepSeek"},
        value = get_provider_index(),
        notifier = function(idx) set_provider_index(idx) end
      }
    },

    vb:text { text = "Prompt:" },
    prompt_field,

    vb:row {
      spacing = 5,
      vb:button {
        text = "Generate",
        width = 100,
        notifier = function()
          handle_generate_request(prompt_field.text, status_text)
        end
      },
      vb:button {
        text = "Settings",
        width = 100,
        notifier = show_settings_dialog
      }
    },

    status_text
  }

  dialog = renoise.app():show_custom_dialog("LLM Composer", content)
end
```

### 7. Phrase Editor Integration

```lua
-- utils/phrase_utils.lua
function insert_into_phrase_editor(code)
  local song = renoise.song()

  -- Check if we're in phrase edit mode
  if not song.selected_phrase then
    renoise.app():show_warning("No phrase selected. Please select a phrase first.")
    return false
  end

  local phrase = song.selected_phrase

  -- Set phrase to script mode if not already
  if phrase.phrase_script_mode ~= renoise.InstrumentPhrase.SCRIPT_MODE_CUSTOM then
    phrase.phrase_script_mode = renoise.InstrumentPhrase.SCRIPT_MODE_CUSTOM
  end

  -- Insert the generated code
  phrase.script_code = code

  renoise.app():show_status("LLM code inserted successfully")
  return true
end
```

## Security & Privacy Considerations

### API Key Management

1. **Storage**: Keys stored in Renoise preferences (encrypted if possible)
2. **Validation**: Never log or display full API keys
3. **Redaction**: Show only last 4 characters (e.g., `sk-...xyz123`)

### Code Execution Safety

1. **Preview Mode**: Show generated code before insertion
2. **Syntax Validation**: Basic Lua syntax check before insertion
3. **User Confirmation**: Optional "Review before insert" setting
4. **Sandboxing**: Renoise's phrase scripts already run in restricted environment

### Network Privacy

1. **HTTPS Only**: All API calls must use encrypted connections
2. **No Telemetry**: Don't send usage data without explicit consent
3. **Local Processing**: Parse responses locally, don't send to third parties

## Challenges & Mitigation Strategies

### Challenge 1: HTTPS in Renoise Lua
**Mitigation**: Use curl/wget system calls (cross-platform compatible)

### Challenge 2: Asynchronous API Calls
**Problem**: HTTP requests block UI thread
**Mitigation**:
- Show loading indicator
- Implement timeout (30s default)
- Consider coroutine-based async wrapper

### Challenge 3: API Rate Limits
**Mitigation**:
- Implement exponential backoff
- Cache recent responses (optional)
- Display clear error messages

### Challenge 4: Response Parsing
**Problem**: LLMs may return non-code text
**Mitigation**:
- Use code fence detection (```lua ... ```)
- System prompts enforce code-only output
- Fallback: extract largest code block

### Challenge 5: Context Awareness
**Problem**: LLM doesn't know current phrase state
**Mitigation**: (Future enhancement)
- Include current phrase script in prompt context
- Send phrase properties (length, notes, etc.)

## Development Roadmap

### Phase 1: MVP (v0.1)
- [x] Project structure
- [ ] Basic HTTP client (curl wrapper)
- [ ] Anthropic API integration
- [ ] Simple prompt dialog UI
- [ ] Direct insertion into phrase editor
- [ ] API key configuration

### Phase 2: Multi-Provider (v0.5)
- [ ] OpenAI API support
- [ ] DeepSeek API support
- [ ] Provider selection UI
- [ ] Error handling improvements
- [ ] Response preview mode

### Phase 3: Polish (v1.0)
- [ ] Keyboard shortcuts
- [ ] Prompt history
- [ ] Code validation before insert
- [ ] Documentation & examples
- [ ] Beta testing

### Phase 4: Advanced Features (v1.x)
- [ ] Context-aware prompts (current phrase analysis)
- [ ] Multi-turn conversations
- [ ] Code refinement ("modify the last generated code to...")
- [ ] Template library
- [ ] Streaming responses (if API supports)

## Testing Strategy

1. **Unit Tests**: Mock HTTP responses, test parsing
2. **Integration Tests**: Real API calls with test keys
3. **Manual Testing**: Various phrase scenarios
4. **Edge Cases**:
   - Empty responses
   - Malformed JSON
   - Network timeouts
   - Invalid API keys
   - Rate limit errors

## Deployment

### Installation
1. Download `.xrnx` file
2. Drag into Renoise or use Tools menu
3. Configure API keys in tool preferences
4. Access via Tools > LLM Composer or keyboard shortcut

### Platform Requirements
- Renoise 3.4.0+ (API version 6+)
- curl or wget installed (for HTTPS)
- Internet connection
- Valid API key for chosen provider

## Cost Considerations

### API Pricing (as of 2025)
- **Anthropic Claude**: ~$3 per 1M input tokens, $15 per 1M output tokens
- **OpenAI GPT-4**: ~$10 per 1M input tokens, $30 per 1M output tokens
- **DeepSeek**: Free tier available, ~$0.27 per 1M tokens (paid)

### Estimated Usage
- Average prompt: ~100 tokens input
- Average response: ~300 tokens output
- Cost per generation: $0.001 - $0.01 (depending on provider)
- 1000 generations: $1 - $10

**Recommendation**: Start with DeepSeek (free) for testing, upgrade to Claude/GPT-4 for production.

## Conclusion

The LLMComposer extension is **highly feasible** and can be implemented entirely within Renoise's Lua scripting API. The primary technical challenge (HTTPS support) has a proven solution via external process calls. The proposed architecture is modular, extensible, and follows Renoise tool development best practices.

**Next Steps:**
1. Set up basic project structure with manifest.xml
2. Implement HTTP client wrapper
3. Build Anthropic API integration first (most reliable)
4. Create minimal UI dialog
5. Test end-to-end workflow
6. Iterate based on user feedback

The tool will significantly streamline phrase script creation for users familiar with natural language but less comfortable with Lua syntax, while remaining a productivity enhancement for experienced scripters.
