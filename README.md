# moonbit-pixelkit

A MoonBit toolkit for 2D pixel game map parsing and pathfinding.

`moonbit-pixelkit` is built for small 2D pixel games, grid-based demos, and algorithm teaching examples. It provides a compact tile map model, ASCII/CSV/Tiled JSON import, walkability queries, Dijkstra reachability, and A* path search.

## Showcase

Open the browser showcase:

```text
showcase.html
```

The page renders the same tactical movement preview as a color grid. Click an open tile to preview a new target, switch between the current-turn route and the full route to the goal, or paste an ASCII map into the built-in map lab to validate it and recalculate the preview.

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
- orthogonal Tiled JSON import with collision and terrain layers
- structured parse and path errors with row, column, field, layer, point, and step context
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
- reproducible A* and Dijkstra performance baselines

## Acceptance Checklist

The repository currently includes the minimum assets expected for a reusable MoonBit package:

- public repository with MIT license
- MoonBit module metadata in `moon.mod`
- runnable examples under `examples/`
- unit tests for parser behavior, map queries, weighted reachability, A*, diagonal movement, Tiled JSON import, and error paths
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
moon run examples/tiled_tactical_preview
moon run examples/parse_diagnostics
```

Build the publish archive:

```bash
moon package
```

Run the release-mode performance baseline:

```bash
moon bench benchmarks/pathfinding --release --deny-warn
```

See [ACCEPTANCE.md](ACCEPTANCE.md) for reviewer-oriented verification notes.
See [CHANGELOG.md](CHANGELOG.md) for release notes.
See [PERFORMANCE.md](PERFORMANCE.md) for benchmark methodology and a local baseline.
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
- `parse_ascii_map_detailed(text, options~)` returns `ParseError` values with ASCII tile coordinates.
- `parse_csv_map(text)` parses CSV tile ids; `1` is treated as a wall.
- `parse_csv_map_detailed(text)` returns structured CSV map errors using default options.
- `parse_csv_map_with_options_detailed(text, options)` returns structured CSV and option errors.
- `parse_tiled_json(text, options~)` imports an orthogonal, uncompressed Tiled JSON map from named collision and optional terrain layers.
- `parse_tiled_json_detailed(text, options~)` returns structured JSON field, orientation, and layer import errors.
- `tiled_options(...)` configures Tiled collision GIDs, terrain layer, and movement-cost mapping.
- `ParseError::message()` converts a structured parser error to concise display text while legacy parser APIs continue returning `Result[..., String]`.
- `TileMap::in_bounds(point)` checks map bounds.
- `TileMap::tile_at(point)` returns a tile when the coordinate is valid.
- `TileMap::is_walkable(point)` returns whether movement is allowed.
- `TileMap::movement_cost(point)` returns the tile movement cost.
- `TileMap::first_point_with_id(id)` returns the first matching tile coordinate.
- `TileMap::single_point_with_id(id)` validates that exactly one matching tile exists.
- `TileMap::path_cost(path)` sums movement cost after the starting cell.
- `TileMap::path_cost_detailed(path)` returns a `PathError` when a path contains an invalid point.
- `TileMap::validate_path(path, options~)` checks for walkable, step-by-step legal routes and returns a path report.
- `TileMap::validate_path_detailed(path, options~)` returns structured empty-path, point, and illegal-step errors.
- `TileMap::render_ascii_overlay(reachable=..., path=...)` renders movement range and planned paths.
- `neighbors4(point)` returns cardinal neighbors.
- `neighbors8(point)` returns cardinal plus diagonal neighbors.
- `search_options(allow_diagonal=true)` enables diagonal movement while still preventing wall-corner cutting by default; use `allow_corner_cutting=true` only when that behavior is intended.
- `bfs_reachable(map, start, max_cost, options~)` returns reachable cells.
- `bfs_reachable_detailed(map, start, max_cost, options~)` returns structured start and movement-budget errors.
- `bfs_reachable_with_costs(map, start, max_cost, options~)` uses a Dijkstra frontier to return reachable cells with minimum accumulated movement costs.
- `movement_preview(map, start, target, max_cost, options~)` returns range, target reachability, target cost, and target path in one call.
- `movement_preview_detailed(...)` returns a `PathError` for invalid starts, targets, or budgets.
- `astar(map, start, goal, options~)` returns a path or `None`.
- `astar_detailed(map, start, goal, options~)` returns structured endpoint errors.

## Turn-Based Movement Use Case

`moonbit-pixelkit` is designed to cover a compact tactical-game loop:

1. Parse an ASCII, CSV, or Tiled JSON grid.
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

## Tiled JSON Import

Export an orthogonal map from Tiled using its JSON format with inline tile-layer data. By default, the importer reads a `Collision` layer and treats gid `1` as a wall. Configure a second terrain layer when individual GIDs carry movement costs:

```moonbit
let options = tiled_options(
  terrain_layer=Some("Terrain"),
  terrain_costs=[terrain_cost("2", 3), terrain_cost("3", 5)],
)
let map = parse_tiled_json(tiled_json, options~).unwrap()
```

Run the complete import-to-movement-preview example:

```bash
moon run examples/tiled_tactical_preview
```

This intentionally supports the portable core of Tiled JSON: orthogonal maps, named `tilelayer` entries, and uncompressed inline integer `data` arrays. Infinite maps, chunked layers, encoded/compressed data, TMX, and image assets remain outside the package boundary.

## Roadmap

- Additional gameplay helpers for turn previews and editor tooling.
- More package examples after the next Mooncakes release.
- Broader Tiled import support such as chunked layers and encoded data, based on real user demand.

## Release

Version `0.1.1` is published on Mooncakes:

https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit

The `v0.1.1` tag matches the current Mooncakes release; the main branch may additionally contain unreleased improvements.

Local packaging is verified with:

```bash
moon package
```

Recommended release tag:

```bash
git tag v0.1.1
git push origin v0.1.1
git push gitlink v0.1.1
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
