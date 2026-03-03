---
title: WebRTC 统计信息
date: 2026-03-02
tags:
  - WebRTC
  - Stats
  - 统计
  - 监控
difficulty: ⭐⭐⭐
status: 🌱 学习中
related:
  - webrtc-internals
  - 问题排查指南
  - QoS策略
---

# WebRTC 统计信息

> WebRTC Stats API 提供了丰富的连接、媒体、网络统计信息，是调试和监控的核心工具

## 📌 核心作用

- 监控连接状态
- 诊断质量问题
- 分析性能瓶颈
- 指导自适应调整

---

## 🔧 获取统计信息

### 基本 API

```javascript
const pc = new RTCPeerConnection();

// 获取所有统计
const stats = await pc.getStats();

// 遍历统计报告
stats.forEach(report => {
  console.log(report.type, report);
});
```

### 封装工具函数

```javascript
async function getWebRTCStats(pc) {
  const stats = await pc.getStats();
  const result = {
    connection: null,
    transport: null,
    audio: { inbound: null, outbound: null },
    video: { inbound: null, outbound: null },
    candidates: []
  };

  stats.forEach(report => {
    switch (report.type) {
      case 'peer-connection':
        result.connection = report;
        break;
      case 'transport':
        result.transport = report;
        break;
      case 'inbound-rtp':
        if (report.kind === 'audio') result.audio.inbound = report;
        if (report.kind === 'video') result.video.inbound = report;
        break;
      case 'outbound-rtp':
        if (report.kind === 'audio') result.audio.outbound = report;
        if (report.kind === 'video') result.video.outbound = report;
        break;
      case 'local-candidate':
      case 'remote-candidate':
        result.candidates.push(report);
        break;
    }
  });

  return result;
}
```

---

## 📊 统计报告类型

### 完整类型列表

| 类型 | 说明 | 关键字段 |
|------|------|----------|
| `inbound-rtp` | 入站 RTP 统计 | packetsReceived, bytesReceived, jitter |
| `outbound-rtp` | 出站 RTP 统计 | packetsSent, bytesSent, targetBitrate |
| `remote-inbound-rtp` | 远程入站统计 | roundTripTime, fractionLost |
| `remote-outbound-rtp` | 远程出站统计 | remoteTimestamp |
| `media-source` | 媒体源统计 | width, height, framesPerSecond |
| `media-playout` | 播放统计 | synthesizedSamplesDuration |
| `peer-connection` | 连接统计 | dataChannelsOpened, dataChannelsClosed |
| `transport` | 传输统计 | selectedCandidatePairChanges |
| `candidate-pair` | 候选对统计 | currentRoundTripTime, availableBitrate |
| `local-candidate` | 本地候选 | ip, port, protocol, candidateType |
| `remote-candidate` | 远程候选 | ip, port, protocol, candidateType |
| `certificate` | 证书信息 | fingerprint, fingerprintAlgorithm |
| `codec` | 编解码器 | mimeType, clockRate, channels |
| `data-channel` | 数据通道 | messagesSent, messagesReceived |
| `stream` | 媒体流 | streamIdentifier |

---

## 🎤 音频统计详解

### 入站音频 (inbound-rtp)

```javascript
async function getAudioInboundStats(pc) {
  const stats = await pc.getStats();
  let audioInbound = null;

  stats.forEach(report => {
    if (report.type === 'inbound-rtp' && report.kind === 'audio') {
      audioInbound = {
        // 基本统计
        ssrc: report.ssrc,
        packetsReceived: report.packetsReceived,
        packetsLost: report.packetsLost,
        bytesReceived: report.bytesReceived,

        // 丢包率
        packetLossRate: report.packetsLost / (report.packetsReceived + report.packetsLost),

        // 抖动 (秒)
        jitter: report.jitter,
        jitterMs: report.jitter * 1000,

        // 编解码
        codecId: report.codecId,

        // 时间
        timestamp: report.timestamp,
        lastPacketReceivedTimestamp: report.lastPacketReceivedTimestamp
      };
    }
  });

  return audioInbound;
}
```

### 出站音频 (outbound-rtp)

```javascript
async function getAudioOutboundStats(pc) {
  const stats = await pc.getStats();
  let audioOutbound = null;

  stats.forEach(report => {
    if (report.type === 'outbound-rtp' && report.kind === 'audio') {
      audioOutbound = {
        ssrc: report.ssrc,
        packetsSent: report.packetsSent,
        bytesSent: report.bytesSent,
        codecId: report.codecId,
        timestamp: report.timestamp
      };
    }
  });

  return audioOutbound;
}
```

---

## 🎬 视频统计详解

### 入站视频 (inbound-rtp)

```javascript
async function getVideoInboundStats(pc) {
  const stats = await pc.getStats();
  let videoInbound = null;

  stats.forEach(report => {
    if (report.type === 'inbound-rtp' && report.kind === 'video') {
      videoInbound = {
        // 基本统计
        ssrc: report.ssrc,
        packetsReceived: report.packetsReceived,
        packetsLost: report.packetsLost,
        bytesReceived: report.bytesReceived,

        // 丢包率
        packetLossRate: report.packetsLost / (report.packetsReceived + report.packetsLost),

        // 抖动
        jitter: report.jitter,
        jitterMs: report.jitter * 1000,

        // 帧统计
        framesDecoded: report.framesDecoded,
        framesDropped: report.framesDropped,
        framesReceived: report.framesReceived,
        frameWidth: report.frameWidth,
        frameHeight: report.frameHeight,
        framesPerSecond: report.framesPerSecond,

        // 解码
        keyFramesDecoded: report.keyFramesDecoded,
        totalDecodeTime: report.totalDecodeTime,
        totalInterFrameDelay: report.totalInterFrameDelay,

        // 抖动缓冲
        jitterBufferDelay: report.jitterBufferDelay,
        jitterBufferEmittedCount: report.jitterBufferEmittedCount,
        jitterBufferMinimumDelay: report.jitterBufferMinimumDelay,

        // 编解码
        codecId: report.codecId,
        decoderImplementation: report.decoderImplementation,

        // FIR/PLI/NACK
        firCount: report.firCount,
        pliCount: report.pliCount,
        nackCount: report.nackCount
      };
    }
  });

  return videoInbound;
}
```

### 出站视频 (outbound-rtp)

```javascript
async function getVideoOutboundStats(pc) {
  const stats = await pc.getStats();
  let videoOutbound = null;

  stats.forEach(report => {
    if (report.type === 'outbound-rtp' && report.kind === 'video') {
      videoOutbound = {
        // 基本统计
        ssrc: report.ssrc,
        packetsSent: report.packetsSent,
        bytesSent: report.bytesSent,

        // 帧统计
        framesEncoded: report.framesEncoded,
        frameWidth: report.frameWidth,
        frameHeight: report.frameHeight,
        framesPerSecond: report.framesPerSecond,

        // 编码
        keyFramesEncoded: report.keyFramesEncoded,
        totalEncodeTime: report.totalEncodeTime,
        totalPacketSendDelay: report.totalPacketSendDelay,

        // 码率
        targetBitrate: report.targetBitrate,
        bitrate: report.bytesSent * 8 / (report.timestamp / 1000),

        // 质量限制
        qualityLimitationReason: report.qualityLimitationReason,
        qualityLimitationDurations: report.qualityLimitationDurations,
        qualityLimitationResolutionChanges: report.qualityLimitationResolutionChanges,

        // 编码器
        encoderImplementation: report.encoderImplementation,
        codecId: report.codecId,

        // 重传
        retransmittedPacketsSent: report.retransmittedPacketsSent,
        retransmittedBytesSent: report.retransmittedBytesSent
      };
    }
  });

  return videoOutbound;
}
```

---

## 🌐 网络统计

### 候选对 (candidate-pair)

```javascript
async function getCandidatePairStats(pc) {
  const stats = await pc.getStats();
  const candidatePairs = [];

  stats.forEach(report => {
    if (report.type === 'candidate-pair') {
      candidatePairs.push({
        // 状态
        state: report.state,  // 'succeeded' | 'in-progress' | 'failed'
        nominated: report.nominated,

        // 延迟
        currentRoundTripTime: report.currentRoundTripTime,
        totalRoundTripTime: report.totalRoundTripTime,
        roundTripTimeMeasurements: report.roundTripTimeMeasurements,

        // 带宽
        availableOutgoingBitrate: report.availableOutgoingBitrate,
        availableIncomingBitrate: report.availableIncomingBitrate,

        // 传输
        bytesSent: report.bytesSent,
        bytesReceived: report.bytesReceived,
        packetsSent: report.packetsSent,
        packetsReceived: report.packetsReceived,

        // 候选
        localCandidateId: report.localCandidateId,
        remoteCandidateId: report.remoteCandidateId,

        // 优先级
        priority: report.priority
      });
    }
  });

  // 返回活跃的候选对
  return candidatePairs.find(p => p.state === 'succeeded' && p.nominated);
}
```

### 候选信息

```javascript
async function getCandidateStats(pc) {
  const stats = await pc.getStats();
  const candidates = {
    local: [],
    remote: []
  };

  stats.forEach(report => {
    if (report.type === 'local-candidate') {
      candidates.local.push({
        id: report.id,
        ip: report.ip || report.address,
        port: report.port,
        protocol: report.protocol,      // 'udp' | 'tcp'
        candidateType: report.candidateType,  // 'host' | 'srflx' | 'prflx' | 'relay'
        relayProtocol: report.relayProtocol,  // 'udp' | 'tcp' | 'tls'
        networkType: report.networkType,
        foundation: report.foundation,
        priority: report.priority
      });
    }

    if (report.type === 'remote-candidate') {
      candidates.remote.push({
        id: report.id,
        ip: report.ip || report.address,
        port: report.port,
        protocol: report.protocol,
        candidateType: report.candidateType
      });
    }
  });

  return candidates;
}
```

---

## 📈 实时监控

### 完整监控类

```javascript
class WebRTCStatsMonitor {
  constructor(pc, interval = 1000) {
    this.pc = pc;
    this.interval = interval;
    this.timer = null;
    this.history = [];
    this.maxHistory = 60;
    this.callbacks = [];
  }

  start() {
    this.timer = setInterval(() => this.collect(), this.interval);
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  async collect() {
    const stats = await this.getFormattedStats();
    this.history.push(stats);

    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }

    this.callbacks.forEach(cb => cb(stats));
  }

  async getFormattedStats() {
    const stats = await this.pc.getStats();
    const formatted = {
      timestamp: Date.now(),
      connection: {},
      audio: { inbound: {}, outbound: {} },
      video: { inbound: {}, outbound: {} },
      network: {}
    };

    stats.forEach(report => {
      switch (report.type) {
        case 'candidate-pair':
          if (report.state === 'succeeded') {
            formatted.network = {
              rtt: (report.currentRoundTripTime * 1000).toFixed(0) + 'ms',
              availableBitrate: ((report.availableOutgoingBitrate || 0) / 1000000).toFixed(2) + 'Mbps',
              bytesSent: report.bytesSent,
              bytesReceived: report.bytesReceived
            };
          }
          break;

        case 'inbound-rtp':
          const inbound = {
            packetsLost: report.packetsLost,
            jitter: (report.jitter * 1000).toFixed(2) + 'ms',
            bytesReceived: report.bytesReceived,
            framesPerSecond: report.framesPerSecond,
            frameWidth: report.frameWidth,
            frameHeight: report.frameHeight
          };
          if (report.kind === 'audio') {
            formatted.audio.inbound = inbound;
          } else {
            formatted.video.inbound = inbound;
          }
          break;

        case 'outbound-rtp':
          const outbound = {
            bytesSent: report.bytesSent,
            framesPerSecond: report.framesPerSecond,
            frameWidth: report.frameWidth,
            frameHeight: report.frameHeight,
            targetBitrate: ((report.targetBitrate || 0) / 1000).toFixed(0) + 'kbps',
            qualityLimitationReason: report.qualityLimitationReason
          };
          if (report.kind === 'audio') {
            formatted.audio.outbound = outbound;
          } else {
            formatted.video.outbound = outbound;
          }
          break;

        case 'peer-connection':
          formatted.connection = {
            connectionState: this.pc.connectionState,
            iceConnectionState: this.pc.iceConnectionState,
            signalingState: this.pc.signalingState
          };
          break;
      }
    });

    return formatted;
  }

  onStats(callback) {
    this.callbacks.push(callback);
  }

  getHistory() {
    return this.history;
  }

  // 计算趋势
  getTrend(metric, samples = 10) {
    if (this.history.length < 2) return 'stable';

    const recent = this.history.slice(-samples);
    const values = recent.map(h => this.extractValue(h, metric));

    const first = values[0];
    const last = values[values.length - 1];
    const change = (last - first) / first;

    if (change > 0.1) return 'increasing';
    if (change < -0.1) return 'decreasing';
    return 'stable';
  }

  extractValue(obj, path) {
    const keys = path.split('.');
    let value = obj;
    for (const key of keys) {
      value = value?.[key];
    }
    return parseFloat(value) || 0;
  }
}

// 使用示例
const monitor = new WebRTCStatsMonitor(pc, 1000);
monitor.start();

monitor.onStats((stats) => {
  console.log('RTT:', stats.network.rtt);
  console.log('视频帧率:', stats.video.inbound.framesPerSecond);
  console.log('视频分辨率:', stats.video.inbound.frameWidth + 'x' + stats.video.inbound.frameHeight);
});
```

---

## 📊 控制台输出格式化

```javascript
// 美化输出统计信息
function printStats(stats) {
  console.log('='.repeat(60));
  console.log('WebRTC Stats @', new Date().toLocaleTimeString());
  console.log('='.repeat(60));

  console.log('\n📡 Network:');
  console.log(`   RTT: ${stats.network.rtt}`);
  console.log(`   Available Bitrate: ${stats.network.availableBitrate}`);

  console.log('\n🎥 Video Inbound:');
  console.log(`   Resolution: ${stats.video.inbound.frameWidth}x${stats.video.inbound.frameHeight}`);
  console.log(`   FPS: ${stats.video.inbound.framesPerSecond}`);
  console.log(`   Jitter: ${stats.video.inbound.jitter}`);
  console.log(`   Packets Lost: ${stats.video.inbound.packetsLost}`);

  console.log('\n🎥 Video Outbound:');
  console.log(`   Resolution: ${stats.video.outbound.frameWidth}x${stats.video.outbound.frameHeight}`);
  console.log(`   FPS: ${stats.video.outbound.framesPerSecond}`);
  console.log(`   Target Bitrate: ${stats.video.outbound.targetBitrate}`);
  console.log(`   Quality Limitation: ${stats.video.outbound.qualityLimitationReason}`);

  console.log('\n🎤 Audio Inbound:');
  console.log(`   Jitter: ${stats.audio.inbound.jitter}`);
  console.log(`   Packets Lost: ${stats.audio.inbound.packetsLost}`);

  console.log('='.repeat(60));
}
```

---

## 🔗 相关笔记

- [[webrtc-internals]] - Chrome 内置调试工具
- [[问题排查指南]] - 基于统计排查问题
- [[QoS策略]] - 基于统计调整策略

---

## 📚 参考资料

- [W3C WebRTC Stats](https://www.w3.org/TR/webrtc-stats/)
- [MDN: RTCPeerConnection.getStats()](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/getStats)
- [WebRTC Stats Explained](https://webrtc.org/getting-started/testing-debugging)

---
#tech/webrtc/stats
