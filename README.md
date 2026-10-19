# QuantPulse AI ⚡

[![Melos](https://img.shields.io/badge/maintained%20with-melos-f74b00.svg)](https://github.com/invertase/melos)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B.svg)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Monorepo%20%7C%20Pub%20Workspaces-green.svg)](#architecture--monorepo-layout)
[![CI Pipeline](https://github.com/amidelu/QuantPulseAI/actions/workflows/ci.yaml/badge.svg)](https://github.com/amidelu/QuantPulseAI/actions/workflows/ci.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An institutional-grade cryptocurrency quantitative trading terminal and AI Copilot built with **Flutter 3.32+** and **Dart 3.13+**.

QuantPulse AI demonstrates production patterns for high-frequency streaming, complex concurrency, hardware-aware edge computing, agentic tool-calling, and reactive offline storage.

---

## At a Glance

| Pillar | Implementation | Technical Advantage |
| :--- | :--- | :--- |
| **High-Frequency Market Stream** | Dedicated background worker Isolate + 120-slot ring buffer + 60/120Hz frame conflation | Ingests **100+ ticks/s** Binance WebSockets (`@aggTrade` + `@depth10`) without UI frame drops |
| **GPU Canvas Rendering** | Optimized `CustomPainter` with `RepaintBoundary` | Smooth 60/120 FPS candlestick chart, EMA-12 curve, volume profile, crosshair HUD, and depth book |
| **Hybrid Edge-Cloud AI** | Pigeon Native Host API + Groq Cloud LPU Client + GGUF Weight Manager | Hardware-aware router balances inference between on-device edge and cloud based on thermals & RAM |
| **Agentic Tool Calling** | Copilot executes structured UI actions via BLoC coordinator | Draws support/resistance price zones directly on chart (`plot_support_resistance`) and triggers backtests |
| **On-Device Quant Backtester** | Parallel simulation inside `Isolate.run` | Evaluates EMA crossover strategies, fees, win rates, Sharpe ratio, and max drawdown in milliseconds |
| **Local RAG & Offline Storage** | Cross-isolate **Drift (SQLite)** in WAL mode | Persists backtest runs and trade journal notes; queries context to enrich AI prompts locally |

---

## System Architecture

The project is structured as a clean layered monorepo using **Dart Pub Workspaces** and **Melos 8.9+**. Packages follow strict dependency inversion rules: **feature packages never depend on each other**, communicating exclusively through abstract contracts and coordinator shells.

```
┌───────────────────────────────────────────────────────────────────────────────┐
│                           APPLICATIONS (apps/)                                │
│   quant_pulse_mobile (Coordinator Shell & DI)  │  widgetbook_showcase (UI)    │
└───────────────────────────────────────┬───────────────────────────────────────┘
                                        │
        ┌───────────────────────────────┼───────────────────────────────┐
        ▼                               ▼                               ▼
┌────────────────────────┐     ┌──────────────────┐     ┌───────────────────────┐
│    feature_terminal    │     │feature_backtester│     │  feature_ai_copilot   │
│ (120 FPS Chart & Depth)│     │(Isolate Backtest)│     │ (Agentic Tool Calling)│
└───────────┬────────────┘     └────────┬─────────┘     └───────────┬───────────┘
            │                           │                           │
            ▼                           ▼                           ▼
┌───────────────────────────────────────────────┐     ┌─────────────────────────┐
│             market_stream_engine              │     │    hybrid_ai_engine     │
│   (WebSocket Actor + 120-Slot Ring Buffer)    │     │(Pigeon Telemetry + Groq)│
└───────────────────────┬───────────────────────┘     └─────────────┬───────────┘
                        │                                           │
                        └───────────────────┬───────────────────────┘
                                            │
        ┌───────────────────────────────────┼───────────────────────────────────┐
        ▼                                   ▼                                   ▼
┌────────────────────────┐     ┌────────────────────────┐     ┌─────────────────┐
│      core_network      │     │      core_storage      │     │  design_system  │
│ (Dio REST + Result<T>) │     │ (Drift SQLite WAL Mode)│     │ (Tokens/Themes) │
└────────────────────────┘     └────────────────────────┘     └─────────────────┘
```

### Architecture Boundary Guardrail
A strict CI guardrail (`melos run check-architecture`) enforces that no feature package imports any other feature package, preventing accidental coupling:
```bash
! grep -rn "package:feature_" packages/features/ | grep -v -E "packages/features/([^/]+)/.*package:\1"
```

---

## Monorepo Layout

```
quant_pulse_ai/
├── apps/
│   ├── quant_pulse_mobile/       # Production application shell, MultiBlocProvider & Coordinator
│   └── widgetbook_showcase/      # Isolated component workbench for UI testing & golden scenarios
│
├── packages/
│   ├── core/
│   │   ├── core_network/         # Dio HTTP client, Result<T> functional types & Binance REST loaders
│   │   ├── core_storage/         # Cross-isolate Drift SQLite database (WAL mode, Backtests & Journals)
│   │   └── design_system/        # Dark-mode quant theme tokens, typography, colors & spacing
│   │
│   ├── engines/
│   │   ├── market_stream_engine/ # WebSocket actor isolate, CandleRingBuffer & 16ms frame conflater
│   │   └── hybrid_ai_engine/     # Pigeon telemetry bridge, Groq LPU API client & HuggingFace GGUF loader
│   │
│   └── features/
│       ├── feature_terminal/     # 120 FPS CandlestickChartCanvas, Order Book Depth & symbol search modal
│       ├── feature_backtester/   # Isolate quantitative strategy simulator, equity curve & SQLite logging
│       └── feature_ai_copilot/   # Agentic bottom sheet, chat stream, thermal switcher & tool dispatcher
│
├── .github/workflows/ci.yaml     # Melos CI: format check, boundary check, analyze & test
├── melos.yaml / pubspec.yaml     # Dart Pub Workspace & Melos task configuration
└── analysis_options.yaml         # Very Good Analysis lint rules
```

---

## Core Technical Features

### 1. High-Frequency Market Stream Engine
- **Dedicated Isolate Actor**: Connects to Binance WebSockets (`<symbol>@aggTrade` and `<symbol>@depth10@100ms`).
- **CandleRingBuffer**: Maintains a fixed-capacity O(1) buffer (120 candles) in worker memory without heap reallocation.
- **Frame Conflation**: Aggregates 100+ ticks/s into 5-second OHLCV candles and conflates UI dispatches to 16ms (~60 FPS cap over `SendPort`), completely eliminating UI thread starvation.
- **Dynamic Symbol Switching**: Switches trading pairs on the live WebSocket without tearing down or respawning the worker Isolate.

### 2. Hybrid Edge-Cloud AI Telemetry Router
- **Native Hardware Telemetry via Pigeon**: Reads host OS thermal status (nominal, fair, serious, critical), free RAM, and low-power mode via type-safe native channel.
- **Hardware-Aware Dispatch**:
  - **Nominal / High RAM**: Runs on-device edge quantitative pipeline (or local quantized GGUF neural weights via `LocalModelManager`).
  - **Serious / Critical / Low RAM**: Routes queries to **Groq Cloud LPU** (`llama-3.3-70b-versatile` / `openai/gpt-oss-20b`) for sub-second cloud inference.
- **Simulated Thermal Switcher**: Interactive switcher in the Copilot UI allows real-time demonstration and testing of routing behaviors.

### 3. Agentic Tool Calling & Canvas Overlays
The AI Copilot does not just answer with text; it operates directly on the trading interface through structured tool directives:
- `plot_support_resistance`: Computes dynamic support and resistance levels and automatically draws visual overlay bands across the `CandlestickChartCanvas`.
- `trigger_ema_backtest`: Dispatches fast/slow EMA parameters to the backtest engine, executes simulations, and renders BUY/SELL signal markers directly onto matching chart candles.

### 4. Cross-Isolate Drift (SQLite) Storage & Local RAG
- **WAL-Enabled Shared Database**: Uses Drift with `shareAcrossIsolates: true` to allow background Isolates and UI threads concurrent read/write access.
- **Performance Logging**: Persists backtest runs (win rate, net profit, Sharpe ratio, max drawdown, equity curve JSON).
- **Trade Journal RAG**: Stores trader notes and reasoning. When Copilot receives a query, it executes an Isolate RAG scan over past journal entries to inject contextual history into prompt memory.

### 5. On-Device Quantitative Strategy Backtester
- Runs parameterizable EMA crossover strategies inside a compute Isolate via `Isolate.run`.
- Models realistic taker exchange fees (0.04% per trade).
- Generates equity curves, calculates annualized Sharpe ratio, and streams results directly into SQLite.

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.32.0` ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: `>= 3.13.0`
- **Melos**: `>= 8.9.0`

### 1. Installation & Bootstrap

Clone the repository and install all dependencies across workspace packages:

```bash
# Clone the repository
git clone https://github.com/amidelu/QuantPulseAI.git
cd QuantPulseAI

# Activate Melos globally
dart pub global activate melos ^8.9.0

# Bootstrap all packages & resolve workspace dependencies
melos bootstrap
```

### 2. Run Quality Checks

Verify architecture boundaries, static analysis, and multi-package test suites:

```bash
# Verify architecture boundaries (no cross-feature imports)
melos run check-architecture

# Run static analysis across all workspace packages
melos run analyze

# Run unit and BLoC tests with coverage
melos run test
```

### 3. Run the Mobile Terminal App

Launch the primary trading application:

```bash
cd apps/quant_pulse_mobile

# Run on macOS desktop / Android / iOS / Web
flutter run

# Optional: Launch with Groq API Key pre-configured
flutter run --dart-define=GROQ_API_KEY=gsk_your_groq_api_key_here
```

> **Tip:** You can also enter or update your Groq API key directly inside the app; it will be encrypted and stored in `FlutterSecureStorage`.

### 4. Run the Component Catalog (Widgetbook)

To inspect standalone UI widgets, visual variants, and chart canvas behaviors in isolation:

```bash
cd apps/widgetbook_showcase
flutter run -d chrome  # or macOS / mobile simulator
```

---

## Workspace Scripts Reference

| Command | Action |
| :--- | :--- |
| `melos bootstrap` | Installs dependencies and links all workspace packages |
| `melos run analyze` | Runs `flutter analyze` across all workspace packages |
| `melos run test` | Executes unit, widget, and BLoC tests concurrently with coverage |
| `melos run codegen` | Runs `build_runner` in topological order for Drift and mocks |
| `melos run check-architecture` | Validates layer boundary rules across feature packages |

---

## CI / CD Pipeline

Every pull request and push to `main` executes a multi-stage GitHub Actions workflow ([`.github/workflows/ci.yaml`](.github/workflows/ci.yaml)):
1. **Quality Gate**: Code formatting verification (`dart format`), architecture boundary check, static analysis (`melos run analyze`), and full multi-package test runner (`melos run test`).
2. **Build Validation**: Automated Android release artifact build (`flutter build apk --debug`).

---

## License

Distributed under the [MIT License](LICENSE).

---
