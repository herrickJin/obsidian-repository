---
title: webrtc-internals 调试工具
date: 2026-03-02
tags:
  - WebRTC
  - 调试
  - Chrome
  - internals
difficulty: ⭐⭐
status: 🌱 学习中
related:
  - WebRTC统计信息
  - 问题排查指南
---

# webrtc-internals 调试工具

> Chrome 内置的 WebRTC 调试工具，提供详细的连接、媒体、网络信息

## 📌 核心功能

- 查看所有 PeerConnection 状态
- 实时统计信息图表
- SDP 和 ICE 候选详情
- 通话质量分析

---

## 🚀 打开方式

### Chrome

```
地址栏输入: chrome://webrtc-internals
```

### Edge

```
地址栏输入: edge://webrtc-internals
```

---

## 🖥️ 界面结构

```
┌─────────────────────────────────────────────────────────────┐
│  chrome://webrtc-internals                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  PeerConnection 列表                                 │   │
│  │  ▼ PeerConnection 1 (tabs)                          │   │
│  │    - Stats tables                                   │   │
│  │    - Stats graphs                                   │   │
│  │    - Connection log                                 │   │
│  │    - SDP                                            │   │
│  │    - ICE candidates                                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Create Dump (导出)                                  │   │
│  │  [Download the PeerConnection updates log]          │   │
│  │  [Download the PeerConnection stats]                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Stats Tables 标签页

### 显示内容

| 表格 | 内容 |
|------|------|
| **Video BWE** | 视频带宽估计 |
| **Video Send** | 视频发送统计 |
| **Video Recv** | 视频接收统计 |
| **Audio Send** | 音频发送统计 |
| **Audio Recv** | 音频接收统计 |

### 关键指标解读

```
Video Send (视频发送):
├── ssrc              - 同步源标识
├── codecId           - 编解码器 ID
├── packetsSent       - 发送包数
├── bytesSent         - 发送字节数
├── framesEncoded     - 已编码帧数
├── framesSent        - 已发送帧数
├── frameWidth        - 帧宽度
├── frameHeight       - 帧高度
├── framesPerSecond   - 帧率
├── targetBitrate     - 目标码率
├── encodedFrames     - 编码帧数
├── hugeFramesSent    - 大帧数
└── qualityLimitationReason - 质量限制原因

Video Recv (视频接收):
├── packetsReceived   - 接收包数
├── packetsLost       - 丢包数
├── bytesReceived     - 接收字节数
├── framesDecoded     - 已解码帧数
├── framesDropped     - 丢弃帧数
├── frameWidth        - 帧宽度
├── frameHeight       - 帧高度
├── framesPerSecond   - 帧率
├── jitter            - 抖动
├── jitterBufferDelay - 抖动缓冲延迟
├── decodeTime        - 解码时间
└── firCount/pliCount/nackCount - 重传统计
```

---

## 📈 Stats Graphs 标签页

### 图表类型

1. **带宽估计图** - 显示发送/接收带宽变化
2. **帧率图** - 显示视频帧率变化
3. **分辨率图** - 显示视频分辨率变化
4. **丢包图** - 显示丢包率变化
5. **延迟图** - 显示 RTT 变化

### 如何阅读图表

```
┌─────────────────────────────────────────────────────────────┐
│  Bitrate (bps)                                              │
│  2M ┤                                                       │
│     │    ╭──────╮                                           │
│  1M ┤╭───╯      ╰──────╮                                    │
│     │                  ╰──────                               │
│  0  └──────────────────────────────────────────────────►    │
│     0s    10s    20s    30s    40s    50s    60s            │
│                                                             │
│  解读:                                                      │
│  - 开始时带宽上升（探测阶段）                                │
│  - 中期稳定（找到合适带宽）                                  │
│  - 波动表示网络不稳定                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 Connection Log 标签页

### 日志级别

```
Log levels:
- error   (红色)    - 错误
- warning (黄色)    - 警告
- info    (蓝色)    - 信息
- debug   (灰色)    - 调试
```

### 常见日志事件

```
连接建立过程:
1. CreateOffer
2. SetLocalDescription
3. IceGatheringStateChange (new -> gathering -> complete)
4. IceConnectionStateChange (new -> checking -> connected)
5. SetRemoteDescription
6. IceCandidateReceived
7. ConnectionEstablished

常见问题日志:
- ICE connection failed
- DTLS handshake failed
- Candidate pair failed
- Transport disconnected
```

### 日志分析示例

```
正常连接日志:
[2026-03-02 10:00:00] CreateOffer
[2026-03-02 10:00:00] SetLocalDescription (type: offer)
[2026-03-02 10:00:01] ICE: gathering state changed to complete
[2026-03-02 10:00:01] SetRemoteDescription (type: answer)
[2026-03-02 10:00:02] ICE: connection state changed to connected
[2026-03-02 10:00:02] DTLS: handshake completed

连接失败日志:
[2026-03-02 10:00:00] CreateOffer
[2026-03-02 10:00:01] ICE: gathering state changed to complete
[2026-03-02 10:00:05] ICE: connection state changed to checking
[2026-03-02 10:00:15] ICE: connection state changed to failed ❌
```

---

## 📄 SDP 标签页

### 显示内容

```
Local SDP (Offer/Answer):
v=0
o=- 123456789 2 IN IP4 127.0.0.1
s=-
t=0 0
...

Remote SDP (Answer/Offer):
v=0
...
```

### 分析要点

```
检查项:
1. ice-ufrag / ice-pwd - ICE 认证
2. fingerprint - DTLS 指纹
3. a=candidate - ICE 候选
4. a=rtpmap - 编解码映射
5. a=fmtp - 格式参数
6. a=rtcp-fb - RTCP 反馈
```

---

## 🧊 ICE Candidates 标签页

### 候选信息

```
Local Candidates:
┌──────────┬────────────────┬──────┬────────┬──────────┐
│ Type     │ IP             │ Port │ Proto  │ Priority │
├──────────┼────────────────┼──────┼────────┼──────────┤
│ host     │ 192.168.1.100  │ 54321│ udp    │ 2122260223│
│ srflx    │ 203.0.113.1    │ 54322│ udp    │ 1686052607│
│ relay    │ 203.0.113.3    │ 3478 │ udp    │ 41885439 │
└──────────┴────────────────┴──────┴────────┴──────────┘

Remote Candidates:
┌──────────┬────────────────┬──────┬────────┬──────────┐
│ Type     │ IP             │ Port │ Proto  │ Priority │
├──────────┼────────────────┼──────┼────────┼──────────┤
│ host     │ 192.168.2.100  │ 54323│ udp    │ 2122260223│
│ srflx    │ 203.0.113.2    │ 54324│ udp    │ 1686052607│
└──────────┴────────────────┴──────┴────────┴──────────┘
```

### 候选对状态

```
Active Candidate Pair:
Local:  192.168.1.100:54321 (host)
Remote: 203.0.113.2:54324 (srflx)
State:  succeeded
RTT:    45ms
```

---

## 📥 导出数据

### 导出选项

```
1. Download the PeerConnection updates log
   - 下载连接更新日志 (.json)

2. Download the PeerConnection stats
   - 下载统计数据 (.json)
```

### 分析导出数据

```javascript
// 解析导出的 JSON
const data = JSON.parse(downloadedJson);

// 查看统计历史
data.stats.forEach(entry => {
  console.log(entry.timestamp, entry.values);
});

// 查看事件历史
data.updates.forEach(update => {
  console.log(update.time, update.type, update.value);
});
```

---

## 🔧 调试技巧

### 1. 检查连接状态

```
正常状态:
- ICE: connected / completed
- DTLS: connected
- Connection: connected

异常状态:
- ICE: checking (卡住) → 检查 STUN/TURN
- ICE: failed → 检查网络/防火墙
- ICE: disconnected → 网络中断
```

### 2. 检查带宽问题

```
查看 Video BWE:
- availableBitrate 估算带宽
- actualBitrate 实际带宽
- targetBitrate 目标带宽

如果 targetBitrate 一直很低:
- 检查拥塞控制
- 检查网络质量
```

### 3. 检查丢包

```
查看 packetsLost / packetsReceived:
- 丢包率 > 5%: 网络问题
- 丢包率 > 10%: 严重问题

检查 nackCount / pliCount:
- 高 NACK: 需要重传多
- 高 PLI: 解码失败，请求关键帧
```

### 4. 检查编解码

```
查看 codecId:
- 确认使用的编解码器
- 检查是否使用了预期的编解码器

查看 qualityLimitationReason:
- bandwidth: 带宽不足
- cpu: CPU 不足
- other: 其他原因
```

---

## 🔗 相关笔记

- [[WebRTC统计信息]] - Stats API 详解
- [[问题排查指南]] - 问题诊断流程
- [[SDP会话描述]] - SDP 格式

---

## 📚 参考资料

- [Chrome WebRTC Internals](https://webrtc.org/getting-started/chrome-webrtc-internals)
- [Debugging WebRTC](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Debugging)

---
#tech/webrtc/debug
