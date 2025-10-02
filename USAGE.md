# LLM Composer - Usage Guide

## Installation

1. **Package the tool**: Rename this directory from `cc.asaf.LLMComposer.xrnx` to have the `.xrnx` extension (it's actually a directory, but Renoise recognizes it as a tool)

2. **Install in Renoise**:
   - Open Renoise
   - Go to `Tools > Tool Browser`
   - Click "Load/Reload Tool" and select this directory
   - OR: Copy this directory to your Renoise scripts folder:
     - Windows: `%APPDATA%\Renoise\V3.4.0\Scripts\Tools\`
     - macOS: `~/Library/Preferences/Renoise/V3.4.0/Scripts/Tools/`
     - Linux: `~/.renoise/V3.4.0/Scripts/Tools/`

3. **Restart Renoise** (if needed)

## Setup

### 1. Get an API Key

You'll need an API key from at least one provider:

- **Anthropic Claude** (Recommended): https://console.anthropic.com/
- **OpenAI ChatGPT**: https://platform.openai.com/api-keys
- **DeepSeek**: https://platform.deepseek.com/

### 2. Configure API Key

1. In Renoise, go to `Tools > LLM Composer > Settings...`
2. Select your preferred provider
3. Paste your API key
4. Click "Close"

## Usage

### Basic Workflow

1. **Open the Instrument Phrase Editor** in Renoise
2. **Select or create a phrase**
3. **Launch LLM Composer**:
   - Menu: `Tools > LLM Composer...`
   - Or set up a keyboard shortcut in Renoise preferences

4. **Enter your prompt**, for example:
   - "Generate a random arpeggio pattern"
   - "Create a drum fill with increasing complexity"
   - "Make a bass line that follows a C minor scale"

5. **Click "Generate"**

6. **Copy the generated code** from the preview area

7. **Paste into your phrase script editor**

### Example Prompts

```
Generate a simple ascending arpeggio in C major

Create a randomized hi-hat pattern with varying velocities

Make a bass line that plays root notes on beats 1 and 3

Generate a chord progression using triads

Create a glitch effect with random note delays
```

### Tips

- Be specific about what you want
- Mention note ranges, scales, rhythms, or effects
- The LLM knows about Renoise's phrase script API
- You can iterate by asking for modifications

## Requirements

### System Requirements

- **Renoise 3.4.0 or later** (API version 6+)
- **curl** must be installed and in PATH:
  - Linux/macOS: Usually pre-installed
  - Windows: Included in Windows 10 1803+, or download from https://curl.se/

To verify curl is installed:
```bash
curl --version
```

### API Costs

- **Anthropic**: ~$3-15 per million tokens (~$0.001-0.01 per generation)
- **OpenAI**: ~$10-30 per million tokens (~$0.002-0.01 per generation)
- **DeepSeek**: Free tier available, ~$0.27 per million tokens

A typical prompt + response costs less than $0.01.

## Troubleshooting

### "curl is not installed or not found in PATH"
- Install curl or ensure it's in your system PATH
- On Windows: Add `C:\Windows\System32` to PATH (where curl.exe lives)

### "API key not configured"
- Open Settings and enter your API key
- Make sure you've selected the correct provider

### "Network error"
- Check your internet connection
- Verify the API key is valid
- Try increasing timeout in config.lua if needed

### "No code found in response"
- The LLM didn't generate valid code
- Try rephrasing your prompt more specifically
- Check the LLM provider's status page

### Code won't paste into phrase editor
- Make sure you're in a phrase (not pattern)
- The phrase must be selected
- Due to API limitations, manual copy-paste is required

## Known Limitations

1. **Manual Copy-Paste Required**: Renoise's scripting API doesn't allow direct editing of phrase scripts, so you must manually copy and paste the generated code

2. **OpenAI and DeepSeek**: Only Anthropic Claude is implemented in v0.1. Other providers coming soon.

3. **No Streaming**: Responses arrive all at once (can take 5-30 seconds for complex requests)

4. **Context Awareness**: The LLM doesn't see your existing phrase script (could be added in future versions)

## Development

To modify or debug:

1. Set `_AUTO_RELOAD_DEBUG = true` in main.lua
2. Edit files
3. Tools > Tool Browser > Reload
4. Check Renoise's scripting console for errors

## Support

- GitHub Issues: https://github.com/asafe/LLMComposer.xrnx/issues
- Renoise Forum: https://forum.renoise.com/

## Version

Current version: **0.1 (MVP)**

MVP includes:
- Anthropic Claude integration
- Basic prompt dialog
- Code preview and copy
- API key management
