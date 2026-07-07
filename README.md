# moonbit-pixelkit

A MoonBit toolkit for 2D pixel game map parsing and pathfinding.

`moonbit-pixelkit` is built for small 2D pixel games, grid-based demos, and algorithm teaching examples. It provides a compact tile map model, ASCII/CSV map parsers, walkability queries, BFS reachability, and A* path search.

## Status

This project is being developed for the 2026 MoonBit open-source ecosystem contest. The current milestone focuses on a small but usable core package:

- rectangular ASCII map parsing
- CSV tile map parsing
- tile lookup and walkability checks
- movement costs
- four-way and eight-way neighbor helpers
- BFS reachable-area search
- A* path search
- CI with `moon check` and `moon test`

## Acceptance Checklist

The repository currently includes the minimum assets expected for a reusable MoonBit package:

- public repository with MIT license
- MoonBit module metadata in `moon.mod`
- runnable examples under `examples/`
- unit tests for parser behavior, map queries, reachability, A*, diagonal movement, and error paths
- GitHub Actions workflow for `moon check` and `moon test`
- project proposal document: `moonbit-pixelkit-project-proposal.md`
- acceptance guide: `ACCEPTANCE.md`
- changelog: `CHANGELOG.md`

## Quick Start

Run the checks:

```bash
moon check
moon test
```

Run the demo:

```bash
moon run cmd/main
moon run examples/ascii_maze
moon run examples/reachable_area
moon run examples/weighted_grid
moon run examples/game_loop_stub
```

Build the publish archive:

```bash
moon package
```

See [ACCEPTANCE.md](ACCEPTANCE.md) for reviewer-oriented verification notes.
See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Example

```moonbit
let source = (
  #|S..
  #|##.
  #|..G
)

let map = parse_ascii_map(source).unwrap()
let path = astar(map, point(0, 0), point(2, 2)).unwrap().unwrap()

println("path length: \{path.length()}")
```

## API Overview

- `point(x, y)` creates a `Point`.
- `parse_ascii_map(text, options~)` parses `#`, `.`, `S`, and `G` maps by default.
- `parse_csv_map(text)` parses CSV tile ids; `1` is treated as a wall.
- `TileMap::in_bounds(point)` checks map bounds.
- `TileMap::tile_at(point)` returns a tile when the coordinate is valid.
- `TileMap::is_walkable(point)` returns whether movement is allowed.
- `TileMap::movement_cost(point)` returns the tile movement cost.
- `neighbors4(point)` returns cardinal neighbors.
- `neighbors8(point)` returns cardinal plus diagonal neighbors.
- `bfs_reachable(map, start, max_cost, options~)` returns reachable cells.
- `astar(map, start, goal, options~)` returns a path or `None`.

## Roadmap

- Structured parse and pathfinding error types.
- More examples for weighted terrain and turn-based movement ranges.
- More package examples after the `0.1.0` Mooncakes release.
- Optional Tiled JSON import experiments after the core API settles.

## Release

Version `0.1.0` is published on Mooncakes:

https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit

Local packaging is verified with:

```bash
moon package
```

Recommended release tag:

```bash
git tag v0.1.0
git push origin v0.1.0
git push gitlink v0.1.0
```

## Development Notes

Useful verification commands:

```bash
moon check
moon test
moon run cmd/main
moon run examples/ascii_maze
moon run examples/reachable_area
moon run examples/weighted_grid
moon run examples/game_loop_stub
moon package
```

Git remotes used during contest development:

```bash
git push origin main
git push gitlink main
```

## License

MIT
