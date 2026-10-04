# DUI Dynamic Topbar HUD — 更新记录 / 与原始设计的差异

> 这份文件记录每次实测后按需求改动的结论，README 里的旧表格可能滞后，以本文为准。

## 2026-10-03 第 5 轮（本次）

### 1. 菜单候选：24 项（去掉"核弹"，把民工/军工/船坞合并成"工业"）

| # | 指标 | 格子数值 | 图标（原版精灵 / 尺寸） |
| --- | --- | --- | --- |
| 1 | 每日政治点 | `[?political_power_daily|+=2]` | `GFX_pol_power` 18×19 |
| 2 | 每日稳定度变化 | 每日快照差值，`+0.05% / 天` | `GFX_stability_texticon` 18×18 |
| 3 | 每日战争支持度变化 | 每日快照差值 | `GFX_war_support_icon` 26×24 |
| 4 | 每日指挥点 | `[?command_power_daily|+=2]` | `GFX_command_power` 24×22 |
| 5 | 政治偏执度（仅苏联） | 0–100% | `GFX_FOCUS_FILTER_SOV_POLITICAL_PARANOIA` 27×27 |
| 6 | 可用人力 | `[?manpower|*]` | `GFX_manpower_icon` 27×27 |
| 7 | 征兵率 | `[?conscription_ratio|%0]` | `GFX_manpower_texticon` 18×16 |
| 8 | 野战兵力 | `[?deployed_army_manpower_k|0]K` | `GFX_army_shield_bg` 18×16 |
| 9 | 陆军师 | `[?num_armies|0]` | `GFX_divisions` 17×27 |
| 10 | 陆军营 | `[?num_battalions|0]` | `GFX_country_army_battle` 29×26 |
| 11 | 作战飞机 | `[?num_deployed_planes|0]` | `GFX_technology_specialization_air` 20×20 |
| 12 | 舰船 | `[?num_ships|0]` | `GFX_naval_combat_icon` 25×25 |
| 13 | 步兵装备库存 | `[?num_equipment@infantry_equipment|0]` | `GFX_raid_equipment_generic` 30×30 |
| 14 | 累计伤亡 | `[?casualties|*]` | `GFX_killed_units_icon` 19×21 |
| 15 | 投降进度 | `[?surrender_progress|%0]` | `GFX_victory_points` 18×18 |
| 16 | 战争分数 | `[?any_war_score|0]` | `GFX_war_score` 18×18 |
| 17 | 敌我陆军比 | `[?enemies_strength_ratio|2]` | `GFX_wargoal_icon` 29×26 |
| 18 | 世界紧张度 | `[?global.threat|%0]` | `GFX_world_tension_icon` 29×25 |
| 19 | 陆军经验 | `[?army_experience|0]` | `GFX_army_experience` 14×14 |
| 20 | 海军经验 | `[?navy_experience|0]` | `GFX_navy_experience` 14×14 |
| 21 | 空军经验 | `[?air_experience|0]` | `GFX_air_experience` 14×14 |
| 22 | **工业** | `民工/军工/船坞` 三个数字 | `GFX_industry_texticon` 21×21 |
| 23 | 燃料储量 | `[?fuel_k|0]K` | `GFX_fuel` 24×24 |
| 24 | 燃料比例 | `[?fuel_ratio|%0]` | `GFX_fuel_texticon` 18×18 |

- **核弹**：按要求从 mod 里完全移除（token 与 4 个文本键都删掉了），因为原版核弹提示要
  解锁科技后才出现，不属于常驻可选项。
- 下面这些仍保留 token 与文本（老存档里已绑定的格子不会变空白），但**不再出现在菜单里**：
  政治点、总人口、空闲民用工厂、钢铁/铝/钨/铬/橡胶/石油盈余、已研发科技、研究槽、
  以及被合并掉的 民工/军工/船坞 三项。

### 2. 每天记录稳定度 / 战争支持度的"日变化"

`on_actions` 里新增 `on_daily` → `dui_topbar_daily_snapshot`：每天把
`stability` / `has_war_support` 与上一次的快照相减（×100 得到百分比），
写进 `dui_stability_delta` / `dui_war_support_delta`，
再由脚本化本地化 `GetDUIStabilityChange` / `GetDUIWarSupportChange` 显示成
`+0.05% / 天`。

### 3. 格子交互（对齐黑冰）

| 操作 | 效果 |
| --- | --- |
| 左键点格子 | 选中该格子并弹出指标菜单；**再点一次同一个格子 = 关闭菜单**（黑冰那种开关式） |
| 右键点格子 | 移除该格子，后面的格子自动补位 |
| 菜单里左键点条目 | 把该指标绑定到选中的格子 |
| 菜单里 Shift + 左键 | 绑定并再新增一个空格子 |
| 左键点「+」 | 新增一个空格子 |
| 右键「+」 | 折叠 / 展开整条信息条 |
| Shift + 右键「+」 | 恢复默认布局 |
| 悬停格子 / 条目 | 显示该指标的说明与相关数值（原版 tooltip 样式） |

### 4. 显示相关的修复

- **选中提示**：原来用 `GFX_decisions_glow`（110×41，比格子还大）画高亮，看起来是一个
  跑出格子的紫色方框。现改为原版 `GFX_execute_battle_plan_glow`（98×28，带脉动动画），
  正好贴着 96×26 的格子。
- **菜单条目**：条目框从 170×26 放大到 **180×28**，图标 x=8 / y=4、文字 x=34，
  格位 188×34（即行列之间留出 8px / 6px 间距），框能完整包住图标和文字。
- **图标统一**：所有指标改用原版 14–30px 的小图标，格子里统一放在 `x = 4 y = 3`
  （水平居左、垂直居中），数值区域 `maxWidth = 67`。
- **顶栏内的 8 个格子**：保持原版 `GFX_generic_box_96` 的 96×26（= 原版人力框尺寸），
  第 1 行 5 格（x 1040–1536）、第 2 行 3 格（x 1240–1536），「+」按钮与第 8 格同位置
  （两者永不同时显示）。

### 5. 坐标（1920 宽基准，`# LAYOUT` 注释同步）

| 元素 | 值 |
| --- | --- |
| 第 1 行 槽位 0–4 | `y = 5`，`x = -480 / -580 / -680 / -780 / -880` |
| 第 2 行 槽位 5–7 | `y = 43`，`x = -480 / -580 / -680` |
| 「+」按钮 | `x = -680 y = 43` |
| 菜单面板 | `x = -972 y = 80`，`size = 588 × 338` |
| 菜单网格容器 | `x = -176 y = 54`（= `12 - 188`，抵消引擎把首个条目右移一个格位） |
| 网格 | `slotsize = 188 × 34`，3 列 × 8 行 = 24 格 |
| 菜单条目 | `size = 180 × 28` |

> 仍未 100% 确认的一点：动态列表的横向起点到底是"容器左边 + 一个**格位宽度**"还是
> "+ 一个**条目宽度**"。两者差 8px，本轮按"格位宽度"处理（`x = 12 - 188`）。
> 如果实测发现整排条目偏左/偏右 8px，把 `dui_menu_grid_container` 的 `x` 改成 `-168`
> 或 `-188` 即可，其它都不用动。

## 2026-10-04 第 9 轮：图标改用 Black Ice 的资源（统一尺寸）

自制美术放弃后，图标改从**黑冰（工坊 1851181613）**复制，选的是它自己那套
`dynamic_topbar` / `texticons` 小图标（尺寸集中在 19–24px，比原版混用 16–27px 整齐得多）。
为避免与黑冰本体重名，复制后统一命名 `GFX_dui_bi_*`，文件放在 `gfx/dui_icons/`。

| 指标 | 复制的黑冰贴图 | 尺寸 |
| --- | --- | --- |
| 每日政治点 | `interface/topbar/dynamic_topbar/topbar_political_power.dds` | 19×20 |
| 稳定度/日 | `.../topbar_stability.dds` | 24×21 |
| 战争支持度/日 | `.../topbar_war_support.dds` | 21×20 |
| 指挥点/日 | `.../topbar_command_power.dds` | 22×21 |
| 政治偏执度 | `texticons/political_violence_texticon.dds` | 20×16 |
| 征兵率 | `.../topbar_conscription.dds` | 20×22 |
| 已部署陆军 | `interface/field_strength_icon.dds` | 20×22 |
| 陆军师 | `.../topbar_divisions.dds` | 20×22 |
| 陆军营 | `.../topbar_battalions.dds` | 20×22 |
| 作战飞机 | `.../topbar_air_strength.dds` | 20×22 |
| 舰船 | `.../topbar_ships.dds` | 20×22 |
| 步兵装备库存 | `texticons/infantry_equipment_texticon.dds` | 20×16 |
| 累计伤亡 | `.../topbar_casualties.dds` | 20×22 |
| 投降进度 | `.../topbar_surrender_progress.dds` | 20×22 |
| 战争分数 | `.../topbar_warscore.dds` | 20×22 |
| 敌我陆军比 | `.../topbar_strength_ratio.dds` | 20×22 |
| 工业 | `texticons/mil_factory.dds` | 20×16 |

- 精灵定义写在 `interface/dui_icons.gfx`，**必须无 BOM**（有 BOM 会让 HOI4 报
  `Unexpected token: spriteTypes` 并导致图标全部失效）。
- 安装时记得把 `gfx` 文件夹一起复制；如果之前装过自制图标版本，先删掉
  `interface\dui_icons.gfx` 与 `gfx\interface\dui_icons\`，否则会闪退。
- README 里已注明图标来自 Black Ice。

## 2026-10-04 第 8 轮：放弃自制美术（修闪退）

游戏在加载贴图时闪退，`error.log` 指向自制图标：

```
[gfx_dds_loader.cpp:325] Expected more data in the texture mipmaps ... dui_icon_pp_daily.dds
[gfx_dx11.cpp:84] Failed to create 2D texture (height=20, width=80, format=87, mips=0)
```

原因是我用 Python 手写的 DDS 文件头错位（`dwSize` 必须是 124，我多塞了一个字段，
导致引擎把宽度读成 80、mipmap 数读成 20）。虽然已按规范修正并校验通过，
但为了不再冒风险，**彻底放弃自制美术**：

- 删除 `dui_topbar/gfx/interface/dui_icons/`（16 个自制 DDS）与 `interface/dui_icons.gfx`；
- 17 个指标的 `_sprite` 全部改回**原版精灵**直接引用：

| 指标 | 原版精灵 |
| --- | --- |
| 每日政治点 | `GFX_pol_power`（18×19） |
| 稳定度/日 | `GFX_stability_texticon`（18×18） |
| 战争支持度/日 | `GFX_war_support_icon`（26×24） |
| 指挥点/日 | `GFX_command_power`（24×22） |
| 政治偏执度 | `GFX_FOCUS_FILTER_SOV_POLITICAL_PARANOIA`（27×27） |
| 征兵率 | `GFX_manpower_texticon`（18×16） |
| 已部署陆军 | `GFX_technology_specialization_land`（20×20） |
| 陆军师 | `GFX_divisions`（17×27） |
| 陆军营 | `GFX_army_shield_bg`（18×16） |
| 作战飞机 | `GFX_technology_specialization_air`（20×20） |
| 舰船 | `GFX_technology_specialization_naval`（20×20） |
| 步兵装备库存 | `GFX_equipment_icon`（原版顶栏补给框那颗） |
| 累计伤亡 | `GFX_killed_units_icon`（19×21） |
| 投降进度 | `GFX_victory_points`（18×18） |
| 战争分数 | `GFX_war_score`（18×18） |
| 敌我陆军比 | `GFX_in_combat`（18×18） |
| 工业 | `GFX_industry_texticon`（21×21） |

`dui_topbar_dev/make_icons.py` 保留留档，但**不要再执行**。

> 卸载自制美术时要注意：`Copy-Item` 只会覆盖、不会删除旧文件，所以安装目录里
> 必须手动删掉 `interface\dui_icons.gfx` 和 `gfx\` 文件夹，否则仍会闪退。

## 2026-10-03 第 7 轮（本次，对应截图 dtbtest6）

### 1. 修掉"切国家后冒出不想要的信息"

原因是 `dui_topbar_init` 里给每个国家的**默认布局还是旧的那 4 项**（政治点 / 可用人力 /
军用工厂 / 民用工厂）。换成新菜单里的 4 项：

| 槽位 | 默认指标 |
| --- | --- |
| 0 | 每日政治点（`dui_m_pp_daily`） |
| 1 | 每日稳定度变化（`dui_m_stability`） |
| 2 | 工业（`dui_m_industry`） |
| 3 | 苏联 → 政治偏执度；其它国家 → 征兵率 |

> 注意：**已经初始化过的国家（含当前存档）不会自动变**，需要点一次 `+` 右键复位
> （`Shift + 右键`「+」= 恢复默认布局）才会套用新默认。

### 2. 弹窗条目：更宽更扁（贴近黑冰那种横条按钮）

条目 `200 × 26`（原来是 180×28），格位 `208 × 32`（横 8px / 竖 6px 留白），
网格 `624 × 192`，网格容器 `x = 12 - 208 = -196`，面板 `648 × 264`（右边缘仍对齐 1536）。

另外每个条目右端新增一个**数值文本**（`dui_menu_item_value`，用新的
`defined_text GetDUIMenuItemValue` 读该 token 的 `_text`），所以菜单里现在是
「图标 + 名称 + 数值」三段式。

### 3. "工业"格子文本显示错误 → 已修

原因：我把三个数字写进了指标的**名称键**（`dui_m_industry:0 "工业 [?...]/[?...]/[?...]"`），
而菜单是走 `GetTokenLocalizedKey` 取名称的，那里**不会二次解析变量**，所以会显示成
字面量 `[?num_of_civilian_factories|0]/...`。
现在名称只留「工业」，数值一律走 `_text`（格子和菜单右侧的数值都用它）。

### 4. 图标：换成原版小图标 + 统一贴住格子

| 指标 | 图标 | 尺寸 |
| --- | --- | --- |
| 每日政治点 | `GFX_pol_power` | 18×19 |
| 每日稳定度变化 | `GFX_stability_texticon` | 18×18 |
| 每日战争支持度变化 | `GFX_war_support_icon` | 26×24 |
| 每日指挥点 | `GFX_command_power` | 24×22 |
| 政治偏执度 | `GFX_FOCUS_FILTER_SOV_POLITICAL_PARANOIA` | 27×27 |
| 征兵率 | `GFX_manpower_texticon` | 18×16 |
| 已部署陆军 | `GFX_technology_specialization_land` | 20×20 |
| 陆军师 | `GFX_divisions` | 17×27 |
| 陆军营 | `GFX_army_shield_bg` | 18×16 |
| 作战飞机 | `GFX_technology_specialization_air` | 20×20 |
| 舰船 | `GFX_technology_specialization_naval` | 20×20 |
| 步兵装备库存 | **`GFX_equipment_icon`**（原版顶栏"补给"框用的就是它） | ≈20 |
| 累计伤亡 | `GFX_killed_units_icon` | 19×21 |
| 投降进度 | `GFX_victory_points` | 18×18 |
| 战争分数 | `GFX_war_score` | 18×18 |
| 敌我陆军比 | `GFX_in_combat` | 18×18 |
| 工业 | `GFX_industry_texticon` | 21×21 |

图标位置统一 `x = 4`、`y = 1`（菜单里 `x = 8`），因此在 26 高的框里：16–21px 的图标
基本居中且不越界，24–27px 的 4 个（战争支持度/指挥点/偏执度/陆军师）最多越界 1–2px。

### 5. "野战兵力" → 改名"已部署陆军"

它原来的意思确实是**已部署（野战）部队里的人力**，变量 `deployed_army_manpower_k`（单位：千人），
不含训练中的部队。为了不再歧义，名称改成「已部署陆军」，tooltip 里写明"千人 / 不含训练中"。

### 6. 变量核对（回答"黑冰有数据但原版没有"）

跑了 `check_vars.ps1`：菜单里所有数值引用的**都是原版内置的游戏变量**，
没有一个是黑冰自己算出来的（唯一被点名的两个是我们自己写的
`dui_stability_delta` / `dui_war_support_delta`，已加入白名单）。
变化周期方面：政治点/指挥点用原版 `*_daily`（每日），稳定度与战争支持度是我们按天记录差值，
所以文本统一写「每日」；没有需要改成"每周"的项。

## 2026-10-03 第 6 轮（本次）

按「原版顶栏已经直接显示的信息不要再进菜单」的原则，再移出 7 项：

**可用人力**（原版人力框）、**世界紧张度**（原版右上角百分比）、**燃料储量**、**燃料比例**
（原版燃料框与比例条）、**陆军经验 / 海军经验 / 空军经验**（原版三个经验星标）。

菜单现在是 **17 项**（苏联 18 项）：

> 每日政治点 · 每日稳定度变化 · 每日战争支持度变化 · 每日指挥点 ·
> 政治偏执度（仅苏联）· 征兵率 · 野战兵力 · 陆军师 · 陆军营 · 作战飞机 · 舰船 ·
> 步兵装备库存 · 累计伤亡 · 投降进度 · 战争分数 · 敌我陆军比 · 工业（民工/军工/船坞）

> 「工业」严格说也对应原版顶栏那个 `12/12/12`，但上一轮是你明确要求把三项合并成它的，
> 所以保留；如果按同一条规则也要删，说一声我一句话就改。

网格随之缩为 **3 列 × 6 行（容量 18）**：
弹窗 `size = 588 × 270`，网格容器/网格 `564 × 204`，`max_slots_vertical = 6`，
其余坐标（格子、条目、间距）不变。

被移出的这 7 项仍然保留 token 与文本，老存档里已绑定的格子不会变空白。

## 更早的轮次（要点）

- 第 1～2 轮：顶栏格子最初排到顶栏外面（y=104），后来移到栏内；确定 `buttonType`
  不能写 `size`（会报 `Malformed token`）。
- 第 3 轮：坐实 `Orientation = UPPER_RIGHT` 的 `x` 是**左边缘**距屏幕右边的距离
  （左边缘 = 屏幕宽 + x），此前按右边缘写导致所有元素右移一格、弹窗跑出屏幕。
- 第 4 轮：格子尺寸对齐原版（`GFX_generic_box_96` = 96×26，原版数据框统一 26 高）；
  发现动态列表的"首个条目右移一个格位"行为；菜单改成 3 列布局。
