# moonbit-pixelkit Acceptance Guide

This guide is for reviewers of the 2026 MoonBit open-source ecosystem contest.

## Project Summary

- Project: `moonbit-pixelkit`
- Direction: MoonBit 2D tile-map parsing and pathfinding toolkit
- GitLink: https://www.gitlink.org.cn/ttxiangshang/moonbit-pixelkit
- GitHub: https://github.com/zhenghao493-netizen/moonbit-pixelkit
- License: MIT
- Main language: MoonBit

`moonbit-pixelkit` provides a small reusable core for grid-based games and demos: ASCII/CSV/Tiled JSON map import, tile queries, walkability checks, movement costs, named point lookup, Dijkstra reachable-area search with accumulated costs, high-level movement previews, A* pathfinding, path validation, path cost summaries, and ASCII debug rendering.

## Initial Review Assets

- Public repository with visible commit history.
- `README.md` with project status, commands, examples, API overview, and roadmap.
- `moonbit-pixelkit-project-proposal.md` with the project proposal.
- `CHANGELOG.md` with the published `0.1.1` release notes.
- `LICENSE` using MIT.
- `.github/workflows/ci.yml` running formatting, `moon check`, `moon build`, `moon test`, and package-metadata verification.
- `showcase.html` with a browser-based tactical movement preview.
- Runnable examples under `examples/`.
- Unit tests covering parser, map query, named point lookup, reachability with costs, movement previews, A*, path cost summaries, rendering, and error paths.

## Verification Commands

Run these commands from the repository root:

```bash
moon check --deny-warn
moon build --deny-warn
moon test --deny-warn
moon package
moon run cmd/main
moon run examples/ascii_maze
moon run examples/reachable_area
moon run examples/weighted_grid
moon run examples/game_loop_stub
moon run examples/turn_based_movement
moon run examples/tactical_preview
moon run examples/tiled_tactical_preview
moon run examples/parse_diagnostics
moon bench benchmarks/pathfinding --release --deny-warn
```

Expected baseline:

- `moon test` passes all tests.
- `moon package` creates a package archive under `_build/publish/`.
- Each example prints a short terminal result without requiring network access.
- `examples/turn_based_movement` demonstrates game-style movement range and path planning in one run.
- `examples/tactical_preview` demonstrates the strongest reviewer-facing output: map rendering, movement range, a selected route, and a full route to the goal.
- `examples/tiled_tactical_preview` demonstrates importing an editor-exported Tiled JSON map into a weighted movement preview.
- `examples/parse_diagnostics` demonstrates matching structured parser and path errors for editor and game-tool feedback.
- `benchmarks/pathfinding` measures release-mode A*, weighted reachability, and movement-preview workloads on a fixed 32 x 32 map.
- `showcase.html` opens as a standalone browser preview for the same tactical movement story.
- `PERFORMANCE.md` records the reproducible benchmark scenario and local baseline; benchmark values are informational rather than performance guarantees.

## Feature Coverage

- `parse_ascii_map` parses rectangular ASCII maps using `#`, `.`, `S`, and `G` by default.
- `parse_csv_map` parses CSV tile ids, with `1` treated as a wall by default.
- `parse_csv_map_with_options` supports configurable wall ids and terrain costs.
- `parse_tiled_json` imports orthogonal Tiled JSON maps with inline tile-layer data, a configurable collision layer, optional terrain layer, and GID-to-cost mapping. It decodes unsigned 32-bit GIDs and clears Tiled flip/rotation flags before matching collision and terrain IDs.
- Detailed parser variants return `ParseError` values with row/column, option, Tiled field, orientation, and layer context; detailed search variants return `PathError` values with budget, endpoint, invalid-point, and illegal-step context. Legacy APIs retain string errors for simple callers.
- `TileMap` supports dimensions, bounds checks, tile lookup, movement costs, id lookup, and ASCII rendering.
- `TileMap::single_point_with_id` validates maps that should contain exactly one start or goal marker.
- `TileMap::path_cost` sums the movement cost of a planned route for game-style turn previews.
- `TileMap::validate_path` checks externally supplied paths for legal movement steps and returns a `PathReport`.
- `TileMap::render_ascii_overlay` marks reachable cells with `+` and planned paths with `*`.
- `bfs_reachable` returns cells reachable within a movement budget.
- `bfs_reachable_with_costs` uses a priority-queue Dijkstra frontier to return reachable cells with their minimum accumulated movement costs.
- `movement_preview` combines reachable cells, target reachability, target cost, and selected-target path for tactical UI flows.
- `astar` returns a path or `None` when a reachable path does not exist.
- `SearchOptions` supports four-way movement by default and optional diagonal movement without wall-corner cutting unless explicitly enabled.

## Known Boundaries

- The package intentionally targets small to medium grid maps for games, demos, and teaching examples.
- Tiled JSON support deliberately covers orthogonal maps with inline, uncompressed layer data; PNG, TMX, infinite/chunked maps, and encoded or compressed layer data are not included.
- Mooncakes publication is complete for version `0.1.1`.

## Publication Status

Version `0.1.1` is published on Mooncakes:

https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit

The package archive can also be rebuilt locally:

```bash
moon package
```

Recommended release tag after final review:

```bash
git tag v0.1.1
git push origin v0.1.1
git push gitlink v0.1.1
```
