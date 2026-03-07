---
title: Electron Chromium 深入
date: 2026-03-04
tags:
  - electron
  - chromium
difficulty: ⭐⭐⭐⭐⭐
status: 📋 待学习
---

# Electron Chromium 深入

## 🎯 学习目标

- 理解 Chromium 架构
- 了解 V8 引擎优化
- 掌握渲染管线原理

---

## 🏗️ Chromium 架构

### 1. 多进程架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Chromium 多进程架构                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Browser Process (浏览器进程)             │   │
│  │  - 主进程，管理 UI、网络、存储                          │   │
│  │  - 对应 Electron 的主进程                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│          ┌───────────────┼───────────────┐                  │
│          ↓               ↓               ↓                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ Renderer     │ │ Renderer     │ │ Renderer     │       │
│  │ Process      │ │ Process      │ │ Process      │       │
│  │ (标签页1)    │ │ (标签页2)    │ │ (标签页N)    │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ GPU Process  │ │ Plugin       │ │ Utility      │       │
│  │ (GPU渲染)    │ │ Process      │ │ Process      │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. 渲染进程架构

```
┌─────────────────────────────────────────────────────────────┐
│                    渲染进程内部结构                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Blink 渲染引擎                      │   │
│  │  ├── DOM/CSS 解析                                    │   │
│  │  ├── 样式计算                                        │   │
│  │  ├── 布局 (Layout)                                   │   │
│  │  └── 绘制 (Paint)                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   V8 JavaScript 引擎                  │   │
│  │  ├── 解析和编译                                      │   │
│  │  ├── 执行优化                                        │   │
│  │  └── 垃圾回收                                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                          ↓                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Skia 图形库                         │   │
│  │  └── 2D 图形渲染                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚡ V8 引擎

### 1. 执行流程

```
JavaScript 代码
     │
     ↓
┌─────────────┐
│   Parser    │  词法分析、语法分析
└─────────────┘
     │
     ↓
┌─────────────┐
│    AST      │  抽象语法树
└─────────────┘
     │
     ↓
┌─────────────┐
│ Ignition    │  解释器，生成字节码
└─────────────┘
     │
     ↓
┌─────────────┐
│  执行字节码   │
└─────────────┘
     │ (热点代码)
     ↓
┌─────────────┐
│ TurboFan    │  优化编译器，生成机器码
└─────────────┘
```

### 2. 优化技巧

```javascript
// ✅ 保持对象形状一致 (Hidden Classes)
function Point(x, y) {
  this.x = x
  this.y = y
}
const p1 = new Point(1, 2)
const p2 = new Point(3, 4)  // 共享 Hidden Class

// ❌ 动态添加属性
const p3 = new Point(5, 6)
p3.z = 7  // 创建新的 Hidden Class，影响性能

// ✅ 保持参数类型一致
function add(a, b) {
  return a + b
}
add(1, 2)      // 整数加法优化
add(1.5, 2.5)  // 触发去优化

// ❌ 混合类型
add(1, '2')    // 类型改变，去优化

// ✅ 使用数组连续存储
const arr = [1, 2, 3, 4, 5]  // 快速元素

// ❌ 稀疏数组
const sparse = []
sparse[1000] = 1  // 慢速元素
```

### 3. 垃圾回收

```javascript
// V8 使用分代 GC
// - 新生代 (New Space): Scavenge 算法
// - 老生代 (Old Space): Mark-Sweep-Compact 算法

// 避免内存泄漏
// 1. 及时清理事件监听
element.removeEventListener('click', handler)

// 2. 避免闭包持有大对象
function createHandler() {
  const largeData = new Array(1000000)

  return () => {
    // largeData 被闭包持有
    console.log(largeData.length)
  }
}

// 3. 使用 WeakMap/WeakSet
const cache = new WeakMap()
cache.set(obj, data)  // 不阻止 obj 被 GC
```

---

## 🎨 渲染管线

### 1. 渲染流程

```
HTML/CSS/JS
     │
     ↓
┌─────────────────────────────────────────────────────────────┐
│ 1. DOM 构建                                                  │
│    HTML → DOM Tree                                          │
└─────────────────────────────────────────────────────────────┘
     │
     ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. CSSOM 构建                                                │
│    CSS → CSSOM Tree                                         │
└─────────────────────────────────────────────────────────────┘
     │
     ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. 渲染树 (Render Tree)                                      │
│    DOM + CSSOM → Render Tree                                │
└─────────────────────────────────────────────────────────────┘
     │
     ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. 布局 (Layout/Reflow)                                      │
│    计算元素位置和大小                                         │
└─────────────────────────────────────────────────────────────┘
     │
     ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. 绘制 (Paint)                                              │
│    生成绘制指令                                               │
└─────────────────────────────────────────────────────────────┘
     │
     ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. 合成 (Composite)                                          │
│    分层、光栅化、合成                                         │
└─────────────────────────────────────────────────────────────┘
     │
     ↓
   显示
```

### 2. 性能优化

```javascript
// 减少重排 (Reflow)
// ❌ 触发重排
element.style.width = '100px'
element.style.height = '100px'

// ✅ 批量修改
element.classList.add('active')

// ✅ 使用 transform (只触发合成)
element.style.transform = 'translateX(100px)'

// 使用 requestAnimationFrame
function animate() {
  // 动画逻辑
  requestAnimationFrame(animate)
}
requestAnimationFrame(animate)

// 使用 Web Workers 处理复杂计算
const worker = new Worker('compute.js')
worker.postMessage(largeData)
worker.onmessage = (e) => {
  // 处理结果
}
```

### 3. 图层优化

```css
/* 创建新的合成层 */
.will-change {
  will-change: transform, opacity;
}

.gpu-accelerated {
  transform: translateZ(0);
  /* 或 */
  transform: translate3d(0, 0, 0);
}

/* 避免过度使用合成层 */
.avoid {
  /* 每个合成层都需要内存 */
  will-change: auto;  /* 不需要时禁用 */
}
```

---

## 🔧 Electron 中的 Chromium

### 1. 命令行开关

```javascript
// main.js
const { app } = require('electron')

// 启用 GPU 加速
app.commandLine.appendSwitch('enable-gpu-rasterization')
app.commandLine.appendSwitch('enable-zero-copy')

// 禁用 GPU (调试用)
app.commandLine.appendSwitch('disable-gpu')
app.commandLine.appendSwitch('disable-software-rasterization')

// 内存限制
app.commandLine.appendSwitch('js-flags', '--max-old-space-size=4096')

// 忽略证书错误 (仅开发环境)
if (process.env.NODE_ENV === 'development') {
  app.commandLine.appendSwitch('ignore-certificate-errors')
}

// 启用实验性功能
app.commandLine.appendSwitch('enable-features', 'SharedArrayBuffer')
```

### 2. GPU 进程调试

```javascript
// 查看 GPU 信息
const { app } = require('electron')

app.getGPUInfo('complete').then(info => {
  console.log('GPU Info:', info)
})

// GPU 特性状态
// chrome://gpu
```

---

## 📝 实践练习

- [ ] 分析 Electron 应用的进程结构
- [ ] 使用 Chrome DevTools 分析渲染性能
- [ ] 优化 JavaScript 执行性能
- [ ] 减少页面重排和重绘

---

## 🔗 相关链接

- [[14-性能极致优化]] - 性能优化实践
- [Chromium 源码](https://source.chromium.org/)
- [V8 博客](https://v8.dev/blog)

---

#tech/electron/chromium
