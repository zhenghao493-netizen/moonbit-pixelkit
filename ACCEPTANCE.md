# moonbit-pixelkit Acceptance Guide

This guide is for reviewers of the 2026 MoonBit open-source ecosystem contest.

## Project Summary

- Project: `moonbit-pixelkit`
- Direction: MoonBit 2D tile-map parsing and pathfinding toolkit
- GitLink: https://www.gitlink.org.cn/ttxiangshang/moonbit-pixelkit
- GitHub: https://github.com/zhenghao493-netizen/moonbit-pixelkit
- License: MIT
- Main language: MoonBit

`moonbit-pixelkit` provides a small reusable core for grid-based games and demos: ASCII/CSV map parsing, tile queries, walkability checks, movement costs, BFS reachable-area search, A* pathfinding, and ASCII path rendering.

## Initial Review Assets

- Public repository with visible commit history.
- `README.md` with project status, commands, examples, API overview, and roadmap.
- `moonbit-pixelkit-project-proposal.md` with the project proposal.
- `CHANGELOG.md` with the `0.1.0` release candidate notes.
- `LICENSE` using MIT.
- `.github/workflows/ci.yml` running `moon check` and `moon test`.
- Runnable examples under `examples/`.
- Unit tests covering parser, map query, reachability, A*, rendering, and error paths.

## Verification Commands

Run these commands from the repository root:

```bash
moon check
moon test
moon package
moon run cmd/main
moon run examples/ascii_maze
moon run examples/reachable_area
moon run examples/weighted_grid
moon run examples/game_loop_stub
```

Expected baseline:

- `moon test` passes all tests.
- `moon package` creates a package archive under `_build/publish/`.
- Each example prints a short terminal result without requiring network access.

## Feature Coverage

- `parse_ascii_map` parses rectangular ASCII maps using `#`, `.`, `S`, and `G` by default.
- `parse_csv_map` parses CSV tile ids, with `1` treated as a wall by default.
- `parse_csv_map_with_options` supports configurable wall ids and terrain costs.
- `TileMap` supports dimensions, bounds checks, tile lookup, movement costs, id lookup, and ASCII rendering.
- `bfs_reachable` returns cells reachable within a movement budget.
- `astar` returns a path or `None` when a reachable path does not exist.
- `SearchOptions` supports four-way movement by default and optional diagonal movement.

## Known Boundaries

- The package intentionally targets small to medium grid maps for games, demos, and teaching examples.
- PNG, TMX, and Tiled JSON parsing are not included in the current milestone.
- Mooncakes publication is complete for version `0.1.0`.

## Publication Status

Version `0.1.0` is published on Mooncakes:

https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit

The package archive can also be rebuilt locally:

```bash
moon package
```

Recommended release tag after final review:

```bash
git tag v0.1.0
git push origin v0.1.0
git push gitlink v0.1.0
```
