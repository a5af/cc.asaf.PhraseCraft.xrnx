# Free AI Provider Options for PhraseCraft

This document outlines free AI provider options that can be used with PhraseCraft, with no credit card required.

## Overview

While PhraseCraft supports paid providers (Anthropic Claude, OpenAI, DeepSeek), there are several **completely free** alternatives that work just as well for crafting Renoise phrase scripts. This guide covers the best free options as of 2025.

---

## Recommended: Google Gemini (Free Tier) ⭐

**Best overall free option** - Generous limits, no credit card required, stable and reliable.

### Why Gemini?

- ✅ **Completely Free**: 1,500 requests per day with Gemini 1.5 Flash
- ✅ **No Credit Card**: Just sign in with a Google account
- ✅ **High Quality**: Excellent code generation capabilities
- ✅ **Stable**: Google has confirmed the free tier "isn't going anywhere anytime soon"
- ✅ **Fast Setup**: Get your API key in under 5 minutes
- ✅ **1M Token Context**: Huge context window for complex requests

### How to Get Your Gemini API Key

1. **Visit Google AI Studio**: https://aistudio.google.com
2. **Sign in** with any Google account (no credit card needed)
3. **Click "Get API key"** button in the dashboard
4. **Create API key** in a new or existing Google Cloud project
5. **Copy your key** - it looks like: `AIzaSy...`

### Rate Limits (Free Tier)

- **Gemini 1.5 Flash**: 1,500 requests/day, 15 requests/minute
- **Gemini 1.5 Pro**: 50 requests/day, 2 requests/minute
- **Gemini 2.0 Flash**: 1,500 requests/day, 10 requests/minute

**For Renoise scripting**: Gemini 1.5 Flash is perfect and more than sufficient.

### API Details

- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/`
- **Compatible with**: OpenAI-style API format (with minor differences)
- **Documentation**: https://ai.google.dev/gemini-api/docs

---

## Alternative: OpenRouter (Free Models)

**Best for variety** - Access to 300+ models, some free, unified API.

### Why OpenRouter?

- ✅ **Multiple Free Models**: DeepSeek, Llama, Qwen, and more
- ✅ **No Setup Cost**: Free tier with 20-50 requests per day
- ✅ **OpenAI Compatible**: Drop-in replacement API
- ✅ **Automatic Fallbacks**: Routes to available models
- ✅ **Single API Key**: Access hundreds of models

### How to Get Your OpenRouter API Key

1. **Visit OpenRouter**: https://openrouter.ai
2. **Sign up** for a free account
3. **Get API key** from your dashboard
4. **Use free models** by appending `:free` to model IDs

### Free Models Available (2025)

- **DeepSeek R1** (`:free`): Strong reasoning capabilities
- **Llama 3.3 70B** (`:free`): Meta's latest open model
- **Qwen 2.5 72B** (`:free`): Excellent for code generation
- **Mistral models** (`:free` variants): Fast and capable

### Rate Limits (Free Tier)

- **Without credits**: 50 requests per day
- **With $10 credit purchase**: 1,000 requests per day
- **Per minute**: 20 requests/minute for free models

### API Details

- **Endpoint**: `https://openrouter.ai/api/v1/`
- **Compatible with**: OpenAI SDK (100% compatible)
- **Format**: Identical to OpenAI's API
- **Documentation**: https://openrouter.ai/docs

### Example Model IDs

```
meta-llama/llama-3.3-70b-instruct:free
deepseek/deepseek-r1:free
qwen/qwen-2.5-72b-instruct:free
mistralai/mistral-7b-instruct:free
```

---

## Other Free Options

### 1. Groq (Fast Inference)

- **Best for**: Ultra-low latency responses
- **Free Tier**: 30 requests/minute, 14,400/day
- **Models**: Llama 3.3, Mixtral, Gemma
- **Endpoint**: `https://api.groq.com/openai/v1/`
- **Sign up**: https://console.groq.com

### 2. Hugging Face Inference API

- **Best for**: Open source models
- **Free Tier**: Rate-limited but generous
- **Models**: Thousands of open models
- **Endpoint**: `https://api-inference.huggingface.co/models/`
- **Sign up**: https://huggingface.co

### 3. GitHub Models (Preview)

- **Best for**: GitHub users
- **Free Tier**: Available with GitHub account
- **Models**: GPT-4, Llama, Mistral
- **Endpoint**: Azure-compatible
- **Sign up**: https://github.com/marketplace/models

### 4. Cloudflare Workers AI

- **Best for**: Edge deployment
- **Free Tier**: 10,000 neurons/day
- **Models**: Llama, Mistral, more
- **Endpoint**: Cloudflare Workers
- **Sign up**: https://dash.cloudflare.com

---

## Comparison Table

| Provider | Free Requests/Day | Setup Time | API Compatibility | Code Quality | Recommended? |
|----------|-------------------|------------|-------------------|--------------|--------------|
| **Google Gemini** | 1,500 | 5 min | OpenAI-like | ⭐⭐⭐⭐⭐ | ✅ **Yes** |
| **OpenRouter** | 50-1,000 | 2 min | OpenAI | ⭐⭐⭐⭐ | ✅ Yes |
| **Groq** | 14,400 | 5 min | OpenAI | ⭐⭐⭐⭐ | ✅ Yes |
| **Hugging Face** | Varies | 10 min | Custom | ⭐⭐⭐ | Maybe |
| **GitHub Models** | Good | 2 min | Azure | ⭐⭐⭐⭐ | Yes |
| **Cloudflare** | 10,000 | 15 min | Custom | ⭐⭐⭐ | Maybe |

---

## Implementation Recommendations

### Default Free Provider: Google Gemini

**Recommendation**: Make **Google Gemini 1.5 Flash** the default free provider for LLM Composer.

**Reasons**:
1. **No friction**: Just a Google account (everyone has one)
2. **Generous limits**: 1,500/day is plenty for music production workflows
3. **High quality**: Excellent at generating Lua code
4. **Stable**: Google committed to keeping it free
5. **Fast**: Low latency responses

### Configuration Priority

```
1. Google Gemini (Free) - Default
2. OpenRouter Free Models - Alternative
3. Anthropic Claude (Paid) - Pro option
4. OpenAI GPT-4 (Paid) - Pro option
5. DeepSeek (Paid/Free) - Budget option
```

### User Experience Flow

**For new users**:
1. Tool opens with Gemini pre-selected
2. Prompt: "Get your free Google Gemini API key at aistudio.google.com"
3. Click link → Copy key → Paste → Start generating

**For power users**:
- Settings allow switching to paid providers
- Keep all existing Anthropic/OpenAI/DeepSeek integrations
- Add OpenRouter as option for variety

---

## Cost Comparison

### Monthly Usage: 100 phrase script generations

| Provider | Cost | Notes |
|----------|------|-------|
| **Google Gemini** | **$0.00** | Free tier (well under 1,500/day) |
| **OpenRouter** | **$0.00** | Free tier (under 50/day) or $10 one-time for 1,000/day |
| **Anthropic Claude** | ~$3-5 | Pay per use |
| **OpenAI GPT-4** | ~$10-15 | Pay per use |
| **DeepSeek** | ~$0.27 | Very cheap paid tier |

---

## Technical Implementation Notes

### Gemini API Differences from OpenAI

**Request Format**:
```json
{
  "contents": [
    {
      "parts": [
        {"text": "Your prompt here"}
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 2048
  }
}
```

**Response Format**:
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {"text": "Generated code here"}
        ]
      }
    }
  ]
}
```

### OpenRouter API (OpenAI Compatible)

OpenRouter uses **exact same format** as OpenAI:
```json
{
  "model": "meta-llama/llama-3.3-70b-instruct:free",
  "messages": [
    {"role": "user", "content": "Your prompt here"}
  ]
}
```

Just change:
- Base URL: `https://openrouter.ai/api/v1/`
- Add header: `HTTP-Referer: https://your-app.com`

---

## Security Best Practices

### API Key Storage

- ✅ Store in Renoise preferences (encrypted if possible)
- ✅ Never commit to git
- ✅ Mask in UI (show only last 4 chars)
- ✅ Allow easy rotation

### Rate Limiting

- ✅ Implement client-side rate limiting
- ✅ Show remaining quota in UI
- ✅ Graceful fallback messages
- ✅ Queue requests if hitting limits

### Error Handling

```lua
-- Example: Graceful degradation
if gemini_fails then
  try_openrouter_free()
  if openrouter_fails then
    show_message("Please check your API key or try again later")
  end
end
```

---

## Migration Path

### For Existing Users (Paid Providers)

- ✅ Keep all existing functionality
- ✅ No breaking changes
- ✅ Add free options alongside paid
- ✅ Allow mixing (free for testing, paid for production)

### For New Users (Free First)

1. Install tool
2. Select "Google Gemini (Free)" as default
3. Click "Get Free API Key" → opens aistudio.google.com
4. Copy key, paste, start creating
5. Upgrade to paid providers later if needed

---

## Conclusion

**Google Gemini** provides the best free option for LLM Composer in 2025:
- No barriers to entry (just Google account)
- Generous free tier (1,500 requests/day)
- High quality code generation
- Stable and reliable
- Fast setup (<5 minutes)

**OpenRouter** is an excellent alternative for:
- Users wanting variety
- Access to multiple models
- OpenAI-compatible API

Both options should be implemented alongside existing paid providers, with Gemini as the **recommended default** for new users.

---

## Resources

- **Google Gemini**: https://ai.google.dev/gemini-api/docs
- **OpenRouter**: https://openrouter.ai/docs
- **Aider LLM Guide**: https://aider.chat/docs/llms.html
- **Free LLM Resources**: https://github.com/cheahjs/free-llm-api-resources
- **API Comparison**: https://apidog.com/blog/free-ai-models/

---

**Last Updated**: October 2025
**For LLM Composer**: v0.2+
