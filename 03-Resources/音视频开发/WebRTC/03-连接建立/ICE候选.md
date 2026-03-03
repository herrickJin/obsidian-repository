---
title: ICE 候选
date: 2026-03-02
tags:
  - WebRTC
  - ICE
  - NAT穿透
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - STUN-TURN服务器
  - NAT穿透
  - RTCPeerConnection
---

# ICE 候选

> ICE (Interactive Connectivity Establishment) 是 WebRTC 实现 NAT 穿透的核心协议

## 📌 核心作用

- 发现设备可达的地址
- 穿透 NAT 设备
- 建立最优的连接路径

---

## 🧊 ICE 候选类型

### 1. Host (主机候选)

```
a=candidate:1 1 UDP 2122260223 192.168.1.100 54321 typ host
```

- 本地网络接口地址
- 优先级最高
- 局域网内直连

### 2. srflx (服务器反射候选)

```
a=candidate:2 1 UDP 1686052607 203.0.113.1 54322 typ srflx raddr 192.168.1.100 rport 54321
```

- 通过 STUN 服务器获取的公网地址
- 用于 NAT 穿透

### 3. prflx (对等反射候选)

```
a=candidate:3 1 UDP 16777215 203.0.113.2 54323 typ prflx raddr 192.168.1.100 rport 54321
```

- 连接检查过程中发现
- 可能比 srflx 更优

### 4. relay (中继候选)

```
a=candidate:4 1 UDP 41885439 203.0.113.3 3478 typ relay raddr 203.0.113.1 rport 54322
```

- TURN 服务器地址
- 所有流量通过服务器转发
- 最后手段

---

## 📊 候选字段解析

```
a=candidate:<foundation> <component-id> <transport> <priority> <connection-address> <port> typ <candidate-type> [raddr <rel-address>] [rport <rel-port>]
```

| 字段 | 说明 |
|------|------|
| foundation | 候选标识符 |
| component-id | 1=RTP, 2=RTCP |
| transport | 传输协议 (UDP) |
| priority | 优先级 (越大越优先) |
| connection-address | IP 地址 |
| port | 端口 |
| candidate-type | host/srflx/prflx/relay |

---

## 🔄 ICE 收集流程

```
┌─────────────┐
│   开始收集   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Host 候选   │ ← 本地接口地址
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ STUN 请求   │ → 获取公网地址
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ srflx 候选  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ TURN 分配   │ (如果配置)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ relay 候选  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 收集完成    │ onicecandidate = null
└─────────────┘
```

---

## 🔧 代码示例

### 监听 ICE 候选

```javascript
pc.onicecandidate = (event) => {
  if (event.candidate) {
    console.log('ICE candidate:', event.candidate.type);
    // 发送给对端
    signaling.send({
      type: 'candidate',
      candidate: event.candidate.toJSON()
    });
  } else {
    console.log('ICE gathering complete');
  }
};
```

### 添加远程候选

```javascript
signaling.on('candidate', async (candidate) => {
  await pc.addIceCandidate(new RTCIceCandidate(candidate));
});
```

### Trickle ICE

```javascript
// 配置 Trickle ICE（默认开启）
const pc = new RTCPeerConnection({
  iceServers: [{ urls: 'stun:stun.l.google.com:19302' }],
  iceCandidatePoolSize: 0  // 0 = trickle, >0 = gather all first
});
```

---

## 🔗 相关笔记

- [[STUN-TURN服务器]] - 服务器配置
- [[NAT穿透]] - 穿透原理
- [[RTCPeerConnection]] - 连接管理

---
#tech/webrtc/ice
