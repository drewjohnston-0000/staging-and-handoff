# Development Guide

## Project Setup

### Prerequisites
- Lua 5.3+ for running unit tests locally
- Farming Simulator 25 for integration testing
- Git for version control

### Local Development

Clone and install:
```bash
git clone https://github.com/drewjohnston-0000/staging-and-handoff.git
cd staging-and-handoff
```

Run unit tests:
```bash
cd tests
lua test_runner.lua
```

### Project Architecture

The mod follows a clean architecture pattern:

```
┌─────────────────────────────────────┐
│   Farming Simulator 25 Engine      │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│   Adapters (Engine Integration)    │
│   ├─ MapInteraction.lua             │
│   ├─ AIJobAdapter.lua               │
│   └─ ConeRenderer.lua               │
└───────────────┬─────────────────────┘
                │
┌───────────────▼─────────────────────┐
│   Core Logic (Pure Lua)             │
│   ├─ StagingPointManager.lua        │
│   ├─ VehicleClassifier.lua          │
│   ├─ DeliveryDispatcher.lua         │
│   └─ BlockedDetector.lua            │
└─────────────────────────────────────┘
```

**Core Logic** modules:
- Are pure Lua (no FS25 dependencies)
- Can be unit tested outside the game
- Contain all business logic
- Use simple data structures

**Adapter** modules:
- Interface with FS25 engine APIs
- Translate between game objects and core data
- Handle rendering, input, and AI integration
- Cannot be unit tested (require game runtime)

### Core Modules

#### StagingPointManager
Manages the lifecycle of staging points:
- Add/remove staging points
- Store metadata (coordinates, compatibility)
- Find nearest compatible point for a destination

#### VehicleClassifier
Classifies vehicles into types:
- Rigid: Standard tractors, trucks
- Articulated: Vehicles with articulation points
- Oversize: Large equipment exceeding thresholds

#### DeliveryDispatcher
Orchestrates delivery jobs:
- Creates jobs for vehicle + destination pairs
- Manages job state machine (IDLE → EN_ROUTE → STAGED/BLOCKED)
- Tracks active jobs

#### BlockedDetector
Detects when AI vehicles are stuck:
- Monitors vehicle position over time
- Triggers blocked state after stationary threshold
- Configurable epsilon for "movement" detection

### Writing Tests

Tests follow a simple assertion pattern:

```lua
function test_my_feature(assert_equal, assert_true, assert_false, assert_not_nil, assert_nil)
    local manager = StagingPointManager.new()
    
    local id = manager:addPoint(100, 50, 200)
    assert_not_nil(id, "Should create staging point")
    
    local point = manager:getPoint(id)
    assert_equal(point.x, 100, "X coordinate should match")
end
```

Add new test files to `tests/` and include them in `test_runner.lua`.

### Integration Testing

Manual integration tests require loading the mod in FS25:

1. Copy mod to `Documents/My Games/FarmingSimulator2025/mods/`
2. Enable in mod menu
3. Load a map
4. Test staging point creation (Ctrl+S)
5. Test delivery dispatch (Ctrl+D)
6. Verify visual cone rendering
7. Test blocked detection by forcing AI into obstacle

Use diagnostic logging to observe behavior:
```lua
print(string.format("[SAH] Job %d: %s", jobId, job.state))
```

### Adding New Features

1. **Design**: Document in PRD.md or create design doc
2. **Core Logic**: Implement in `src/core/` as pure Lua
3. **Unit Tests**: Add tests to `tests/`
4. **Adapter**: Create engine integration in `src/adapters/`
5. **Integration Test**: Validate in-game
6. **Document**: Update README.md

### Code Style

- Use LuaDoc comments for public APIs
- Prefer explicit over implicit
- Keep functions small and focused
- No global state (except mod entry point)
- Use `local` by default

### CI/CD

GitHub Actions runs unit tests automatically on:
- Push to main/develop branches
- Pull requests to main

See [.github/workflows/test.yml](.github/workflows/test.yml) for configuration.

### Debugging

**Unit Tests**:
- Use `print()` statements liberally
- Create minimal reproduction scripts in `tests/`
- Check distance calculations manually

**Integration (In-Game)**:
- Check FS25 log file: `Documents/My Games/FarmingSimulator2025/log.txt`
- Add diagnostic prints to adapters
- Use Visual Debugger if available

### Release Process

1. Update version in `modDesc.xml`
2. Run full test suite
3. Create integration test save
4. Tag release: `git tag v0.1.0`
5. Build mod package (zip with proper structure)
6. Upload to ModHub / GitHub Releases

### Common Issues

**Tests fail with "module not found"**:
- Check `package.path` in test files
- Ensure running from `tests/` directory

**AI not driving to staging point**:
- Verify staging point coordinates are valid
- Check vehicle classification
- Ensure AI strategy is available

**Cones not visible**:
- Check cone renderer initialization
- Verify staging points were created
- Check camera distance (labels only render within 50m)

## Future Enhancements

- Savegame persistence for staging points
- Multiplayer synchronization
- UI for staging point management
- Advanced routing (multi-hop deliveries)
- Integration with GPS/AutoDrive mods
