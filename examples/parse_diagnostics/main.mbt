///|
/// Show structured parser failures suitable for editors and import tools.
fn main {
  let invalid_source =
    #|S.x
    #|..G
  match @pixelkit.parse_ascii_map_detailed(invalid_source) {
    Ok(_) => println("map parsed")
    Err(@pixelkit.UnknownAsciiTile(row, column, tile)) =>
      println("Unknown tile '\{tile}' at row \{row}, column \{column}")
    Err(error) => println(error.message())
  }

  let map = @pixelkit.parse_ascii_map(
    (
      #|S#G
      #|...
    ),
  ).unwrap()
  match
    map.validate_path_detailed([@pixelkit.point(0, 0), @pixelkit.point(2, 0)]) {
    Err(@pixelkit.IllegalPathStep(index, from, to)) =>
      println(
        "Step \{index} is illegal: (\{from.x()}, \{from.y()}) -> (\{to.x()}, \{to.y()})",
      )
    Err(error) => println(error.message())
    Ok(_) => println("path is valid")
  }
}
