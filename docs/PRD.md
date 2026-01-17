

# Product Requirements Document (PRD)

## Product Name (working)
**Staging & Handoff** – AI Logistics for Farming Simulator 25

## Problem Statement
Farming Simulator 25 allows players to set destinations for vehicles, but AI drivers frequently fail when handling large or articulated vehicles, especially in yards, tight farm layouts, and near obstacles. This leads to blocked vehicles, unrealistic behavior, and player frustration, undermining the farm‑manager fantasy.

In real farming operations, large machinery is rarely driven directly into tight spaces. Instead, equipment is staged at safe handoff points, and humans handle final positioning. FS25 lacks this abstraction.

## Objective
Provide a management‑oriented logistics layer that enables AI helpers to safely move vehicles and equipment **to realistic staging points**, avoiding high‑risk maneuvers while preserving immersion and reducing AI failure.

The mod should **orchestrate existing AI behavior**, not replace or rewrite GIANTS’ pathfinding.

## Target Player
- Players who enjoy the **farm manager / operator** role rather than constant manual driving
- Large‑scale or realism‑oriented farms
- Players frustrated by AI vehicles getting stuck, jack‑knifed, or launched into terrain

## Non‑Goals (Explicitly Out of Scope)
- Replacing or rewriting FS25 core AI pathfinding
- Teaching AI advanced reversing or articulated maneuvering
- New vehicles, implements, or 3D assets
- Full autonomous yard work

## Core Concept
Introduce **Staging Zones**: predefined safe locations where AI helpers are allowed to deliver vehicles and equipment.

AI jobs are limited to:
> “Move vehicle from A to a compatible staging zone near B.”

Final positioning is handled by the player or a separate short‑range interaction.

## Key Features (MVP)

### 1. Staging Zones
- Staging zones are **virtual markers**, not placeable objects
- They exist as data (coordinate + metadata) and are rendered visually in‑world
- A small **traffic cone prop** is used purely as a visual indicator (no ownership, no economy impact)
- Cones do **not** interact with land ownership rules

**Creation:**
- Player‑defined via map interaction (Add Staging Point)
- Optional automatic creation for single jobs when no suitable staging point exists

**Persistence:**
- MVP: staging points exist for the current session only
- Future: optional savegame persistence and multiplayer sync

**Examples:**
- Yard entrance
- Field gate
- Roadside pull‑off
- Workshop apron

### 2. AI Delivery Jobs
- New job type: **Deliver to Staging Zone**
- Player selects:
  - Vehicle
  - Destination (field, building, workshop)
- Mod automatically resolves the nearest compatible staging zone
- AI drives vehicle to that zone and stops

### 3. Vehicle Compatibility Rules
Each vehicle is classified internally using simple heuristics:
- Rigid
- Articulated
- Oversize

Each staging zone declares which vehicle classes it supports.

Dispatch logic selects the **nearest eligible staging zone** based on distance and compatibility.

### 4. Failure Handling
- If AI is blocked or stationary beyond a threshold:
  - Job aborts cleanly
  - Vehicle is secured (engine off, hazards optional)
  - Player receives notification

No infinite retries. No chaos escalation.

### 5. Player Feedback
- Clear job state:
  - En route
  - Staged
  - Blocked (assistance required)
- Minimal UI: notifications + map indicators

## User Stories

### Core Flow
- As a player, I want to send a tractor and trailer to a field **without it attempting to reverse into a shed or clip trees**.
- As a player, I want AI helpers to stop at logical boundaries instead of trying to reach impossible destinations.

### Management Fantasy
- As a farm manager, I want to coordinate logistics while personally handling only the final, delicate steps.

## UX Principles
- Zero micromanagement once job is issued
- Predictable outcomes
- Failure is communicated clearly and early
- Defaults should favor safety over speed

## Configuration Options
- Enable/disable staging system globally
- Maximum AI retry time before abort
- Allow risky deliveries (off by default)

## Technical Approach (High Level)
- Use existing FS25 AI “drive to destination” behavior
- Intercept destination selection
- Redirect to staging zone transform
- Monitor vehicle movement state

No modification of vehicle physics or AI steering logic.

## Risks & Constraints
- AI attach/detach behavior may be unreliable → explicitly excluded from MVP
- Limited FS25 scripting documentation → scope must remain conservative
- Map compatibility: staging zones must fail gracefully on unsupported maps
- Engine‑dependent behavior cannot be fully validated via automation; integration testing remains manual

## Testing Strategy

### Unit Testing (Automated)
- Core logic modules (staging point selection, vehicle classification, blocked detection, job state transitions) are implemented as **pure Lua**
- Unit tests are executed:
  - Locally on macOS during development
  - Automatically via GitHub Actions on each push
- Tests run outside the Farming Simulator runtime and do not depend on GIANTS engine globals

### Integration Testing (Manual)
- Engine‑facing adapters (AI job dispatch, map interaction, cone rendering) are validated in‑game using a dedicated development save
- Diagnostic logging is used to observe runtime behavior and failure modes

### Tooling Principles
- Separation of concerns between core logic and engine integration
- Deterministic, side‑effect‑free logic wherever possible
- Logging used as a first‑class diagnostic tool

## Success Criteria
- AI vehicles no longer become irrecoverably stuck during delivery jobs
- Players report reduced frustration with AI logistics
- Mod is compatible with existing AI, GPS, and contract mods
- Core logistics and decision logic is verifiably correct via automated unit tests

---

**Design Philosophy:**
The goal is not smarter AI, but smarter delegation. The mod embraces the reality that some tasks are better handed off at the right boundary rather than forced through automation.