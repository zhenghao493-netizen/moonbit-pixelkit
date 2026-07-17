///|
/// Import a Tiled JSON battlefield, then preview a weighted tactical move.
fn main {
  let source =
    #|{
    #|  "orientation": "orthogonal",
    #|  "width": 6,
    #|  "height": 5,
    #|  "layers": [
    #|    {
    #|      "name": "Collision",
    #|      "type": "tilelayer",
    #|      "data": [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0]
    #|    },
    #|    {
    #|      "name": "Terrain",
    #|      "type": "tilelayer",
    #|      "data": [0, 0, 2, 2, 0, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0]
    #|    }
    #|  ]
    #|}
  let options = @pixelkit.tiled_options(terrain_layer=Some("Terrain"), terrain_costs=[
    @pixelkit.terrain_cost("2", 3),
    @pixelkit.terrain_cost("3", 5),
  ])
  let map = @pixelkit.parse_tiled_json(source, options~).unwrap()
  let actor = @pixelkit.point(0, 0)
  let target = @pixelkit.point(5, 4)
  let preview = @pixelkit.movement_preview(map, actor, target, 14).unwrap()
  let reachable = preview.reachable_points()
  let path = preview.path().unwrap()

  println("Tiled JSON tactical preview")
  println("")
  println("Imported map (# wall, + reachable, * selected route):")
  println(map.render_ascii_overlay(reachable~, path~))
  println("")
  println("Target reachable: \{preview.target_reachable()}")
  println("Selected route cost: \{preview.path_cost().unwrap()}")
  println("Selected route steps: \{path.length() - 1}")
}
