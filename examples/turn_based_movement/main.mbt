///|
/// Turn-based movement example for a grid game.
fn main {
  let source =
    #|S....
    #|##.#.
    #|...#G
    #|.....
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let actor = map.single_point_with_id("start").unwrap()
  let goal = map.single_point_with_id("goal").unwrap()
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
  println("planned movement cost: \{map.path_cost(path).unwrap()}")
  println(map.render_ascii_overlay(reachable~, path~))
}
