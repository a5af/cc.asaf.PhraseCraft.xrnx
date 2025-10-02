# LLM Composer for Renoise

Generate Renoise phrase scripts using natural language prompts powered by LLM APIs.

## Overview

LLM Composer is a Renoise tool that lets you generate phrase script code by describing what you want in plain English. Instead of manually writing Lua code, simply describe your pattern or effect, and the LLM will generate the code for you.

**Example:**
- Prompt: "Create a random arpeggio in C minor"
- Result: Ready-to-use Lua code for your phrase editor

## Features

- 🤖 **Multiple LLM Providers**: Anthropic Claude, OpenAI ChatGPT, DeepSeek (v0.1 has Anthropic only)
- 💬 **Natural Language**: Describe patterns in plain English
- 📝 **Code Preview**: See generated code before using it
- ⚙️ **Configurable**: Manage API keys and preferences
- 🔒 **Secure**: Keys stored in Renoise preferences

## Quick Start

1. **Install**: Copy this directory to your Renoise tools folder
2. **Configure**: `Tools > LLM Composer > Settings` - add your API key
3. **Use**: `Tools > LLM Composer` - enter a prompt and generate code
4. **Copy**: Copy the generated code and paste into your phrase script editor

See [USAGE.md](USAGE.md) for detailed instructions.

## Requirements

- Renoise 3.4.0+ (API version 6+)
- `curl` installed and in PATH
- API key from one of:
  - Anthropic Claude: https://console.anthropic.com/
  - OpenAI: https://platform.openai.com/api-keys
  - DeepSeek: https://platform.deepseek.com/

## Documentation

- **[DESIGN.md](DESIGN.md)**: Technical design and architecture
- **[USAGE.md](USAGE.md)**: Installation and usage guide

## Project Structure

```
cc.asaf.LLMComposer.xrnx/
├── manifest.xml              # Tool metadata
├── main.lua                  # Entry point
├── api/
│   └── anthropic_client.lua  # Claude API client
├── http/
│   └── https_client.lua      # HTTPS wrapper (curl)
├── ui/
│   └── prompt_panel.lua      # Main UI dialog
└── utils/
    ├── config.lua            # Preferences management
    └── phrase_utils.lua      # Phrase editor utilities
```

## Current Status

**Version 0.1 - MVP** ✅

Implemented:
- [x] Anthropic Claude API integration
- [x] Prompt dialog UI
- [x] Code preview and copy
- [x] API key configuration
- [x] curl-based HTTPS client

Coming Soon:
- [ ] OpenAI and DeepSeek support
- [ ] Prompt history
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

**Note**: This tool requires external API access and may incur costs. See USAGE.md for pricing details.
