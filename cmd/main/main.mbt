///| Minimal runnable demo for the package.
fn main {
  let source = (
    #|S.#
    #|..G
  )
  let map = @pixelkit.parse_ascii_map(source).unwrap()
  println("map: \{map.width()}x\{map.height()}")
  println("start walkable: \{map.is_walkable(@pixelkit.point(0, 0))}")
}
