---
title: Skia 图形库
date: 2026-03-06
tags:
  - chromium
  - skia
  - graphics
difficulty: ⭐⭐⭐
status: 📋 待学习
---

# Skia 图形库

## 🎯 学习目标

- 理解 Skia 在 Chromium 中的作用
- 掌握 2D 图形绘制基础
- 了解 GPU 加速渲染原理
- 熟悉文本和图像处理

---

## 🏗️ Skia 概述

### 什么是 Skia？

Skia 是一个开源的 2D 图形库，由 Google 维护，用于：
- Chromium / Chrome 浏览器
- Android 系统
- Flutter 框架
- Google Chrome OS

```
┌─────────────────────────────────────────────────────────────┐
│                    Skia 图形库                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  核心功能:                                                   │
│  ├── 2D 图形绘制                                            │
│  ├── 文本渲染                                                │
│  ├── 图像解码/编码                                          │
│  ├── 路径操作                                                │
│  ├── 滤镜效果                                                │
│  └── GPU 加速                                                │
│                                                             │
│  支持的后端:                                                 │
│  ├── CPU (光栅化)                                           │
│  ├── OpenGL                                                 │
│  ├── Vulkan                                                 │
│  ├── Metal (macOS/iOS)                                      │
│  └── Direct3D (Windows)                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 在 Chromium 中的位置

```
┌─────────────────────────────────────────────────────────────┐
│                 Chromium 图形栈                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Blink                              │   │
│  │              (DOM/CSS/布局)                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               Paint (绘制指令)                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    Skia                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │   Canvas    │  │   Path      │  │   Paint     │ │   │
│  │  │   (画布)    │  │   (路径)    │  │   (画笔)    │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   GPU / CPU                          │   │
│  │  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐          │   │
│  │  │OpenGL │ │Vulkan │ │ Metal │ │  D3D  │          │   │
│  │  └───────┘ └───────┘ └───────┘ └───────┘          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 基础概念

### Canvas (画布)

```cpp
// Skia Canvas 是绑定的绘图目标

// 创建 Canvas
SkBitmap bitmap;
bitmap.allocPixels(SkImageInfo::MakeN32Premul(800, 600));
SkCanvas canvas(bitmap);

// 或从 GPU 表面创建
sk_sp<SkSurface> surface = SkSurfaces::RenderTarget(
    context,                    // GPU 上下文
    budgeted,
    SkImageInfo::MakeN32Premul(800, 600)
);
SkCanvas* canvas = surface->getCanvas();
```

### Paint (画笔)

```cpp
// Paint 定义绘制样式

SkPaint paint;

// 颜色
paint.setColor(SK_ColorRED);
paint.setARGB(255, 255, 0, 0);  // Alpha, R, G, B

// 抗锯齿
paint.setAntiAlias(true);

// 样式
paint.setStyle(SkPaint::kFill_Style);      // 填充
paint.setStyle(SkPaint::kStroke_Style);    // 描边
paint.setStyle(SkPaint::kStrokeAndFill_Style);

// 描边宽度
paint.setStrokeWidth(2.0f);

// 文字大小
paint.setTextSize(16.0f);
```

### Path (路径)

```cpp
// Path 用于复杂形状

SkPath path;

// 移动到起点
path.moveTo(0, 0);

// 直线
path.lineTo(100, 0);
path.lineTo(100, 100);
path.lineTo(0, 100);

// 闭合路径
path.close();

// 曲线
path.cubicTo(x1, y1, x2, y2, x3, y3);  // 贝塞尔曲线
path.quadTo(x1, y1, x2, y2);            // 二次曲线

// 圆弧
path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);

// 几何操作
SkPath result;
Op(path1, path2, SkPathOp::kUnion_SkPathOp, &result);        // 并集
Op(path1, path2, SkPathOp::kDifference_SkPathOp, &result);   // 差集
Op(path1, path2, SkPathOp::kIntersect_SkPathOp, &result);    // 交集
```

---

## 🖌️ 2D 图形绘制

### 基本形状

```cpp
// 矩形
canvas->drawRect(SkRect::MakeXYWH(10, 10, 100, 50), paint);

// 圆形
canvas->drawCircle(200, 100, 50, paint);

// 椭圆
canvas->drawOval(SkRect::MakeXYWH(10, 10, 100, 50), paint);

// 圆角矩形
SkRRect rrect;
rrect.setRectXY(SkRect::MakeXYWH(10, 10, 100, 50), 10, 10);
canvas->drawRRect(rrect, paint);

// 路径
canvas->drawPath(path, paint);

// 点
canvas->drawPoint(10, 10, paint);

// 线
canvas->drawLine(0, 0, 100, 100, paint);
```

### 变换

```cpp
// 平移
canvas->translate(100, 100);

// 旋转
canvas->rotate(45);  // 度数

// 缩放
canvas->scale(2.0f, 2.0f);

// 倾斜
canvas->skew(0.5f, 0);

// 矩阵变换
SkMatrix matrix;
matrix.setRotate(45);
matrix.postTranslate(100, 100);
canvas->concat(matrix);

// 保存/恢复状态
canvas->save();
canvas->translate(100, 100);
// 绘制操作...
canvas->restore();  // 恢复到 save 前的状态
```

### 裁剪

```cpp
// 矩形裁剪
canvas->clipRect(SkRect::MakeXYWH(0, 0, 100, 100));

// 路径裁剪
canvas->clipPath(path);

// 圆形裁剪
canvas->clipRRect(rrect);

// 裁剪操作
canvas->clipRect(rect, SkClipOp::kDifference);  // 差集裁剪
```

---

## 🖼️ 图像处理

### 图像绘制

```cpp
// 从文件加载
sk_sp<SkImage> image = SkImages::DeferredFromEncodedData(data);

// 绘制图像
canvas->drawImage(image, 0, 0);

// 绘制图像 (指定区域)
SkSamplingOptions sampling;
canvas->drawImageRect(image, SkRect::MakeWH(100, 100),
                      SkRect::MakeXYWH(0, 0, 200, 200),
                      sampling, nullptr, SkCanvas::kFast_SrcRectConstraint);

// 绘制位图
canvas->drawBitmap(bitmap, 0, 0);
```

### 图像滤镜

```cpp
// 模糊滤镜
sk_sp<SkImageFilter> blur = SkImageFilters::Blur(
    5.0f, 5.0f,  // sigma X, Y
    SkTileMode::kClamp,
    nullptr
);
paint.setImageFilter(blur);

// 阴影滤镜
sk_sp<SkImageFilter> shadow = SkImageFilters::DropShadow(
    5.0f, 5.0f,  // offset
    3.0f, 3.0f,  // blur sigma
    SK_ColorBLACK,
    nullptr
);

// 颜色矩阵
sk_sp<SkColorFilter> colorFilter = SkColorFilters::Matrix(
    // 灰度矩阵
    0.21f, 0.72f, 0.07f, 0, 0,
    0.21f, 0.72f, 0.07f, 0, 0,
    0.21f, 0.72f, 0.07f, 0, 0,
    0,     0,     0,     1, 0
);
paint.setColorFilter(colorFilter);
```

### 图像编解码

```cpp
// 解码
sk_sp<SkData> data = SkData::MakeFromFileName("image.png");
sk_sp<SkImage> image = SkImages::DeferredFromEncodedData(data);

// 编码
sk_sp<SkData> encoded = image->encodeToData(nullptr,  // 默认编码器
                                            SkEncodedImageFormat::kPNG,
                                            100);  // 质量
```

---

## 📝 文本渲染

### 文本绘制

```cpp
// 基本文本
paint.setTextSize(24);
paint.setColor(SK_ColorBLACK);
canvas->drawString("Hello, Skia!", 100, 100, paint);

// 使用字体
sk_sp<SkFontMgr> fontMgr = SkFontMgr::RefDefault();
sk_sp<SkTypeface> typeface = fontMgr->matchFamilyStyle(
    "Arial",
    SkFontStyle::Normal()
);
paint.setTypeface(typeface);

// 文字路径
SkPath textPath;
paint.getTextPath("Hello", 5, &textPath, 0, 0);
canvas->drawPath(textPath, paint);
```

### 文本测量

```cpp
// 测量文本宽度
SkFont font(typeface, 24);
SkScalar width = font.measureText("Hello", 5, SkTextEncoding::kUTF8);

// 获取文字边界
SkRect bounds;
font.measureText("Hello", 5, SkTextEncoding::kUTF8, &bounds);

// 获取字形位置
SkGlyphID glyphs[5];
int count = font.textToGlyphs("Hello", 5, SkTextEncoding::kUTF8, glyphs, 5);
SkPoint positions[5];
font.getPos(glyphs, count, positions, SkPoint::Make(0, 0));
```

---

## ⚡ GPU 加速

### Ganesh (GPU 后端)

```
┌─────────────────────────────────────────────────────────────┐
│                  Skia GPU 架构                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Skia API                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Ganesh                              │   │
│  │         (GPU 渲染抽象层)                             │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│       ┌──────────────────┼──────────────────┐              │
│       ▼                  ▼                  ▼              │
│  ┌─────────┐      ┌─────────┐      ┌─────────┐           │
│  │  GL     │      │ Vulkan  │      │  Metal  │           │
│  │ Backend │      │ Backend │      │ Backend │           │
│  └─────────┘      └─────────┘      └─────────┘           │
│       │                  │                  │              │
│       └──────────────────┼──────────────────┘              │
│                          ▼                                  │
│                    GPU 硬件                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### GPU 渲染流程

```cpp
// 创建 GPU 上下文

// OpenGL
sk_sp<GrDirectContext> context = GrDirectContext::MakeGL();

// Vulkan
sk_sp<GrDirectContext> context = GrDirectContext::MakeVulkan(vulkanBackendContext);

// Metal
sk_sp<GrDirectContext> context = GrDirectContext::MakeMetal(mtlBackendContext);

// 创建 GPU Surface
sk_sp<SkSurface> surface = SkSurfaces::RenderTarget(
    context.get(),
    budgeted,
    SkImageInfo::MakeN32Premul(800, 600)
);

// 绘制
SkCanvas* canvas = surface->getCanvas();
canvas->clear(SK_ColorWHITE);
// 绘制操作...

// 刷新到屏幕
surface->flushAndSubmit();
```

### 性能优化

```cpp
// 1. 使用 Atlasing (纹理图集)
// Skia 自动将小图像合并到大纹理中

// 2. 批处理绘制
// 减少状态切换
for (const auto& rect : rects) {
  canvas->drawRect(rect, paint);  // 尽量使用相同 paint
}

// 3. 使用 Path Cache
// 复杂路径会被缓存为纹理

// 4. 避免频繁创建对象
SkPaint paint;  // 复用 paint 对象
for (const auto& shape : shapes) {
  paint.setColor(shape.color);
  canvas->drawRect(shape.rect, paint);
}

// 5. 使用 Deferred Rendering
// Skia 会自动优化绘制顺序
```

---

## 🔧 Chromium 中的 Skia

### 绘制命令

```cpp
// Chromium 使用 cc (Compositor) 层

// PaintRecord 记录绘制命令
cc::PaintRecorder recorder;
cc::PaintCanvas* canvas = recorder.beginRecording(bounds);

// 使用 Skia API 绘制
canvas->drawRect(rect, paint);
canvas->drawImage(image, x, y);

cc::PaintRecord record = recorder.finishRecording();
```

### 合成器集成

```
┌─────────────────────────────────────────────────────────────┐
│                Chromium 合成流程                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Blink                                                      │
│    │                                                        │
│    │ Paint (生成 PaintRecord)                               │
│    ▼                                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Paint Layer                          │   │
│  │            (记录绘制命令)                             │   │
│  └─────────────────────────────────────────────────────┘   │
│    │                                                        │
│    │ Commit                                                │
│    ▼                                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               Compositor                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │ Picture     │  │ Picture     │  │ Picture     │ │   │
│  │  │ Layer       │  │ Layer       │  │ Layer       │ │   │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
│    │                                                        │
│    │ Rasterize                                             │
│    ▼                                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Skia                                │   │
│  │           (光栅化/渲染)                               │   │
│  └─────────────────────────────────────────────────────┘   │
│    │                                                        │
│    │ GPU Compose                                           │
│    ▼                                                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  Screen                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 实践练习

- [ ] 使用 Skia 编写简单的 2D 绘图程序
- [ ] 对比 CPU 和 GPU 渲染性能
- [ ] 实现自定义的图像滤镜
- [ ] 研究 Chromium 中的 Skia 调用

---

## 🔗 相关链接

- [[10-渲染管线详解]] - 完整渲染流程
- [[13-GPU加速]] - GPU 渲染深入
- [[05-Blink渲染引擎]] - Blink 与 Skia 的交互
- [Skia 官网](https://skia.org/)
- [Skia 源码](https://skia.googlesource.com/skia/)

---

#tech/chromium/skia
