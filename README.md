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
```

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
- User-configurable CSV terrain costs.
- More examples for weighted terrain and turn-based movement ranges.
- Mooncakes package publishing.
- Optional Tiled JSON import experiments after the core API settles.

## License

MIT
