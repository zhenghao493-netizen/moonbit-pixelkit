///|
let benchmark_grid_size = 32

///|
test "bench A* open grid 32x32" (it : @bench.T) {
  let map = benchmark_open_map(benchmark_grid_size)
  let start = @pixelkit.point(0, 0)
  let goal = @pixelkit.point(benchmark_grid_size - 1, benchmark_grid_size - 1)
  it.bench(fn() {
    let path = @pixelkit.astar(map, start, goal).unwrap().unwrap()
    it.keep(path.length())
  })
}

///|
test "bench Dijkstra reachability open grid 32x32" (it : @bench.T) {
  let map = benchmark_open_map(benchmark_grid_size)
  let start = @pixelkit.point(0, 0)
  let max_cost = (benchmark_grid_size - 1) * 2
  it.bench(fn() {
    let reachable = @pixelkit.bfs_reachable_with_costs(map, start, max_cost).unwrap()
    it.keep(reachable.length())
  })
}

///|
test "bench movement preview open grid 32x32" (it : @bench.T) {
  let map = benchmark_open_map(benchmark_grid_size)
  let start = @pixelkit.point(0, 0)
  let target = @pixelkit.point(benchmark_grid_size - 1, benchmark_grid_size - 1)
  let max_cost = (benchmark_grid_size - 1) * 2
  it.bench(fn() {
    let preview = @pixelkit.movement_preview(map, start, target, max_cost).unwrap()
    it.keep(preview.target_reachable())
  })
}
