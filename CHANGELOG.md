# Changelog

All notable changes to `moonbit-pixelkit` are documented here.

## Unreleased

### Added

- Added `parse_tiled_json` and `tiled_options` for importing orthogonal, uncompressed Tiled JSON maps with configurable collision and terrain layers.
- Added `examples/tiled_tactical_preview` to demonstrate editor-exported map import feeding a weighted movement preview.
- Added `ParseError` plus detailed ASCII, CSV, and Tiled parsing APIs for typed diagnostics without breaking existing string-returning parser APIs.
- Added `examples/parse_diagnostics` and an editable ASCII map lab in `showcase.html` for immediate parser and movement-preview feedback.
- Added `PathError` and detailed path cost, validation, reachability, movement preview, and A* APIs for typed gameplay diagnostics.
- Added an isolated release-mode benchmark package and `PERFORMANCE.md` for reproducible A*, Dijkstra, and movement-preview baselines.
- Tiled JSON import now clears all four Tiled GID flip and rotation flags before collision and terrain-cost lookup, including IDs with the unsigned high bit set.
- Replaced A*'s linear candidate scan with a priority-queue frontier, preserving weighted-route optimality while substantially improving the benchmarked 32 x 32 route and movement-preview workloads.
- CI now compiles the isolated benchmark package on every push and pull request.
- Added weighted-map corpus tests that cross-check A* route costs against Dijkstra results.
- Tiled JSON import now supports uncompressed Base64 little-endian 32-bit layer data and returns typed errors for unsupported encodings, compression, malformed Base64, and byte-count mismatches.

## 0.1.1 - 2026-07-17

### Added

- Added `examples/turn_based_movement`, a game-style example that combines BFS reachable cells with A* path planning.
- Added `TileMap::first_point_with_id` and `TileMap::single_point_with_id` for named marker lookup.
- Added `TileMap::path_cost` for movement-cost summaries.
- Added `TileMap::render_ascii_overlay` for reachable-cell and path debug views.
- Added `ReachableCell` and `bfs_reachable_with_costs` for movement range previews that need per-cell accumulated costs.
- Added `MovementPreview` and `movement_preview` for one-call tactical target previews.
- Added `PathReport` and `TileMap::validate_path` for validating externally supplied routes.
- Added `examples/tactical_preview`, a reviewer-facing showcase for tactical movement range and route previews.
- Added `showcase.html`, a standalone browser preview for tactical movement and route visualization.

### Changed

- Diagonal pathfinding, reachability, and path validation now reject wall-corner cutting by default; callers can opt in with `allow_corner_cutting=true`.
- Weighted reachable-area search now uses a priority-queue Dijkstra frontier for stable minimum-cost results on larger maps.

## 0.1.0 - 2026-07-08

Initial contest-ready release candidate.

### Added

- MoonBit package metadata and CI workflow.
- ASCII tile-map parser with default `#`, `.`, `S`, and `G` conventions.
- CSV tile-map parser with configurable wall ids and terrain costs.
- `TileMap` queries for dimensions, bounds, tile lookup, walkability, movement costs, and tile id lookup.
- Four-way and eight-way neighbor helpers.
- BFS reachable-area search for movement-budget style gameplay.
- A* pathfinding with four-way and optional diagonal movement.
- ASCII path rendering with `*` overlays.
- Runnable examples:
  - `cmd/main`
  - `examples/ascii_maze`
  - `examples/reachable_area`
  - `examples/weighted_grid`
  - `examples/game_loop_stub`
- Acceptance guide for reviewers.

### Fixed

- Diagonal A* now uses a Chebyshev heuristic instead of Manhattan distance.
- ASCII and CSV parsers accept CRLF line endings and trailing newlines.
- Weighted-grid example reports movement cost without counting the starting tile.
- Game-loop example checks that start and goal markers exist before indexing.

### Validation

- `moon check` passes.
- `moon test` passes with 19 tests.
- `moon package` creates `_build/publish/ttxiangshang-moonbit-pixelkit-0.1.0.zip`.
