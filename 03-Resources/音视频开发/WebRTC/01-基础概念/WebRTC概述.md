---
title: WebRTC 概述
date: 2026-03-02
tags:
  - WebRTC
  - 音视频
  - 实时通信
difficulty: ⭐⭐
status: 🌱 学习中
related:
  - RTCPeerConnection
  - getUserMedia
---

# WebRTC 概述

> WebRTC (Web Real-Time Communication) 是一项开源技术，支持浏览器和移动应用之间进行实时音视频通信，无需安装插件

## 📌 一句话概述

WebRTC 让浏览器具备了原生的实时音视频通信能力，实现了"点对点"（Peer-to-Peer）的数据传输。

---

## 🎯 是什么

### 定义

WebRTC 是一个**免费的开放源代码项目**，通过简单的 API 为浏览器和移动应用程序提供实时通信（RTC）功能。

### 核心特性

| 特性 | 说明 |
|------|------|
| **跨平台** | 支持所有主流浏览器和移动平台 |
| **无需插件** | 原生浏览器支持 |
| **P2P 通信** | 点对点直接传输，减少服务器压力 |
| **安全加密** | 强制使用 DTLS/SRTP 加密 |
| **高质量** | 支持高清音视频，自适应网络 |

---

## 🌐 应用场景

### 1. 视频会议
- Zoom、Google Meet、腾讯会议的 Web 版
- 在线教育平台
- 远程医疗问诊

### 2. 实时协作
- 在线文档协作
- 远程桌面控制
- 实时白板

### 3. 在线客服
- 视频客服
- 在线咨询
- 远程协助

### 4. 社交娱乐
- 视频聊天
- 在线直播（连麦）
- 云游戏

### 5. IoT 物联网
- 智能摄像头
- 远程监控
- 智能家居控制

---

## 🏗️ WebRTC 架构

### 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      Web Application                         │
│                    (开发者编写的应用)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     WebRTC API Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ getUserMedia │  │RTCPeerConn-  │  │RTCData-      │       │
│  │              │  │  ection      │  │  Channel     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    WebRTC C++ Layer                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │   Session   │ │   Network   │ │    Audio    │            │
│  │  Management │ │    Stack    │ │   Engine    │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │    Video    │ │   SRTP      │ │    ICE      │            │
│  │   Engine    │ │   Stack     │ │   Stack     │            │
│  └─────────────┘ └─────────────┘ └─────────────┘            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Operating System                            │
│         (Windows / macOS / Linux / iOS / Android)           │
└─────────────────────────────────────────────────────────────┘
```

### 三大核心组件

| 组件 | 功能 | 作用 |
|------|------|------|
| **音频引擎** | 音频采集、编解码、处理 | 回声消除、噪声抑制、增益控制 |
| **视频引擎** | 视频采集、编解码、渲染 | 帧率控制、分辨率调整 |
| **网络传输** | 数据传输、NAT 穿透 | ICE/STUN/TURN、SRTP 加密 |

---

## 🔧 三大核心 API

### 1. getUserMedia
获取本地音视频流

```javascript
// 获取摄像头和麦克风
const stream = await navigator.mediaDevices.getUserMedia({
  video: true,
  audio: true
});

// 将流绑定到 video 元素
const videoElement = document.querySelector('video');
videoElement.srcObject = stream;
```

### 2. RTCPeerConnection
建立点对点连接

```javascript
// 创建连接
const pc = new RTCPeerConnection(configuration);

// 添加本地流
stream.getTracks().forEach(track => {
  pc.addTrack(track, stream);
});

// 接收远程流
pc.ontrack = (event) => {
  const remoteVideo = document.querySelector('#remote-video');
  remoteVideo.srcObject = event.streams[0];
};
```

### 3. RTCDataChannel
传输任意数据

```javascript
// 创建数据通道
const channel = pc.createDataChannel('chat');

// 发送消息
channel.send('Hello!');

// 接收消息
channel.onmessage = (event) => {
  console.log('Received:', event.data);
};
```

---

## 🌍 浏览器支持

### 桌面浏览器

| 浏览器 | 支持版本 | 备注 |
|--------|----------|------|
| Chrome | 23+ | 完整支持 |
| Firefox | 22+ | 完整支持 |
| Safari | 11+ | 完整支持 |
| Edge | 79+ (Chromium) | 完整支持 |
| Opera | 18+ | 完整支持 |

### 移动浏览器

| 浏览器 | iOS | Android |
|--------|-----|---------|
| Chrome | ✅ (12+) | ✅ (29+) |
| Safari | ✅ (11+) | - |
| Firefox | ✅ | ✅ (24+) |
| 微信浏览器 | ⚠️ 受限 | ⚠️ 受限 |

### 检测浏览器支持

```javascript
function checkWebRTCSupport() {
  const support = {
    getUserMedia: !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia),
    RTCPeerConnection: !!window.RTCPeerConnection,
    RTCDataChannel: !!(window.RTCPeerConnection && new RTCPeerConnection().createDataChannel),
  };

  console.log('WebRTC Support:', support);
  return support;
}

checkWebRTCSupport();
```

---

## 🔐 安全机制

WebRTC 强制使用加密传输：

| 协议 | 用途 | 说明 |
|------|------|------|
| **DTLS** | 数据通道加密 | 基于 UDP 的 TLS |
| **SRTP** | 媒体数据加密 | 安全的 RTP |
| **ICE** | 安全的连接建立 | 防止 IP 泄露 |

```javascript
// WebRTC 强制加密，无法禁用
const pc = new RTCPeerConnection({
  iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
});

// 所有传输都自动加密
// 无法选择明文传输
```

---

## 📊 WebRTC vs 传统方案

| 特性 | WebRTC | Flash | 插件方案 |
|------|--------|-------|----------|
| 安装 | 无需 | 需要 | 需要 |
| 安全 | 强制加密 | 可选 | 可选 |
| 移动端 | 原生支持 | 不支持 | 有限支持 |
| 延迟 | < 500ms | > 1s | > 1s |
| 标准 | W3C/IETF | 私有 | 私有 |
| 状态 | **活跃** | 已废弃 | 逐渐淘汰 |

---

## 🔗 相关笔记

- [[getUserMedia]] - 媒体采集详解
- [[RTCPeerConnection]] - 连接管理
- [[RTCDataChannel]] - 数据通道
- [[SDP会话描述]] - 会话描述协议

---

## 📚 参考资料

- [WebRTC Official](https://webrtc.org/)
- [MDN WebRTC API](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)
- [WebRTC for the Curious](https://webrtcforthecurious.com/)

---
#tech/webrtc/basics
