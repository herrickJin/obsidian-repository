---
title: RTP/RTCP 协议
date: 2026-03-02
tags:
  - WebRTC
  - RTP
  - RTCP
  - 协议
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - SRTP加密
  - 编解码器
  - 拥塞控制
---

# RTP/RTCP 协议

> RTP (Real-time Transport Protocol) 是 WebRTC 传输音视频数据的核心协议

## 📌 核心概念

- **RTP**: 传输实时媒体数据
- **RTCP**: 传输控制信息和统计报告
- **SRTP**: 加密的 RTP

---

## 📦 RTP 协议

### RTP 包头结构

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|V=2|P|X|  CC   |M|     PT      |       sequence number         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           timestamp                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|           synchronization source (SSRC) identifier            |
+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
|            contributing source (CSRC) identifiers             |
|                             ....                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                            Extension                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                            Payload                            |
|                             ....                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### 字段说明

| 字段 | 位数 | 说明 |
|------|------|------|
| V | 2 | 版本号，固定为 2 |
| P | 1 | 填充位 |
| X | 1 | 扩展位 |
| CC | 4 | CSRC 计数 |
| M | 1 | 标记位（帧边界等） |
| PT | 7 | Payload Type（载荷类型） |
| Sequence Number | 16 | 序列号 |
| Timestamp | 32 | 时间戳 |
| SSRC | 32 | 同步源标识 |
| CSRC | 32*n | 贡献源标识 |

### 关键字段详解

#### Payload Type (PT)

```
常用 Payload Type:
- 111: Opus
- 96:  VP8 (动态)
- 98:  VP9 (动态)
- 100: H.264 (动态)

动态 PT 范围: 96-127
```

#### Sequence Number

```javascript
// 16位，范围 0-65535，循环使用
// 用于检测丢包和重排序

let seqNum = 0;
function sendRtpPacket(payload) {
  const packet = {
    sequenceNumber: seqNum,
    timestamp: getCurrentTimestamp(),
    payload: payload
  };
  seqNum = (seqNum + 1) % 65536;
  return packet;
}
```

#### Timestamp

```javascript
// 32位，时钟频率取决于编码格式
// Opus: 48000 Hz
// VP8/VP9/H.264: 90000 Hz

// 计算时间戳
const clockRate = 90000; // 视频默认
const frameRate = 30;
const timestampIncrement = clockRate / frameRate; // 3000

let timestamp = 0;
function getTimestamp() {
  const current = timestamp;
  timestamp += timestampIncrement;
  return current;
}
```

---

## 📊 RTCP 协议

### RTCP 包类型

| 类型 | 名称 | 说明 |
|------|------|------|
| SR | Sender Report | 发送者报告 |
| RR | Receiver Report | 接收者报告 |
| SDES | Source Description | 源描述 |
| BYE | Goodbye | 离开会话 |
| APP | Application | 应用定义 |
| RTPFB | Transport FB | 传输反馈 |
| PSFB | Payload-specific FB | 载荷特定反馈 |

### Sender Report (SR)

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|V=2|P|    RC   |       PT=200      |             length        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         SSRC of sender                        |
+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
|              NTP timestamp, most significant word             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|             NTP timestamp, least significant word             |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         RTP timestamp                         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                     sender's packet count                     |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                      sender's octet count                     |
+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
|                 report block 1 (optional)                     |
|                              ....                             |
+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+
```

### Receiver Report (RR)

```javascript
// RR 包含接收统计信息
{
  ssrc: 12345678,           // 接收的 SSRC
  fractionLost: 0,          // 丢包率 (0-255)
  packetsLost: 0,           // 累计丢包数
  highestSeqNum: 1000,      // 最高序列号
  interarrivalJitter: 0,    // 抖动
  lastSR: 0,                // 最后 SR 时间
  delaySinceLastSR: 0       // 距离最后 SR 的延迟
}
```

### RTCP 反馈 (Feedback)

#### NACK (Negative Acknowledgment)

```javascript
// 请求重传丢失的包
{
  type: 205,        // RTPFB
  fmt: 1,           // NACK
  ssrc: 12345678,
  lostSeqNums: [100, 101, 102]  // 丢失的序列号
}
```

#### PLI (Picture Loss Indication)

```javascript
// 请求发送关键帧
{
  type: 206,        // PSFB
  fmt: 1,           // PLI
  ssrc: 12345678
}
```

#### FIR (Full Intra Request)

```javascript
// 强制请求关键帧（比 PLI 更强）
{
  type: 206,        // PSFB
  fmt: 4,           // FIR
  ssrc: 12345678
}
```

#### REMB (Receiver Estimated Maximum Bitrate)

```javascript
// 接收端估计的最大带宽
{
  type: 206,
  fmt: 15,          // 应用层反馈
  ssrc: 12345678,
  bitrate: 2500000  // 2.5 Mbps
}
```

#### Transport-CC (Transport Wide Congestion Control)

```javascript
// 传输层拥塞控制反馈
{
  type: 205,
  fmt: 15,
  ssrc: 12345678,
  feedback: [
    { seqNum: 100, received: true, delay: 5000 },
    { seqNum: 101, received: true, delay: 3000 },
    { seqNum: 102, received: false, delay: 0 }
  ]
}
```

---

## 📈 RTCP 统计信息

### 获取 RTCP 统计

```javascript
async function getRtcpStats(pc) {
  const stats = await pc.getStats();

  stats.forEach(report => {
    // 入站 RTP 统计
    if (report.type === 'inbound-rtp') {
      console.log('入站统计:', {
        kind: report.kind,
        packetsReceived: report.packetsReceived,
        packetsLost: report.packetsLost,
        jitter: report.jitter,
        bytesReceived: report.bytesReceived
      });
    }

    // 出站 RTP 统计
    if (report.type === 'outbound-rtp') {
      console.log('出站统计:', {
        kind: report.kind,
        packetsSent: report.packetsSent,
        bytesSent: report.bytesSent,
        targetBitrate: report.targetBitrate
      });
    }

    // 远程入站统计（对端的视角）
    if (report.type === 'remote-inbound-rtp') {
      console.log('远程入站:', {
        packetsLost: report.packetsLost,
        jitter: report.jitter,
        roundTripTime: report.roundTripTime,
        fractionLost: report.fractionLost
      });
    }
  });
}

// 定期获取
setInterval(() => getRtcpStats(pc), 1000);
```

### 关键指标

| 指标 | 说明 | 理想值 |
|------|------|--------|
| packetsLost | 丢包数 | 0 |
| jitter | 抖动（秒） | < 0.03 |
| roundTripTime | 往返延迟（秒） | < 0.15 |
| fractionLost | 丢包率 | < 0.01 |

---

## 🔄 RTCP 反馈机制

### WebRTC 中的 RTCP 反馈

```javascript
// SDP 中声明的 RTCP 反馈能力
a=rtcp-fb:96 goog-remb       // REMB 带宽估计
a=rtcp-fb:96 transport-cc    // 传输拥塞控制
a=rtcp-fb:96 ccm fir         // 完整帧请求
a=rtcp-fb:96 nack            // NACK 重传
a=rtcp-fb:96 nack pli        // 图像丢失指示
```

### NACK 重传流程

```
发送端                              接收端
   │                                  │
   │  RTP (seq=100)                   │
   │ ──────────────────────────────► │
   │                                  │
   │  RTP (seq=101) [丢失]            │
   │ ────────✗                       │
   │                                  │
   │  RTP (seq=102)                   │
   │ ──────────────────────────────► │
   │                                  │
   │                    RTCP NACK (101)
   │ ◄────────────────────────────── │
   │                                  │
   │  RTP (seq=101) 重传              │
   │ ──────────────────────────────► │
   │                                  │
```

### PLI 请求关键帧

```
发送端                              接收端
   │                                  │
   │  [无法解码，需要关键帧]          │
   │                                  │
   │                    RTCP PLI
   │ ◄────────────────────────────── │
   │                                  │
   │  RTP (I-Frame)                   │
   │ ──────────────────────────────► │
   │                                  │
```

---

## 🛠️ RTCP 间隔计算

```javascript
// RTCP 报告间隔计算（RFC 3550）
function calculateRtcpInterval(session) {
  const MIN_INTERVAL = 5; // 秒
  const members = session.members;
  const senders = session.senders;

  // 基础间隔
  let interval = session.avgRtcpSize * 8 / session.bandwidth;

  // 如果发送者少于成员的 25%
  if (senders <= members * 0.25) {
    interval *= members;
  }

  // 最小间隔限制
  interval = Math.max(interval, MIN_INTERVAL);

  // 添加随机抖动 [0.5, 1.5]
  interval *= 0.5 + Math.random();

  return interval;
}
```

---

## 🔧 实用工具

### 丢包率计算

```javascript
function calculatePacketLoss(stats) {
  const packetsExpected = stats.packetsReceived + stats.packetsLost;
  if (packetsExpected === 0) return 0;

  return stats.packetsLost / packetsExpected;
}

// 使用
const stats = await getRtcpStats(pc);
const lossRate = calculatePacketLoss(stats);
console.log(`丢包率: ${(lossRate * 100).toFixed(2)}%`);
```

### 抖动计算

```javascript
// RFC 3550 抖动计算公式
// J = J + (|D(i-1,i)| - J)/16

let jitter = 0;

function updateJitter(packet) {
  const D = packet.arrivalTime - packet.sendingTime -
            (prevPacket.arrivalTime - prevPacket.sendingTime);

  jitter = jitter + (Math.abs(D) - jitter) / 16;

  return jitter;
}
```

### RTT 计算

```javascript
// 通过 Sender Report 计算 RTT
function calculateRTT(sr, rr) {
  // RR 中的 delaySinceLastSR 是从收到 SR 到发送 RR 的延迟
  const delay = rr.delaySinceLastSR;

  // 当前时间 - SR 中的 NTP 时间戳 - 处理延迟 = RTT
  const rtt = Date.now() - sr.ntpTimestamp - delay;

  return rtt;
}
```

---

## 🔗 相关笔记

- [[SRTP加密]] - RTP 加密传输
- [[拥塞控制]] - 基于 RTCP 的拥塞控制
- [[FEC前向纠错]] - 前向纠错机制
- [[编解码器]] - Payload Type 映射

---

## 📚 参考资料

- [RFC 3550 - RTP](https://tools.ietf.org/html/rfc3550)
- [RFC 4585 - RTCP Feedback](https://tools.ietf.org/html/rfc4585)
- [RFC 5104 - Codec Control Messages](https://tools.ietf.org/html/rfc5104)
- [WebRTC Stats API](https://developer.mozilla.org/en-US/docs/Web/API/RTCStatsReport)

---
#tech/webrtc/protocol
