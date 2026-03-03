---
title: RTCPeerConnection API
date: 2026-03-02
tags:
  - WebRTC
  - API
  - 连接管理
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - SDP会话描述
  - ICE候选
  - 信令服务器
---

# RTCPeerConnection API

> RTCPeerConnection 是 WebRTC 的核心 API，负责管理点对点连接的建立、维护和监控

## 📌 核心作用

- 建立 P2P 连接
- 处理 ICE 候选
- 管理媒体轨道的添加/移除
- 监控连接状态
- 处理 SDP 协商

---

## 🔧 创建连接

### 基本创建

```javascript
const pc = new RTCPeerConnection();
```

### 带配置创建

```javascript
const config = {
  // ICE 服务器配置
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    {
      urls: 'turn:your-turn-server.com:3478',
      username: 'username',
      credential: 'password'
    }
  ],

  // ICE 传输策略
  iceTransportPolicy: 'all', // 'all' | 'relay'

  // Bundle 策略（多路复用）
  bundlePolicy: 'balanced', // 'balanced' | 'max-compat' | 'max-bundle'

  // SDP 语义
  sdpSemantics: 'unified-plan' // 推荐
};

const pc = new RTCPeerConnection(config);
```

### 配置项详解

| 配置项 | 说明 | 可选值 |
|--------|------|--------|
| `iceServers` | STUN/TURN 服务器列表 | - |
| `iceTransportPolicy` | ICE 传输策略 | `all`, `relay` |
| `bundlePolicy` | BUNDLE 策略 | `balanced`, `max-compat`, `max-bundle` |
| `rtcpMuxPolicy` | RTCP 复用策略 | `negotiate`, `require` |
| `sdpSemantics` | SDP 语义 | `unified-plan`（推荐） |

---

## 📊 状态管理

### 连接状态

```javascript
// 连接状态
pc.onconnectionstatechange = () => {
  console.log('Connection state:', pc.connectionState);
};
```

| 状态 | 说明 |
|------|------|
| `new` | 初始状态 |
| `connecting` | 正在连接 |
| `connected` | 已连接 |
| `disconnected` | 连接断开（可能恢复） |
| `failed` | 连接失败 |
| `closed` | 连接已关闭 |

### ICE 连接状态

```javascript
pc.oniceconnectionstatechange = () => {
  console.log('ICE state:', pc.iceConnectionState);
};
```

| 状态 | 说明 |
|------|------|
| `new` | ICE 代理正在收集候选 |
| `checking` | 正在检查候选对 |
| `connected` | 找到可用的候选对 |
| `completed` | 检查完成，找到最优路径 |
| `disconnected` | 连接断开 |
| `failed` | 所有候选对检查失败 |
| `closed` | ICE 代理已关闭 |

### ICE 收集状态

```javascript
pc.onicegatheringstatechange = () => {
  console.log('ICE gathering:', pc.iceGatheringState);
};
```

| 状态 | 说明 |
|------|------|
| `new` | 刚创建，未开始收集 |
| `gathering` | 正在收集候选 |
| `complete` | 收集完成 |

### 信令状态

```javascript
pc.onsignalingstatechange = () => {
  console.log('Signaling state:', pc.signalingState);
};
```

| 状态 | 说明 |
|------|------|
| `stable` | 稳定状态 |
| `have-local-offer` | 已设置本地 Offer |
| `have-remote-offer` | 已设置远程 Offer |
| `have-local-pranswer` | 已设置本地预回答 |
| `have-remote-pranswer` | 已设置远程预回答 |
| `closed` | 已关闭 |

### 状态流转图

```
┌─────────────────────────────────────────────────────────────────┐
│                    ICE Connection State                          │
│                                                                  │
│   new ──► checking ──► connected ──► completed                  │
│              │              │                                    │
│              │              ▼                                    │
│              │         disconnected ──► connected (恢复)         │
│              │              │                                    │
│              ▼              ▼                                    │
│           failed ◄──────────┘                                    │
│              │                                                   │
│              ▼                                                   │
│           closed                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    Signaling State                               │
│                                                                  │
│                        stable                                    │
│                       /     \                                    │
│          have-local-offer   have-remote-offer                    │
│                     /             \                              │
│       have-remote-pranswer   have-local-pranswer                 │
│                     \             /                              │
│                        stable                                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎤 添加媒体轨道

### 添加轨道

```javascript
// 方式1: 使用 addTrack
stream.getTracks().forEach(track => {
  pc.addTrack(track, stream);
});

// 方式2: 使用 addTransceiver（推荐，更灵活）
stream.getTracks().forEach(track => {
  pc.addTransceiver(track, {
    direction: 'sendrecv', // 'sendrecv' | 'sendonly' | 'recvonly' | 'inactive'
    streams: [stream]
  });
});
```

### 接收远程轨道

```javascript
pc.ontrack = (event) => {
  // event.track - 新的轨道
  // event.streams - 关联的流
  // event.receiver - 接收器
  // event.transceiver - 收发器

  const remoteVideo = document.querySelector('#remote-video');
  if (event.streams && event.streams[0]) {
    remoteVideo.srcObject = event.streams[0];
  }
};
```

### 移除轨道

```javascript
// 获取发送器
const senders = pc.getSenders();

// 找到视频发送器
const videoSender = senders.find(s =>
  s.track && s.track.kind === 'video'
);

// 移除轨道
if (videoSender) {
  pc.removeTrack(videoSender);
}

// 需要重新协商
await renegotiate();
```

### 替换轨道

```javascript
// 替换摄像头（如切换前后摄像头）
async function switchCamera(newStream) {
  const videoTrack = newStream.getVideoTracks()[0];
  const sender = pc.getSenders().find(s => s.track?.kind === 'video');

  if (sender) {
    await sender.replaceTrack(videoTrack);
    // 不需要重新协商
  }
}
```

---

## 📝 SDP 协商

### 创建 Offer

```javascript
// 创建 Offer
const offer = await pc.createOffer();

// 设置本地描述
await pc.setLocalDescription(offer);

// 发送 offer 给对端（通过信令服务器）
signaling.send({
  type: 'offer',
  sdp: offer
});
```

### 创建 Answer

```javascript
// 接收远程 offer
signaling.on('offer', async (offer) => {
  // 设置远程描述
  await pc.setRemoteDescription(new RTCSessionDescription(offer));

  // 创建 Answer
  const answer = await pc.createAnswer();

  // 设置本地描述
  await pc.setLocalDescription(answer);

  // 发送 answer 给对端
  signaling.send({
    type: 'answer',
    sdp: answer
  });
});
```

### 接收 Answer

```javascript
// 接收远程 answer
signaling.on('answer', async (answer) => {
  await pc.setRemoteDescription(new RTCSessionDescription(answer));
});
```

### SDP 协商选项

```javascript
// 创建 Offer 时可以指定选项
const offer = await pc.createOffer({
  iceRestart: false,        // 是否重启 ICE
  offerToReceiveAudio: true,
  offerToReceiveVideo: true
});

// 创建 Answer 时的选项
const answer = await pc.createAnswer({
  iceRestart: false
});
```

---

## 🧊 ICE 候选

### 收集 ICE 候选

```javascript
pc.onicecandidate = (event) => {
  if (event.candidate) {
    // 发送候选给对端
    signaling.send({
      type: 'candidate',
      candidate: event.candidate
    });
  } else {
    // 候选收集完成
    console.log('ICE gathering complete');
  }
};
```

### 添加远程 ICE 候选

```javascript
signaling.on('candidate', async (candidate) => {
  try {
    await pc.addIceCandidate(new RTCIceCandidate(candidate));
  } catch (error) {
    console.error('添加 ICE 候选失败:', error);
  }
});
```

### ICE 候选类型

```javascript
pc.onicecandidate = (event) => {
  if (event.candidate) {
    const candidate = event.candidate;
    console.log('Candidate type:', candidate.type);
    // 'host'     - 本地地址
    // 'srflx'    - 服务器反射地址 (STUN)
    // 'prflx'    - 对等反射地址
    // 'relay'    - 中继地址 (TURN)
  }
};
```

### ICE 重启

```javascript
// 当连接断开时，重启 ICE
async function restartIce() {
  const offer = await pc.createOffer({ iceRestart: true });
  await pc.setLocalDescription(offer);
  signaling.send({ type: 'offer', sdp: offer });
}

// 监听连接断开
pc.oniceconnectionstatechange = () => {
  if (pc.iceConnectionState === 'disconnected') {
    // 等待一段时间看是否能恢复
    setTimeout(() => {
      if (pc.iceConnectionState === 'disconnected') {
        restartIce();
      }
    }, 5000);
  }
};
```

---

## 🔄 重新协商

### 触发重新协商

```javascript
// 场景: 添加/移除轨道，修改编码参数等

async function renegotiate() {
  // 检查当前状态
  if (pc.signalingState !== 'stable') {
    console.log('正在协商中，请稍后');
    return;
  }

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);

  signaling.send({
    type: 'offer',
    sdp: offer
  });
}

// 添加新轨道后重新协商
const newStream = await navigator.mediaDevices.getDisplayMedia();
newStream.getTracks().forEach(track => {
  pc.addTrack(track, newStream);
});
await renegotiate();
```

### 处理重新协商请求（Glare 处理）

```javascript
signaling.on('offer', async (offer) => {
  if (pc.signalingState !== 'stable') {
    // Glare 情况：双方同时发起 offer
    // 使用 RFC 3264 的规则处理
    console.log('Glare detected');

    // 方案1: 回滚并接受远程 offer
    // 方案2: 拒绝远程 offer
    return;
  }

  await pc.setRemoteDescription(new RTCSessionDescription(offer));
  const answer = await pc.createAnswer();
  await pc.setLocalDescription(answer);

  signaling.send({
    type: 'answer',
    sdp: answer
  });
});
```

---

## 📊 统计信息

### 获取统计信息

```javascript
// 获取所有统计
const stats = await pc.getStats();

stats.forEach(report => {
  console.log(report.type, report);
});
```

### 常见报告类型

| 类型 | 说明 |
|------|------|
| `inbound-rtp` | 入站 RTP 统计 |
| `outbound-rtp` | 出站 RTP 统计 |
| `remote-inbound-rtp` | 远程入站统计 |
| `remote-outbound-rtp` | 远程出站统计 |
| `media-source` | 媒体源统计 |
| `candidate-pair` | ICE 候选对统计 |
| `transport` | 传输统计 |
| `codec` | 编解码器信息 |

### 监控关键指标

```javascript
async function getNetworkStats(pc) {
  const stats = await pc.getStats();
  let videoStats = {};
  let audioStats = {};
  let networkStats = {};

  stats.forEach(report => {
    if (report.type === 'outbound-rtp') {
      if (report.kind === 'video') {
        videoStats = {
          bytesSent: report.bytesSent,
          packetsSent: report.packetsSent,
          framesEncoded: report.framesEncoded,
          frameWidth: report.frameWidth,
          frameHeight: report.frameHeight,
          framesPerSecond: report.framesPerSecond,
          encoderImplementation: report.encoderImplementation
        };
      } else if (report.kind === 'audio') {
        audioStats = {
          bytesSent: report.bytesSent,
          packetsSent: report.packetsSent
        };
      }
    }

    if (report.type === 'candidate-pair' && report.state === 'succeeded') {
      networkStats = {
        rtt: report.currentRoundTripTime,
        availableBitrate: report.availableOutgoingBitrate,
        localCandidateType: report.localCandidateType,
        remoteCandidateType: report.remoteCandidateType
      };
    }
  });

  return { video: videoStats, audio: audioStats, network: networkStats };
}

// 定期监控
setInterval(async () => {
  const stats = await getNetworkStats(pc);
  console.log('Stats:', stats);
}, 1000);
```

---

## 🛠️ 完整封装示例

```javascript
class PeerConnection {
  constructor(config = {}) {
    this.pc = new RTCPeerConnection({
      iceServers: config.iceServers || [
        { urls: 'stun:stun.l.google.com:19302' }
      ],
      sdpSemantics: 'unified-plan',
      ...config
    });

    this.localStream = null;
    this.remoteStream = new MediaStream();
    this._setupEventHandlers();
  }

  _setupEventHandlers() {
    // ICE 候选
    this.pc.onicecandidate = (event) => {
      if (event.candidate && this.onIceCandidate) {
        this.onIceCandidate(event.candidate);
      }
    };

    // 远程轨道
    this.pc.ontrack = (event) => {
      event.streams[0]?.getTracks().forEach(track => {
        this.remoteStream.addTrack(track);
      });
      if (this.onRemoteStream) {
        this.onRemoteStream(this.remoteStream);
      }
    };

    // 连接状态
    this.pc.onconnectionstatechange = () => {
      console.log('Connection:', this.pc.connectionState);
      if (this.onConnectionStateChange) {
        this.onConnectionStateChange(this.pc.connectionState);
      }
    };

    // ICE 连接状态
    this.pc.oniceconnectionstatechange = () => {
      console.log('ICE:', this.pc.iceConnectionState);
      if (this.onIceStateChange) {
        this.onIceStateChange(this.pc.iceConnectionState);
      }
    };

    // 数据通道
    this.pc.ondatachannel = (event) => {
      console.log('Received data channel:', event.channel.label);
      if (this.onDataChannel) {
        this.onDataChannel(event.channel);
      }
    };
  }

  // 添加本地流
  addStream(stream) {
    this.localStream = stream;
    stream.getTracks().forEach(track => {
      this.pc.addTrack(track, stream);
    });
  }

  // 创建数据通道
  createDataChannel(label, options = {}) {
    return this.pc.createDataChannel(label, options);
  }

  // 创建 Offer
  async createOffer() {
    const offer = await this.pc.createOffer();
    await this.pc.setLocalDescription(offer);
    return offer;
  }

  // 创建 Answer
  async createAnswer() {
    const answer = await this.pc.createAnswer();
    await this.pc.setLocalDescription(answer);
    return answer;
  }

  // 设置远程描述
  async setRemoteDescription(sdp) {
    await this.pc.setRemoteDescription(new RTCSessionDescription(sdp));
  }

  // 添加 ICE 候选
  async addIceCandidate(candidate) {
    await this.pc.addIceCandidate(new RTCIceCandidate(candidate));
  }

  // 获取发送器
  getSenders() {
    return this.pc.getSenders();
  }

  // 获取收发器
  getTransceivers() {
    return this.pc.getTransceivers();
  }

  // 获取统计信息
  async getStats() {
    return await this.pc.getStats();
  }

  // 关闭连接
  close() {
    this.pc.close();
  }
}

// 使用示例
const peer = new PeerConnection({
  iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
});

// 设置回调
peer.onIceCandidate = (candidate) => {
  signaling.send({ type: 'candidate', candidate });
};

peer.onRemoteStream = (stream) => {
  remoteVideo.srcObject = stream;
};

peer.onConnectionStateChange = (state) => {
  if (state === 'connected') {
    console.log('连接成功！');
  } else if (state === 'disconnected') {
    console.log('连接断开');
  }
};

// 添加本地流
peer.addStream(localStream);

// 创建 offer
const offer = await peer.createOffer();
signaling.send({ type: 'offer', sdp: offer });
```

---

## 🔗 相关笔记

- [[SDP会话描述]] - SDP 格式详解
- [[ICE候选]] - ICE 穿透原理
- [[信令服务器]] - 信令流程
- [[STUN-TURN服务器]] - NAT 穿透

---

## 📚 参考资料

- [MDN: RTCPeerConnection](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection)
- [WebRTC API Samples](https://webrtc.github.io/samples/)
- [W3C WebRTC Specification](https://www.w3.org/TR/webrtc/)

---
#tech/webrtc/api
