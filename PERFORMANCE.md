# Performance Baseline

`moonbit-pixelkit` includes reproducible microbenchmarks for its two core search paths: A* routing and priority-queue Dijkstra reachability.

Run them from the repository root:

```bash
moon bench benchmarks/pathfinding --release --deny-warn
```

## Scenario

- Grid: 32 x 32 open CSV map.
- Start: `(0, 0)`.
- Goal and movement target: `(31, 31)`.
- Movement budget: `62`, enough to cover the complete grid.
- Setup is outside the timed closure: parsing and map construction are not included in the measurements.

## Development Baseline

Recorded on 2026-07-18 with the command above:

| Benchmark | Mean |
| --- | ---: |
| A* route | 86.33 us |
| Dijkstra reachability | 93.47 us |
| Movement preview | 176.94 us |

The A* benchmark uses the same priority-queue frontier pattern as Dijkstra, while retaining the admissible grid heuristic for weighted terrain. These figures are a reproducibility baseline, not a cross-machine performance promise. Compare changes only with the same MoonBit version, target, hardware, and command. The benchmark suite is intentionally separate from the library package so production consumers do not inherit test-only dependencies.
