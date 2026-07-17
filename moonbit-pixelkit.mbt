///|
/// A point in a 2D tile grid.
pub struct Point {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
/// A parsed tile. `wall` means the tile blocks movement.
pub struct Tile {
  id : String
  wall : Bool
  cost : Int
} derive(Eq, Debug)

///|
/// A rectangular 2D tile map stored in row-major order.
pub struct TileMap {
  width : Int
  height : Int
  tiles : Array[Tile]
} derive(Debug)

///|
/// Options for ASCII map parsing.
pub struct AsciiOptions {
  wall : Char
  floor : Char
  start : Char
  goal : Char
} derive(Eq, Debug)

///|
/// Options shared by path search helpers. Diagonal movement does not cut corners by default.
pub struct SearchOptions {
  allow_diagonal : Bool
  allow_corner_cutting : Bool
} derive(Eq, Debug)

///|
/// A per-tile movement cost override for CSV maps.
pub struct TerrainCost {
  id : String
  cost : Int
} derive(Eq, Debug)

///|
/// A walkable point reached by BFS together with its accumulated movement cost.
pub struct ReachableCell {
  point : Point
  cost : Int
} derive(Eq, Debug)

///|
/// A complete movement preview for selecting a target in a grid game.
pub struct MovementPreview {
  start : Point
  target : Point
  max_cost : Int
  reachable : Array[ReachableCell]
  target_cost : Int?
  path : Array[Point]?
} derive(Debug)

///|
/// A validated movement path with step count and movement cost.
pub struct PathReport {
  steps : Int
  cost : Int
} derive(Eq, Debug)

///|
/// Options for CSV map parsing.
pub struct CsvOptions {
  wall_ids : Array[String]
  terrain_costs : Array[TerrainCost]
  default_cost : Int
} derive(Debug)

///|
/// Default ASCII conventions: `#` walls, `.` floors, `S` start, `G` goal.
pub fn AsciiOptions::default() -> AsciiOptions {
  { wall: '#', floor: '.', start: 'S', goal: 'G' }
}

///|
/// Default path search settings: four-direction movement.
pub fn SearchOptions::default() -> SearchOptions {
  { allow_diagonal: false, allow_corner_cutting: false }
}

///|
/// Default CSV conventions: tile id `1` is a wall and other ids cost 1.
pub fn CsvOptions::default() -> CsvOptions {
  { wall_ids: ["1"], terrain_costs: [], default_cost: 1 }
}

///|
/// Create search options. Set `allow_corner_cutting` only for games that permit diagonal wall cutting.
pub fn search_options(
  allow_diagonal? : Bool = false,
  allow_corner_cutting? : Bool = false,
) -> SearchOptions {
  { allow_diagonal, allow_corner_cutting }
}

///|
/// Create a CSV terrain cost override.
pub fn terrain_cost(id : String, cost : Int) -> TerrainCost {
  { id, cost }
}

///|
/// Create CSV parsing options.
pub fn csv_options(
  wall_ids? : Array[String] = ["1"],
  terrain_costs? : Array[TerrainCost] = [],
  default_cost? : Int = 1,
) -> CsvOptions {
  { wall_ids, terrain_costs, default_cost }
}

///|
/// Create a point.
pub fn point(x : Int, y : Int) -> Point {
  { x, y }
}

///|
/// Return the x coordinate.
pub fn Point::x(self : Point) -> Int {
  self.x
}

///|
/// Return the y coordinate.
pub fn Point::y(self : Point) -> Int {
  self.y
}

///|
/// Return the map width.
pub fn TileMap::width(self : TileMap) -> Int {
  self.width
}

///|
/// Return the map height.
pub fn TileMap::height(self : TileMap) -> Int {
  self.height
}

///|
/// Return true when `p` is inside the map rectangle.
pub fn TileMap::in_bounds(self : TileMap, p : Point) -> Bool {
  p.x >= 0 && p.y >= 0 && p.x < self.width && p.y < self.height
}

///|
fn TileMap::index(self : TileMap, p : Point) -> Int {
  p.y * self.width + p.x
}

///|
/// Return the tile at `p`, or `None` when the coordinate is out of bounds.
pub fn TileMap::tile_at(self : TileMap, p : Point) -> Tile? {
  if self.in_bounds(p) {
    Some(self.tiles[self.index(p)])
  } else {
    None
  }
}

///|
/// Return true when a coordinate is inside the map and not a wall.
pub fn TileMap::is_walkable(self : TileMap, p : Point) -> Bool {
  match self.tile_at(p) {
    Some(tile) => !tile.wall
    None => false
  }
}

///|
/// Return the movement cost for `p`, or `None` for out-of-bounds cells.
pub fn TileMap::movement_cost(self : TileMap, p : Point) -> Int? {
  match self.tile_at(p) {
    Some(tile) => Some(tile.cost)
    None => None
  }
}

///|
fn tile(id : String, wall : Bool, cost : Int) -> Tile {
  { id, wall, cost }
}

///|
fn strip_trailing_cr(row : String) -> String {
  if row.has_suffix("\r") {
    row.view(end_offset=row.length() - 1).to_owned()
  } else {
    row
  }
}

///|
fn input_rows(input : String) -> Array[String] {
  let rows = input
    .split("\n")
    .map(row => strip_trailing_cr(row.to_owned()))
    .collect()
  while rows.length() > 0 && rows[rows.length() - 1] == "" {
    let _ = rows.pop()
  }
  rows
}

///|
/// Return the tile id.
pub fn Tile::id(self : Tile) -> String {
  self.id
}

///|
/// Return whether the tile blocks movement.
pub fn Tile::is_wall(self : Tile) -> Bool {
  self.wall
}

///|
/// Return the tile movement cost.
pub fn Tile::cost(self : Tile) -> Int {
  self.cost
}

///|
/// Return the reached point.
pub fn ReachableCell::point(self : ReachableCell) -> Point {
  self.point
}

///|
/// Return the accumulated movement cost from the BFS start point.
pub fn ReachableCell::cost(self : ReachableCell) -> Int {
  self.cost
}

///|
/// Return the movement preview start point.
pub fn MovementPreview::start(self : MovementPreview) -> Point {
  self.start
}

///|
/// Return the selected target point.
pub fn MovementPreview::target(self : MovementPreview) -> Point {
  self.target
}

///|
/// Return the movement budget used for this preview.
pub fn MovementPreview::max_cost(self : MovementPreview) -> Int {
  self.max_cost
}

///|
/// Return reachable cells and their accumulated costs.
pub fn MovementPreview::reachable(
  self : MovementPreview,
) -> Array[ReachableCell] {
  self.reachable
}

///|
/// Return only the points from the reachable cells, useful for rendering.
pub fn MovementPreview::reachable_points(
  self : MovementPreview,
) -> Array[Point] {
  let points : Array[Point] = []
  for cell in self.reachable {
    points.push(cell.point)
  }
  points
}

///|
/// Return whether the target can be reached within the movement budget.
pub fn MovementPreview::target_reachable(self : MovementPreview) -> Bool {
  self.target_cost is Some(_)
}

///|
/// Return the target's accumulated movement cost when it is reachable.
pub fn MovementPreview::target_cost(self : MovementPreview) -> Int? {
  self.target_cost
}

///|
/// Return the planned path cost when the target is reachable within the budget.
pub fn MovementPreview::path_cost(self : MovementPreview) -> Int? {
  self.target_cost
}

///|
/// Return the planned path when the target is reachable within the budget.
pub fn MovementPreview::path(self : MovementPreview) -> Array[Point]? {
  self.path
}

///|
/// Return the number of movement steps in the validated path.
pub fn PathReport::steps(self : PathReport) -> Int {
  self.steps
}

///|
/// Return the movement cost of the validated path.
pub fn PathReport::cost(self : PathReport) -> Int {
  self.cost
}

///|
/// Return every point whose tile id equals `id`.
pub fn TileMap::points_with_id(self : TileMap, id : String) -> Array[Point] {
  let points : Array[Point] = []
  for index in 0..<self.tiles.length() {
    if self.tiles[index].id == id {
      points.push(self.point_from_index(index))
    }
  }
  points
}

///|
/// Return the first point whose tile id equals `id`, or `None` when absent.
pub fn TileMap::first_point_with_id(self : TileMap, id : String) -> Point? {
  let points = self.points_with_id(id)
  if points.length() == 0 {
    None
  } else {
    Some(points[0])
  }
}

///|
/// Return one required point for `id`.
pub fn TileMap::single_point_with_id(
  self : TileMap,
  id : String,
) -> Result[Point, String] {
  let points = self.points_with_id(id)
  if points.length() == 1 {
    Ok(points[0])
  } else {
    Err("expected one tile with id '\{id}', found \{points.length()}")
  }
}

///|
/// Parse an ASCII tile map. Every row must have the same character length.
pub fn parse_ascii_map(
  input : String,
  options? : AsciiOptions = AsciiOptions::default(),
) -> Result[TileMap, String] {
  let rows = input_rows(input)
  if rows.length() == 0 {
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
      return Err("row \{row_index} has width \{row_width}, expected \{width}")
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

///|
/// Parse a CSV tile map. `1` is treated as a wall; all other ids are walkable.
pub fn parse_csv_map(input : String) -> Result[TileMap, String] {
  parse_csv_map_with_options(input, CsvOptions::default())
}

///|
fn CsvOptions::cost_for(self : CsvOptions, id : String) -> Int {
  for item in self.terrain_costs {
    if item.id == id {
      return item.cost
    }
  }
  self.default_cost
}

///|
/// Parse a CSV tile map with configurable wall ids and terrain costs.
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
  let rows = input_rows(input)
  if rows.length() == 0 {
    return Err("map is empty")
  }
  let first = rows[0].split(",").map(cell => cell.trim().to_owned()).collect()
  let width = first.length()
  if width == 0 {
    return Err("map has an empty first row")
  }
  let tiles : Array[Tile] = []
  for row_index in 0..<rows.length() {
    let cells = rows[row_index]
      .split(",")
      .map(cell => cell.trim().to_owned())
      .collect()
    if cells.length() != width {
      return Err(
        "row \{row_index} has width \{cells.length()}, expected \{width}",
      )
    }
    for id in cells {
      let is_wall = options.wall_ids.contains(id)
      tiles.push(
        tile(id, is_wall, if is_wall { 0 } else { options.cost_for(id) }),
      )
    }
  }
  Ok({ width, height: rows.length(), tiles })
}

///|
/// Four-direction neighbors in right, left, down, up order.
pub fn neighbors4(p : Point) -> Array[Point] {
  [
    point(p.x + 1, p.y),
    point(p.x - 1, p.y),
    point(p.x, p.y + 1),
    point(p.x, p.y - 1),
  ]
}

///|
/// Eight-direction neighbors, including diagonals.
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

///|
fn render_tile_overlay(
  point : Point,
  tile : Tile,
  reachable : Array[Point],
  path : Array[Point],
) -> Char {
  if tile.id == "start" {
    'S'
  } else if tile.id == "goal" {
    'G'
  } else if path.contains(point) {
    '*'
  } else if tile.wall {
    '#'
  } else if reachable.contains(point) {
    '+'
  } else {
    '.'
  }
}

///|
/// Render a map as ASCII, optionally overlaying a path with `*`.
pub fn TileMap::render_ascii(
  self : TileMap,
  path? : Array[Point] = [],
) -> String {
  self.render_ascii_overlay(path~)
}

///|
/// Render a map with reachable cells marked as `+` and path cells as `*`.
pub fn TileMap::render_ascii_overlay(
  self : TileMap,
  reachable? : Array[Point] = [],
  path? : Array[Point] = [],
) -> String {
  let chars : Array[Char] = []
  for y in 0..<self.height {
    for x in 0..<self.width {
      let p = point(x, y)
      chars.push(
        render_tile_overlay(p, self.tiles[self.index(p)], reachable, path),
      )
    }
    if y + 1 < self.height {
      chars.push('\n')
    }
  }
  String::from_array(chars)
}

///|
/// Return the movement cost of a path, excluding the starting cell.
pub fn TileMap::path_cost(
  self : TileMap,
  path : Array[Point],
) -> Result[Int, String] {
  let mut total = 0
  for index in 0..<path.length() {
    let p = path[index]
    if !self.in_bounds(p) {
      return Err("path point (\{p.x}, \{p.y}) is out of bounds")
    }
    if !self.is_walkable(p) {
      return Err("path point (\{p.x}, \{p.y}) is not walkable")
    }
    if index > 0 {
      total = total + self.movement_cost(p).unwrap()
    }
  }
  Ok(total)
}

///|
/// Validate that a path stays walkable and uses legal neighbor-to-neighbor steps.
pub fn TileMap::validate_path(
  self : TileMap,
  path : Array[Point],
  options? : SearchOptions = SearchOptions::default(),
) -> Result[PathReport, String] {
  if path.length() == 0 {
    return Err("path is empty")
  }
  for index in 0..<path.length() {
    let p = path[index]
    if !self.in_bounds(p) {
      return Err("path point (\{p.x}, \{p.y}) is out of bounds")
    }
    if !self.is_walkable(p) {
      return Err("path point (\{p.x}, \{p.y}) is not walkable")
    }
    if index > 0 {
      let previous = path[index - 1]
      if !self.can_step(previous, p, options) {
        return Err(
          "illegal step from (\{previous.x}, \{previous.y}) to (\{p.x}, \{p.y})",
        )
      }
    }
  }
  Ok({ steps: path.length() - 1, cost: self.path_cost(path).unwrap() })
}

///|
fn abs_int(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}

///|
fn manhattan(a : Point, b : Point) -> Int {
  abs_int(a.x - b.x) + abs_int(a.y - b.y)
}

///|
fn chebyshev(a : Point, b : Point) -> Int {
  let dx = abs_int(a.x - b.x)
  let dy = abs_int(a.y - b.y)
  if dx > dy {
    dx
  } else {
    dy
  }
}

///|
fn heuristic(a : Point, b : Point, options : SearchOptions) -> Int {
  if options.allow_diagonal {
    chebyshev(a, b)
  } else {
    manhattan(a, b)
  }
}

///|
fn is_legal_step(a : Point, b : Point, options : SearchOptions) -> Bool {
  let dx = abs_int(a.x - b.x)
  let dy = abs_int(a.y - b.y)
  if options.allow_diagonal {
    (dx <= 1 && dy <= 1) && dx + dy > 0
  } else {
    dx + dy == 1
  }
}

///|
fn is_diagonal_step(a : Point, b : Point) -> Bool {
  abs_int(a.x - b.x) == 1 && abs_int(a.y - b.y) == 1
}

///|
fn TileMap::can_step(
  self : TileMap,
  from : Point,
  to : Point,
  options : SearchOptions,
) -> Bool {
  if !self.is_walkable(to) || !is_legal_step(from, to, options) {
    return false
  }
  if !options.allow_corner_cutting && is_diagonal_step(from, to) {
    let horizontal = point(to.x, from.y)
    let vertical = point(from.x, to.y)
    return self.is_walkable(horizontal) && self.is_walkable(vertical)
  }
  true
}

///|
fn TileMap::point_from_index(self : TileMap, index : Int) -> Point {
  point(index % self.width, index / self.width)
}

///|
fn TileMap::candidate_neighbors(
  self : TileMap,
  p : Point,
  options : SearchOptions,
) -> Array[Point] {
  let candidates = if options.allow_diagonal {
    neighbors8(p)
  } else {
    neighbors4(p)
  }
  let neighbors : Array[Point] = []
  for next in candidates {
    if self.can_step(p, next, options) {
      neighbors.push(next)
    }
  }
  neighbors
}

///|
/// Return all walkable cells reachable from `start` within `max_cost`.
pub fn bfs_reachable(
  map : TileMap,
  start : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[Array[Point], String] {
  match bfs_reachable_with_costs(map, start, max_cost, options~) {
    Err(message) => Err(message)
    Ok(cells) => {
      let points : Array[Point] = []
      for cell in cells {
        points.push(cell.point)
      }
      Ok(points)
    }
  }
}

///|
/// Return all walkable cells reachable from `start`, including accumulated cost.
pub fn bfs_reachable_with_costs(
  map : TileMap,
  start : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[Array[ReachableCell], String] {
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
    for next in map.candidate_neighbors(current, options) {
      let next_index = map.index(next)
      let step_cost = map.movement_cost(next).unwrap()
      let new_cost = current_cost + step_cost
      if new_cost <= max_cost &&
        (cost[next_index] == -1 || new_cost < cost[next_index]) {
        cost[next_index] = new_cost
        queue.push(next)
      }
    }
  }
  let reachable : Array[ReachableCell] = []
  for index in 0..<size {
    if cost[index] >= 0 {
      reachable.push({ point: map.point_from_index(index), cost: cost[index] })
    }
  }
  Ok(reachable)
}

///|
/// Build a game-style movement preview for a selected target.
pub fn movement_preview(
  map : TileMap,
  start : Point,
  target : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[MovementPreview, String] {
  if !map.is_walkable(target) {
    return Err("target is not walkable")
  }
  match bfs_reachable_with_costs(map, start, max_cost, options~) {
    Err(message) => Err(message)
    Ok(reachable) => {
      let mut target_cost : Int? = None
      for cell in reachable {
        if cell.point == target {
          target_cost = Some(cell.cost)
        }
      }
      match target_cost {
        None =>
          Ok({
            start,
            target,
            max_cost,
            reachable,
            target_cost: None,
            path: None,
          })
        Some(_) =>
          match astar(map, start, target, options~) {
            Err(message) => Err(message)
            Ok(None) =>
              Ok({ start, target, max_cost, reachable, target_cost, path: None })
            Ok(Some(path)) =>
              Ok({
                start,
                target,
                max_cost,
                reachable,
                target_cost,
                path: Some(path),
              })
          }
      }
    }
  }
}

///|
/// Find a path from `start` to `goal` with A*. Returns `None` when unreachable.
pub fn astar(
  map : TileMap,
  start : Point,
  goal : Point,
  options? : SearchOptions = SearchOptions::default(),
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
        let score = g_score[index] + heuristic(p, goal, options)
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
    for next in map.candidate_neighbors(current, options) {
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
  Ok(None)
}
