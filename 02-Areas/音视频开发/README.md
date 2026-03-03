# 🎬 音视频开发

> 实时通信与媒体处理

## 📊 技能树

```
音视频开发
├── 实时通信
│   ├── WebRTC ⭐
│   ├── 信令服务器
│   ├── STUN/TURN
│   └── SFU/MCU
│
├── 编解码
│   ├── H.264/H.265
│   ├── VP8/VP9/AV1
│   ├── Opus/AAC
│   └── FFmpeg ⭐
│
├── 流媒体
│   ├── RTMP
│   ├── HLS
│   ├── DASH
│   └── RTSP
│
└── 底层
    ├── 音频采集
    ├── 视频渲染
    └── 性能优化
```

## 🎯 当前重点

### WebRTC 🔴
- [ ] 连接建立流程
- [ ] ICE/STUN/TURN
- [ ] SDP 协商
- [ ] MediaStream API
- [ ] DataChannel
- [ ] SFU 架构

### FFmpeg
- [ ] 命令行工具
- [ ] API 使用
- [ ] 滤镜系统
- [ ] 硬件加速

### 编解码
- [ ] H.264 原理
- [ ] Opus 音频
- [ ] 码率控制

## 📚 学习资源

```dataview
TABLE 
  category as 分类,
  status as 状态
FROM "03-Resources/AudioVideo"
WHERE file.name != "README"
SORT status
```

## 🎯 学习路径

```
1. 基础概念
   └→ 音视频基础 / 编码原理

2. WebRTC 入门
   └→ API 使用 / 简单通话

3. 深入理解
   └→ 协议分析 / 源码阅读

4. 工程实践
   └→ SFU 开发 / 性能优化

5. 扩展领域
   └→ 播放器 / 直播系统
```

## 🔗 相关项目

- [[WebRTC 学习项目]]
- [[FFmpeg 实践]]

## 📝 问题记录

```dataview
LIST
FROM #问题记录
WHERE contains(file.folder, "音视频")
SORT date DESC
```

---
#area/audiovideo
