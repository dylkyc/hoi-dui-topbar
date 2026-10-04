# DUI Dynamic Topbar HUD —— 制作过程记录

本文件夹记录 **DUI 顶栏自制 HUD**（`D:\Local_Mod\Hearts of Iron IV\dui_topbar`）的开发流程、遇到的问题与解决办法。
用途：换人接手 / 隔一段时间回看时，不用重新踩一遍坑。

## 目录

| 文件 | 内容 |
| --- | --- |
| `README.md` | 目标、开发流程、每轮迭代怎么做、仓库结构 |
| `问题与解决.md` | 全部问题：现象 → 根因 → 解决 → 证据（文件:行号） |
| `接口与数据来源.md` | 每个指标用哪个接口、出处、是否可用；装备"结余"口径的推导过程 |
| `规范与硬性约束.md` | 不会被引擎接受的写法（BOM、粘连行等）与自检脚本用法 |
| `hoi4-modding-kit/` | 把本文件夹的经验做成 Harness 插件：技能 `hoi4-modding` + 6 个 `hoi4_*` 工具（lint / doctor / sync / game_log / gui_map / knowledge） |

## 一、目标

在 HOI4 顶栏做一个**玩家自选数据**的 HUD：8 个格子可绑定不同指标，点击格子打开选择菜单，
菜单里的数值随游戏实时变化；重点指标额外做**红/绿**（缺口红、盈余绿）。
参考对象：原版 UI 优先，其次黑冰（Black Ice，工坊 1851181613）与装备图标 mod（3792413299）。

## 二、开发流程（实际跑通的顺序）

1. **定范围**：列出候选指标 → 决定哪些放菜单（战争相关项仅在开战后出现）。
2. **查接口**（最关键的一步）：
   - 先在**原版**文件里找出处（`common/`、`localisation/english/`、`interface/`），记录 `文件:行号`；
   - 原版没有的，再去工坊 mod 找（黑冰是主要参考）；
   - 找不到就**明确写"没有可读接口"**，不要凭猜测写变量名。
3. **写结构**：
   - `common/scripted_guis/*.txt` —— 窗口逻辑（`window_name`/`parent_window_token`/`dynamic_lists`/`properties`/`effects`/`triggers`/`dirty`）；
   - `interface/*.gui` —— 元素与坐标；
   - `common/scripted_localisation/*.txt` —— 动态文本（**取值必须在这里做**：`set_temp_variable` 后再输出）；
   - `common/scripted_effects|triggers`、`common/synchronized_dynamic_tokens`、`on_actions`、`localisation/*.yml`。
4. **自检**：`dui_topbar_dev\validate.ps1`（结构/引用/精灵/容量）与 `check_vars.ps1`（变量名是否真实存在）都必须 **0 问题**。
5. **安装测试**：
   - 关键教训：**必须逐文件确认复制成功**（MD5 比对），否则你测的是旧版本（本流程因此白跑过两轮）；
   - 进游戏后**先看 `logs/error.log` 里有没有 `dui` 相关报错**，再看画面。
6. **对照原版验证**：把界面数值与原版对应窗口（如「后勤」「陆军总览 → 现役装备」）**同屏截图**对比；
   注意数值每天变化，**不同时刻的数字不能互相比较**。
7. **记录**：每轮改完写 `dui_topbar\CHANGELOG.md`（含 `文件:行号`）。

## 三、每轮迭代的固定动作

```
读 error.log → 复现问题 → 在原版/黑冰找正确写法 → 改代码
→ validate.ps1 + check_vars.ps1（都要 0）→ 写 CHANGELOG
→ 给用户"怎么测、看什么、复制后如何自证"三件事
```

## 四、仓库结构

```
dui_topbar\                 ← 成品 mod（复制到 Documents\...\mod\top_barUI）
  descriptor.mod  thumbnail.png  README.md  CHANGELOG.md
  common\  interface\  gfx\  localisation\
dui_topbar_dev\             ← 开发工具
  validate.ps1  check_vars.ps1  _loc_patch*.tsv
dui_topbar_docs\            ← 本文件夹（过程与经验）
_shots\                     ← 诊断截图
```

## 五、现状（2026-10-04 19:10）

- 已完成：菜单与绑定、装备 12 大类的"结余（红/绿）"、稳定度/战争支持度的"每周"口径、工业数值等；
- 待处理：菜单排版（只排 2 列、条目内无数值）、下拉浮层（元素级显示触发器）、接口审计（`deployed_army_manpower_k` 仅黑冰有）、TESTPLAN 文档；
- 详细状态见看板卡片与 `问题与解决.md` 末尾"未完成项"。

## 六、Harness 插件（`hoi4-modding-kit/`）

把本文件夹的规范做成 DSH 插件（纯宿主、零依赖），已安装到本机 `desktop` profile：

- 技能 `hoi4-modding`：模型可调用，正文即 `hoi4-modding-kit/knowledge/doctrine.md`；
- 工具：`hoi4_lint`（按硬约束检查模组）、`hoi4_doctor`（环境与安装状态）、`hoi4_sync`（复制并哈希自证）、
  `hoi4_game_log`（error.log 归并计数）、`hoi4_gui_map`（窗口 / 元素 / 脚本化 GUI 结构）、`hoi4_knowledge`（规范与变量清单）。

跑法：让 Harness 调用 `hoi4_lint` 并传 `modDir`。当前 `dui_topbar` 的结果是 **0 error / 5 warn / 3 info**（2026-10-04 实测），
其中 4 条 `VAR-UNSUPPORTED`（`deployed_army_manpower_k`）与 1 条 `VAR-EQUIP-OUTSIDE-LOC`（`dui_topbar_equip_snapshot` 死代码，12 处）
正好对应"未完成项"第 3、5 条，可直接按提示清理。

> 注意：`validate.ps1` 第 227 行那条"粘连行"检查被写进了字符串里，实际从未执行；插件里的 `SYN-GLUED-BRACE` 是它的可用替代。

安装、配置与已知限制见 `hoi4-modding-kit/README.md`。
