///| Turn-based movement example for a grid game.
fn render_turn_map(
  map : @pixelkit.TileMap,
  reachable : Array[@pixelkit.Point],
  path : Array[@pixelkit.Point],
) -> String {
  let chars : Array[Char] = []
  for y in 0..<map.height() {
    for x in 0..<map.width() {
      let p = @pixelkit.point(x, y)
      let tile = map.tile_at(p).unwrap()
      if tile.id() == "start" {
        chars.push('S')
      } else if tile.id() == "goal" {
        chars.push('G')
      } else if path.contains(p) {
        chars.push('*')
      } else if tile.is_wall() {
        chars.push('#')
      } else if reachable.contains(p) {
        chars.push('+')
      } else {
        chars.push('.')
      }
    }
    if y + 1 < map.height() {
      chars.push('\n')
    }
  }
  String::from_array(chars)
}

fn movement_cost(map : @pixelkit.TileMap, path : Array[@pixelkit.Point]) -> Int {
  let mut total = 0
  for index in 1..<path.length() {
    total = total + map.movement_cost(path[index]).unwrap()
  }
  total
}

fn main {
  let source = (
    #|S....
    #|##.#.
    #|...#G
    #|.....
  )
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let starts = map.points_with_id("start")
  let goals = map.points_with_id("goal")
  if starts.length() == 0 || goals.length() == 0 {
    println("map must contain one S start and one G goal")
    return
  }
  let actor = starts[0]
  let goal = goals[0]
  let move_budget = 5
  let selected_target = @pixelkit.point(4, 1)
  let reachable = @pixelkit.bfs_reachable(map, actor, move_budget).unwrap()
  if !reachable.contains(selected_target) {
    println("selected target is outside this turn's movement range")
    return
  }
  let path = @pixelkit.astar(map, actor, selected_target).unwrap().unwrap()
  println("turn: 1")
  println("actor: (\{actor.x()}, \{actor.y()})")
  println("goal: (\{goal.x()}, \{goal.y()})")
  println("move budget: \{move_budget}")
  println("reachable cells: \{reachable.length()}")
  println("selected target: (\{selected_target.x()}, \{selected_target.y()})")
  println("planned movement cost: \{movement_cost(map, path)}")
  println(render_turn_map(map, reachable, path))
}
