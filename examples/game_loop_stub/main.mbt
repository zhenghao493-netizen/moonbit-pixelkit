///| A small game-loop style pathfinding stub.
fn main {
  let source = (
    #|S...
    #|##..
    #|...G
  )
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let starts = map.points_with_id("start")
  let goals = map.points_with_id("goal")
  if starts.length() == 0 || goals.length() == 0 {
    println("map must contain one S start and one G goal")
    return
  }
  let start = starts[0]
  let goal = goals[0]
  let path = @pixelkit.astar(map, start, goal).unwrap().unwrap()
  let next_step = if path.length() > 1 { path[1] } else { start }
  println("start: (\{start.x()}, \{start.y()})")
  println("goal: (\{goal.x()}, \{goal.y()})")
  println("next step: (\{next_step.x()}, \{next_step.y()})")
  println(map.render_ascii(path=path))
}
