///|
/// Showcase a tactical movement preview with range, planned route, and goal path.
fn main {
  let source =
    #|S......#...G
    #|.####..#....
    #|....#.......
    #|.##.#.####..
    #|....#.......
    #|..###..##...
    #|............
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let actor = map.single_point_with_id("start").unwrap()
  let goal = map.single_point_with_id("goal").unwrap()
  let move_budget = 8
  let selected_target = @pixelkit.point(6, 2)
  let reachable = @pixelkit.bfs_reachable(map, actor, move_budget).unwrap()
  let turn_path = @pixelkit.astar(map, actor, selected_target).unwrap().unwrap()
  let goal_path = @pixelkit.astar(map, actor, goal).unwrap().unwrap()
  println("moonbit-pixelkit tactical preview")
  println("")
  println(
    "Legend: S actor, G goal, # wall, + reachable this turn, * planned path",
  )
  println("")
  println("Input battlefield:")
  println(map.render_ascii())
  println("")
  println("Turn 1 movement range, budget \{move_budget}:")
  println(map.render_ascii_overlay(reachable~))
  println("")
  println("Selected target: (\{selected_target.x()}, \{selected_target.y()})")
  println("Selected target reachable: \{reachable.contains(selected_target)}")
  println("This-turn path cost: \{map.path_cost(turn_path).unwrap()}")
  println(map.render_ascii_overlay(reachable~, path=turn_path))
  println("")
  println("Full route to goal:")
  println("Goal path length: \{goal_path.length()}")
  println("Goal path cost: \{map.path_cost(goal_path).unwrap()}")
  println(map.render_ascii(path=goal_path))
}
