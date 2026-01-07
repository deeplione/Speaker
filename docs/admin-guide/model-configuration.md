# Model Configuration

This guide covers how to configure AI models for text generation in Speakr, including OpenRouter and self-hosted OpenAI-compatible providers. Set `ENABLE_LLM_FEATURES=true` to enable these features; they are disabled by default in the provided ASR templates.

## Overview

Speakr uses AI models for several key features:

- **Summary Generation**: Creating intelligent summaries of your transcriptions
- **Title Generation**: Automatically generating descriptive titles for recordings
- **Event Extraction**: Identifying calendar-worthy events from conversations
- **Interactive Chat**: Answering questions about your recordings
- **Speaker Identification**: Detecting speaker names from conversation context

These features are powered by large language models (LLMs) configured through your `.env` file.

## Basic Configuration

The text generation model is configured using three environment variables:

```bash
TEXT_MODEL_BASE_URL=https://openrouter.ai/api/v1
TEXT_MODEL_API_KEY=your_api_key_here
TEXT_MODEL_NAME=meta-llama/llama-3.1-8b-instruct
```

### Choosing a Provider

**OpenRouter** (recommended for most users): Provides access to multiple AI models through a single API, often at competitive prices.
Configure using `TEXT_MODEL_BASE_URL=https://openrouter.ai/api/v1`.

**Self-hosted OpenAI-compatible endpoints**: Speakr works with providers like Ollama, LocalAI, LM Studio, or enterprise API gateways that expose an OpenAI-compatible `/chat/completions` endpoint.
Point `TEXT_MODEL_BASE_URL` at your server (for example, `http://localhost:11434/v1`).

## Separate Chat Model Configuration

Speakr allows you to configure a separate model specifically for real-time chat interactions, while using a different model for background tasks like summarization and title generation. This enables you to:

- **Use different service tiers**: Configure a faster, more expensive model for interactive chat while using a cheaper model for background processing
- **Optimize costs**: Use a budget-friendly model for summarization while keeping a high-quality model for chat
- **Balance speed and quality**: Prioritize low latency for chat while accepting slower processing for summaries

### Configuration

Add these optional environment variables to your `.env` file:

```bash
# Chat Model Configuration (Optional)
# If not set, chat will use TEXT_MODEL_* settings
CHAT_MODEL_API_KEY=your_chat_api_key
CHAT_MODEL_BASE_URL=https://openrouter.ai/api/v1
CHAT_MODEL_NAME=meta-llama/llama-3.1-8b-instruct
```

### Fallback Behavior

| Configuration | Behavior |
|--------------|----------|
| No `CHAT_MODEL_*` variables set | Chat uses `TEXT_MODEL_*` settings (default) |
| Only `CHAT_MODEL_NAME` set | Falls back to `TEXT_MODEL_*` (API key required) |
| Only `CHAT_MODEL_API_KEY` set | Falls back to `TEXT_MODEL_*` (model name required) |
| `CHAT_MODEL_API_KEY` + `CHAT_MODEL_NAME` set | Uses chat config with `TEXT_MODEL_BASE_URL` |
| All `CHAT_MODEL_*` variables set | Uses fully dedicated chat configuration |

### Example Configurations

**Cheap Summarization + Premium Chat**:
```bash
# Background tasks: Use budget model
TEXT_MODEL_BASE_URL=https://openrouter.ai/api/v1
TEXT_MODEL_API_KEY=your_openrouter_key
TEXT_MODEL_NAME=meta-llama/llama-3.1-8b-instruct

# Interactive chat: Use premium model
CHAT_MODEL_API_KEY=your_openrouter_key
CHAT_MODEL_BASE_URL=https://openrouter.ai/api/v1
CHAT_MODEL_NAME=meta-llama/llama-3.1-70b-instruct
```

**Same Provider, Different Models**:
```bash
# Background tasks: Smaller model
TEXT_MODEL_BASE_URL=https://openrouter.ai/api/v1
TEXT_MODEL_API_KEY=your_api_key
TEXT_MODEL_NAME=qwen/qwen-2.5-7b-instruct

# Interactive chat: Larger model (same provider)
CHAT_MODEL_NAME=qwen/qwen-2.5-32b-instruct
# Note: CHAT_MODEL_API_KEY not needed if using same key
# Note: CHAT_MODEL_BASE_URL not needed if using same endpoint
```

### When to Use Separate Chat Models

**Recommended for**:
- High-volume deployments where chat responsiveness is critical
- Users who need different service tiers for different operations
- Cost optimization when chat usage is significantly higher than summarization

**Not needed for**:
- Small deployments with low usage
- When using the same model for all operations is acceptable
- Simple setups where configuration simplicity is preferred

## Model Selection Guidelines

### For Summaries

The model you choose significantly impacts summary quality:

- **Larger instruction-tuned models**: Produce nuanced, context-aware summaries with excellent understanding of complex topics
- **Mid-sized models (7B-13B)**: Budget-friendly option, suitable for straightforward content
- **High-quality open models**: Options like Llama, Qwen, or Mistral families can produce strong results depending on provider tuning

### For Chat

Chat features benefit from more capable models:

- **Larger models (30B+)**: Best for complex multi-turn conversations and detailed analysis
- **Mid-sized models (7B-13B)**: Recommended for cost-conscious chat use cases with acceptable quality

### Cost Optimization

To reduce costs while maintaining quality:

1. **Use smaller models for simple tasks**: 7B-13B instruction models handle straightforward summaries well
2. **Set token limits**: Configure `SUMMARY_MAX_TOKENS` and `CHAT_MAX_TOKENS` in your `.env`
3. **Use OpenRouter**: Often provides better rates than direct API access

### Testing Configuration

After changing model configuration:

1. Restart the Speakr container
2. Create a test recording
3. Review the generated summary and title
4. Test the chat feature
5. Monitor logs for any errors or warnings

## Environment Variables Reference

```bash
# Required: API endpoint
TEXT_MODEL_BASE_URL=https://openrouter.ai/api/v1

# Required: API key
TEXT_MODEL_API_KEY=your_api_key_here

# Required: Model identifier
TEXT_MODEL_NAME=meta-llama/llama-3.1-8b-instruct

# Optional: Maximum tokens for summaries (default: 8000)
SUMMARY_MAX_TOKENS=8000

# Optional: Maximum tokens for chat responses (default: 2000)
CHAT_MAX_TOKENS=2000

# Chat model configuration (optional - falls back to TEXT_MODEL_* if not set)
CHAT_MODEL_API_KEY=your_chat_api_key
CHAT_MODEL_BASE_URL=https://openrouter.ai/api/v1
CHAT_MODEL_NAME=meta-llama/llama-3.1-8b-instruct
```

## Troubleshooting

### Model Not Responding

Check logs for authentication errors:
```bash
docker compose logs -f app | grep "LLM"
```

Common issues:
- Invalid API key
- Model name not available on your plan
- Rate limits exceeded
- Insufficient credits

### Poor Summary Quality

Try these adjustments:
- Upgrade to a more capable model
- Increase `SUMMARY_MAX_TOKENS`
- Review and refine [custom prompts](prompts.md)

### High Costs

Reduce costs with:
- Switch to smaller models
- Lower token limits
- Use OpenRouter for better rates

## Additional Resources

- [OpenRouter Documentation](https://openrouter.ai/docs)
- [Ollama Documentation](https://ollama.com/)
- [LocalAI Documentation](https://localai.io/)
- [Custom Prompts Guide](prompts.md)
- [System Settings](system-settings.md)

---

Next: [Default Prompts](prompts.md) | Back to [Admin Guide](index.md)
