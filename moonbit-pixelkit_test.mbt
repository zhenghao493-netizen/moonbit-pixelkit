///|
test "parse ASCII map dimensions and walkability" {
  let source =
    #|S.#
    #|..G
  let result = parse_ascii_map(source)
  let map = result.unwrap()
  inspect(map.width(), content="3")
  inspect(map.height(), content="2")
  inspect(map.is_walkable(point(0, 0)), content="true")
  inspect(map.is_walkable(point(2, 0)), content="false")
  inspect(map.is_walkable(point(2, 1)), content="true")
}

///|
test "tile accessors and id lookup" {
  let source =
    #|S.#
    #|..G
  let map = parse_ascii_map(source).unwrap()
  let start_points = map.points_with_id("start")
  let goal_points = map.points_with_id("goal")
  inspect(start_points.length(), content="1")
  inspect(goal_points.length(), content="1")
  debug_inspect(start_points[0], content="{ x: 0, y: 0 }")
  debug_inspect(goal_points[0], content="{ x: 2, y: 1 }")
  let wall = map.tile_at(point(2, 0)).unwrap()
  inspect(wall.id(), content="#")
  inspect(wall.is_wall(), content="true")
  inspect(wall.cost(), content="0")
  debug_inspect(
    map.first_point_with_id("start"),
    content="Some({ x: 0, y: 0 })",
  )
  debug_inspect(map.first_point_with_id("missing"), content="None")
  debug_inspect(
    map.single_point_with_id("goal").unwrap(),
    content="{ x: 2, y: 1 }",
  )
  inspect(map.single_point_with_id(".") is Err(_), content="true")
}

///|
test "ASCII parser rejects non-rectangular maps" {
  let source =
    #|S.
    #|..G
  let result = parse_ascii_map(source)
  inspect(result is Err(_), content="true")
}

///|
test "ASCII parser rejects unknown tiles" {
  let source =
    #|Sx
    #|.G
  let result = parse_ascii_map(source)
  inspect(result is Err(_), content="true")
}

///|
test "ASCII parser rejects empty maps" {
  inspect(parse_ascii_map("") is Err(_), content="true")
}

///|
test "ASCII parser accepts CRLF and trailing newline" {
  let map = parse_ascii_map("S.\r\n.G\r\n").unwrap()
  inspect(map.width(), content="2")
  inspect(map.height(), content="2")
  debug_inspect(map.points_with_id("goal")[0], content="{ x: 1, y: 1 }")
}

///|
test "parse CSV map walls and tile ids" {
  let source =
    #|0,1,2
    #|0,0,3
  let map = parse_csv_map(source).unwrap()
  inspect(map.width(), content="3")
  inspect(map.height(), content="2")
  inspect(map.is_walkable(point(1, 0)), content="false")
  inspect(map.is_walkable(point(2, 0)), content="true")
  debug_inspect(map.movement_cost(point(2, 0)), content="Some(1)")
}

///|
test "CSV parser supports terrain costs" {
  let source =
    #|0,2,3
    #|1,0,2
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("2", 4), terrain_cost("3", 8)]),
  ).unwrap()
  debug_inspect(map.movement_cost(point(0, 0)), content="Some(1)")
  debug_inspect(map.movement_cost(point(1, 0)), content="Some(4)")
  debug_inspect(map.movement_cost(point(2, 0)), content="Some(8)")
  inspect(map.is_walkable(point(0, 1)), content="false")
}

///|
test "CSV parser rejects invalid dimensions and costs" {
  let non_rect =
    #|0,1
    #|0,1,2
  inspect(parse_csv_map(non_rect) is Err(_), content="true")
  let bad_options = csv_options(terrain_costs=[terrain_cost("2", 0)])
  inspect(
    parse_csv_map_with_options("0,2", bad_options) is Err(_),
    content="true",
  )
}

///|
test "CSV parser accepts CRLF and trailing newline" {
  let map = parse_csv_map("0,1\r\n2,3\r\n").unwrap()
  inspect(map.width(), content="2")
  inspect(map.height(), content="2")
  inspect(map.is_walkable(point(1, 0)), content="false")
}

///|
test "neighbors helpers" {
  inspect(neighbors4(point(2, 2)).length(), content="4")
  inspect(neighbors8(point(2, 2)).length(), content="8")
}

///|
test "BFS reachable respects walls and movement budget" {
  let source =
    #|S..
    #|##.
    #|..G
  let map = parse_ascii_map(source).unwrap()
  let reachable = bfs_reachable(map, point(0, 0), 2).unwrap()
  inspect(reachable.contains(point(0, 0)), content="true")
  inspect(reachable.contains(point(1, 0)), content="true")
  inspect(reachable.contains(point(2, 0)), content="true")
  inspect(reachable.contains(point(2, 1)), content="false")
  inspect(reachable.contains(point(0, 1)), content="false")
}

///|
test "BFS reachable with costs reports accumulated movement cost" {
  let source =
    #|0,2,3
    #|0,0,0
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("2", 4), terrain_cost("3", 8)]),
  ).unwrap()
  let reachable = bfs_reachable_with_costs(map, point(0, 0), 5).unwrap()
  inspect(reachable.length(), content="5")
  debug_inspect(reachable[0].point(), content="{ x: 0, y: 0 }")
  inspect(reachable[0].cost(), content="0")
  debug_inspect(reachable[1].point(), content="{ x: 1, y: 0 }")
  inspect(reachable[1].cost(), content="4")
  debug_inspect(reachable[2].point(), content="{ x: 0, y: 1 }")
  inspect(reachable[2].cost(), content="1")
  inspect(
    reachable.map(cell => cell.point()).contains(point(2, 0)),
    content="false",
  )
}

///|
test "Dijkstra reachability keeps the lowest weighted route" {
  let source =
    #|0,9,0
    #|0,0,0
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("9", 9)]),
  ).unwrap()
  let reachable = bfs_reachable_with_costs(map, point(0, 0), 10).unwrap()
  let mut target_cost = -1
  for cell in reachable {
    if cell.point() == point(2, 0) {
      target_cost = cell.cost()
    }
  }
  // The direct route costs 10 through tile 9; the lower route costs 4.
  inspect(target_cost, content="4")
}

///|
test "movement preview combines range target cost and path" {
  let source =
    #|0,2,3
    #|0,0,0
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("2", 4), terrain_cost("3", 8)]),
  ).unwrap()
  let preview = movement_preview(map, point(0, 0), point(1, 0), 5).unwrap()
  debug_inspect(preview.start(), content="{ x: 0, y: 0 }")
  debug_inspect(preview.target(), content="{ x: 1, y: 0 }")
  inspect(preview.max_cost(), content="5")
  inspect(preview.reachable().length(), content="5")
  inspect(preview.reachable_points().contains(point(0, 1)), content="true")
  inspect(preview.target_reachable(), content="true")
  debug_inspect(preview.target_cost(), content="Some(4)")
  debug_inspect(preview.path_cost(), content="Some(4)")
  debug_inspect(
    preview.path().unwrap(),
    content="[{ x: 0, y: 0 }, { x: 1, y: 0 }]",
  )
}

///|
test "movement preview reports targets outside budget without a path" {
  let source =
    #|0,2,3
    #|0,0,0
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("2", 4), terrain_cost("3", 8)]),
  ).unwrap()
  let preview = movement_preview(map, point(0, 0), point(2, 0), 5).unwrap()
  inspect(preview.target_reachable(), content="false")
  debug_inspect(preview.target_cost(), content="None")
  debug_inspect(preview.path(), content="None")
}

///|
test "movement preview rejects blocked targets" {
  let source =
    #|S#
    #|.G
  let map = parse_ascii_map(source).unwrap()
  inspect(
    movement_preview(map, point(0, 0), point(1, 0), 2) is Err(_),
    content="true",
  )
}

///|
test "validate path reports steps and cost" {
  let source =
    #|S..
    #|##.
    #|..G
  let map = parse_ascii_map(source).unwrap()
  let path = astar(map, point(0, 0), point(2, 2)).unwrap().unwrap()
  let report = map.validate_path(path).unwrap()
  inspect(report.steps(), content="4")
  inspect(report.cost(), content="4")
}

///|
test "validate path rejects illegal steps out of bounds and blocked tiles" {
  let source =
    #|S#G
    #|..#
  let map = parse_ascii_map(source).unwrap()
  inspect(
    map.validate_path([point(0, 0), point(2, 0)]) is Err(_),
    content="true",
  )
  inspect(
    map.validate_path([point(0, 0), point(1, 0)]) is Err(_),
    content="true",
  )
  inspect(
    map.validate_path([point(0, 0), point(-1, 0)]) is Err(_),
    content="true",
  )
}

///|
test "BFS rejects invalid starts and budgets" {
  let source =
    #|S#
    #|.G
  let map = parse_ascii_map(source).unwrap()
  inspect(bfs_reachable(map, point(1, 0), 2) is Err(_), content="true")
  inspect(bfs_reachable(map, point(0, 0), -1) is Err(_), content="true")
}

///|
test "A star finds a path around walls" {
  let source =
    #|S..
    #|##.
    #|..G
  let map = parse_ascii_map(source).unwrap()
  let path = astar(map, point(0, 0), point(2, 2)).unwrap().unwrap()
  inspect(path.length(), content="5")
  debug_inspect(path[0], content="{ x: 0, y: 0 }")
  debug_inspect(path[path.length() - 1], content="{ x: 2, y: 2 }")
}

///|
test "render ASCII overlays path" {
  let source =
    #|S..
    #|##.
    #|..G
  let map = parse_ascii_map(source).unwrap()
  let path = astar(map, point(0, 0), point(2, 2)).unwrap().unwrap()
  inspect(
    map.render_ascii(path~),
    content=(
      #|S**
      #|##*
      #|..G
    ),
  )
}

///|
test "render ASCII overlays reachable cells and paths" {
  let source =
    #|S..
    #|##.
    #|..G
  let map = parse_ascii_map(source).unwrap()
  let reachable = bfs_reachable(map, point(0, 0), 2).unwrap()
  let path = astar(map, point(0, 0), point(2, 2)).unwrap().unwrap()
  inspect(
    map.render_ascii_overlay(reachable~, path~),
    content=(
      #|S**
      #|##*
      #|..G
    ),
  )
}

///|
test "path cost sums movement after the starting cell" {
  let source =
    #|0,2,3
    #|0,0,0
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("2", 4), terrain_cost("3", 8)]),
  ).unwrap()
  let path = [point(0, 0), point(1, 0), point(2, 0)]
  inspect(map.path_cost(path).unwrap(), content="12")
  inspect(map.path_cost([point(0, 0), point(9, 9)]) is Err(_), content="true")
  inspect(map.path_cost([point(0, 0), point(0, 0)]) is Ok(_), content="true")
}

///|
test "A star reports unreachable goals" {
  let source =
    #|S#G
    #|###
    #|...
  let map = parse_ascii_map(source).unwrap()
  let path = astar(map, point(0, 0), point(2, 0)).unwrap()
  debug_inspect(path, content="None")
}

///|
test "A star rejects blocked endpoints" {
  let source =
    #|S#G
    #|...
  let map = parse_ascii_map(source).unwrap()
  inspect(astar(map, point(1, 0), point(2, 0)) is Err(_), content="true")
  inspect(astar(map, point(0, 0), point(1, 0)) is Err(_), content="true")
}

///|
test "A star can use diagonal movement when enabled" {
  let source =
    #|S.
    #|.G
  let map = parse_ascii_map(source).unwrap()
  let path = astar(
      map,
      point(0, 0),
      point(1, 1),
      options=search_options(allow_diagonal=true),
    )
    .unwrap()
    .unwrap()
  inspect(path.length(), content="2")
}

///|
test "diagonal movement does not cut through blocked corners by default" {
  let source =
    #|S#
    #|#G
  let map = parse_ascii_map(source).unwrap()
  let options = search_options(allow_diagonal=true)
  debug_inspect(
    astar(map, point(0, 0), point(1, 1), options~).unwrap(),
    content="None",
  )
  inspect(
    map.validate_path([point(0, 0), point(1, 1)], options~) is Err(_),
    content="true",
  )
}

///|
test "diagonal movement can opt into corner cutting" {
  let source =
    #|S#
    #|#G
  let map = parse_ascii_map(source).unwrap()
  let options = search_options(allow_diagonal=true, allow_corner_cutting=true)
  let path = astar(map, point(0, 0), point(1, 1), options~).unwrap().unwrap()
  inspect(path.length(), content="2")
  inspect(map.validate_path(path, options~) is Ok(_), content="true")
}

///|
test "A star diagonal movement still respects terrain costs" {
  let source =
    #|0,9,0
    #|0,0,0
  let map = parse_csv_map_with_options(
    source,
    csv_options(terrain_costs=[terrain_cost("9", 9)]),
  ).unwrap()
  let path = astar(
      map,
      point(0, 0),
      point(2, 0),
      options=search_options(allow_diagonal=true),
    )
    .unwrap()
    .unwrap()
  // Direct path through (1, 0) costs 10; diagonal detour costs 2.
  debug_inspect(
    path,
    content="[{ x: 0, y: 0 }, { x: 1, y: 1 }, { x: 2, y: 0 }]",
  )
}
