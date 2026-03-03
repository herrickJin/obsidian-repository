# 📚 资源库

> 技术学习笔记与参考资料

## 📂 目录结构

```
03-Resources/
├── 前端开发/           # Vue, TS, Canvas, Electron...
├── 后端开发/           # Rust, C++, Go, Java, Python, C#...
├── 音视频开发/         # WebRTC, FFmpeg, 编解码...
├── 开发工具/           # Git, Docker, Vim...
└── 计算机基础/         # 算法, 网络, 操作系统...
```

## 📊 学习统计

```dataview
TABLE 
  length(rows) as 笔记数
FROM "03-Resources"
WHERE file.name != "README"
GROUP BY file.folder
```

## 🔥 最近更新

```dataview
TABLE 
  file.folder as 分类,
  file.mtime as 更新时间
FROM "03-Resources"
WHERE file.name != "README"
SORT file.mtime DESC
LIMIT 15
```

## 📌 快速导航

| 分类 | 说明 | 进入 |
|------|------|------|
| 🎨 前端开发 | Vue, TypeScript, Canvas, Electron | [[前端开发/README\|查看]] |
| ⚙️ 后端开发 | Rust, C++, Go, Java, Python, C# | [[后端开发/README\|查看]] |
| 🎬 音视频开发 | WebRTC, FFmpeg, 编解码 | [[音视频开发/README\|查看]] |
| 🛠️ 开发工具 | Git, Docker, Vim | [[开发工具/README\|查看]] |
| 📖 计算机基础 | 算法, 网络, 操作系统 | [[计算机基础/README\|查看]] |

---
#resources
