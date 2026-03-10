# mlx-swift-chat

A macOS chat application powered by a local LLM using Apple's [MLX](https://github.com/ml-explore/mlx-swift) framework. 
Runs fully on-device — no API keys, no internet required after the model is downloaded.

> This project started as a technical interview assignment for an undisclosed company.

![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-lightgrey)
![Swift](https://img.shields.io/badge/swift-6.0-orange)
![Chip](https://img.shields.io/badge/chip-Apple%20Silicon-blue)

## Requirements

- macOS 14+
- Apple Silicon (M1 or later)
- Xcode 16+

## Getting Started

1. Clone the repo
2. Open `LMChatApp.xcworkspace`
3. Select `LMChatApp` scheme
4. Build and run
5. The model downloads automatically on first launch (~700 MB)

> The model is cached to `~/Library/Caches/models/` after the first download.

## Architecture

The project is split into two parts: a Swift Package (`LMChatAssistant`) and a macOS app (`LMChatApp`).

**LMChatAssistant** is a wrapper around MLX that exposes a simple API for loading a model and generating responses. The app never interacts with MLX directly.

**LMChatApp** is a SwiftUI macOS app following MVVM. A `ChatManager` owns the shared assistant instance and manages the list of chats. Each `Chat` holds its own message history and state, and delegates inference to the assistant. Views observe state changes via `@Observable`.

### Response Modes

Each chat supports two response modes:

- **Stream** — tokens appear as they are generated
- **Complete** — full response appears at once after generation finishes

## Model

Two models are supported out of the box, both quantized to 4-bit and optimized for Apple Silicon via MLX:

| Model | HuggingFace | Size |
|-------|-------------|------|
| `llama_v3_2_1B` ✦ | [Llama-3.2-1B-Instruct-4bit](https://huggingface.co/mlx-community/Llama-3.2-1B-Instruct-4bit) | ~700 MB |
| `llama_v3_2_3B` | [Llama-3.2-3B-Instruct-4bit](https://huggingface.co/mlx-community/Llama-3.2-3B-Instruct-4bit) | ~1.8 GB |

✦ default

### Quality

Quality controls `temperature` and `maxTokens` for generation:

| Quality | Temperature | Max Tokens |
|---------|-------------|------------|
| `.fast` | 0.3 | 256 |
| `.balanced` ✦ | 0.7 | 512 |
| `.best` | 1.0 | 1024 |

✦ default

To customize, change the configuration in `ChatManager`:

```swift
LMCAConfiguration(model: .llama_v3_2_3B, quality: .best)
```

## Author

[Dmytrii Golovanov](https://github.com/dmytriigolovanov)
