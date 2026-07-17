# moonbit-pixelkit

A MoonBit toolkit for 2D pixel game map parsing and pathfinding.

`moonbit-pixelkit` is built for small 2D pixel games, grid-based demos, and algorithm teaching examples. It provides a compact tile map model, ASCII/CSV map parsers, walkability queries, BFS reachability, and A* path search.

## Showcase

Open the browser showcase:

```text
showcase.html
```

The page renders the same tactical movement preview as a color grid. Click an open tile to preview a new target, or switch between the current-turn route and the full route to the goal.

Run the tactical preview:

```bash
moon run examples/tactical_preview
```

It renders a battlefield, the cells an actor can reach this turn, and the planned path:

```text
moonbit-pixelkit tactical preview

Legend: S actor, G goal, # wall, + reachable this turn, * planned path

Turn 1 movement range, budget 8:
S++++++#...G
+####++#....
+++#++.....
+##+#+####..
+++#.......
++###..##...
+++.........

Selected target: (6, 2)
Selected target reachable: true
This-turn path cost: 8
This-turn path steps: 8
S******#...G
+####+*#....
+++#+*.....
+##+#+####..
+++#.......
++###..##...
+++.........
```

## Status

This project is being developed for the 2026 MoonBit open-source ecosystem contest. The current milestone focuses on a small but usable core package:

- rectangular ASCII map parsing
- CSV tile map parsing
- tile lookup and walkability checks
- movement costs
- four-way and eight-way neighbor helpers
- Dijkstra reachable-area search with accumulated movement costs
- A* path search
- start/goal lookup helpers
- path movement-cost summaries
- high-level movement previews for tactical target selection
- ASCII overlays for reachable cells and planned paths
- game-style examples for pathfinding, turn previews, and tactical movement
- CI with `moon check`, `moon build`, and `moon test`

## Acceptance Checklist

The repository currently includes the minimum assets expected for a reusable MoonBit package:

- public repository with MIT license
- MoonBit module metadata in `moon.mod`
- runnable examples under `examples/`
- unit tests for parser behavior, map queries, reachability, A*, diagonal movement, and error paths
- GitHub Actions workflow for `moon check`, `moon build`, and `moon test`
- project proposal document: `moonbit-pixelkit-project-proposal.md`
- acceptance guide: `ACCEPTANCE.md`
- changelog: `CHANGELOG.md`
- browser showcase: `showcase.html`

## Quick Start

Install the package in another MoonBit project:

```bash
moon add ttxiangshang/moonbit-pixelkit
```

Then import it from your `moon.pkg`:

```moonbit
import {
  "ttxiangshang/moonbit-pixelkit" @pixelkit,
}
```

Run from this repository:

```bash
git clone https://github.com/zhenghao493-netizen/moonbit-pixelkit.git
cd moonbit-pixelkit
moon check
moon build
moon test
```

Run the checks:

```bash
moon check
moon build
moon test
```

Run the demo:

```bash
moon run cmd/main
moon run examples/ascii_maze
moon run examples/reachable_area
moon run examples/weighted_grid
moon run examples/game_loop_stub
moon run examples/turn_based_movement
moon run examples/tactical_preview
```

Build the publish archive:

```bash
moon package
```

See [ACCEPTANCE.md](ACCEPTANCE.md) for reviewer-oriented verification notes.
See [CHANGELOG.md](CHANGELOG.md) for release notes.
Open `showcase.html` for a browser-based visual preview.

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
- `TileMap::first_point_with_id(id)` returns the first matching tile coordinate.
- `TileMap::single_point_with_id(id)` validates that exactly one matching tile exists.
- `TileMap::path_cost(path)` sums movement cost after the starting cell.
- `TileMap::validate_path(path, options~)` checks for walkable, step-by-step legal routes and returns a path report.
- `TileMap::render_ascii_overlay(reachable=..., path=...)` renders movement range and planned paths.
- `neighbors4(point)` returns cardinal neighbors.
- `neighbors8(point)` returns cardinal plus diagonal neighbors.
- `search_options(allow_diagonal=true)` enables diagonal movement while still preventing wall-corner cutting by default; use `allow_corner_cutting=true` only when that behavior is intended.
- `bfs_reachable(map, start, max_cost, options~)` returns reachable cells.
- `bfs_reachable_with_costs(map, start, max_cost, options~)` uses a Dijkstra frontier to return reachable cells with minimum accumulated movement costs.
- `movement_preview(map, start, target, max_cost, options~)` returns range, target reachability, target cost, and target path in one call.
- `astar(map, start, goal, options~)` returns a path or `None`.

## Turn-Based Movement Use Case

`moonbit-pixelkit` is designed to cover a compact tactical-game loop:

1. Parse an ASCII or CSV grid.
2. Find named points such as `start` and `goal`.
3. Compute the cells an actor can reach this turn.
4. Plan a path to a selected target.
5. Render a terminal overlay for debugging or examples.

```moonbit
let map = parse_ascii_map(source).unwrap()
let actor = map.single_point_with_id("start").unwrap()
let target = point(4, 1)
let preview = movement_preview(map, actor, target, 5).unwrap()
let reachable = preview.reachable_points()
let path = preview.path().unwrap()

println("cost: \{preview.path_cost().unwrap()}")
println("steps: \{map.validate_path(path).unwrap().steps()}")
println(map.render_ascii_overlay(reachable=reachable, path=path))
```

## Roadmap

- Structured parse and pathfinding error types.
- Additional gameplay helpers for turn previews and editor tooling.
- More package examples after the `0.1.1` Mooncakes release.
- Optional Tiled JSON import experiments after the core API settles.

## Release

Version `0.1.0` is published on Mooncakes:

https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit

The main branch is now continuing toward `0.1.1`.

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
moon build
moon test
moon run cmd/main
moon run examples/ascii_maze
moon run examples/reachable_area
moon run examples/weighted_grid
moon run examples/game_loop_stub
moon run examples/turn_based_movement
moon run examples/tactical_preview
moon package
```

Git remotes used during contest development:

```bash
git push origin main
git push gitlink main
```

## License

MIT
