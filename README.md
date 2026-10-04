# DUI Dynamic Topbar HUD（钢铁雄心4 顶栏数据 HUD）

一个让**玩家自选**顶栏显示哪些数据的 HOI4 模组：8 个格子可各自绑定一个指标，点击格子打开选择菜单，
数值随游戏实时变化；消耗类指标（装备结余等）按**赤字红 / 盈余绿**着色。

> 开发过程中的流程、踩过的坑与解决办法全部记录在仓库的 `dui_topbar_docs/`（若未随仓库上传，请见 `dui_topbar/CHANGELOG.md`）。

---

## 功能

| 分类 | 功能 |
| --- | --- |
| 顶栏格子 | 8 个格子，左键点击绑定/更换指标，右键移除；Shift+左键绑定并追加空格子 |
| 选择菜单 | 点格子弹出「顶栏数据」；菜单内含变化类、军事类、工业类指标，条目带图标 |
| 装备库存（▼） | 菜单里的固定入口，点开后可选 **12 个装备大类**（步兵装备/支援装备/火炮/反坦克/防空/火箭炮/装甲车/摩托化/机械化/轻中重型坦克） |
| 装备结余 | 每个大类显示**结余**：负数=缺口（红）、非负=盈余（绿），口径见下文"数据来源" |
| 时间口径 | 政治点/指挥点按**日**；稳定度/战争支持度按**周**（原版本身就是 `*_weekly` 修饰符结算） |
| 战时项 | 投降进度、战争分数、敌我陆军比 仅在**开战后**出现在菜单里 |
| 自适应 | 全部元素锚定屏幕边缘（`Orientation = UPPER_RIGHT/LEFT`）并挂在原版 `top_bar` 上，分辨率变化不影响版面关系 |

## 安装

1. 把 `dui_topbar` 文件夹复制到游戏的 mod 目录：

   ```
   C:\Users\<你的用户名>\Documents\Paradox Interactive\Hearts of Iron IV\mod\top_barUI
   ```

2. 在 `mod` 目录下建立 `top_barUI.mod`（本仓库未包含该文件），内容：

   ```
   version="1.0.0"
   tags={
       "Graphics"
       "Utilities"
   }
   name="DUI Dynamic Topbar HUD"
   picture="thumbnail.png"
   supported_version="1.19.*"
   path="C:/Users/<你的用户名>/Documents/Paradox Interactive/Hearts of Iron IV/mod/top_barUI"
   ```

3. 启动器里勾选 **DUI Dynamic Topbar HUD**，进游戏即可在顶栏看到格子。

> 更新版本时请**整包覆盖**（`Remove-Item` 后 `Copy-Item`），只复制单个文件容易留下旧文件导致"改了没效果"。

## 目录结构

```
dui_topbar/                       ← 模组本体（复制到 mod/top_barUI）
  descriptor.mod  thumbnail.png  README.md  CHANGELOG.md
  common/
    scripted_guis/                ← 窗口逻辑（顶栏 HUD、选择菜单）
    scripted_effects/             ← 初始化、菜单填充、装备快照（历史遗留）
    scripted_localisation/        ← 动态文本（取值都在这里做）
    synchronized_dynamic_tokens/  ← 本模组的动态 token 清单
    on_actions/                   ← on_startup 初始化
  interface/                      ← 界面布局与控制台精灵定义
  gfx/                            ← 图标贴图
  localisation/                   ← 中英文文本
dui_topbar_dev/                   ← 开发工具
  validate.ps1                    ← 结构/引用/精灵/容量/编码自检
  check_vars.ps1                  ← 变量名是否真实存在
dui_topbar_docs/                  ← 开发过程记录（流程、问题与解决、接口来源、硬性规范）
```

## 数据来源（原版优先，其次工坊参考）

| 指标 | 取数写法 | 出处 |
| --- | --- | --- |
| 每日政治点 | `political_power_daily` | 原版 `common/decisions`（`political_power_daily > 0.5`） |
| 稳定度变化/周 | `modifier@stability_weekly` | 原版 `common/decisions/AST.txt:1266` |
| 战争支持变化/周 | `modifier@war_support_weekly` | 原版 `common/decisions/CZE.txt` |
| 每日指挥点 | `modifier@command_power_gain` | 原版 `localisation/english/modifiers_l_english.yml:1082` |
| 工业（民工/军工/船坞） | `num_of_civilian_factories` / `num_of_military_factories` / `num_of_naval_factories` | 原版决策与本地化多处 |
| 战争分数 / 投降进度 / 敌我陆军比 | `any_war_score` / `surrender_progress` / `enemies_strength_ratio` | 原版多处 |
| 政治偏执度 | `SOV_paranoia` | 原版 SOV 系统 |
| **装备结余（12 大类）** | `num_equipment_in_armies@大类 − num_target_equipment_in_armies@大类 + num_equipment@大类` | 黑冰 `common/scripted_localisation/BI_AI_scripted_loc.txt:543-558`、`common/scripted_effects/pulse_effect.txt:154`；原版 `common/achievements.txt:2695` |

**装备结余口径的验证**：与原版「后勤」窗口 `资源` 列同屏对照——步兵装备 后勤 `-18.4K` vs 本模组 `-18555`（差≈0.7%，属数值每日变化造成的漂移）；
原版悬浮提示把"储备"与"陆军师携援"分开显示，两者之差即"库存"，所以结余 =（已装备 − 部队需要）+ 库存。

**已知不可读**（原版未开放给脚本）：引擎的净储备本身、装备产量与消耗；界面上那列数字由引擎直接填入具名元素与本地化参数。

## 开发与验证

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
& .\dui_topbar_dev\validate.ps1     # 结构/引用/精灵/菜单容量/编码（含"粘连行"检查）
& .\dui_topbar_dev\check_vars.ps1   # 变量名是否真实存在（含本模组自建 dui_* 白名单）
```

改完必做：两个自检 **0 问题** → 整包覆盖到 mod 目录 → 先读 `logs/error.log` 里有无 `dui` 报错 → 再看画面。
详细流程与全部历史问题见 `dui_topbar_docs/`。

## 已知问题 / 路线图

- [ ] 选择菜单目前只排出 2 列（声明 3 列），面板右侧留空；
- [ ] 菜单条目内暂不显示数值（只有图标 + 名称），数值需绑定到顶栏格子后查看；
- [ ] 长名称（如"战争支持/周"6 字）在 124px 条目内会换行；
- [ ] 弹窗背景图不随面板尺寸拉伸；
- [ ] 装备入口目前是"替换菜单内容"，尚未做成锚定条目的浮层下拉；
- [ ] 「已部署陆军」使用的 `deployed_army_manpower_k` 仅见于黑冰，需要替换为原版可读数据或移除。

## 第三方资源与致谢

- 界面控件使用**游戏本体原版精灵**（`GFX_generic_box_*`、`GFX_tiled_window2_1b_border`、`GFX_closebutton` 等）；
- 指标图标取自 **Black Ice（创意工坊 1851181613）**，复制时改名为 `GFX_dui_bi_*`；
- 装备大类小图标取自创意工坊 **3792413299**，复制时改名为 `GFX_dui_equip_*`；
- 交互与排版参考 Black Ice 的顶栏实现（`common/scripted_guis/BI_topbar.txt`）。
  若相关作者要求撤下这些贴图，删除 `gfx/` 与 `interface/*.gfx` 并改回原版精灵名即可（见 `dui_topbar/README.md`）。

## 许可

本仓库代码可自由查阅与学习；其中来自第三方模组的贴图版权归原作者，使用时请遵守其条款。

---

## English summary

**DUI Dynamic Topbar HUD** is a Hearts of Iron IV mod that lets the player choose which values appear in the top bar.
Eight slots can each be bound to a metric; clicking a slot opens a picker. Equipment categories show a **surplus/deficit
balance** (red = deficit, green = surplus) computed as `fielded − needed + stock`, verified against the vanilla
logistics window. Stability and war support use the weekly modifiers (`*_weekly`). War-related metrics only appear once
at war. Interface elements are anchored to the screen edges and attached to the vanilla `top_bar`, so the layout is
resolution independent. See `dui_topbar_docs/` for the full development log, data-source citations and hard rules.
