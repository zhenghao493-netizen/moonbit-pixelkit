///|
test "parse ASCII map dimensions and walkability" {
  let source = (
    #|S.#
    #|..G
  )
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
  let source = (
    #|S.#
    #|..G
  )
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
}

///|
test "ASCII parser rejects non-rectangular maps" {
  let source = (
    #|S.
    #|..G
  )
  let result = parse_ascii_map(source)
  inspect(result is Err(_), content="true")
}

///|
test "ASCII parser rejects unknown tiles" {
  let source = (
    #|Sx
    #|.G
  )
  let result = parse_ascii_map(source)
  inspect(result is Err(_), content="true")
}

///|
test "parse CSV map walls and tile ids" {
  let source = (
    #|0,1,2
    #|0,0,3
  )
  let map = parse_csv_map(source).unwrap()
  inspect(map.width(), content="3")
  inspect(map.height(), content="2")
  inspect(map.is_walkable(point(1, 0)), content="false")
  inspect(map.is_walkable(point(2, 0)), content="true")
  debug_inspect(map.movement_cost(point(2, 0)), content="Some(1)")
}

///|
test "neighbors helpers" {
  inspect(neighbors4(point(2, 2)).length(), content="4")
  inspect(neighbors8(point(2, 2)).length(), content="8")
}

///|
test "BFS reachable respects walls and movement budget" {
  let source = (
    #|S..
    #|##.
    #|..G
  )
  let map = parse_ascii_map(source).unwrap()
  let reachable = bfs_reachable(map, point(0, 0), 2).unwrap()
  inspect(reachable.contains(point(0, 0)), content="true")
  inspect(reachable.contains(point(1, 0)), content="true")
  inspect(reachable.contains(point(2, 0)), content="true")
  inspect(reachable.contains(point(2, 1)), content="false")
  inspect(reachable.contains(point(0, 1)), content="false")
}

///|
test "A star finds a path around walls" {
  let source = (
    #|S..
    #|##.
    #|..G
  )
  let map = parse_ascii_map(source).unwrap()
  let path = astar(map, point(0, 0), point(2, 2)).unwrap().unwrap()
  inspect(path.length(), content="5")
  debug_inspect(path[0], content="{ x: 0, y: 0 }")
  debug_inspect(path[path.length() - 1], content="{ x: 2, y: 2 }")
}

///|
test "A star reports unreachable goals" {
  let source = (
    #|S#G
    #|###
    #|...
  )
  let map = parse_ascii_map(source).unwrap()
  let path = astar(map, point(0, 0), point(2, 0)).unwrap()
  debug_inspect(path, content="None")
}

///|
test "A star can use diagonal movement when enabled" {
  let source = (
    #|S.
    #|.G
  )
  let map = parse_ascii_map(source).unwrap()
  let path = astar(
    map,
    point(0, 0),
    point(1, 1),
    options=search_options(allow_diagonal=true),
  ).unwrap().unwrap()
  inspect(path.length(), content="2")
}
