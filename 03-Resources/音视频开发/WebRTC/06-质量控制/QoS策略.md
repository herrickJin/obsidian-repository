---
title: QoS 策略
date: 2026-03-02
tags:
  - WebRTC
  - QoS
  - 服务质量
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - 拥塞控制
  - 码率自适应
  - 网络检测
---

# QoS 策略

> QoS (Quality of Service) 是保证 WebRTC 通话质量的一系列技术和策略

## 📌 核心目标

- 保证音视频质量
- 降低延迟
- 提高抗丢包能力
- 自适应网络变化

---

## 🔄 QoS 技术体系

```
┌─────────────────────────────────────────────────────────────┐
│                    WebRTC QoS 技术栈                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  带宽估计   │  │  拥塞控制   │  │  码率控制   │         │
│  │   (BWE)     │  │   (GCC)     │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  丢包恢复   │  │  抖动缓冲   │  │  错误隐藏   │         │
│  │ (FEC/NACK)  │  │  (JB)       │  │  (PLC)      │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  音频处理   │  │  视频处理   │  │  优先级     │         │
│  │ (AEC/NS/AGC)│  │  (编码)     │  │  控制       │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 质量指标

### 关键指标

| 指标 | 说明 | 理想值 |
|------|------|--------|
| **RTT** | 往返延迟 | < 150ms |
| **Jitter** | 抖动 | < 30ms |
| **Packet Loss** | 丢包率 | < 2% |
| **Bitrate** | 码率 | 适配带宽 |
| **Frame Rate** | 帧率 | > 24fps |
| **Resolution** | 分辨率 | > 640x480 |

### MOS 评分

```
MOS (Mean Opinion Score) 主观评分:

5 - 优秀: 完美质量
4 - 良好: 高质量，有轻微问题
3 - 一般: 可接受，有明显问题
2 - 较差: 难以接受
1 - 极差: 无法通信
```

### MOS 估算公式

```javascript
// 基于 E-Model 的 MOS 估算
function calculateMOS(rtt, packetLoss, jitter) {
  // 简化公式
  const R = 94.2 - (
    0.024 * rtt +
    0.11 * (rtt - 177.3) * (rtt > 177.3 ? 1 : 0) +
    2.5 * packetLoss * 100 +
    0.01 * jitter
  );

  const MOS = 1 + 0.035 * R + 7 * Math.pow(10, -6) * Math.pow(R, 3);

  return Math.max(1, Math.min(5, MOS));
}
```

---

## 🎛️ 自适应策略

### 码率自适应

```javascript
class AdaptiveBitrateController {
  constructor() {
    this.currentBitrate = 500000;
    this.minBitrate = 30000;
    this.maxBitrate = 5000000;
    this.targetBitrate = 500000;

    // 状态
    this.state = 'stable'; // increasing | decreasing | stable
  }

  update(networkStats) {
    const { bandwidth, lossRate, rtt, jitter } = networkStats;

    // 根据网络状态调整
    if (lossRate > 0.1 || rtt > 0.3) {
      // 网络差，降低码率
      this.decreaseBitrate();
    } else if (lossRate < 0.02 && rtt < 0.1) {
      // 网络好，可以增加码率
      this.increaseBitrate();
    }

    // 根据带宽限制
    if (bandwidth > 0 && this.targetBitrate > bandwidth * 0.9) {
      this.targetBitrate = bandwidth * 0.9;
    }

    return this.targetBitrate;
  }

  increaseBitrate() {
    // 缓慢增加
    this.targetBitrate = Math.min(
      this.targetBitrate * 1.05,
      this.maxBitrate
    );
  }

  decreaseBitrate() {
    // 快速降低
    this.targetBitrate = Math.max(
      this.targetBitrate * 0.7,
      this.minBitrate
    );
  }
}
```

### 分辨率自适应

```javascript
class ResolutionController {
  constructor() {
    this.resolutions = [
      { width: 320, height: 240, minBitrate: 50000 },
      { width: 640, height: 360, minBitrate: 150000 },
      { width: 640, height: 480, minBitrate: 300000 },
      { width: 1280, height: 720, minBitrate: 800000 },
      { width: 1920, height: 1080, minBitrate: 1500000 }
    ];
    this.currentResolution = 2; // 索引
  }

  selectResolution(bitrate) {
    // 选择不超过当前码率的最大分辨率
    for (let i = this.resolutions.length - 1; i >= 0; i--) {
      if (bitrate >= this.resolutions[i].minBitrate) {
        this.currentResolution = i;
        return this.resolutions[i];
      }
    }
    return this.resolutions[0];
  }

  async applyResolution(track, resolution) {
    await track.applyConstraints({
      width: { ideal: resolution.width },
      height: { ideal: resolution.height }
    });
  }
}
```

### 帧率自适应

```javascript
class FrameRateController {
  constructor() {
    this.frameRates = [30, 24, 15, 10, 5];
    this.currentIndex = 0;
  }

  selectFrameRate(bitrate, resolution) {
    // 根据码率和分辨率选择帧率
    const pixels = resolution.width * resolution.height;
    const pixelsPerSecond = pixels * this.frameRates[this.currentIndex];
    const bitsPerPixel = bitrate / pixelsPerSecond;

    if (bitsPerPixel < 0.1) {
      // 每像素比特数太低，降低帧率
      this.decreaseFrameRate();
    } else if (bitsPerPixel > 0.3 && this.currentIndex > 0) {
      // 每像素比特数足够，可以增加帧率
      this.increaseFrameRate();
    }

    return this.getCurrentFrameRate();
  }

  getCurrentFrameRate() {
    return this.frameRates[this.currentIndex];
  }

  decreaseFrameRate() {
    if (this.currentIndex < this.frameRates.length - 1) {
      this.currentIndex++;
    }
  }

  increaseFrameRate() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
    }
  }
}
```

---

## 🎯 优先级控制

### 媒体优先级

```javascript
// 音频优先于视频
const mediaPriority = {
  audio: {
    priority: 'high',
    minBitrate: 16000,
    maxBitrate: 64000
  },
  video: {
    priority: 'medium',
    minBitrate: 30000,
    maxBitrate: 5000000
  },
  data: {
    priority: 'low',
    minBitrate: 0,
    maxBitrate: 100000
  }
};

class PriorityController {
  allocate(totalBitrate) {
    const allocation = {
      audio: 0,
      video: 0,
      data: 0
    };

    // 首先满足音频最低需求
    allocation.audio = Math.min(
      mediaPriority.audio.maxBitrate,
      Math.max(mediaPriority.audio.minBitrate, totalBitrate * 0.1)
    );

    // 剩余给视频
    const remaining = totalBitrate - allocation.audio;

    // FEC 和重传预留
    const overhead = remaining * 0.15;

    // 视频使用大部分
    allocation.video = Math.min(
      mediaPriority.video.maxBitrate,
      remaining - overhead
    );

    // 数据使用剩余
    allocation.data = Math.min(
      mediaPriority.data.maxBitrate,
      totalBitrate - allocation.audio - allocation.video
    );

    return allocation;
  }
}
```

---

## 🔧 关键帧策略

### 请求关键帧的时机

```javascript
class KeyFrameController {
  constructor() {
    this.lastKeyFrameTime = 0;
    this.keyFrameInterval = 5000; // 最小间隔
  }

  shouldRequestKeyFrame(stats) {
    const now = Date.now();

    // 1. 解码错误
    if (stats.decodeErrorCount > 0) {
      return true;
    }

    // 2. 连续丢包
    if (stats.consecutiveLostPackets > 3) {
      return true;
    }

    // 3. 长时间没有关键帧
    if (now - this.lastKeyFrameTime > 30000) {
      return true;
    }

    // 4. 新用户加入
    // (需要信令层通知)

    return false;
  }

  requestKeyFrame() {
    // 通过 RTCP PLI 请求
    // WebRTC 自动处理
    this.lastKeyFrameTime = Date.now();
  }
}
```

---

## 📈 质量监控

### 实时监控

```javascript
class QualityMonitor {
  constructor(pc) {
    this.pc = pc;
    this.history = [];
    this.maxHistory = 60; // 1分钟历史
  }

  async collect() {
    const stats = await this.pc.getStats();
    const quality = {
      timestamp: Date.now(),
      audio: this.extractAudioStats(stats),
      video: this.extractVideoStats(stats),
      network: this.extractNetworkStats(stats)
    };

    this.history.push(quality);
    if (this.history.length > this.maxHistory) {
      this.history.shift();
    }

    return quality;
  }

  extractAudioStats(stats) {
    let audioStats = {};
    stats.forEach(report => {
      if (report.type === 'inbound-rtp' && report.kind === 'audio') {
        audioStats = {
          packetsLost: report.packetsLost,
          jitter: report.jitter,
          bytesReceived: report.bytesReceived
        };
      }
    });
    return audioStats;
  }

  extractVideoStats(stats) {
    let videoStats = {};
    stats.forEach(report => {
      if (report.type === 'inbound-rtp' && report.kind === 'video') {
        videoStats = {
          packetsLost: report.packetsLost,
          jitter: report.jitter,
          framesDecoded: report.framesDecoded,
          framesDropped: report.framesDropped,
          frameWidth: report.frameWidth,
          frameHeight: report.frameHeight,
          framesPerSecond: report.framesPerSecond
        };
      }
    });
    return videoStats;
  }

  extractNetworkStats(stats) {
    let networkStats = {};
    stats.forEach(report => {
      if (report.type === 'candidate-pair' && report.state === 'succeeded') {
        networkStats = {
          rtt: report.currentRoundTripTime,
          availableBitrate: report.availableOutgoingBitrate,
          packetsSent: report.packetsSent,
          packetsReceived: report.packetsReceived
        };
      }
    });
    return networkStats;
  }

  // 获取质量评分
  getQualityScore() {
    if (this.history.length === 0) return 5;

    const recent = this.history.slice(-10);
    let totalScore = 0;

    recent.forEach(q => {
      const lossRate = q.video.packetsLost / (q.video.packetsLost + 100);
      const rtt = q.network.rtt || 0;
      const jitter = q.video.jitter || 0;

      totalScore += calculateMOS(rtt * 1000, lossRate, jitter * 1000);
    });

    return totalScore / recent.length;
  }

  // 检测质量问题
  detectIssues() {
    const issues = [];
    const latest = this.history[this.history.length - 1];

    if (!latest) return issues;

    // 高延迟
    if (latest.network.rtt > 0.2) {
      issues.push({ type: 'high-latency', severity: 'warning', value: latest.network.rtt });
    }

    // 高丢包
    const lossRate = latest.video.packetsLost / (latest.video.packetsLost + 100);
    if (lossRate > 0.05) {
      issues.push({ type: 'high-loss', severity: 'error', value: lossRate });
    }

    // 低帧率
    if (latest.video.framesPerSecond < 15) {
      issues.push({ type: 'low-framerate', severity: 'warning', value: latest.video.framesPerSecond });
    }

    return issues;
  }
}

// 使用
const monitor = new QualityMonitor(pc);
setInterval(async () => {
  const quality = await monitor.collect();
  const score = monitor.getQualityScore();
  const issues = monitor.detectIssues();

  console.log('质量评分:', score.toFixed(2));
  console.log('问题:', issues);
}, 1000);
```

---

## 🔗 相关笔记

- [[拥塞控制]] - 带宽估计和码率控制
- [[网络检测]] - 网络质量检测
- [[码率自适应]] - 动态码率调整
- [[延迟优化]] - 降低延迟策略

---

## 📚 参考资料

- [RFC 3611 - RTCP XR](https://tools.ietf.org/html/rfc3611)
- [WebRTC Stats](https://www.w3.org/TR/webrtc-stats/)
- [E-Model (ITU-T G.107)](https://www.itu.int/rec/T-REC-G.107)

---
#tech/webrtc/qos
