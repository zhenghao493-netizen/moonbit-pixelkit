///|
/// Weighted CSV terrain example.
fn main {
  let source =
    #|0,2,2,0
    #|0,1,1,0
    #|0,0,0,0
  let map = @pixelkit.parse_csv_map_with_options(
    source,
    @pixelkit.csv_options(terrain_costs=[@pixelkit.terrain_cost("2", 5)]),
  ).unwrap()
  let path = @pixelkit.astar(map, @pixelkit.point(0, 0), @pixelkit.point(3, 0))
    .unwrap()
    .unwrap()
  let mut total_cost = 0
  for index in 1..<path.length() {
    total_cost = total_cost + map.movement_cost(path[index]).unwrap()
  }
  println("weighted_grid path length: \{path.length()}")
  println("weighted_grid movement cost: \{total_cost}")
}
