///|
/// Show structured parser failures suitable for editors and import tools.
fn main {
  let source =
    #|S.x
    #|..G
  match @pixelkit.parse_ascii_map_detailed(source) {
    Ok(_) => println("map parsed")
    Err(@pixelkit.UnknownAsciiTile(row, column, tile)) =>
      println("Unknown tile '\{tile}' at row \{row}, column \{column}")
    Err(error) => println(error.message())
  }
}
