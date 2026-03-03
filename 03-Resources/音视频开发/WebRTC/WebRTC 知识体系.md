---
title: WebRTC 知识体系
date: 2026-03-02
tags:
  - WebRTC
  - 音视频
  - 实时通信
difficulty: ⭐⭐⭐⭐
status: 🔥 重点学习
related:
  - FFmpeg
  - 编解码
  - 流媒体
---

# WebRTC 知识体系

> WebRTC (Web Real-Time Communication) 是一项支持浏览器和移动应用进行实时音视频通信的技术

## 📚 知识体系全景

```
WebRTC
│
├── 🎯 第一层：基础概念
│   ├── 什么是 WebRTC
│   ├── 应用场景
│   ├── 浏览器支持
│   └── 核心 API 概览
│
├── 🔧 第二层：核心 API
│   ├── getUserMedia - 媒体采集
│   ├── RTCPeerConnection - 连接管理
│   ├── RTCDataChannel - 数据通道
│   └── MediaStream - 媒体流
│
├── 🌐 第三层：连接建立
│   ├── SDP 会话描述
│   ├── ICE 候选
│   ├── STUN/TURN 服务器
│   ├── NAT 穿透
│   └── 信令服务器
│
├── 📦 第四层：媒体处理
│   ├── 编解码器 (Codec)
│   │   ├── VP8/VP9/AV1
│   │   ├── H.264/H.265
│   │   ├── Opus/AAC/G.711
│   │   └── 编解码协商
│   ├── SDP 协商
│   ├── 带宽估计 (BWE)
│   ├── 模拟增益控制 (AGC)
│   ├── 回声消除 (AEC)
│   └── 噪声抑制 (ANS)
│
├── 📡 第五层：网络传输
│   ├── RTP/RTCP 协议
│   ├── SRTP 加密
│   ├── RTCP 反馈机制
│   ├── 拥塞控制
│   ├── FEC 前向纠错
│   └── Jitter Buffer
│
├── ⚡ 第六层：质量控制
│   ├── QoS 策略
│   ├── 网络质量检测
│   ├── 码率自适应
│   ├── 分辨率动态调整
│   └── 延迟优化
│
├── 🔍 第七层：调试与分析
│   ├── WebRTC Internal Stats
│   ├── chrome://webrtc-internals
│   ├── getStats API
│   └── 问题排查
│
└── 🚀 第八层：实战应用
    ├── 1v1 视频通话
    ├── 多人会议 (SFU/MCU)
    ├── 屏幕共享
    ├── 录制与回放
    └── 跨平台开发
```

---

## 📁 目录结构

```
WebRTC/
├── README.md              # 本文件 - 知识体系索引
├── 01-基础概念/
│   ├── WebRTC概述.md
│   ├── 应用场景.md
│   └── 浏览器兼容性.md
├── 02-核心API/
│   ├── getUserMedia.md
│   ├── RTCPeerConnection.md
│   ├── RTCDataChannel.md
│   └── MediaStream.md
├── 03-连接建立/
│   ├── SDP会话描述.md
│   ├── ICE候选.md
│   ├── STUN-TURN服务器.md
│   ├── NAT穿透.md
│   └── 信令服务器.md
├── 04-媒体处理/
│   ├── 编解码器.md
│   ├── SDP协商.md
│   ├── 带宽估计BWE.md
│   ├── 音频处理.md
│   └── 视频处理.md
├── 05-网络传输/
│   ├── RTP-RTCP协议.md
│   ├── SRTP加密.md
│   ├── 拥塞控制.md
│   ├── FEC前向纠错.md
│   └── JitterBuffer.md
├── 06-质量控制/
│   ├── QoS策略.md
│   ├── 网络检测.md
│   ├── 码率自适应.md
│   └── 延迟优化.md
├── 07-调试分析/
│   ├── WebRTC统计信息.md
│   ├── webrtc-internals.md
│   └── 问题排查指南.md
└── 08-实战应用/
    ├── 1v1视频通话.md
    ├── 多人会议架构.md
    ├── 屏幕共享.md
    ├── 录制回放.md
    └── 跨平台开发.md
```

---

## 🎯 学习路径

### 阶段一：入门基础（2周）
- [ ] 理解 WebRTC 基本概念和应用场景
- [ ] 掌握 getUserMedia 获取音视频流
- [ ] 理解 MediaStream 和 MediaStreamTrack
- [ ] 实现本地视频预览

### 阶段二：连接建立（3周）
- [ ] 理解 RTCPeerConnection 工作原理
- [ ] 掌握 Offer/Answer 交互流程
- [ ] 理解 ICE 候选收集过程
- [ ] 搭建简单信令服务器
- [ ] 实现 1v1 视频通话

### 阶段三：深入理解（3周）
- [ ] 深入理解 SDP 格式和协商过程
- [ ] 掌握 NAT 穿透原理
- [ ] 部署 STUN/TURN 服务器
- [ ] 理解编解码器协商

### 阶段四：网络与质量（2周）
- [ ] 理解 RTP/RTCP 协议
- [ ] 掌握带宽估计 (BWE) 算法
- [ ] 理解拥塞控制机制
- [ ] 掌握 QoS 优化策略

### 阶段五：实战进阶（4周）
- [ ] 实现多人会议 (SFU 架构)
- [ ] 实现屏幕共享功能
- [ ] 实现录制与回放
- [ ] 跨平台应用开发

---

## 📊 核心概念速查

### WebRTC 三大核心 API

| API | 作用 | 关键方法 |
|-----|------|----------|
| `getUserMedia` | 获取本地媒体流 | `navigator.mediaDevices.getUserMedia()` |
| `RTCPeerConnection` | 建立点对点连接 | `createOffer()`, `createAnswer()`, `setLocalDescription()` |
| `RTCDataChannel` | 传输任意数据 | `send()`, `onmessage` |

### 连接建立流程

```
┌─────────────┐                    ┌─────────────┐
│   Peer A    │                    │   Peer B    │
└──────┬──────┘                    └──────┬──────┘
       │                                  │
       │  1. getUserMedia()               │
       │ ◄────────────────────            │
       │                                  │
       │  2. createOffer()                │
       │ ◄────────────────────            │
       │                                  │
       │  3. setLocalDescription()        │
       │ ◄────────────────────            │
       │                                  │
       │  4. Offer (via Signaling)        │
       │ ─────────────────────────────────►
       │                                  │
       │                    5. setRemoteDescription()
       │                       ◄──────────┤
       │                                  │
       │                    6. createAnswer()
       │                       ◄──────────┤
       │                                  │
       │                    7. setLocalDescription()
       │                       ◄──────────┤
       │                                  │
       │  8. Answer (via Signaling)       │
       │ ◄─────────────────────────────────
       │                                  │
       │  9. setRemoteDescription()       │
       │ ◄────────────────────            │
       │                                  │
       │  10. ICE Candidates Exchange     │
       │ ◄───────────────────────────────►│
       │                                  │
       │  11. P2P Connection Established  │
       │ ═════════════════════════════════│
       │                                  │
```

---

## 🔗 相关知识

- [[03-Resources/音视频开发/编解码/README|编解码原理]]
- [[03-Resources/音视频开发/FFmpeg/README|FFmpeg]]
- [[03-Resources/音视频开发/流媒体/README|流媒体协议]]
- [[03-Resources/前端开发/Canvas/README|Canvas]] - 视频渲染
- [[03-Resources/后端开发/Rust/README|Rust]] - 服务端开发

---

## 📚 推荐资源

### 官方文档
- [WebRTC API - MDN](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)
- [WebRTC Samples](https://webrtc.github.io/samples/)
- [W3C WebRTC Specification](https://www.w3.org/TR/webrtc/)

### 开源项目
- [Jitsi](https://github.com/jitsi/jitsi-meet) - 开源视频会议
- [mediasoup](https://github.com/versatica/mediasoup) - SFU 框架
- [Pion](https://github.com/pion/webrtc) - Go WebRTC 库
- [aiortc](https://github.com/aiortc/aiortc) - Python WebRTC

### 学习资料
- [WebRTC for the Curious](https://webrtcforthecurious.com/)
- [Real-Time Communication with WebRTC](https://book.douban.com/subject/25835112/)

---

## 📝 学习记录

| 日期 | 内容 | 状态 |
|------|------|------|
| 2026-03-02 | 创建知识体系框架 | ✅ |

---
#tech/webrtc
