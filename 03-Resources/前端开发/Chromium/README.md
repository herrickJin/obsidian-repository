---
title: Chromium 学习笔记
date: 2026-03-06
tags:
  - MOC
  - chromium
  - browser
  - frontend
---

# Chromium 学习笔记

> 技能等级: ⭐⭐⭐⭐ | 状态: 📚 学习中

## 📚 知识体系总览

```
Chromium 技能树
│
├── 🟢 基础篇 (入门理解)
│   ├── 01-概述与发展历史
│   │   ├── Chromium vs Chrome 区别
│   │   ├── 浏览器引擎发展史
│   │   ├── Blink/WebKit 分离历史
│   │   └── Chromium 生态 (Electron, CEF, WebView)
│   │
│   ├── 02-多进程架构
│   │   ├── Browser Process 浏览器主进程
│   │   ├── Renderer Process 渲染进程
│   │   ├── GPU Process GPU进程
│   │   ├── Utility Process 实用进程
│   │   ├── Plugin Process 插件进程
│   │   └── 进程间通信 (IPC/Mojo)
│   │
│   ├── 03-多线程模型
│   │   ├── 主线程与 IO 线程
│   │   ├── 线程池与任务调度
│   │   ├── 消息循环 (Message Loop)
│   │   └── 线程安全与同步
│   │
│   └── 04-代码结构概览
│       ├── 目录结构说明
│       ├── 核心模块划分
│       ├── 构建系统 (GN/Ninja)
│       └── 代码风格指南
│
├── 🟡 进阶篇 (核心组件)
│   ├── 05-Blink 渲染引擎
│   │   ├── Blink 架构概述
│   │   ├── DOM 树构建
│   │   ├── CSS 解析与样式计算
│   │   ├── 布局算法 (Layout)
│   │   ├── 绘制流程 (Paint)
│   │   └── 合成层 (Compositing)
│   │
│   ├── 06-V8 JavaScript 引擎
│   │   ├── V8 架构与执行流水线
│   │   ├── Ignition 解释器
│   │   ├── TurboFan 优化编译器
│   │   ├── Maglev 编译器
│   │   ├── Hidden Classes 与 Inline Caches
│   │   ├── 垃圾回收机制 (GC)
│   │   └── V8 API 与嵌入
│   │
│   ├── 07-网络栈 (Network Stack)
│   │   ├── 网络请求流程
│   │   ├── HTTP/HTTPS 协议栈
│   │   ├── HTTP/2 与 HTTP/3 (QUIC)
│   │   ├── TCP/Socket 管理
│   │   ├── 缓存机制 (Cache)
│   │   ├── Cookie 管理
│   │   └── 网络安全
│   │
│   ├── 08-Skia 图形库
│   │   ├── Skia 基础概念
│   │   ├── 2D 图形绘制
│   │   ├── GPU 加速渲染
│   │   ├── 文本渲染
│   │   └── 图像解码与编码
│   │
│   └── 09-存储与数据
│       ├── SQLite 数据库
│       ├── LevelDB 使用
│       ├── IndexedDB 实现
│       ├── LocalStorage/SessionStorage
│       ├── Cookie 存储
│       └── 缓存存储
│
├── 🟠 高级篇 (深入机制)
│   ├── 10-渲染管线详解
│   │   ├── 从 HTML 到像素
│   │   ├── 关键渲染路径 (CRP)
│   │   ├── 重排 Reflow
│   │   ├── 重绘 Repaint
│   │   ├── 合成 Composite
│   │   ├── 光栅化 Rasterization
│   │   └── 硬件加速
│   │
│   ├── 11-进程间通信 (IPC/Mojo)
│   │   ├── 传统 IPC
│   │   ├── Mojo 框架
│   │   ├── 消息管道
│   │   ├── 数据序列化
│   │   └── 安全边界
│   │
│   ├── 12-安全模型
│   │   ├── 沙箱机制 (Sandbox)
│   │   ├── Site Isolation 站点隔离
│   │   ├── Origin 进程隔离
│   │   ├── 同源策略 (SOP)
│   │   ├── CORS 实现
│   │   └── 安全更新策略
│   │
│   ├── 13-GPU 加速
│   │   ├── GPU 进程架构
│   │   ├── OpenGL/Vulkan/Metal
│   │   ├── GPU 命令缓冲区
│   │   ├── 合成器 (Compositor)
│   │   └── GPU 光栅化
│   │
│   └── 14-扩展系统
│       ├── Chrome Extensions API
│       ├── 扩展架构
│       ├── Content Scripts
│       ├── Background Scripts
│       └── Native Messaging
│
├── 🔴 专家篇 (底层精通)
│   ├── 15-内存管理
│   │   ├── 分配器 (Allocator)
│   │   ├── PartitionAlloc
│   │   ├── 内存分区
│   │   ├── 内存泄漏检测
│   │   └── OOM 处理
│   │
│   ├── 16-性能优化深入
│   │   ├── 启动优化
│   │   ├── 内存占用优化
│   │   ├── CPU 性能调优
│   │   ├── 渲染性能优化
│   │   ├── 网络性能
│   │   └── 性能分析工具
│   │
│   ├── 17-源码编译与调试
│   │   ├── depot_tools 工具链
│   │   ├── GN 构建系统
│   │   ├── Ninja 编译
│   │   ├── 增量编译
│   │   ├── 调试配置
│   │   └── 符号与崩溃分析
│   │
│   └── 18-定制与嵌入
│       ├── Content API
│       ├── Chromium Embedder
│       ├── CEF (Chromium Embedded Framework)
│       ├── Electron 原理
│       └── 自定义 Chromium 构建
│
└── 🔧 实践篇 (动手实践)
    ├── 19-调试工具使用
    │   ├── chrome:// 内部页面
    │   ├── Chrome DevTools Protocol
    │   ├── tracing 与性能分析
    │   └── crash 收集与分析
    │
    ├── 20-源码阅读实践
    │   ├── 阅读源码的方法
    │   ├── 代码搜索工具 (cs.chromium.org)
    │   ├── 关键路径追踪
    │   └── 提交历史与设计文档
    │
    └── 21-贡献与社区
        ├── Chromium issue 跟踪
        ├── 代码审查流程
        ├── 提交 Patch
        └── 设计文档 (Design Docs)
```

---

## 🎯 学习路径

### 阶段一：基础认知 (1-2 周)

```mermaid
graph LR
    A[概述与历史] --> B[多进程架构]
    B --> C[多线程模型]
    C --> D[代码结构]
```

| 序号 | 主题 | 笔记 | 难度 | 状态 |
|------|------|------|------|------|
| 1 | 概述与发展历史 | [[01-概述与发展历史\|查看]] | ⭐⭐ | 📋 待学习 |
| 2 | 多进程架构 | [[02-多进程架构\|查看]] | ⭐⭐ | 📋 待学习 |
| 3 | 多线程模型 | [[03-多线程模型\|查看]] | ⭐⭐⭐ | 📋 待学习 |
| 4 | 代码结构概览 | [[04-代码结构概览\|查看]] | ⭐⭐ | 📋 待学习 |

### 阶段二：核心组件 (4-6 周)

| 序号 | 主题 | 笔记 | 难度 | 状态 |
|------|------|------|------|------|
| 5 | Blink 渲染引擎 | [[05-Blink渲染引擎\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 6 | V8 JavaScript 引擎 | [[06-V8引擎\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 7 | 网络栈 | [[07-网络栈\|查看]] | ⭐⭐⭐ | 📋 待学习 |
| 8 | Skia 图形库 | [[08-Skia图形库\|查看]] | ⭐⭐⭐ | 📋 待学习 |
| 9 | 存储与数据 | [[09-存储与数据\|查看]] | ⭐⭐⭐ | 📋 待学习 |

### 阶段三：深入机制 (4-6 周)

| 序号 | 主题 | 笔记 | 难度 | 状态 |
|------|------|------|------|------|
| 10 | 渲染管线详解 | [[10-渲染管线详解\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 11 | 进程间通信 IPC/Mojo | [[11-IPC与Mojo\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 12 | 安全模型 | [[12-安全模型\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 13 | GPU 加速 | [[13-GPU加速\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 14 | 扩展系统 | [[14-扩展系统\|查看]] | ⭐⭐⭐ | 📋 待学习 |

### 阶段四：专家进阶 (持续)

| 序号 | 主题 | 笔记 | 难度 | 状态 |
|------|------|------|------|------|
| 15 | 内存管理 | [[15-内存管理\|查看]] | ⭐⭐⭐⭐⭐ | 📋 待学习 |
| 16 | 性能优化深入 | [[16-性能优化深入\|查看]] | ⭐⭐⭐⭐⭐ | 📋 待学习 |
| 17 | 源码编译与调试 | [[17-源码编译与调试\|查看]] | ⭐⭐⭐⭐⭐ | 📋 待学习 |
| 18 | 定制与嵌入 | [[18-定制与嵌入\|查看]] | ⭐⭐⭐⭐⭐ | 📋 待学习 |

### 阶段五：实践应用 (持续)

| 序号 | 主题 | 笔记 | 难度 | 状态 |
|------|------|------|------|------|
| 19 | 调试工具使用 | [[19-调试工具使用\|查看]] | ⭐⭐⭐ | 📋 待学习 |
| 20 | 源码阅读实践 | [[20-源码阅读实践\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |
| 21 | 贡献与社区 | [[21-贡献与社区\|查看]] | ⭐⭐⭐⭐ | 📋 待学习 |

---

## 🔗 与 Electron 的关联

Chromium 是 Electron 的核心组成部分，深入学习 Chromium 有助于：

| Chromium 模块 | 关联 Electron 知识 | 学习价值 |
|--------------|-------------------|----------|
| 多进程架构 | Electron 进程模型 | 理解主进程/渲染进程本质 |
| V8 引擎 | JavaScript 性能优化 | 编写高性能 JS 代码 |
| 渲染管线 | 前端性能优化 | 减少重排重绘，优化渲染 |
| IPC/Mojo | Electron IPC 通信 | 理解进程通信底层原理 |
| 安全模型 | Electron 安全策略 | 构建安全的桌面应用 |
| 定制与嵌入 | Electron 源码编译 | 自定义 Electron 版本 |

> 相关笔记: [[../Electron/README\|Electron 学习笔记]]

---

## 📌 实践项目

### 入门级实践

- [ ] **架构探索** - 使用 Chrome Task Manager 观察进程
- [ ] **chrome:// 页面** - 探索 `chrome://version`, `chrome://gpu`, `chrome://process-internals`
- [ ] **DevTools 分析** - Performance 面板分析渲染流程

### 进阶级实践

- [ ] **V8 优化分析** - 使用 `--trace-opt` 和 `--trace-deopt` 分析代码优化
- [ ] **网络分析** - 使用 `chrome://net-internals` 分析网络请求
- [ ] **扩展开发** - 开发一个简单的 Chrome 扩展

### 高级实践

- [ ] **编译 Chromium** - 从源码编译 Chromium
- [ ] **源码调试** - 使用 LLDB/GDB 调试 Chromium
- [ ] **性能分析** - 使用 `chrome://tracing` 分析性能瓶颈

### 专家级实践

- [ ] **Chromium 定制** - 修改源码实现自定义功能
- [ ] **CEF 集成** - 使用 CEF 嵌入 Chromium
- [ ] **贡献代码** - 向 Chromium 提交 Patch

---

## 🔧 开发环境准备

### 源码阅读环境

```bash
# 安装 depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:/path/to/depot_tools"

# 下载源码 (需要科学上网)
mkdir chromium && cd chromium
fetch --nohooks chromium
```

### 调试工具

| 工具 | 用途 | 链接 |
|------|------|------|
| depot_tools | Chromium 开发工具集 | [GitHub](https://chromium.googlesource.com/chromium/tools/depot_tools/) |
| Chromium Code Search | 在线源码搜索 | [cs.chromium.org](https://source.chromium.org/) |
| Chrome DevTools | 前端调试 | 内置 |
| chrome://tracing | 性能追踪 | 内置 |
| V8 Inspector | V8 调试 | 内置 |

---

## 📖 推荐资源

### 官方文档

- [Chromium 官方网站](https://www.chromium.org/)
- [Chromium 源码](https://source.chromium.org/)
- [Chromium 设计文档](https://www.chromium.org/developers/design-documents/)
- [V8 官方博客](https://v8.dev/blog)

### 技术博客

- [Chrome Developers](https://developer.chrome.com/blog/)
- [Chromium Blog](https://blog.chromium.org/)
- [V8 Dev Blog](https://v8.dev/)

### 视频教程

- [Chrome University (YouTube)](https://www.youtube.com/playlist?list=PLNYkxOF6rcIBgG-FYjBzYePVrLgkx3T2a)
- [BlinkOn Conference](https://www.youtube.com/results?search_query=blinkon)

### 推荐书籍

- 《Browser Architecture》- 浏览器架构深度解析
- 《V8 Engine Internals》- V8 引擎内部原理
- 《Web Browser Engineering》- [在线阅读](https://browser.engineering/)

---

## 📊 学习进度追踪

```dataview
TABLE
  difficulty as 难度,
  status as 状态,
  date as 更新日期
FROM "03-Resources/前端开发/Chromium"
WHERE file.name != "README"
SORT difficulty ASC
```

---

## 💡 学习建议

1. **先宏观后微观** - 先理解整体架构，再深入具体模块
2. **结合实践** - 边学边用 DevTools 验证理论
3. **阅读源码** - 使用 Code Search 阅读关键代码
4. **关注设计文档** - Chromium 有丰富的设计文档
5. **循序渐进** - 从应用到原理，从使用到定制

---

## 📝 学习笔记模板

每个章节笔记建议包含：

```markdown
---
title: 章节标题
date: YYYY-MM-DD
tags:
  - chromium
  - 具体标签
difficulty: ⭐⭐⭐
status: 📋 待学习
---

# 章节标题

## 🎯 学习目标

- 目标1
- 目标2

## 📖 核心概念

### 概念1
内容...

### 概念2
内容...

## 🔧 实践示例

代码示例...

## 🔗 相关链接

- [[相关笔记]]
- [外部链接]()

## 📝 学习心得

个人理解和笔记...

#tech/chromium
```

---

#tech/chromium #MOC
