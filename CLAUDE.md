# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a LÖVE2D (Love2D) game project - an "OSU!-Style Orb Destroyer" game written in Lua. LÖVE2D is a 2D game framework that uses Lua as its scripting language.

## Running the Project
```bash
# Run the game (requires LÖVE2D installed)
love .

# Or from parent directory
love osu_love
```

## Architecture
The codebase follows a modular entity-component-system pattern:

- **main.lua**: Entry point, handles LÖVE2D callbacks (load, update, draw, input)
- **entities/**: Game objects (orb, particle, wave, sparkle, hit_effect)
- **systems/**: Core game logic (collision detection, rendering, entity spawning)
- **game/**: Game state management and configuration
- **utils/**: Shared utilities (colors, easing functions, validation)

Key architectural decisions:
- Each entity is self-contained with update/draw methods
- Collision system uses quadtree optimization for performance
- Renderer handles all drawing operations with proper layering
- State management tracks score, accuracy, effects, and active entities

## Development Guidelines
- No build step required - Lua is interpreted
- No external dependencies beyond LÖVE2D framework
- Configuration changes: Edit `game/config.lua`
- Debug mode: Press 'D' in-game or set `DEBUG = true` in config.lua
- Game controls: 
  - Mouse click: Destroy orbs
  - ESC: Pause game (in-game) / Quit (from menu)
  - Space: Change color palette
  - R: Reset game
  - D: Toggle debug mode
  - Pause menu: Use mouse or arrow keys + Enter to select options

## Common Tasks
- **Add new visual effect**: Create entity in `entities/`, integrate in `systems/renderer.lua`
- **Modify game difficulty**: Adjust parameters in `game/config.lua` (spawn rates, orb speeds, sizes)
- **Change scoring**: Update scoring logic in `game/state.lua`
- **Add new easing function**: Extend `utils/easing.lua`