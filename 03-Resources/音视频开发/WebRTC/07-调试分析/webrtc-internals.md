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
- 导出调试数据

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

### Opera

```
地址栏输入: opera://webrtc-internals
```

> ⚠️ 注意：需要在有 WebRTC 连接的页面打开后，webrtc-internals 才会显示数据

---

## 🖥️ 界面结构详解

### 整体布局

```
┌─────────────────────────────────────────────────────────────┐
│  chrome://webrtc-internals                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  全局设置                                            │   │
│  │  - Enable diagnostic audio recordings               │   │
│  │  - Enable event log recording                       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  PeerConnection 列表 (每个连接一个区块)              │   │
│  │  ▼ PeerConnection 0 (from page1.html)               │   │
│  │    [Stats tables] [Stats graphs] [Connection log]   │   │
│  │    [SDP] [ICE candidates]                           │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  ▼ PeerConnection 1 (from page2.html)               │   │
│  │    ...                                              │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Create Dump (导出数据)                              │   │
│  │  [Download the PeerConnection updates log]          │   │
│  │  [Download the PeerConnection stats]                │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Stats Tables 标签页

### 完整表格列表

| 表格名称 | 说明 | 关键字段 |
|----------|------|----------|
| **Video BWE** | 视频带宽估计 | availableBitrate, targetBitrate |
| **Video Send** | 视频发送统计 | bytesSent, framesEncoded, targetBitrate |
| **Video Recv** | 视频接收统计 | bytesReceived, framesDecoded, jitter |
| **Audio Send** | 音频发送统计 | bytesSent, packetsSent |
| **Audio Recv** | 音频接收统计 | bytesReceived, packetsLost, jitter |

### Video Send 详细字段

```
┌──────────────────────────┬────────────────────────────────────┐
│ 字段                     │ 说明                                │
├──────────────────────────┼────────────────────────────────────┤
│ ssrc                     │ 同步源标识 (SSRC)                  │
│ codecId                  │ 编解码器 ID (指向 codec 表)         │
│ packetsSent              │ 已发送的 RTP 包数                   │
│ bytesSent                │ 已发送的字节数                      │
│ framesEncoded            │ 已编码的帧数                        │
│ framesSent               │ 已发送的帧数                        │
│ frameWidth               │ 视频帧宽度 (像素)                   │
│ frameHeight              │ 视频帧高度 (像素)                   │
│ framesPerSecond          │ 当前帧率 (fps)                      │
│ totalEncodeTime          │ 总编码时间 (秒)                     │
│ totalEncodedBytesTarget  │ 目标编码字节数                      │
│ targetBitrate            │ 目标码率 (bps)                      │
│ bitrate (computed)       │ 实际码率 (bps)                      │
│ hugeFramesSent           │ 大帧数量 (> 通常帧 3 倍)            │
│ frames                    │ 编码的帧详细信息                    │
│ qualityLimitationReason  │ 质量限制原因                        │
│ qualityLimitationDurations│ 各限制原因的持续时间               │
│ qualityLimitationResolutionChanges│ 因限制导致的分辨率变化次数│
│ encoderImplementation    │ 编码器实现 (软件/硬件)              │
│ powerEfficientEncoder    │ 是否使用低功耗编码器                │
│ scalable                 │ 是否可扩展 (SVC)                    │
│ retransmittedPacketsSent │ 重传的包数                          │
│ retransmittedBytesSent   │ 重传的字节数                        │
│ nackCount                │ 收到的 NACK 请求数                  │
│ firCount                 │ 发送的 FIR 请求数                   │
│ pliCount                 │ 发送的 PLI 请求数                   │
└──────────────────────────┴────────────────────────────────────┘
```

### Video Recv 详细字段

```
┌──────────────────────────┬────────────────────────────────────┐
│ 字段                     │ 说明                                │
├──────────────────────────┼────────────────────────────────────┤
│ ssrc                     │ 同步源标识                          │
│ codecId                  │ 编解码器 ID                         │
│ transportId              │ 传输层 ID                           │
│ packetsReceived          │ 已接收的包数                        │
│ packetsLost              │ 丢失的包数                          │
│ bytesReceived            │ 已接收的字节数                      │
│ lastPacketReceivedTimestamp│ 最后收到包的时间                  │
│ headerBytesReceived      │ 接收的头字节数                      │
│ jitter                   │ 抖动 (秒)                           │
│ jitterBufferDelay        │ 抖动缓冲总延迟 (秒)                 │
│ jitterBufferEmittedCount │ 抖动缓冲发出的包数                  │
│ jitterBufferMinimumDelay │ 最小抖动缓冲延迟                    │
│ jitterBufferTargetDelay  │ 目标抖动缓冲延迟                    │
│ framesReceived           │ 接收的完整帧数                      │
│ framesDecoded            │ 已解码的帧数                        │
│ framesDropped            │ 丢弃的帧数                          │
│ frameWidth               │ 帧宽度                              │
│ frameHeight              │ 帧高度                              │
│ framesPerSecond          │ 帧率                                │
│ totalDecodeTime          │ 总解码时间 (秒)                     │
│ totalInterFrameDelay     │ 帧间总延迟                          │
│ totalSquaredInterFrameDelay│ 帧间延迟平方和                     │
│ firCount                 │ 发送的 FIR 数                       │
│ pliCount                 │ 发送的 PLI 数                       │
│ nackCount                │ 发送的 NACK 数                      │
│ decoderImplementation    │ 解码器实现                          │
│ powerEfficientDecoder    │ 是否低功耗解码                      │
│ timingInfo               │ 时序信息                            │
└──────────────────────────┴────────────────────────────────────┘
```

### Audio Send/Recv 详细字段

```
Audio Send:
├── ssrc              - SSRC
├── codecId           - 编解码器 ID
├── packetsSent       - 发送包数
├── bytesSent         - 发送字节数
├── totalSamplesSent  - 发送采样总数
├── samplesEncodedWithSilk - SILK 编码采样数 (Opus)
├── samplesEncodedWithCelt - CELT 编码采样数 (Opus)
├── totalEncodeTime   - 总编码时间
├── averageEncodeTime - 平均编码时间
├── bitrate (computed)- 实际码率
└── targetBitrate     - 目标码率

Audio Recv:
├── ssrc              - SSRC
├── codecId           - 编解码器 ID
├── packetsReceived   - 接收包数
├── packetsLost       - 丢包数
├── bytesReceived     - 接收字节数
├── jitter            - 抖动 (秒)
├── jitterBufferDelay - 抖动缓冲延迟
├── jitterBufferEmittedCount - 抖动缓冲发出包数
├── totalSamplesReceived - 接收采样总数
├── totalSamplesDecoded - 解码采样总数
├── totalDecodeTime   - 总解码时间
├── averageDecodeTime - 平均解码时间
├── concealedSamples  - 隐藏采样数 (PLC)
├── silentConcealedSamples - 静音隐藏采样
├── insertedSamplesForDeceleration - 插入采样 (减速)
├── removedSamplesForAcceleration - 移除采样 (加速)
├── audioLevel        - 音频电平 (0-1)
└── totalAudioEnergy  - 总音频能量
```

### Video BWE 详细字段

```
Video Bandwidth Estimation:
├── availableSendBandwidth - 可用发送带宽
├── availableReceiveBandwidth - 可用接收带宽
├── targetDelay          - 目标延迟
├── actualDelay          - 实际延迟
├── sendBandwidth        - 发送带宽
├── receiveBandwidth     - 接收带宽
├── retransmitBitrate    - 重传码率
├── paddingBitrate       - 填充码率
├── targetBitrate        - 目标码率
└── effectiveFramerate   - 有效帧率
```

---

## 📈 Stats Graphs 标签页

### 图表类型详解

#### 1. 带宽图 (Bitrate)

```
┌─────────────────────────────────────────────────────────────┐
│  Bitrate (bps)                                              │
│  3M ┤                          ╭──────                      │
│     │                    ╭─────╯                            │
│  2M ┤              ╭─────╯                                  │
│     │        ╭─────╯                                        │
│  1M ┤  ╭─────╯                                              │
│     │──╯                                                    │
│  0  └──────────────────────────────────────────────────►    │
│     0s    10s    20s    30s    40s    50s    60s            │
│                                                             │
│  曲线说明:                                                  │
│  - 蓝线: 发送码率                                          │
│  - 绿线: 目标码率                                          │
│  - 红线: 可用带宽估计                                      │
│                                                             │
│  诊断要点:                                                  │
│  - 快速上升: 带宽探测阶段                                   │
│  - 平稳: 稳定状态                                          │
│  - 波动大: 网络不稳定                                      │
│  - 突降: 网络拥塞                                          │
└─────────────────────────────────────────────────────────────┘
```

#### 2. 帧率图 (FPS)

```
┌─────────────────────────────────────────────────────────────┐
│  Frames Per Second                                          │
│  30 ┤────────────────────────────────────────────────       │
│     │                                                       │
│  25 ┤                                                       │
│     │                                                       │
│  20 ┤                                                       │
│     │                   ╭───────╮                           │
│  15 ┤───────────────────╯       ╰────────────────           │
│     │                                                       │
│  10 ┤                                                       │
│     │                                                       │
│   0 └──────────────────────────────────────────────────►    │
│                                                             │
│  诊断要点:                                                  │
│  - 稳定 30fps: 理想状态                                     │
│  - 频繁波动: 编码器压力或带宽不足                           │
│  - 突然下降: 可能是质量限制生效                             │
│  - 长期低位: 需要降低分辨率或检查 CPU                       │
└─────────────────────────────────────────────────────────────┘
```

#### 3. 分辨率图 (Resolution)

```
┌─────────────────────────────────────────────────────────────┐
│  Resolution                                                 │
│  1080┤                                                      │
│      │                                                      │
│   720┤───────────────────────────────                       │
│      │                           ╭───╮                      │
│   480┤───────────────────────────╯   ╰──────────            │
│      │                                                      │
│   360┤                                                      │
│      │                                                      │
│   0  └──────────────────────────────────────────────────►   │
│                                                             │
│  诊断要点:                                                  │
│  - 阶梯下降: 带宽自适应降低分辨率                           │
│  - 频繁切换: 网络不稳定                                     │
│  - 无法上升: 带宽瓶颈                                       │
└─────────────────────────────────────────────────────────────┘
```

#### 4. 丢包图 (Packet Loss)

```
┌─────────────────────────────────────────────────────────────┐
│  Packet Loss (%)                                            │
│  20%┤                                                       │
│     │                                                       │
│  10%┤                                                       │
│     │   ▲      ▲              ▲                             │
│   5%┤───┴──────┴──────────────┴─────────────────            │
│     │                                                       │
│   0%└──────────────────────────────────────────────────►    │
│                                                             │
│  诊断要点:                                                  │
│  - 偶发丢包 (<2%): 正常，FEC 可恢复                         │
│  - 持续丢包 (2-5%): 网络质量一般                            │
│  - 高丢包 (>5%): 需要启用 FEC 或降低码率                    │
│  - 突发丢包: 可能是网络拥塞                                 │
└─────────────────────────────────────────────────────────────┘
```

#### 5. 延迟图 (RTT)

```
┌─────────────────────────────────────────────────────────────┐
│  Round Trip Time (ms)                                       │
│  300┤                                                       │
│      │                                                       │
│  200┤                                                       │
│      │                    ╭─────╮                            │
│  100┤────────────────────╯     ╰───────────                 │
│      │                                                       │
│   50┤─────────────────────────────────────────              │
│      │                                                       │
│    0└──────────────────────────────────────────────────►    │
│                                                             │
│  诊断要点:                                                  │
│  - <100ms: 理想                                            │
│  - 100-200ms: 可接受                                       │
│  - >200ms: 延迟较高，影响体验                               │
│  - 波动大: 网络不稳定                                       │
└─────────────────────────────────────────────────────────────┘
```

#### 6. 抖动缓冲图 (Jitter Buffer)

```
┌─────────────────────────────────────────────────────────────┐
│  Jitter Buffer (ms)                                         │
│  150┤                                                       │
│      │                                                       │
│  100┤                                                       │
│      │                                                       │
│   50┤─────────────────────────────────────────              │
│      │                                                       │
│    0└──────────────────────────────────────────────────►    │
│                                                             │
│  诊断要点:                                                  │
│  - 稳定: 网络抖动小                                         │
│  - 波动大: 网络抖动严重                                     │
│  - 持续增大: 可能是时钟漂移                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 Connection Log 标签页

### 日志格式

```
[时间戳] 类型: 消息内容

示例:
[2026-03-02 10:30:45.123] Info: CreateOffer
[2026-03-02 10:30:45.234] Info: SetLocalDescription type=offer
[2026-03-02 10:30:45.345] Info: ICE gathering state changed to gathering
```

### 完整事件列表

#### 1. SDP 相关事件

```
CreateOffer
  - 创建 Offer

CreateAnswer
  - 创建 Answer

SetLocalDescription
  - 参数: type (offer/answer)
  - 设置本地 SDP

SetRemoteDescription
  - 参数: type (answer/offer)
  - 设置远程 SDP

AddIceCandidate
  - 添加 ICE 候选
```

#### 2. ICE 相关事件

```
ICE gathering state changed
  - 值: new → gathering → complete
  - 候选收集状态变化

ICE connection state changed
  - 值: new → checking → connected → completed
  - 值: disconnected → failed → closed
  - ICE 连接状态变化

ICE candidate pair changed
  - 活跃候选对变化

ICE selected candidate pair changed
  - 选中的候选对变化
```

#### 3. DTLS 相关事件

```
DTLS transport state changed
  - 值: new → connecting → connected → closed
  - 值: failed
  - DTLS 传输状态

DTLS handshake completed
  - DTLS 握手完成

Certificate fingerprint
  - 证书指纹
```

#### 4. 媒体相关事件

```
MediaStream added
  - 添加媒体流

MediaStream removed
  - 移除媒体流

Track added
  - 添加轨道

Track removed
  - 移除轨道

Renderered resolution changed
  - 渲染分辨率变化
```

#### 5. 数据通道事件

```
DataChannel created
  - 创建数据通道

DataChannel opened
  - 数据通道打开

DataChannel closed
  - 数据通道关闭
```

### 典型日志流程

#### 正常连接流程

```
[10:30:45.000] Info: CreateOffer
[10:30:45.001] Info: SetLocalDescription type=offer
[10:30:45.002] Info: ICE gathering state changed: new → gathering
[10:30:45.100] Info: ICE candidate found: host 192.168.1.100:54321
[10:30:45.150] Info: ICE candidate found: srflx 203.0.113.1:54322
[10:30:45.200] Info: ICE candidate found: relay 203.0.113.3:3478
[10:30:45.201] Info: ICE gathering state changed: gathering → complete
[10:30:45.500] Info: SetRemoteDescription type=answer
[10:30:45.501] Info: AddIceCandidate
[10:30:45.550] Info: ICE connection state changed: new → checking
[10:30:45.600] Info: ICE candidate pair found
[10:30:45.700] Info: ICE connection state changed: checking → connected
[10:30:45.750] Info: DTLS transport state changed: new → connecting
[10:30:45.850] Info: DTLS transport state changed: connecting → connected
[10:30:45.851] Info: DTLS handshake completed
[10:30:45.900] Info: Connection established
```

#### 连接失败流程

```
[10:30:45.000] Info: CreateOffer
[10:30:45.001] Info: SetLocalDescription type=offer
[10:30:45.100] Info: ICE gathering state changed: new → gathering
[10:30:45.150] Info: ICE candidate found: host 192.168.1.100:54321
[10:30:45.200] Info: ICE gathering state changed: gathering → complete
[10:30:45.500] Info: SetRemoteDescription type=answer
[10:30:45.550] Info: ICE connection state changed: new → checking
[10:30:50.000] Warning: ICE connection check timeout
[10:30:55.000] Error: ICE connection state changed: checking → failed
[10:30:55.001] Error: Connection failed - no candidate pairs succeeded
```

---

## 📄 SDP 标签页

### SDP 显示格式

```
=== Local SDP (Offer/Answer) ===
v=0
o=- 123456789012345678 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0 1
a=msid-semantic: WMS
m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8
...

=== Remote SDP (Answer/Offer) ===
v=0
o=- 876543210987654321 2 IN IP4 127.0.0.1
...
```

### SDP 分析要点

```
1. 检查 ICE 认证:
   a=ice-ufrag:xxxx
   a=ice-pwd:yyyy

2. 检查 DTLS 指纹:
   a=fingerprint:sha-256 XX:XX:XX...

3. 检查 ICE 候选:
   a=candidate:1 1 UDP 2122260223 192.168.1.100 54321 typ host
   a=candidate:2 1 UDP 1686052607 203.0.113.1 54322 typ srflx

4. 检查编解码器:
   a=rtpmap:111 opus/48000/2
   a=rtpmap:96 VP8/90000

5. 检查 RTCP 反馈:
   a=rtcp-fb:96 nack
   a=rtcp-fb:96 nack pli

6. 检查方向:
   a=sendrecv / a=sendonly / a=recvonly
```

---

## 🧊 ICE Candidates 标签页

### 候选表格详解

```
Local Candidates:
┌──────────┬─────────────────┬──────┬────────┬──────────┬─────────┬────────────┐
│ Type     │ IP              │ Port │ Proto  │ Priority │ Relayed │ Network    │
├──────────┼─────────────────┼──────┼────────┼──────────┼─────────┼────────────┤
│ host     │ 192.168.1.100   │ 54321│ udp    │ 2122260223│ -      │ wifi       │
│ host     │ 10.0.0.100      │ 54322│ udp    │ 2122260222│ -      │ cellular   │
│ srflx    │ 203.0.113.1     │ 54323│ udp    │ 1686052607│ 192.168.1.100│ -      │
│ relay    │ 203.0.113.3     │ 3478 │ udp    │ 41885439 │ 203.0.113.1│ -        │
└──────────┴─────────────────┴──────┴────────┴──────────┴─────────┴────────────┘

Remote Candidates:
┌──────────┬─────────────────┬──────┬────────┬──────────┐
│ Type     │ IP              │ Port │ Proto  │ Priority │
├──────────┼─────────────────┼──────┼────────┼──────────┤
│ host     │ 192.168.2.100   │ 54324│ udp    │ 2122260223│
│ srflx    │ 203.0.113.2     │ 54325│ udp    │ 1686052607│
└──────────┴─────────────────┴──────┴────────┴──────────┘
```

### 候选对信息

```
Active Candidate Pair:
┌─────────────────────────────────────────────────────────────┐
│ Local Candidate:                                            │
│   Type: host                                                │
│   IP: 192.168.1.100                                         │
│   Port: 54321                                               │
│                                                             │
│ Remote Candidate:                                           │
│   Type: srflx                                               │
│   IP: 203.0.113.2                                           │
│   Port: 54325                                               │
│                                                             │
│ Pair State: succeeded                                       │
│ Nominated: yes                                              │
│ RTT: 45ms                                                   │
│ Current Round Trip Time: 0.045s                             │
│ Available Outgoing Bitrate: 2.5Mbps                        │
└─────────────────────────────────────────────────────────────┘
```

### 候选类型说明

```
host   - 本地网络接口地址
         优先级最高，局域网内直连

srflx  - 服务器反射地址 (通过 STUN 获取)
         公网 IP，NAT 穿透

prflx  - 对等反射地址
         连接检查过程中发现

relay  - 中继地址 (通过 TURN 获取)
         优先级最低，所有流量经过服务器
```

---

## 📥 导出数据

### 导出按钮说明

```
┌─────────────────────────────────────────────────────────────┐
│  Create Dump                                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Download the PeerConnection updates log]                  │
│   → 导出所有事件日志 (JSON)                                 │
│   → 包含: SDP 变化、ICE 事件、状态变化等                    │
│                                                             │
│  [Download the PeerConnection stats]                        │
│   → 导出统计数据 (JSON)                                     │
│   → 包含: 所有 getStats 数据的历史记录                      │
│                                                             │
│  [Start recording RTP packets]                              │
│   → 开始录制 RTP 包 (调试用)                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 解析导出数据

```javascript
// 解析 updates log
const updatesLog = JSON.parse(downloadedJson);

// 查看所有 PeerConnection
Object.keys(updatesLog).forEach(pcId => {
  console.log('PeerConnection:', pcId);

  const pc = updatesLog[pcId];

  // 查看更新历史
  pc.updates.forEach(update => {
    console.log(`  [${update.time}] ${update.type}:`, update.value);
  });

  // 查看 SDP 历史
  pc.sdpHistory.forEach(sdp => {
    console.log('  SDP type:', sdp.type);
    console.log('  SDP:', sdp.sdp);
  });
});

// 解析 stats dump
const statsDump = JSON.parse(downloadedJson);

// 查看统计历史
Object.keys(statsDump).forEach(pcId => {
  const pc = statsDump[pcId];

  // 遍历每次采样
  pc.forEach(sample => {
    console.log('Time:', sample.time);

    // 遍历所有报告
    sample.values.forEach(report => {
      console.log(`  ${report.type}:`, report);
    });
  });
});
```

### 数据分析工具

```javascript
// 分析导出的统计数据
function analyzeStatsDump(statsDump) {
  const results = {
    connectionDuration: 0,
    avgBitrate: { video: 0, audio: 0 },
    avgFps: 0,
    packetLoss: [],
    rttHistory: []
  };

  Object.values(statsDump).forEach(pc => {
    pc.forEach((sample, index) => {
      sample.values.forEach(report => {
        // 视频发送统计
        if (report.type === 'outbound-rtp' && report.kind === 'video') {
          results.avgBitrate.video += report.bytesSent || 0;
          results.avgFps += report.framesPerSecond || 0;
        }

        // 视频接收统计
        if (report.type === 'inbound-rtp' && report.kind === 'video') {
          const lossRate = report.packetsLost / (report.packetsReceived + report.packetsLost);
          results.packetLoss.push(lossRate);
        }

        // 网络统计
        if (report.type === 'candidate-pair' && report.state === 'succeeded') {
          results.rttHistory.push(report.currentRoundTripTime);
        }
      });
    });
  });

  // 计算平均值
  const samples = Object.values(statsDump)[0]?.length || 1;
  results.avgBitrate.video = (results.avgBitrate.video * 8) / samples;
  results.avgFps = results.avgFps / samples;

  results.avgPacketLoss = results.packetLoss.reduce((a, b) => a + b, 0) / results.packetLoss.length;
  results.avgRtt = results.rttHistory.reduce((a, b) => a + b, 0) / results.rttHistory.length;

  return results;
}
```

---

## 🔧 高级调试技巧

### 1. 启用详细日志

```
Chrome 启动参数:
--enable-logging --v=1
--enable-logging --vmodule=*/webrtc/*=3

查看日志位置:
Windows: %APPDATA%\..\Local\Google\Chrome\User Data\chrome_debug.log
macOS: ~/Library/Application Support/Google/Chrome/chrome_debug.log
Linux: ~/.config/google-chrome/chrome_debug.log
```

### 2. 使用 chrome://net-internals

```
查看网络详情:
chrome://net-internals/#events

搜索 WebRTC 相关:
- 搜索 "stun"
- 搜索 "turn"
- 搜索 "dtls"
```

### 3. 检查媒体设备

```
chrome://settings/content/camera
chrome://settings/content/microphone

查看设备权限和状态
```

### 4. 使用 chrome://media-internals

```
查看媒体管道详情:
chrome://media-internals

显示:
- 解码器信息
- 缓冲状态
- 播放统计
```

---

## 🐛 常见问题诊断

### 问题 1: ICE 连接一直 checking

```
检查项:
1. 查看 ICE Candidates 是否完整
   - 是否有 host 候选?
   - 是否有 srflx 候选?
   - 如果没有，检查 STUN 服务器

2. 查看候选对状态
   - 是否有 succeeded 的候选对?
   - 如果全部 failed，检查防火墙/NAT

3. 检查 SDP 交换
   - 是否成功交换?
   - ICE 候选是否完整传递?

解决方案:
- 检查 STUN/TURN 服务器配置
- 检查防火墙设置
- 检查信令服务器是否正常
```

### 问题 2: 视频质量差

```
检查项:
1. 查看 qualityLimitationReason
   - bandwidth: 带宽不足
   - cpu: CPU 不足
   - other: 其他原因

2. 查看码率图
   - targetBitrate 是否很低?
   - 是否频繁波动?

3. 查看丢包率
   - packetsLost 是否很高?

解决方案:
- 带宽问题: 降低分辨率/帧率
- CPU 问题: 关闭其他应用，使用硬件加速
- 丢包问题: 启用 FEC
```

### 问题 3: 音频断续

```
检查项:
1. 查看 Audio Recv 的 jitter
   - jitter > 30ms 表示抖动严重

2. 查看 concealedSamples
   - 高表示频繁使用 PLC

3. 查看 packetsLost
   - 丢包率高导致断续

解决方案:
- 增加抖动缓冲
- 启用 Opus FEC
- 检查网络质量
```

---

## 🔗 相关笔记

- [[WebRTC统计信息]] - Stats API 详解
- [[问题排查指南]] - 问题诊断流程
- [[SDP会话描述]] - SDP 格式
- [[ICE候选]] - ICE 原理

---

## 📚 参考资料

- [Chrome WebRTC Internals](https://webrtc.org/getting-started/chrome-webrtc-internals)
- [WebRTC Native Code](https://webrtc.googlesource.com/src/)
- [Debugging WebRTC](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Debugging)

---
#tech/webrtc/debug
