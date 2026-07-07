///| A point in a 2D tile grid.
pub struct Point {
  x : Int
  y : Int
} derive(Eq, Debug)

///| A parsed tile. `wall` means the tile blocks movement.
pub struct Tile {
  id : String
  wall : Bool
  cost : Int
} derive(Eq, Debug)

///| A rectangular 2D tile map stored in row-major order.
pub struct TileMap {
  width : Int
  height : Int
  tiles : Array[Tile]
} derive(Debug)

///| Options for ASCII map parsing.
pub struct AsciiOptions {
  wall : Char
  floor : Char
  start : Char
  goal : Char
} derive(Eq, Debug)

///| Options shared by path search helpers.
pub struct SearchOptions {
  allow_diagonal : Bool
} derive(Eq, Debug)

///| A per-tile movement cost override for CSV maps.
pub struct TerrainCost {
  id : String
  cost : Int
} derive(Eq, Debug)

///| Options for CSV map parsing.
pub struct CsvOptions {
  wall_ids : Array[String]
  terrain_costs : Array[TerrainCost]
  default_cost : Int
} derive(Debug)

///| Default ASCII conventions: `#` walls, `.` floors, `S` start, `G` goal.
pub fn AsciiOptions::default() -> AsciiOptions {
  { wall: '#', floor: '.', start: 'S', goal: 'G' }
}

///| Default path search settings: four-direction movement.
pub fn SearchOptions::default() -> SearchOptions {
  { allow_diagonal: false }
}

///| Default CSV conventions: tile id `1` is a wall and other ids cost 1.
pub fn CsvOptions::default() -> CsvOptions {
  { wall_ids: ["1"], terrain_costs: [], default_cost: 1 }
}

///| Create search options.
pub fn search_options(allow_diagonal~ : Bool = false) -> SearchOptions {
  { allow_diagonal, }
}

///| Create a CSV terrain cost override.
pub fn terrain_cost(id : String, cost : Int) -> TerrainCost {
  { id, cost }
}

///| Create CSV parsing options.
pub fn csv_options(
  wall_ids~ : Array[String] = ["1"],
  terrain_costs~ : Array[TerrainCost] = [],
  default_cost~ : Int = 1,
) -> CsvOptions {
  { wall_ids, terrain_costs, default_cost }
}

///| Create a point.
pub fn point(x : Int, y : Int) -> Point {
  { x, y }
}

///| Return the x coordinate.
pub fn Point::x(self : Point) -> Int {
  self.x
}

///| Return the y coordinate.
pub fn Point::y(self : Point) -> Int {
  self.y
}

///| Return the map width.
pub fn TileMap::width(self : TileMap) -> Int {
  self.width
}

///| Return the map height.
pub fn TileMap::height(self : TileMap) -> Int {
  self.height
}

///| Return true when `p` is inside the map rectangle.
pub fn TileMap::in_bounds(self : TileMap, p : Point) -> Bool {
  p.x >= 0 && p.y >= 0 && p.x < self.width && p.y < self.height
}

fn TileMap::index(self : TileMap, p : Point) -> Int {
  p.y * self.width + p.x
}

///| Return the tile at `p`, or `None` when the coordinate is out of bounds.
pub fn TileMap::tile_at(self : TileMap, p : Point) -> Tile? {
  if self.in_bounds(p) {
    Some(self.tiles[self.index(p)])
  } else {
    None
  }
}

///| Return true when a coordinate is inside the map and not a wall.
pub fn TileMap::is_walkable(self : TileMap, p : Point) -> Bool {
  match self.tile_at(p) {
    Some(tile) => !tile.wall
    None => false
  }
}

///| Return the movement cost for `p`, or `None` for out-of-bounds cells.
pub fn TileMap::movement_cost(self : TileMap, p : Point) -> Int? {
  match self.tile_at(p) {
    Some(tile) => Some(tile.cost)
    None => None
  }
}

fn tile(id : String, wall : Bool, cost : Int) -> Tile {
  { id, wall, cost }
}

///| Return the tile id.
pub fn Tile::id(self : Tile) -> String {
  self.id
}

///| Return whether the tile blocks movement.
pub fn Tile::is_wall(self : Tile) -> Bool {
  self.wall
}

///| Return the tile movement cost.
pub fn Tile::cost(self : Tile) -> Int {
  self.cost
}

///| Return every point whose tile id equals `id`.
pub fn TileMap::points_with_id(self : TileMap, id : String) -> Array[Point] {
  let points : Array[Point] = []
  for index in 0..<self.tiles.length() {
    if self.tiles[index].id == id {
      points.push(self.point_from_index(index))
    }
  }
  points
}

///| Parse an ASCII tile map. Every row must have the same character length.
pub fn parse_ascii_map(
  input : String,
  options~ : AsciiOptions = AsciiOptions::default(),
) -> Result[TileMap, String] {
  let rows = input.split("\n").map(row => row.to_owned()).collect()
  if rows.length() == 0 || (rows.length() == 1 && rows[0].length() == 0) {
    return Err("map is empty")
  }
  let width = rows[0].iter().count()
  if width == 0 {
    return Err("map has an empty first row")
  }
  let tiles : Array[Tile] = []
  for row_index in 0..<rows.length() {
    let row = rows[row_index]
    let row_width = row.iter().count()
    if row_width != width {
      return Err(
        "row \{row_index} has width \{row_width}, expected \{width}",
      )
    }
    for ch in row.iter() {
      if ch == options.wall {
        tiles.push(tile("#", true, 0))
      } else if ch == options.floor {
        tiles.push(tile(".", false, 1))
      } else if ch == options.start {
        tiles.push(tile("start", false, 1))
      } else if ch == options.goal {
        tiles.push(tile("goal", false, 1))
      } else {
        return Err("unknown tile '\{ch}' at row \{row_index}")
      }
    }
  }
  Ok({ width, height: rows.length(), tiles })
}

///| Parse a CSV tile map. `1` is treated as a wall; all other ids are walkable.
pub fn parse_csv_map(input : String) -> Result[TileMap, String] {
  parse_csv_map_with_options(input, CsvOptions::default())
}

fn CsvOptions::cost_for(self : CsvOptions, id : String) -> Int {
  for item in self.terrain_costs {
    if item.id == id {
      return item.cost
    }
  }
  self.default_cost
}

///| Parse a CSV tile map with configurable wall ids and terrain costs.
pub fn parse_csv_map_with_options(
  input : String,
  options : CsvOptions,
) -> Result[TileMap, String] {
  if options.default_cost <= 0 {
    return Err("default_cost must be positive")
  }
  for item in options.terrain_costs {
    if item.cost <= 0 {
      return Err("terrain cost for '\{item.id}' must be positive")
    }
  }
  let rows = input.split("\n").map(row => row.to_owned()).collect()
  if rows.length() == 0 || (rows.length() == 1 && rows[0].length() == 0) {
    return Err("map is empty")
  }
  let first = rows[0].split(",").map(cell => cell.trim().to_owned()).collect()
  let width = first.length()
  if width == 0 {
    return Err("map has an empty first row")
  }
  let tiles : Array[Tile] = []
  for row_index in 0..<rows.length() {
    let cells = rows[row_index].split(",").map(cell => cell.trim().to_owned()).collect()
    if cells.length() != width {
      return Err(
        "row \{row_index} has width \{cells.length()}, expected \{width}",
      )
    }
    for id in cells {
      let is_wall = options.wall_ids.contains(id)
      tiles.push(tile(id, is_wall, if is_wall { 0 } else { options.cost_for(id) }))
    }
  }
  Ok({ width, height: rows.length(), tiles })
}

///| Four-direction neighbors in right, left, down, up order.
pub fn neighbors4(p : Point) -> Array[Point] {
  [
    point(p.x + 1, p.y),
    point(p.x - 1, p.y),
    point(p.x, p.y + 1),
    point(p.x, p.y - 1),
  ]
}

///| Eight-direction neighbors, including diagonals.
pub fn neighbors8(p : Point) -> Array[Point] {
  [
    point(p.x + 1, p.y),
    point(p.x - 1, p.y),
    point(p.x, p.y + 1),
    point(p.x, p.y - 1),
    point(p.x + 1, p.y + 1),
    point(p.x + 1, p.y - 1),
    point(p.x - 1, p.y + 1),
    point(p.x - 1, p.y - 1),
  ]
}

fn abs_int(value : Int) -> Int {
  if value < 0 { -value } else { value }
}

fn manhattan(a : Point, b : Point) -> Int {
  abs_int(a.x - b.x) + abs_int(a.y - b.y)
}

fn TileMap::point_from_index(self : TileMap, index : Int) -> Point {
  point(index % self.width, index / self.width)
}

fn candidate_neighbors(p : Point, options : SearchOptions) -> Array[Point] {
  if options.allow_diagonal { neighbors8(p) } else { neighbors4(p) }
}

///| Return all walkable cells reachable from `start` within `max_cost`.
pub fn bfs_reachable(
  map : TileMap,
  start : Point,
  max_cost : Int,
  options~ : SearchOptions = SearchOptions::default(),
) -> Result[Array[Point], String] {
  if max_cost < 0 {
    return Err("max_cost must be non-negative")
  }
  if !map.is_walkable(start) {
    return Err("start is not walkable")
  }
  let size = map.width * map.height
  let mut cursor = 0
  let queue : Array[Point] = [start]
  let cost = Array::make(size, -1)
  cost[map.index(start)] = 0
  while cursor < queue.length() {
    let current = queue[cursor]
    cursor = cursor + 1
    let current_cost = cost[map.index(current)]
    for next in candidate_neighbors(current, options) {
      if map.is_walkable(next) {
        let next_index = map.index(next)
        let step_cost = map.movement_cost(next).unwrap()
        let new_cost = current_cost + step_cost
        if new_cost <= max_cost && (cost[next_index] == -1 || new_cost < cost[next_index]) {
          cost[next_index] = new_cost
          queue.push(next)
        }
      }
    }
  }
  let reachable : Array[Point] = []
  for index in 0..<size {
    if cost[index] >= 0 {
      reachable.push(map.point_from_index(index))
    }
  }
  Ok(reachable)
}

///| Find a path from `start` to `goal` with A*. Returns `None` when unreachable.
pub fn astar(
  map : TileMap,
  start : Point,
  goal : Point,
  options~ : SearchOptions = SearchOptions::default(),
) -> Result[Array[Point]?, String] {
  if !map.is_walkable(start) {
    return Err("start is not walkable")
  }
  if !map.is_walkable(goal) {
    return Err("goal is not walkable")
  }
  let size = map.width * map.height
  let open : Array[Point] = [start]
  let closed = Array::make(size, false)
  let g_score = Array::make(size, 1_000_000_000)
  let came_from = Array::make(size, -1)
  g_score[map.index(start)] = 0
  while true {
    let mut best_index = -1
    let mut best_score = 1_000_000_000
    for p in open {
      let index = map.index(p)
      if !closed[index] {
        let score = g_score[index] + manhattan(p, goal)
        if score < best_score {
          best_score = score
          best_index = index
        }
      }
    }
    if best_index == -1 {
      return Ok(None)
    }
    let current = map.point_from_index(best_index)
    if current == goal {
      let path : Array[Point] = []
      let mut cursor = best_index
      while cursor != -1 {
        path.push(map.point_from_index(cursor))
        cursor = came_from[cursor]
      }
      return Ok(Some(path.rev()))
    }
    closed[best_index] = true
    for next in candidate_neighbors(current, options) {
      if map.is_walkable(next) {
        let next_index = map.index(next)
        if !closed[next_index] {
          let tentative = g_score[best_index] + map.movement_cost(next).unwrap()
          if tentative < g_score[next_index] {
            came_from[next_index] = best_index
            g_score[next_index] = tentative
            if !open.contains(next) {
              open.push(next)
            }
          }
        }
      }
    }
  }
  Ok(None)
}
