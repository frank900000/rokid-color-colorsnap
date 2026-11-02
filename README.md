# 奇光 ColorSnap — Rokid Color 全彩 AI 内容社交智能体（AIUI）

> 由 `ai-agent-studio` 工作流产出：厂商 Rokid（Rokid Color）× 内容/社交/娱乐 × 普通消费者。
> 经 Stage 2 商城全量扫描，锁定**全彩 AR 滤镜 + AI 成片社交**这一最高分空白赛道（现有 700+ 智能体全跑在单绿显示上，无人吃透 Color 的双目全彩）。

## 当前状态（已用官方工具验证）
- ✅ 工程已按 AIUI 官方 **Ink SFC 四段式**（`app.json` / `app.js` / `AGENTS.md` / `pages/index/index.ink`）重写。
- ✅ 用官方 **AIX CLI `aix pack`** 静态打包成功，产物 `colorsnap.aix`（无报错，7 个源文件全部正确收集）。
- ✅ `aix show` 解析出合法智能体定义（schemaVersion 1）。
- ⚠️ **"提交审核"这一步必须由你本人在浏览器完成**：AIUI Studio 是网页端平台，需登录你的乐奇开发者账号，并经过真机验证与人工审核，我无法代为点击。下方给出逐条可照做的操作。

## 交付物
| 文件 | 说明 |
|---|---|
| `colorsnap.aix` | **官方打包产物**，可直接导入 AIUI Studio / AIUI Editor（.aix 方式）。 |
| `AGENTS.md` / `app.json` / `app.js` / `pages/index/index.ink` | **原生 AIUI 智能体工程源码**（Ink SFC），可"本地文件夹"方式导入。 |
| `index.html` | **Web 原型**（手机 HUD 模拟，仅用于演示/预览，不被 AIUI 运行时使用）。 |
| `README.md` | 本说明。 |

## 一、把工程导入 AIUI Studio（3 选 1）
> 入口：[aiui.rokid.com](https://aiui.rokid.com) → 用乐奇账号登录 → 新建智能体。

- **方式 A（推荐）：本地文件夹导入**
  点「本地导入」→ 授权系统文件夹 → 选择本目录 `rokid-color-app`（含 `app.json` 的那个文件夹）。
- **方式 B：.aix 导入**
  在 AIUI Editor（[js.rokid.com/editor](https://js.rokid.com/editor)）中选「导入 .aix」，上传 `colorsnap.aix`。
- **方式 C：GitHub 导入**
  把本目录推到 GitHub 仓库，在 Studio 用「仓库 URL / 分支 / 子目录」导入。

## 二、网页模拟调试（无需眼镜）
- 进入「设备模拟」→ 点 **Preview** 即可在浏览器看交互。
- 可模拟：语音输入（唤醒→识别→大模型）、镜腿控制（单击/双击/前后滑）、环境光。
- 验证核心流程：切换 6 种滤镜 → 点「📸 抓拍」生成底片 → 「✨ AI 一键成片」出卡片 → 点小红书/朋友圈/微博生成分享卡。

## 三、打包并同步云端（提审前必做）
- 进入 **Build & Review → Package AIX**：打包成功后包会**自动同步到云端**（这是真机调试与提审的前置）。
- 真机验证（可选）：Rokid AI App → 设置 → 开发者 → 更新眼镜资源包 → 说"Hi Rokid，打开奇光 ColorSnap"。

## 四、填写资料并提交审核（你本人操作）
进入 **「构建与提审」**，按以下建议填写（与代码能力保持一致，避免被拒）：

| 字段 | 建议内容 |
|---|---|
| 智能体名称 | 奇光 ColorSnap |
| 一句话简介 | Rokid Color 双目全彩 AI 内容社交：实时全彩 AR 滤镜、第一视角抓拍、AI 一键成片与分享卡。 |
| 分类 | 内容创作 / 摄影 / 社交 |
| 权限声明 | 摄像头（第一视角抓拍）、显示（双目全彩 AR 滤镜预览）、Ring 输入（抓拍/翻页）、分享（生成并确认分享卡） |
| 预览素材 | 滤镜预览截图、抓拍底片条、AI 成片卡片、分享卡（图片/录屏，数量与格式按平台要求） |

填写并确认后点 **「提交审核」**。状态：审核中 →（通过）可发布 /（驳回）按原因改代码或资料后重新打包、保存、提交。

> 提交前自查：核心流程已通、权限声明与代码一致、资料无夸大、图视频数量与格式合规。

## 五、实现说明与边界
- **全彩定位**：Rokid Color 是双目全彩，UI 用深色 + 多色渐变是刻意的（普通单绿眼镜才走 `#40FF5E` 单绿规范），正好吃透 Color 差异点。
- **真实摄像头**：页面用渐变占位模拟取景框；真机环境由 **CXR-L SDK** 提供拍照能力（`capture()` 调用拍照 API），模拟器里用占位帧验证交互逻辑。
- **分享确认**：分享严格走"用户确认"路径，不自动发布，符合 AGENTS.md 行为边界。
- **迭代路线**（对应"后期可继续开发"维度）：滤镜库 → 虚拟穿戴（穿搭/美妆镜像）→ AR 合拍虚拟形象 → Vlog 模板 → 创作者激励。

## 本地校验命令（如需复跑）
```bash
npm install -g @yodaos-pkg/aix-cli
aix show  /workspace/rokid-color-app      # 解析智能体定义
aix pack  /workspace/rokid-color-app -o colorsnap.aix   # 打包（已产出）
```
