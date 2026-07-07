///| BFS reachable-area example for turn-based movement.
fn main {
  let source = (
    #|S..
    #|##.
    #|..G
  )
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  let reachable = @pixelkit.bfs_reachable(map, @pixelkit.point(0, 0), 2).unwrap()
  println("reachable cells within cost 2: \{reachable.length()}")
}
