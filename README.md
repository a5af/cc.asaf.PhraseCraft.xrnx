# PhraseCraft for Renoise

Craft Renoise phrase scripts using natural language prompts powered by AI.

## Overview

PhraseCraft is a Renoise tool that lets you generate phrase script code by describing what you want in plain English. Instead of manually writing Lua code, simply describe your pattern or effect, and AI will craft the code for you.

**Example:**
- Prompt: "Create a random arpeggio in C minor"
- Result: Ready-to-use Lua code for your phrase editor

## Features

- 🆓 **Free Options Available**: Google Gemini (1,500 requests/day) and OpenRouter (free models)
- 🤖 **Multiple LLM Providers**: Gemini, OpenRouter, Anthropic Claude, OpenAI, DeepSeek
- 💬 **Natural Language**: Describe patterns in plain English
- 📝 **Code Preview**: See generated code before using it
- ⚙️ **Configurable**: Manage API keys and preferences
- 🔒 **Secure**: Keys stored in Renoise preferences

## Quick Start

1. **Install**: Copy this directory to your Renoise tools folder
2. **Configure**: `Tools > PhraseCraft > Settings` - add your API key
3. **Use**: `Tools > PhraseCraft` - enter a prompt and generate code
4. **Copy**: Copy the generated code and paste into your phrase script editor

See [USAGE.md](USAGE.md) for detailed instructions.

## Requirements

- Renoise 3.4.0+ (API version 6+)
- `curl` installed and in PATH
- API key from one of:
  - **Google Gemini (FREE)**: https://aistudio.google.com - 1,500 requests/day
  - **OpenRouter (FREE)**: https://openrouter.ai - Free models available
  - Anthropic Claude: https://console.anthropic.com/
  - OpenAI: https://platform.openai.com/api-keys
  - DeepSeek: https://platform.deepseek.com/

## Documentation

- **[DESIGN.md](DESIGN.md)**: Technical design and architecture
- **[USAGE.md](USAGE.md)**: Installation and usage guide
- **[FREE_PROVIDERS.md](FREE_PROVIDERS.md)**: Free LLM provider options (recommended)

## Project Structure

```
cc.asaf.PhraseCraft.xrnx/
├── manifest.xml              # Tool metadata
├── main.lua                  # Entry point
├── api/
│   ├── gemini_client.lua     # Google Gemini API (free)
│   ├── openrouter_client.lua # OpenRouter API (free models)
│   └── anthropic_client.lua  # Anthropic Claude API
├── http/
│   └── https_client.lua      # HTTPS wrapper (curl)
├── ui/
│   └── prompt_panel.lua      # Main UI dialog
└── utils/
    ├── config.lua            # Preferences management
    └── phrase_utils.lua      # Phrase editor utilities
```

## Current Status

**Version 0.2** ✅

Implemented:
- [x] Google Gemini API (free tier - default)
- [x] OpenRouter API (free models)
- [x] Anthropic Claude API integration
- [x] Prompt dialog UI with all providers
- [x] Code preview and copy
- [x] API key configuration
- [x] curl-based HTTPS client
- [x] Comprehensive test suite

Coming Soon:
- [ ] OpenAI and DeepSeek API support
- [ ] Prompt history UI
- [ ] Direct code insertion (if API permits)
- [ ] Context-aware prompts

## Development

To hack on this tool:

1. Edit files in this directory
2. In Renoise: `Tools > Tool Browser > Reload`
3. Check the scripting console for errors

## License

MIT License - See LICENSE file

## Credits

Created by Asaf
Built for the Renoise community

---

**Note**: This tool works with both free and paid LLM providers. See [FREE_PROVIDERS.md](FREE_PROVIDERS.md) for completely free options (recommended for most users).
