///| A* pathfinding over an ASCII maze.
fn main {
  let source = (
    #|S..
    #|##.
    #|..G
  )
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let path = @pixelkit.astar(
    map,
    @pixelkit.point(0, 0),
    @pixelkit.point(2, 2),
  ).unwrap().unwrap()
  println("ascii_maze path length: \{path.length()}")
}
