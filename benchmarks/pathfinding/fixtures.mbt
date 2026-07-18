///|
pub fn benchmark_open_map(size : Int) -> @pixelkit.TileMap {
  let row = "0,".repeat(size - 1) + "0"
  let source = (row + "\n").repeat(size - 1) + row
  @pixelkit.parse_csv_map(source).unwrap()
}
