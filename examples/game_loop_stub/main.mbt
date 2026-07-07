///| A small game-loop style pathfinding stub.
fn main {
  let source = (
    #|S...
    #|##..
    #|...G
  )
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let start = map.points_with_id("start")[0]
  let goal = map.points_with_id("goal")[0]
  let path = @pixelkit.astar(map, start, goal).unwrap().unwrap()
  let next_step = if path.length() > 1 { path[1] } else { start }
  println("start: (\{start.x()}, \{start.y()})")
  println("goal: (\{goal.x()}, \{goal.y()})")
  println("next step: (\{next_step.x()}, \{next_step.y()})")
  println(map.render_ascii(path=path))
}
