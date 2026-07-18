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
priv struct FrontierEntry {
  cost : Int
  index : Int
} derive(Eq)

///|
impl Compare for FrontierEntry with fn compare(self, other) -> Int {
  let cost_order = other.cost.compare(self.cost)
  if cost_order != 0 {
    cost_order
  } else {
    other.index.compare(self.index)
  }
}

///|
/// Options for CSV map parsing.
pub struct CsvOptions {
  wall_ids : Array[String]
  terrain_costs : Array[TerrainCost]
  default_cost : Int
} derive(Debug)

///|
/// Options for importing an orthogonal, uncompressed Tiled JSON map.
pub struct TiledOptions {
  collision_layer : String
  terrain_layer : String?
  wall_gids : Array[Int]
  terrain_costs : Array[TerrainCost]
  default_cost : Int
} derive(Debug)

///|
/// A structured failure returned by the detailed map parsers.
pub enum ParseError {
  EmptyMap
  EmptyFirstRow
  NonRectangularRow(Int, Int, Int)
  UnknownAsciiTile(Int, Int, Char)
  InvalidDefaultCost
  InvalidTerrainCost(String, Int)
  TiledInvalidJson
  TiledRootMustBeObject
  TiledMissingField(String)
  TiledFieldMustBeInteger(String)
  TiledFieldMustBeString(String)
  TiledFieldMustBeIntegerArray(String)
  TiledInvalidDimensions
  TiledUnsupportedOrientation(String)
  TiledLayersMustBeArray
  TiledLayersMustBeObjects
  TiledLayerNotFound(String)
  TiledLayerNotTileLayer(String)
  TiledLayerSizeMismatch(String, Int, Int)
} derive(Eq, Debug)

///|
/// Render a structured parser error as a concise user-facing message.
pub fn ParseError::message(self : ParseError) -> String {
  match self {
    EmptyMap => "map is empty"
    EmptyFirstRow => "map has an empty first row"
    NonRectangularRow(row, width, expected) =>
      "row \{row} has width \{width}, expected \{expected}"
    UnknownAsciiTile(row, column, tile) =>
      "unknown tile '\{tile}' at row \{row}, column \{column}"
    InvalidDefaultCost => "default_cost must be positive"
    InvalidTerrainCost(id, cost) =>
      "terrain cost for '\{id}' must be positive, got \{cost}"
    TiledInvalidJson => "invalid Tiled JSON"
    TiledRootMustBeObject => "Tiled root must be an object"
    TiledMissingField(field) => "Tiled JSON is missing '\{field}'"
    TiledFieldMustBeInteger(field) => "Tiled '\{field}' must be an integer"
    TiledFieldMustBeString(field) => "Tiled '\{field}' must be a string"
    TiledFieldMustBeIntegerArray(field) =>
      "Tiled '\{field}' must be an integer array"
    TiledInvalidDimensions => "Tiled width and height must be positive"
    TiledUnsupportedOrientation(orientation) =>
      "Tiled orientation '\{orientation}' is not supported; use orthogonal"
    TiledLayersMustBeArray => "Tiled 'layers' must be an array"
    TiledLayersMustBeObjects => "Tiled layers must be objects"
    TiledLayerNotFound(name) => "Tiled layer '\{name}' was not found"
    TiledLayerNotTileLayer(name) => "Tiled layer '\{name}' is not a tilelayer"
    TiledLayerSizeMismatch(name, actual, expected) =>
      "Tiled layer '\{name}' has \{actual} cells, expected \{expected}"
  }
}

///|
/// A structured failure returned by detailed pathfinding and path-validation APIs.
pub enum PathError {
  PathEmpty
  PathPointOutOfBounds(Int, Point)
  PathPointNotWalkable(Int, Point)
  IllegalPathStep(Int, Point, Point)
  NegativeMaxCost(Int)
  StartNotWalkable(Point)
  GoalNotWalkable(Point)
  TargetNotWalkable(Point)
} derive(Eq, Debug)

///|
/// Render a structured path error as a concise user-facing message.
pub fn PathError::message(self : PathError) -> String {
  match self {
    PathEmpty => "path is empty"
    PathPointOutOfBounds(_, point) =>
      "path point (\{point.x}, \{point.y}) is out of bounds"
    PathPointNotWalkable(_, point) =>
      "path point (\{point.x}, \{point.y}) is not walkable"
    IllegalPathStep(_, from, to) =>
      "illegal step from (\{from.x}, \{from.y}) to (\{to.x}, \{to.y})"
    NegativeMaxCost(_) => "max_cost must be non-negative"
    StartNotWalkable(_) => "start is not walkable"
    GoalNotWalkable(_) => "goal is not walkable"
    TargetNotWalkable(_) => "target is not walkable"
  }
}

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
/// Default Tiled conventions: a `Collision` layer with gid `1` as walls.
pub fn TiledOptions::default() -> TiledOptions {
  {
    collision_layer: "Collision",
    terrain_layer: None,
    wall_gids: [1],
    terrain_costs: [],
    default_cost: 1,
  }
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
/// Create Tiled JSON import options for collision and optional terrain layers.
pub fn tiled_options(
  collision_layer? : String = "Collision",
  terrain_layer? : String? = None,
  wall_gids? : Array[Int] = [1],
  terrain_costs? : Array[TerrainCost] = [],
  default_cost? : Int = 1,
) -> TiledOptions {
  { collision_layer, terrain_layer, wall_gids, terrain_costs, default_cost }
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
  match parse_ascii_map_detailed(input, options~) {
    Ok(map) => Ok(map)
    Err(error) => Err(error.message())
  }
}

///|
/// Parse an ASCII tile map and return structured errors with row and column details.
pub fn parse_ascii_map_detailed(
  input : String,
  options? : AsciiOptions = AsciiOptions::default(),
) -> Result[TileMap, ParseError] {
  let rows = input_rows(input)
  if rows.length() == 0 {
    return Err(EmptyMap)
  }
  let width = rows[0].iter().count()
  if width == 0 {
    return Err(EmptyFirstRow)
  }
  let tiles : Array[Tile] = []
  for row_index in 0..<rows.length() {
    let row = rows[row_index]
    let row_width = row.iter().count()
    if row_width != width {
      return Err(NonRectangularRow(row_index, row_width, width))
    }
    let mut column = 0
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
        return Err(UnknownAsciiTile(row_index, column, ch))
      }
      column = column + 1
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
/// Parse a default CSV tile map and return structured errors.
pub fn parse_csv_map_detailed(input : String) -> Result[TileMap, ParseError] {
  parse_csv_map_with_options_detailed(input, CsvOptions::default())
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
  match parse_csv_map_with_options_detailed(input, options) {
    Ok(map) => Ok(map)
    Err(error) => Err(error.message())
  }
}

///|
/// Parse a CSV tile map and return structured parser and option errors.
pub fn parse_csv_map_with_options_detailed(
  input : String,
  options : CsvOptions,
) -> Result[TileMap, ParseError] {
  if options.default_cost <= 0 {
    return Err(InvalidDefaultCost)
  }
  for item in options.terrain_costs {
    if item.cost <= 0 {
      return Err(InvalidTerrainCost(item.id, item.cost))
    }
  }
  let rows = input_rows(input)
  if rows.length() == 0 {
    return Err(EmptyMap)
  }
  let first = rows[0].split(",").map(cell => cell.trim().to_owned()).collect()
  let width = first.length()
  if width == 0 {
    return Err(EmptyFirstRow)
  }
  let tiles : Array[Tile] = []
  for row_index in 0..<rows.length() {
    let cells = rows[row_index]
      .split(",")
      .map(cell => cell.trim().to_owned())
      .collect()
    if cells.length() != width {
      return Err(NonRectangularRow(row_index, cells.length(), width))
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
fn TiledOptions::cost_for_gid(self : TiledOptions, gid : Int) -> Int {
  let id = gid.to_string()
  for item in self.terrain_costs {
    if item.id == id {
      return item.cost
    }
  }
  self.default_cost
}

///|
fn tiled_required(
  object : Map[String, Json],
  key : String,
) -> Result[Json, ParseError] {
  match object.get(key) {
    Some(value) => Ok(value)
    None => Err(TiledMissingField(key))
  }
}

///|
fn tiled_int(value : Json, label : String) -> Result[Int, ParseError] {
  try {
    let decoded : Int = @json.from_json(value)
    Ok(decoded)
  } catch {
    _ => Err(TiledFieldMustBeInteger(label))
  }
}

///|
fn tiled_string(value : Json, label : String) -> Result[String, ParseError] {
  match value {
    String(text) => Ok(text)
    _ => Err(TiledFieldMustBeString(label))
  }
}

///|
fn tiled_int_array(
  value : Json,
  label : String,
) -> Result[Array[Int], ParseError] {
  try {
    let decoded : Array[Int] = @json.from_json(value)
    Ok(decoded)
  } catch {
    _ => Err(TiledFieldMustBeIntegerArray(label))
  }
}

///|
fn tiled_layer_data(
  layers : Array[Json],
  name : String,
  expected_size : Int,
) -> Result[Array[Int], ParseError] {
  for layer in layers {
    match layer {
      Object(object) => {
        let name_value = match tiled_required(object, "name") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        let layer_name = match tiled_string(name_value, "layers[].name") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        if layer_name == name {
          let type_value = match tiled_required(object, "type") {
            Err(message) => return Err(message)
            Ok(value) => value
          }
          let layer_type = match tiled_string(type_value, "layers[].type") {
            Err(message) => return Err(message)
            Ok(value) => value
          }
          if layer_type != "tilelayer" {
            return Err(TiledLayerNotTileLayer(name))
          }
          let data_value = match tiled_required(object, "data") {
            Err(message) => return Err(message)
            Ok(value) => value
          }
          let data = match tiled_int_array(data_value, "layers[].data") {
            Err(message) => return Err(message)
            Ok(value) => value
          }
          if data.length() != expected_size {
            return Err(
              TiledLayerSizeMismatch(name, data.length(), expected_size),
            )
          }
          return Ok(data)
        }
      }
      _ => return Err(TiledLayersMustBeObjects)
    }
  }
  Err(TiledLayerNotFound(name))
}

///|
/// Parse an orthogonal, uncompressed Tiled JSON map with collision and terrain layers.
pub fn parse_tiled_json(
  input : String,
  options? : TiledOptions = TiledOptions::default(),
) -> Result[TileMap, String] {
  match parse_tiled_json_detailed(input, options~) {
    Ok(map) => Ok(map)
    Err(error) => Err(error.message())
  }
}

///|
/// Parse a Tiled JSON map and return structured import errors.
pub fn parse_tiled_json_detailed(
  input : String,
  options? : TiledOptions = TiledOptions::default(),
) -> Result[TileMap, ParseError] {
  if options.default_cost <= 0 {
    return Err(InvalidDefaultCost)
  }
  for item in options.terrain_costs {
    if item.cost <= 0 {
      return Err(InvalidTerrainCost(item.id, item.cost))
    }
  }
  try {
    let root = @json.parse(input)
    match root {
      Object(object) => {
        let width_value = match tiled_required(object, "width") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        let height_value = match tiled_required(object, "height") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        let layers_value = match tiled_required(object, "layers") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        let width = match tiled_int(width_value, "width") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        let height = match tiled_int(height_value, "height") {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        if width <= 0 || height <= 0 {
          return Err(TiledInvalidDimensions)
        }
        match object.get("orientation") {
          Some(value) => {
            let orientation = match tiled_string(value, "orientation") {
              Err(message) => return Err(message)
              Ok(value) => value
            }
            if orientation != "orthogonal" {
              return Err(TiledUnsupportedOrientation(orientation))
            }
          }
          None => ()
        }
        let layers = match layers_value {
          Array(items) => items
          _ => return Err(TiledLayersMustBeArray)
        }
        let size = width * height
        let collision = match
          tiled_layer_data(layers, options.collision_layer, size) {
          Err(message) => return Err(message)
          Ok(value) => value
        }
        let terrain : Array[Int]? = match options.terrain_layer {
          None => None
          Some(name) =>
            match tiled_layer_data(layers, name, size) {
              Err(message) => return Err(message)
              Ok(data) => Some(data)
            }
        }
        let tiles : Array[Tile] = []
        for index in 0..<size {
          let collision_gid = collision[index]
          let terrain_gid = match terrain {
            None => collision_gid
            Some(data) => data[index]
          }
          let is_wall = options.wall_gids.contains(collision_gid)
          let id = terrain_gid.to_string()
          let cost = if is_wall { 0 } else { options.cost_for_gid(terrain_gid) }
          tiles.push(tile(id, is_wall, cost))
        }
        Ok({ width, height, tiles })
      }
      _ => Err(TiledRootMustBeObject)
    }
  } catch {
    _ => Err(TiledInvalidJson)
  }
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
  match self.path_cost_detailed(path) {
    Ok(cost) => Ok(cost)
    Err(error) => Err(error.message())
  }
}

///|
/// Return a path movement cost with structured point-validation errors.
pub fn TileMap::path_cost_detailed(
  self : TileMap,
  path : Array[Point],
) -> Result[Int, PathError] {
  let mut total = 0
  for index in 0..<path.length() {
    let p = path[index]
    if !self.in_bounds(p) {
      return Err(PathPointOutOfBounds(index, p))
    }
    if !self.is_walkable(p) {
      return Err(PathPointNotWalkable(index, p))
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
  match self.validate_path_detailed(path, options~) {
    Ok(report) => Ok(report)
    Err(error) => Err(error.message())
  }
}

///|
/// Validate a path with structured errors for empty paths, tiles, and steps.
pub fn TileMap::validate_path_detailed(
  self : TileMap,
  path : Array[Point],
  options? : SearchOptions = SearchOptions::default(),
) -> Result[PathReport, PathError] {
  if path.length() == 0 {
    return Err(PathEmpty)
  }
  for index in 0..<path.length() {
    let p = path[index]
    if !self.in_bounds(p) {
      return Err(PathPointOutOfBounds(index, p))
    }
    if !self.is_walkable(p) {
      return Err(PathPointNotWalkable(index, p))
    }
    if index > 0 {
      let previous = path[index - 1]
      if !self.can_step(previous, p, options) {
        return Err(IllegalPathStep(index, previous, p))
      }
    }
  }
  let cost = match self.path_cost_detailed(path) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  Ok({ steps: path.length() - 1, cost })
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
  match bfs_reachable_detailed(map, start, max_cost, options~) {
    Err(error) => Err(error.message())
    Ok(points) => Ok(points)
  }
}

///|
/// Return reachable cells with structured start and budget errors.
pub fn bfs_reachable_detailed(
  map : TileMap,
  start : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[Array[Point], PathError] {
  match bfs_reachable_with_costs_detailed(map, start, max_cost, options~) {
    Err(error) => Err(error)
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
/// Uses a Dijkstra frontier for weighted terrain.
pub fn bfs_reachable_with_costs(
  map : TileMap,
  start : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[Array[ReachableCell], String] {
  match bfs_reachable_with_costs_detailed(map, start, max_cost, options~) {
    Ok(cells) => Ok(cells)
    Err(error) => Err(error.message())
  }
}

///|
/// Return reachable cells and structured start or movement-budget errors.
pub fn bfs_reachable_with_costs_detailed(
  map : TileMap,
  start : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[Array[ReachableCell], PathError] {
  if max_cost < 0 {
    return Err(NegativeMaxCost(max_cost))
  }
  if !map.is_walkable(start) {
    return Err(StartNotWalkable(start))
  }
  let size = map.width * map.height
  let cost = Array::make(size, -1)
  cost[map.index(start)] = 0
  let frontier : @priority_queue.PriorityQueue[FrontierEntry] = @priority_queue.PriorityQueue([],
  )
  frontier.push({ cost: 0, index: map.index(start) })
  while !frontier.is_empty() {
    let entry = frontier.pop().unwrap()
    if entry.cost == cost[entry.index] {
      let current = map.point_from_index(entry.index)
      for next in map.candidate_neighbors(current, options) {
        let next_index = map.index(next)
        let new_cost = entry.cost + map.movement_cost(next).unwrap()
        if new_cost <= max_cost &&
          (cost[next_index] == -1 || new_cost < cost[next_index]) {
          cost[next_index] = new_cost
          frontier.push({ cost: new_cost, index: next_index })
        }
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
  match movement_preview_detailed(map, start, target, max_cost, options~) {
    Ok(preview) => Ok(preview)
    Err(error) => Err(error.message())
  }
}

///|
/// Build a movement preview with structured target, start, and budget errors.
pub fn movement_preview_detailed(
  map : TileMap,
  start : Point,
  target : Point,
  max_cost : Int,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[MovementPreview, PathError] {
  if !map.is_walkable(target) {
    return Err(TargetNotWalkable(target))
  }
  match bfs_reachable_with_costs_detailed(map, start, max_cost, options~) {
    Err(error) => Err(error)
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
          match astar_detailed(map, start, target, options~) {
            Err(error) => Err(error)
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
  match astar_detailed(map, start, goal, options~) {
    Ok(path) => Ok(path)
    Err(error) => Err(error.message())
  }
}

///|
/// Find an A* path with structured start and goal validation errors.
pub fn astar_detailed(
  map : TileMap,
  start : Point,
  goal : Point,
  options? : SearchOptions = SearchOptions::default(),
) -> Result[Array[Point]?, PathError] {
  if !map.is_walkable(start) {
    return Err(StartNotWalkable(start))
  }
  if !map.is_walkable(goal) {
    return Err(GoalNotWalkable(goal))
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
