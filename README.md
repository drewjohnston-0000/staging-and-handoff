# Staging & Handoff

**AI Logistics for Farming Simulator 25**

[![Unit Tests](https://github.com/drewjohnston-0000/staging-and-handoff/workflows/Unit%20Tests/badge.svg)](https://github.com/drewjohnston-0000/staging-and-handoff/actions)

## Overview

Staging & Handoff adds realistic logistics management to Farming Simulator 25 by introducing **staging zones** - safe waypoints where AI helpers deliver vehicles instead of attempting risky maneuvers in tight spaces.

### The Problem
FS25's AI drivers fail frequently with large or articulated vehicles, especially near obstacles, in yards, and tight farm layouts. This leads to blocked vehicles, unrealistic behavior, and player frustration.

### The Solution
In real farming operations, equipment is staged at safe handoff points rather than driven directly into tight spaces. This mod brings that abstraction to the game:
- Define staging zones at logical boundaries (field gates, yard entrances, workshop aprons)
- AI delivers vehicles to compatible staging zones
- Players handle final positioning
- Clear failure handling with notifications

**Philosophy:** Not smarter AI, but smarter delegation.

## Features (MVP)

- ✅ **Staging Zones**: Player-defined safe delivery points with vehicle compatibility rules
- ✅ **AI Delivery Jobs**: Automatic routing to nearest compatible staging zone
- ✅ **Vehicle Classification**: Rigid / Articulated / Oversize detection
- ✅ **Failure Handling**: Clean abort with notifications when AI is blocked
- ✅ **Zero Micromanagement**: Set and forget logistics
- ✅ **Pure Lua Core**: Testable business logic independent of game engine

## Installation

1. Download latest release
2. Extract to `Documents/My Games/FarmingSimulator2025/mods/`
3. Enable in-game mod menu

## Usage

### Creating Staging Zones
- Press `Ctrl+S` while near desired location
- Set vehicle compatibility (Rigid/Articulated/Oversize)
- Visual cone marker appears

### Dispatching Delivery Jobs
- Select vehicle
- Press `Ctrl+D` to open delivery menu
- Choose destination (field, building, workshop)
- Mod automatically routes to nearest compatible staging zone

### Job States
- **En Route**: AI is driving to staging zone
- **Staged**: Vehicle delivered successfully
- **Blocked**: AI stuck, manual assistance required

## Development

### Project Structure
```
staging-and-handoff/
├── src/
│   ├── StagingAndHandoff.lua          # Main mod entry point
│   ├── core/                          # Pure Lua logic (testable)
│   │   ├── StagingPointManager.lua
│   │   ├── VehicleClassifier.lua
│   │   ├── DeliveryDispatcher.lua
│   │   └── BlockedDetector.lua
│   └── adapters/                      # FS25 engine integration
│       ├── MapInteraction.lua
│       ├── AIJobAdapter.lua
│       └── ConeRenderer.lua
├── tests/                             # Unit tests (Lua 5.3)
│   ├── test_runner.lua
│   └── test_*.lua
├── docs/
│   └── PRD.md                         # Product requirements
└── modDesc.xml                        # FS25 mod manifest
```

### Testing

**Automated Unit Tests** (pure Lua logic):
```bash
cd tests
lua test_runner.lua
```

**Integration Tests** (manual, in-game):
- Load development save
- Test staging zone creation
- Test AI delivery dispatch
- Verify failure handling
- Check visual indicators

Tests run automatically via GitHub Actions on push/PR.

### Architecture Principles

1. **Separation of Concerns**: Core logic is pure Lua, engine integration is isolated in adapters
2. **Testability**: Business logic has zero GIANTS engine dependencies
3. **Conservative Scope**: Orchestrate existing AI, don't replace it
4. **Fail Gracefully**: Explicit failure states, no infinite retries

## Configuration

Settings available in mod options:
- Enable/disable staging system globally
- Maximum AI retry time before abort
- Allow risky deliveries (off by default)

## Compatibility

- Farming Simulator 25 (v1.0+)
- Works with GPS, AutoDrive, Courseplay
- Multiplayer supported

## Contributing

Contributions welcome! Please:
1. Run unit tests before submitting PRs
2. Keep core logic pure (no engine dependencies)
3. Follow existing code style
4. Update tests for new features

## License

MIT License - see [LICENSE](LICENSE) for details

## Credits

**Author**: Drew Johnston  
**Inspired by**: Real-world farm logistics and the pragmatic limits of automation

---

*"The goal is not smarter AI, but smarter delegation."*
