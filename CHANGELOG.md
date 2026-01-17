# Changelog

All notable changes to Staging & Handoff will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Core logic modules (StagingPointManager, VehicleClassifier, DeliveryDispatcher, BlockedDetector)
- Comprehensive unit test suite with 47 tests
- GitHub Actions CI for automated testing
- Engine adapter stubs (MapInteraction, AIJobAdapter, ConeRenderer)
- Project documentation (README, PRD, Development Guide)
- Lua 5.3+ compatibility

### Architecture
- Clean separation between pure Lua core and FS25 engine integration
- Test-driven development approach for core business logic
- Conservative scope focusing on orchestration vs replacement of AI

## [0.1.0] - TBD

### Planned for MVP
- [ ] Staging point creation via map interaction
- [ ] Visual cone indicators for staging points
- [ ] AI delivery job dispatch
- [ ] Vehicle classification (Rigid/Articulated/Oversize)
- [ ] Blocked vehicle detection and abort
- [ ] Player notifications for job states
- [ ] In-game testing and validation
- [ ] ModHub submission

---

## Development Notes

### Testing Strategy
- Unit tests validate core logic independently of game engine
- Integration tests performed manually in FS25
- GitHub Actions ensures tests pass on every commit

### Known Limitations (MVP)
- Session-only persistence (staging points not saved)
- No multiplayer sync (single-player focus)
- Manual final positioning required
- No automatic staging point creation
