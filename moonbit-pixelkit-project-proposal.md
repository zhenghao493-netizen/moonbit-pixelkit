# moonbit-pixelkit 项目申报书

## 基本信息

- 项目名称：moonbit-pixelkit
- GitHub 仓库链接：https://github.com/zhenghao493-netizen/moonbit-pixelkit
- GitLink 仓库链接：https://www.gitlink.org.cn/ttxiangshang/moonbit-pixelkit
- Mooncakes 发布页：https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit
- 项目方向：MoonBit 2D 网格地图解析、路径搜索与战术移动预览工具库
- 项目性质：原创 MoonBit 开源项目
- 开源许可证：MIT

## 项目简介

moonbit-pixelkit 是一个面向 2D 像素游戏、战棋原型、迷宫/Roguelike Demo 和算法教学场景的 MoonBit 工具库。项目提供轻量的 tile map 数据结构、ASCII/CSV 地图解析、可通行性查询、移动代价、BFS 可达区域搜索与累计代价、A* 路径搜索、高层移动预览、路径代价统计和调试渲染能力。

项目的目标不是做完整游戏引擎，而是补齐 MoonBit 生态中“小型网格地图 + 路径搜索 + 可视化调试”这一类基础组件。开发者可以用几行 ASCII 或 CSV 描述地图，快速验证角色移动范围、障碍绕行、目标点选择和路径规划逻辑，再把这些能力接入自己的游戏、教学示例或工具原型。

## 适用场景与生态价值

- 2D 像素游戏和战棋类 Demo：快速计算角色本回合可达格子和前往目标点的路径。
- 迷宫、Roguelike 和关卡原型：用 ASCII 文本描述地图，便于测试和复现。
- 算法教学：用 MoonBit 展示 BFS、A*、加权地形和路径代价等基础算法。
- 工具链示例：为 MoonBit 包结构、测试、CI、Mooncakes 发布和可运行示例提供参考。

相比只提供单个 A* 函数的示例项目，moonbit-pixelkit 更强调可复用的工程边界：地图解析、地图查询、搜索选项、结果渲染、测试覆盖和 reviewer-facing showcase 都被组织成一个可安装、可运行、可验证的 MoonBit 包。

## 已实现核心功能

- 统一的 `TileMap` / `Point` / `Tile` 数据结构，支持宽高、tile id、墙体、移动代价和坐标查询。
- ASCII 地图解析，默认支持 `#` 墙体、`.` 空地、`S` 起点和 `G` 目标。
- CSV tile 地图解析，支持自定义墙体 id、默认移动代价和地形代价覆盖。
- 地图查询接口：越界判断、tile 查询、可通行性判断、移动代价查询、按 id 查找点位。
- BFS 可达区域搜索，用于固定移动预算内的角色行动范围预览，并可返回每个可达格子的累计移动代价。
- 高层 `MovementPreview` API，一次性返回可达范围、目标是否可达、目标累计代价和目标路径，减少游戏原型中的胶水代码。
- A* 路径搜索，支持四方向和可选八方向移动。
- 路径代价统计、起点/终点 marker 校验、ASCII 路径与可达区域叠加渲染。
- 可运行示例：ASCII 迷宫、可达区域、加权地图、游戏循环 stub、回合制移动、战术预览。
- 浏览器视觉展示页 `showcase.html`，用于展示战术地图、移动范围、目标路径和完整路线。
- 单元测试覆盖解析、错误输入、地图查询、可达区域、A*、加权路径、渲染和边界行为。
- GitHub Actions CI 覆盖 `moon check` 和 `moon test`。

## 交付物与验收方式

仓库已提供以下可验收材料：

- README：项目目标、快速开始、API 概览、示例命令和发布说明。
- `ACCEPTANCE.md`：面向评审的验证命令、功能覆盖和边界说明。
- `CHANGELOG.md`：版本变更记录。
- `LICENSE`：MIT 开源许可证。
- `examples/`：多个可直接运行的 MoonBit 示例。
- `showcase.html`：可在浏览器打开的视觉展示页面。
- Mooncakes 0.1.0 发布页：https://mooncakes.io/docs/ttxiangshang/moonbit-pixelkit

推荐验收命令：

```bash
moon check
moon test
moon package
moon run examples/tactical_preview
```

视觉展示可通过浏览器打开仓库根目录的 `showcase.html`，或在本地启动静态服务后访问该页面。

## 原创性与开源合规说明

本项目为原创 MoonBit 实现，不是对某个已有库的直接移植。项目使用的 BFS、A* 等属于通用算法思想；具体 API 设计、数据结构组织、示例代码、测试用例、文档和 MoonBit 实现均由本项目独立完成。

当前仓库未引入第三方源代码、私有代码或商业代码。如后续参考其他开源项目的接口设计、测试数据或示例组织方式，将在 README 或专门文档中补充原项目名称、链接、许可证和参考范围，确保来源清晰、许可证兼容。

## 后续计划

- 发布包含 helper API 与 showcase 的 0.1.1 版本到 Mooncakes。
- 增加结构化错误类型，替代当前字符串错误。
- 继续补充面向编辑器/关卡工具的地图预览和调试辅助能力。
- 评估 Tiled JSON 等常见 2D 地图格式的轻量导入支持。
