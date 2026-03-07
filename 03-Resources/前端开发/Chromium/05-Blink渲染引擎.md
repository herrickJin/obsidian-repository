---
title: Blink 渲染引擎
date: 2026-03-06
tags:
  - chromium
  - blink
  - rendering
difficulty: ⭐⭐⭐⭐
status: 📋 待学习
---

# Blink 渲染引擎

## 🎯 学习目标

- 理解 Blink 在 Chromium 中的角色
- 掌握 DOM 树构建过程
- 了解 CSS 解析与样式计算
- 理解布局与绘制流程

---

## 🏗️ Blink 概述

### 什么是 Blink？

Blink 是 Chromium 的渲染引擎，负责：
- HTML 解析与 DOM 构建
- CSS 解析与样式计算
- 布局计算
- 绘制与合成
- JavaScript 绑定 (与 V8 协作)

```
┌─────────────────────────────────────────────────────────────┐
│                    Blink 渲染引擎                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  输入                        输出                           │
│  ─────                       ─────                          │
│  HTML    ─────────────────────────────────>   DOM Tree      │
│  CSS     ─────────────────────────────────>   CSSOM         │
│  JavaScript (V8)  <─────────────────────>    DOM API        │
│                                                             │
│  处理流程:                                                   │
│  HTML/CSS → DOM/CSSOM → Render Tree → Layout → Paint       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Blink 架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Blink 架构层次                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Web API Layer (public/web)             │   │
│  │         对外暴露的稳定 API 接口                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Core DOM/CSS (core/)                    │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │
│  │  │   DOM   │ │   CSS   │ │  HTML   │ │ Events  │   │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Modules (modules/)                      │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │
│  │  │ Storage │ │ WebGL   │ │ Fetch   │ │ WebAudio│   │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Platform (platform/)                    │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │   │
│  │  │ Graphics│ │  Fonts  │ │Scheduler│ │  Network│   │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Bindings (bindings/)                    │   │
│  │              V8 JavaScript 绑定                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🌳 DOM 树构建

### HTML 解析流程

```
HTML 源码
    │
    ▼
┌─────────────┐
│  Tokenizer  │  词法分析，生成 Token
│  (分词器)    │
└─────────────┘
    │
    ▼
┌─────────────┐
│   Tree      │  语法分析，构建 DOM 树
│ Constructor │
└─────────────┘
    │
    ▼
┌─────────────┐
│  DOM Tree   │
└─────────────┘
```

### 解析过程详解

```
HTML 输入:
┌─────────────────────────────────────────┐
│ <html>                                  │
│   <head>                                │
│     <title>Page</title>                 │
│   </head>                               │
│   <body>                                │
│     <div id="app">Hello</div>           │
│   </body>                               │
│ </html>                                 │
└─────────────────────────────────────────┘

Token 流:
StartTag: html
StartTag: head
StartTag: title
Character: Page
EndTag: title
EndTag: head
StartTag: body
StartTag: div (id="app")
Character: Hello
EndTag: div
EndTag: body
EndTag: html

DOM 树:
        Document
            │
          html
         /    \
      head    body
        │       │
     title    div (id="app")
        │       │
    "Page"   "Hello"
```

### DOM 节点类型

```cpp
// 主要 DOM 节点类型

// Node (基类)
class Node : public EventTarget {
  // 节点类型
  enum NodeType {
    kElementNode = 1,
    kTextNode = 3,
    kCommentNode = 8,
    kDocumentNode = 9,
    // ...
  };
};

// Element (元素节点)
class Element : public ContainerNode {
  // 属性操作
  AttributeCollection Attributes() const;
  AtomicString getAttribute(const QualifiedName&) const;

  // DOM 操作
  Element* querySelector(const AtomicString& selectors);
};

// Text (文本节点)
class Text : public CharacterData {
  // 文本内容
  String data() const;
};

// Document (文档节点)
class Document : public ContainerNode {
  // DOM 创建
  Element* createElement(const AtomicString& name);
  Text* createTextNode(const String& data);

  // 查询
  Element* getElementById(const AtomicString& id);
};
```

---

## 🎨 CSS 解析与样式计算

### CSS 解析流程

```
CSS 源码
    │
    ▼
┌─────────────┐
│  Tokenizer  │  词法分析
└─────────────┘
    │
    ▼
┌─────────────┐
│   Parser    │  语法分析
└─────────────┘
    │
    ▼
┌─────────────┐
│  CSSRule    │  CSS 规则对象
└─────────────┘
    │
    ▼
┌─────────────┐
│   CSSOM     │  CSS 对象模型
└─────────────┘
```

### 样式规则

```css
/* CSS 规则结构 */
selector {
  property: value;
}

/* 示例 */
.container {
  display: flex;
  padding: 10px;
}

.item {
  flex: 1;
  color: #333;
}
```

```
CSS 规则内部表示:

┌─────────────────────────────────────────┐
│              CSS Rule                    │
├─────────────────────────────────────────┤
│  Selector: .container                    │
│  Specificity: 0, 0, 1, 0                 │
│  Properties:                             │
│    - display: flex                       │
│    - padding: 10px                       │
└─────────────────────────────────────────┘
```

### 样式计算

```
┌─────────────────────────────────────────────────────────────┐
│                    样式计算流程                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 收集样式                                                │
│     ├── 浏览器默认样式 (User Agent Style)                   │
│     ├── 用户样式 (User Style)                               │
│     └── 作者样式 (Author Style)                             │
│                                                             │
│  2. 规则匹配                                                │
│     └── 根据选择器匹配元素                                   │
│                                                             │
│  3. 级联计算 (Cascade)                                      │
│     ├── 来源优先级                                          │
│     ├── !important                                          │
│     ├── 特殊性 (Specificity)                                │
│     └── 源码顺序                                            │
│                                                             │
│  4. 继承                                                    │
│     └── 可继承属性从父元素获取                               │
│                                                             │
│  5. 默认值                                                  │
│     └── 未设置属性使用默认值                                 │
│                                                             │
│  6. 计算值 (Computed Value)                                 │
│     └── 相对值转换为绝对值                                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 样式优先级

```javascript
// CSS 优先级计算 (Specificity)

// 格式: (inline, id, class/attribute/pseudo-class, element/pseudo-element)

// 示例计算:
*               // (0, 0, 0, 0)
div             // (0, 0, 0, 1)
.container      // (0, 0, 1, 0)
div.container   // (0, 0, 1, 1)
#app            // (0, 1, 0, 0)
style=""        // (1, 0, 0, 0)

// !important 最高优先级
// (会覆盖内联样式)
```

---

## 📐 布局 (Layout)

### 布局流程

```
┌─────────────────────────────────────────────────────────────┐
│                     布局流程                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  DOM Tree + Computed Style                                  │
│           │                                                 │
│           ▼                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Render Tree (渲染树)                       │   │
│  │  只包含可见元素 (display: none 不包含)                │   │
│  └─────────────────────────────────────────────────────┘   │
│           │                                                 │
│           ▼                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Layout (布局)                           │   │
│  │  计算每个元素的位置和大小                             │   │
│  └─────────────────────────────────────────────────────┘   │
│           │                                                 │
│           ▼                                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Layout Tree (布局树)                      │   │
│  │  包含布局信息的对象树                                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 布局对象

```cpp
// Blink 中的布局对象

// LayoutObject (基类)
class LayoutObject {
  // 位置和大小
  LayoutRect FrameRect() const;

  // 布局
  virtual void Layout();

  // 样式
  ComputedStyle* Style() const;
};

// LayoutBlock (块级)
class LayoutBlock : public LayoutBox {
  // 块级布局逻辑
};

// LayoutInline (行内)
class LayoutInline : public LayoutBoxModelObject {
  // 行内布局逻辑
};

// LayoutText (文本)
class LayoutText : public LayoutObject {
  // 文本布局
};
```

### 布局算法

```
┌─────────────────────────────────────────────────────────────┐
│                    布局算法示例                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Block Layout (块布局):                                      │
│  ┌─────────────────────────────────────────┐               │
│  │ Block 1                                 │               │
│  │ height: auto                            │               │
│  └─────────────────────────────────────────┘               │
│  ┌─────────────────────────────────────────┐               │
│  │ Block 2                                 │               │
│  └─────────────────────────────────────────┘               │
│                                                             │
│  Flexbox Layout (弹性布局):                                  │
│  ┌───────────┬───────────┬───────────┐                     │
│  │   Item 1  │   Item 2  │   Item 3  │                     │
│  │  flex: 1  │  flex: 2  │  flex: 1  │                     │
│  └───────────┴───────────┴───────────┘                     │
│                                                             │
│  Grid Layout (网格布局):                                     │
│  ┌───────────────────┬───────────┐                         │
│  │     Header        │           │                         │
│  ├─────────┬─────────┼───────────┤                         │
│  │ Sidebar │ Content │  Aside    │                         │
│  └─────────┴─────────┴───────────┘                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 触发布局的场景

```javascript
// 触发布局 (Reflow) 的操作

// 1. 改变元素尺寸
element.style.width = '100px'
element.style.height = '100px'

// 2. 改变元素位置
element.style.margin = '10px'
element.style.padding = '10px'

// 3. 改变字体
element.style.fontSize = '16px'

// 4. 添加/删除元素
parent.appendChild(child)
parent.removeChild(child)

// 5. 获取布局信息 (强制同步布局)
const width = element.offsetWidth
const height = element.offsetHeight
const rect = element.getBoundingClientRect()

// 6. 改变窗口大小
window.addEventListener('resize', () => {})
```

---

## 🖌️ 绘制 (Paint)

### 绘制流程

```
┌─────────────────────────────────────────────────────────────┐
│                     绘制流程                                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layout Tree                                                │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Paint (绘制)                            │   │
│  │  生成绘制指令 (Paint Operations)                     │   │
│  └─────────────────────────────────────────────────────┘   │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │          Display Item List (显示项列表)              │   │
│  │  记录所有绘制操作                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Compositing (合成)                         │   │
│  │  将绘制内容分层                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Rasterization (光栅化)                    │   │
│  │  将矢量图形转换为位图                                │   │
│  └─────────────────────────────────────────────────────┘   │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │            Display (显示)                            │   │
│  │  最终显示在屏幕上                                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 绘制顺序

```
绘制顺序 (从后到前):

1. 背景颜色 (Background Color)
2. 背景图片 (Background Image)
3. 边框 (Border)
4. 子元素 (Children)
5. 轮廓 (Outline)
6. 其他装饰 (Decorations)

示例:
┌─────────────────────────────────────────┐
│  ┌───────────────────────────────────┐  │
│  │    Border                         │  │
│  │  ┌─────────────────────────────┐  │  │
│  │  │  Background Image           │  │  │
│  │  │  ┌───────────────────────┐  │  │  │
│  │  │  │  Background Color     │  │  │  │
│  │  │  │                       │  │  │  │
│  │  │  └───────────────────────┘  │  │  │
│  │  └─────────────────────────────┘  │  │
│  └───────────────────────────────────┘  │
│  Outline                                │
└─────────────────────────────────────────┘
```

### 绘制操作

```cpp
// 绘制操作类型

// 绘制背景
void DrawBackground(const PaintInfo&, const IntRect&);

// 绘制边框
void DrawBorder(const PaintInfo&, const IntRect&);

// 绘制文本
void DrawText(const PaintInfo&, const TextFragment&);

// 绘制图片
void DrawImage(const PaintInfo&, Image*, const IntRect&);

// 绘制阴影
void DrawBoxShadow(const PaintInfo&, const IntRect&);
```

---

## 🔧 合成层 (Compositing)

### 为什么需要合成？

```
传统绘制问题:
│
├── 每次更新都需要重绘整个页面
├── 动画性能差
└── 滚动时频繁重绘

合成层解决方案:
│
├── 将页面分成多个图层
├── 只更新变化的图层
└── GPU 加速合成
```

### 合成层结构

```
┌─────────────────────────────────────────────────────────────┐
│                    合成层结构                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Graphics Layer                     │   │
│  │                    (根图层)                          │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │              Graphics Layer                  │   │   │
│  │  │            (滚动容器图层)                     │   │   │
│  │  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ │   │   │
│  │  │  │  Layer 1  │ │  Layer 2  │ │  Layer 3  │ │   │   │
│  │  │  │ (transform)│ │  (fixed)  │ │ (video)   │ │   │   │
│  │  │  └───────────┘ └───────────┘ └───────────┘ │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 创建合成层的条件

```css
/* 会创建合成层的 CSS 属性 */

/* 3D 变换 */
.transform-3d {
  transform: translateZ(0);
  transform: translate3d(0, 0, 0);
}

/* will-change */
.will-change {
  will-change: transform, opacity;
}

/* 动画 */
@keyframes slide {
  from { transform: translateX(0); }
  to { transform: translateX(100px); }
}
.animated {
  animation: slide 1s;
}

/* position: fixed */
.fixed {
  position: fixed;
}

/* video, canvas */
video, canvas {
  /* 自动创建合成层 */
}

/* opacity 动画 */
@keyframes fade {
  from { opacity: 0; }
  to { opacity: 1; }
}
.fade {
  animation: fade 1s;
}
```

---

## 📝 实践练习

- [ ] 使用 DevTools 查看页面的 DOM 树结构
- [ ] 分析 CSS 样式计算过程
- [ ] 使用 Layers 面板查看合成层
- [ ] 观察布局抖动 (Layout Thrashing)

---

## 🔗 相关链接

- [[10-渲染管线详解]] - 完整渲染流程
- [[06-V8引擎]] - JavaScript 与 DOM 交互
- [[13-GPU加速]] - GPU 合成原理
- [Blink 开发文档](https://www.chromium.org/blink/)
- [Blink 架构](https://www.chromium.org/blink/blink-architecture/)

---

#tech/chromium/blink
