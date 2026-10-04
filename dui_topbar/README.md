# DUI 动态顶栏 HUD（DUI Dynamic Topbar HUD）

给《钢铁雄心 4》加一条**可自定义的顶部实时数据条**：像黑冰那样，玩家自己挑选想一直盯着的数据，
固定在游戏 UI 顶部（顶栏正下方、屏幕右上角），数值每帧刷新，随存档保存。

- 游戏版本：**1.19.x**（Operation Postern）
- 依赖：**无**（只用到原版精灵图，不含任何自制美术/DLL）
- 语言：简体中文 + English
- 联机：变量存于各自国家作用域，可正常用于多人游戏
- 上传创意工坊：只需打包 `dui_topbar` 文件夹（含 `descriptor.mod` 与 `thumbnail.png`）

> ⚠️ **想要「铁人模式 + 原版成就」？** 这个完整版因为用到了 `common/` 脚本，会改动游戏校验和，
> 所以开它就没有原版成就了（游戏提示：*"HOI4运行了一个MOD或者其他非原版改变，成就将被禁用"*）。
> 同系列的 **[DUI Topbar Lite](../dui_topbar_lite/README.md)** 是纯界面版本（只放 `interface/topbar.gui`，
> 不在 `checksum_manifest.txt` 里）：**铁人模式、原版成就、和原版玩家的联机校验和都正常**，
> 代价是不能自选数据、也没有苏联政治偏执度。两个版本可以各自单独发布。

---

## 1. 本地安装（上传工坊前也要先本地装好）

1. 打开 `文档\Paradox Interactive\Hearts of Iron IV\mod\`（没有就新建；
   「文档」被 OneDrive 接管的话，就在 OneDrive 下的同名目录里）；
2. 把 **`dui_topbar` 整个文件夹**复制进去；
3. 把 **`dui_topbar.mod`** 复制进去（和文件夹同级）；
4. 启动 HOI4 启动器 → **Mods / 模组** → 把 *DUI Dynamic Topbar HUD* 加入当前**播放集（playset）** → 启动游戏。

> 本地化文件已经是 **UTF-8 带 BOM**，直接复制即可；
> 如果之后用编辑器改过 yml，记得存回「UTF-8 BOM」，否则中文会乱码。
>
> 卸载：删掉 `…\mod\dui_topbar\` 与 `…\mod\dui_topbar.mod`。

## 2. 上传创意工坊

**上传内容 = `dui_topbar` 文件夹本身**（`descriptor.mod`、`thumbnail.png` 都在它里面）。
外层的 `dui_topbar.mod` 只服务于本地启动器，不需要上传；
`dui_topbar_dev/`（自检脚本）在 mod 文件夹之外，不会被打包。

1. 先按第 1 节本地安装并进游戏验证一遍（顶栏出现、能选指标、数值在动）；
2. 启动器 → **Mods / 模组** → 选中 *DUI Dynamic Topbar HUD* → **上传 / Upload mod**；
3. 上传前检查清单：
   - `descriptor.mod`：`name` / `version` / `supported_version="1.19.*"` / `tags` 是否正确；
   - `picture="thumbnail.png"` 与文件夹内的 `thumbnail.png`（512×512）是否配套；
   - **不要**手动填写 `remote_file_id`——首次上传与后续更新都由启动器自动处理；
   - 本 mod 没有任何 `replace_path`，不覆盖原版文件，与其它 mod 冲突面极小；
   - 只上传 `dui_topbar` 文件夹的内容，别把外层工作区一起传上去。
4. 上传后可在创意工坊页面自行修改标题与简介（游戏内显示的名称取自 `descriptor.mod` 的 `name`，
   想改成中文标题可以直接改这一行，改完重新上传即可）。
5. 以后更新：改一下 `version`，再对同一个工坊条目上传一次。

---

## 3. 操作

| 操作 | 效果 |
| --- | --- |
| **左键点某个格子** | 打开指标选择菜单（该格子发光高亮） |
| **菜单里左键点某项** | 把该指标绑定到当前选中的格子 |
| **Shift + 左键点菜单项** | 绑定并**再新增一个空格子**，方便连续添加 |
| **左键点 `+`** | 增加一个空格子（上限 8 个） |
| **右键点某个格子** | 移除该格子，后面的格子自动左移补位 |
| **右键点 `+`** | 折叠 / 展开整条信息条 |
| **Shift + 右键点 `+`** | 恢复默认布局 |
| 关闭菜单 | 点菜单右上角关闭按钮，或绑定完成后自动关闭 |

**默认布局（4 格）**：政治点 · 可用人力 · 军用工厂 · 政治偏执度
其中「政治偏执度」只在**苏联**（或已启用偏执度系统的国家）默认放入；
其他国家默认是**民用工厂**，且偏执度指标本身会显示 `--`。

---

## 4. 可选的 17 项实时数据（最新清单见 `CHANGELOG.md`；苏联额外多一项偏执度）

> **美术资源来源（重要）**
>
> - 界面控件全部来自游戏本体原版精灵：数据格底板 `GFX_generic_box_96`、
>   弹窗底 `GFX_tiled_window2_1b_border`、关闭键 `GFX_closebutton`、新增按钮底 `GFX_generic_box_smallest`。
> - **17 个指标图标取自「Black Ice」模组**（Steam 创意工坊 ID **1851181613**，作者：Black Ice 团队，
>   详见其工坊页面）。为免与黑冰本体重名，复制时统一改名为 `GFX_dui_bi_*`，
>   文件放在 `gfx/dui_icons/`，尺寸集中在 19–24px（原来直接引用原版精灵时是 16–27px，大小不一）。
>   在此按要求注明出处。
> - 若需要撤下这些图标：删除 `gfx/` 文件夹与 `interface/dui_icons.gfx`，
>   再把 `localisation/*.yml` 里的 `GFX_dui_bi_*` 换回原版精灵名即可（`CHANGELOG.md` 第 8 轮有对照表）。
> - 黑冰同时作为交互与排版参考。

数值全部直接引用游戏内置的**只读变量**（game variables），所以是实时变化的，不需要任何后台脚本刷新。

> 已按要求把与"阵营目标"无关的指标全部移出菜单（前后共移除 26 项）。它们的 token 与本地化
> 文本仍保留在 mod 内，**老存档里已经绑定这些指标的格子不会变空白**。

| 图标（原版精灵） | 指标 | 显示内容 |
| --- | --- | --- |
| `GFX_pol_power_icon` | 政治点日增 | 每日增长（带 +/-） |
| `GFX_stability_icon` | 稳定度 | 0–100% |
| `GFX_war_support_icon` | 战争支持度 | 0–100% |
| `GFX_command_power` | 指挥点 | 当前存量 |
| `GFX_SOV_paranoia_text_icon` | **政治偏执度** | **只有苏联（或已拥有偏执度系统的国家）才会在菜单里出现；0–100%** |
| `GFX_killed_units_icon` | 累计伤亡 | 所有战争的累计损失 |
| `GFX_victory_points` | 投降进度 | 距投降的程度 |
| `GFX_war_score` | 战争分数 | 各场战争中的最高分数 |
| `GFX_civ_factory` | 民用工厂 | 总数 |
| `GFX_mil_factory` | 军用工厂 | 总数 |
| `GFX_nav_dockyard_texticon` | 海军船坞 | 总数 |
| `GFX_fuel` | 燃料储量 | 当前储量 / 上限 |

> 已移出菜单的 26 项：政治点、可用人力、征兵率、总人口、野战兵力、陆军师、陆军营、
> 作战飞机、舰船、陆军经验、海军经验、空军经验、步兵装备库存、敌我陆军比、世界紧张度、
> 空闲民用工厂、钢铁盈余、铬盈余、铝盈余、钨盈余、橡胶盈余、石油盈余、研究槽、已研发科技、
> 燃料比例、核弹。

> 鼠标悬停在格子上会显示该指标的**详细说明与相关数值**；悬停在菜单项上会显示该指标说明。

---

## 5. 分辨率适配与顶栏内的落位

设计上做到「任何分辨率都贴在右上角」：

- 顶栏本体（`dui_topbar_root`）是一个铺满全屏的透明容器；
- 8 个格子、`+` 按钮、选择面板**都用 `Orientation = UPPER_RIGHT` 锚定到屏幕右边缘**，
  用负的 x 值向内偏移——所以宽屏不会被拉长、窄屏不会跑出屏幕；
- 坐标用的是和原版顶栏相同的像素单位，所以 UI Scale（界面缩放）变化时，
  本 mod 的格子和原版元素会一起等比缩放，相对位置不变。

### 为什么排成两行（1920×1080 实测）

原版顶栏实际高约 80px，内部已经被占满：

| 区域 | 原版内容 |
| --- | --- |
| 第 1 行 y 0–32 | 政治点 / 稳定度 / 人力 / 工厂 / 资源… 一直到 x≈1030 |
| 第 2 行 y 32–80 | 国策按钮 x 95–660、情报与警报按钮 x 715–1240（数量随当前警报变化） |
| 右上角 | 暂停键 x≈1545、日期 x≈1600、圆形警报组 x≈1543–1700（y 60–105） |

也就是说，顶栏内**只剩下右上角这一块空白**：第 1 行 x≈1040–1536、第 2 行 x≈1240–1536。
8 个格子按 5 + 3 排成两行全部放进去，既都在顶栏内，也不会盖住任何原版按钮。
（黑冰那种「更高的顶栏 + 更多行」靠的是它自制的加高底衬 `GFX_topbar_background_ax0`，
我们复用原版底衬，所以只能用原版顶栏已有的高度。）

| 元素 | 位置写法（`# LAYOUT`） | 屏幕上的实际范围（1920 宽） |
| --- | --- | --- |
| 第 1 行 槽位 0–4 | `y = 5`，`x = -480 / -580 / -680 / -780 / -880` | x 1040–1536（每格 96×26） |
| 第 2 行 槽位 5–7 | `y = 43`，`x = -480 / -580 / -680` | x 1240–1536 |
| `+` 按钮 | `x = -680 y = 43`（与第 8 格同位，两者永不同时显示） | x 1240–1336 |
| 选择菜单面板 | `x = -924 y = 80`，`size = { width = 540 height = 186 }` | x 996–1536，弹出窗口，位于顶栏下方 |
| 菜单网格容器 | `x = -158 y = 54`（= `12 - 170`），`slotsize = { width = 170 height = 30 }`，3 列 × 4 行 | 条目 170×26；x 必须先减一个条目宽度，抵消引擎把首个条目右移一个条目宽的行为 |

> ⚠ **x 的含义（踩过的坑）**：`Orientation = UPPER_RIGHT` 时，x 是**左边缘**距屏幕右边缘的距离
> （左边缘 = 屏幕宽 + x）。所以想让右边缘落在距右边 R 处，必须写 `x = -(R + 元素宽度)`。
> 之前写 `x = -384`（以为右边缘在 1536），实际格子出现在 1560~1656，弹窗更是整块跑到屏幕外。

x 一律是「元素**右边缘**离屏幕右边缘的距离」，格子宽 96、间隔 100。
想整体挪位置就只改这些数值：例如整体下移 4px，就是把 `y = 4` 改成 `y = 8`、
`y = 42` 改成 `y = 46`、`+` 的 `y = 44` 改成 `y = 48`、面板的 `y = 78` 改成 `y = 82`。

**窄屏（宽度 < 1920）请注意**：本 mod 的格子锚定在屏幕右侧，永远不会跑出屏幕；
但原版顶栏左侧那些数据（x 85–1030）是**绝对坐标**，不会跟着屏幕变窄而移动，
所以在 1600 / 1366 这种宽度下，我们的格子会压到原版数据上。
最省事的解决办法是把游戏设置里的 **UI Scale（界面缩放）调到 ≈ 屏幕宽 ÷ 1920**
（1366 → 0.71，1600 → 0.83，2560 → 1.33）：原版元素和我们的格子会一起等比缩放，
相对位置与 1920 下完全一致。不想动 UI Scale，就把 8 个格子的 `x` 整体减 100 的整数倍、
或者少开几格（默认只显示 4 格：`dui_slot_count = 4`）。

> ⚠ 踩过的坑：`buttonType` 里**不能**写 `size`（游戏会在 `error.log` 报
> `Malformed token: width / height`）。按钮会自动铺满所在容器的尺寸，
> 所以格子大小写在 `containerWindowType` 的 `size` 上。

---

## 6. 想加自己的指标？（4 步）

以「空军数量」为例：

1. **声明 token**：`common\synchronized_dynamic_tokens\dui_topbar_tokens.txt` 里加一行 `dui_m_my_stat`
2. **写数值**：`localisation\...\*.yml` 里加 4 个键

   ```yaml
    dui_m_my_stat:0 "我的指标"
    dui_m_my_stat_text:0 "[?num_deployed_planes|0]"
    dui_m_my_stat_sprite:0 "GFX_airoverview_button"
    dui_m_my_stat_tt:0 "§Y我的指标§!\n说明文字，可以写 [?变量|格式]"
   ```

   `_text` / `_tt` 里可以直接用游戏只读变量，格式码见下：
   `|0` 整数、`|2` 两位小数、`|%0` 乘 100 加 %、`|%%` 只加 %、`|+0` 带正负号、`|*` 自动 K/M、`|Y0` 黄色…

3. **加进菜单**：`common\scripted_effects\dui_topbar_effects.txt` 的 `dui_topbar_open_menu` 里
   加一行 `add_to_array = { dui_menu_items = token:dui_m_my_stat }`
   （候选总数上限 39 = 网格 3 列 × 13 行）
4. **换图标**：`_sprite` 填任意原版精灵名即可（可在 `interface\*.gfx` 里搜 `GFX_`）

数值想再加工（例如求差值、百分比）也可以：在
`common\scripted_localisation\dui_topbar_scripted_loc.txt` 里加一个 `defined_text`，
用 `set_temp_variable` + `[?t|0]` 的形式，再让 `_text` 指向它（本 mod 的偏执度就是这么做的）。

想加第 9 个格子或改槽位数，则需要复制 `.gui` 里的槽位块、
`scripted_guis` 里的 effects/triggers、`scripted_localisation` 里的 `GetDUISlotN*`，
并把 `dui_slot_count` 上限从 8 改掉。

---

## 7. 与其它 mod 共存

- **不覆盖任何原版文件**：没有 `replace_path`，只新增自己的文件名 → 和绝大多数 mod 兼容。
- **和黑冰（Black Ice）同时使用**：两者互不覆盖，但黑冰自己也有一套顶栏动态数据条
  （占用顶栏第 1 行 x≈730–1030，外加一个从 y≈116 开始的下拉“仓储”面板）。
  同时开时两者会争右上角这块空间，建议一次只开一个；一定要同时开的话，
  把本 mod 的 8 个格子整体左移（把每个 `x` 再减 100 的整数倍）会比较安全。
- 与本 mod 争顶栏空间的**原版**元素已经避开（见第 5 节的实测表）；如果你还装了别的
  右上角 HUD mod，可能需要在 `dui_topbar.gui` 里微调 `x` / `y`。

---

## 8. 排查

| 现象 | 原因 / 处理 |
| --- | --- |
| 启动器里看不到 mod | `.mod` 文件没和 `dui_topbar` 文件夹放在同一个 mod 目录；或没加入播放集 |
| 信息条完全不出现 | 只看到 `+` 按钮说明变量未初始化：点一次 `+` 会自动初始化（正常开局由 `on_actions` 自动完成） |
| 中文显示成方块/乱码 | yml 被编辑器存成了不带 BOM 的 UTF-8 → 用 Notepad++ 另存为「UTF-8 BOM」（本 mod 原始文件已带 BOM，直接复制不会出这个问题） |
| 数字显示成 `[?political_power|0]` 原文 | 本地化键没读到（拼写/文件名后缀必须是 `_l_simp_chinese.yml`） |
| 数字显示 `--` | 该指标当前不适用（例如非苏联国家的政治偏执度） |
| 图标位置有空格子 | 该格子还没绑定指标：左键点它选一个，或右键把它移除 |

游戏日志：`文档\Paradox Interactive\Hearts of Iron IV\logs\error.log`
（搜索 `dui_topbar` / `dui_m_` 可定位本地化或脚本错误）。

---

## 9. 文件结构

```
dui_topbar/
├─ descriptor.mod                                     mod 描述（工坊上传必需）
├─ thumbnail.png                                      创意工坊缩略图 512×512
├─ README.md                                          本文件
├─ interface/
│  └─ dui_topbar.gui                                  界面布局（槽位 / 菜单面板 / 菜单条目）
├─ common/
│  ├─ scripted_guis/
│  │  └─ dui_topbar_scripted_gui.txt                 两个脚本化 GUI：信息条本体 + 选择菜单
│  ├─ scripted_effects/
│  │  └─ dui_topbar_effects.txt                      初始化 / 增删槽位 / 指派指标 / 构建菜单
│  ├─ scripted_localisation/
│  │  └─ dui_topbar_scripted_loc.txt                 动态文本分发（槽位 → token → 本地化键）
│  ├─ synchronized_dynamic_tokens/
│  │  └─ dui_topbar_tokens.txt                       39 个 token 声明（其中 12 项出现在菜单）
│  └─ on_actions/
│     └─ dui_topbar_on_actions.txt                   开局给每个国家写入默认布局
└─ localisation/
   ├─ english/dui_topbar_l_english.yml
   └─ simp_chinese/dui_topbar_l_simp_chinese.yml
```

### 实现要点（给二创作者）

- **实时数值**：信息条那个脚本化 GUI **故意不写 `dirty`**，即每 tick 刷新；
  文本框内容形如 `[GetDUISlot0Text]` → `defined_text` 用
  `[?dui_slot_0.GetTokenKey]_text` 动态拼出本地化键 → 真正的数值来自
  `[?political_power|0]` 这类**游戏只读变量**，所以天然实时。
- **选择菜单**单独做成第二个脚本化 GUI，用 `visible` 整体隐藏，并配 `dirty = dui_menu_dirty`，
  只在菜单内容变化时重建 12 条候选列表（苏联为 13 条），避免每帧重建网格。
- **存档保存**：`dui_slot_count` / `dui_slot_0..7` 都是国家变量，随存档保存，读档后保留布局。
