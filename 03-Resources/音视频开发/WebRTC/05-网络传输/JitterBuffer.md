---
title: Jitter Buffer
date: 2026-03-02
tags:
  - WebRTC
  - JitterBuffer
  - 抖动
  - 播放控制
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - RTP-RTCP协议
  - FEC前向纠错
  - 音频处理
---

# Jitter Buffer

> Jitter Buffer 是用于平滑网络抖动、保证音视频连续播放的关键组件

## 📌 核心作用

- 吸收网络抖动
- 处理乱序包
- 平滑播放
- 平衡延迟和质量

---

## 📊 网络抖动问题

### 什么是抖动

```
理想情况（固定间隔）:
发送:  |---|---|---|---|---|
时间:  0   50  100 150 200  (ms)

实际情况（网络抖动）:
发送:  |---|---|---|---|---|
接收:  |--|----|-|--|----|--
时间:  0  40  110 130 180 230  (ms)
           ↑   ↑   ↑
         早到 晚到 乱序
```

### 抖动的影响

```javascript
// 没有抖动缓冲的问题：
// 1. 播放卡顿
// 2. 音视频不同步
// 3. 画面闪烁
// 4. 声音断断续续
```

---

## 🔄 Jitter Buffer 原理

### 基本架构

```
┌─────────────────────────────────────────────────────────────┐
│                    Jitter Buffer                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  接收包          缓冲区                播放                  │
│    │              │                    │                    │
│    ▼              ▼                    ▼                    │
│  ┌─────┐      ┌─────────────┐      ┌─────┐                 │
│  │ RTP │ ───► │ [1][2][3][4]│ ───► │解码 │ ───► 播放       │
│  │ 包  │      │   缓冲队列   │      │渲染 │                 │
│  └─────┘      └─────────────┘      └─────┘                 │
│                     │                                       │
│                     ▼                                       │
│              ┌─────────────┐                                │
│              │  自适应调整  │                                │
│              │  缓冲大小    │                                │
│              └─────────────┘                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 工作流程

```
1. 接收 RTP 包
2. 根据时间戳排序
3. 放入缓冲队列
4. 等待一定时间（缓冲延迟）
5. 按顺序取出播放
```

---

## 🎛️ 自适应 Jitter Buffer

### 动态调整策略

```javascript
class AdaptiveJitterBuffer {
  constructor() {
    this.buffer = [];
    this.minDelay = 20;      // 最小延迟 (ms)
    this.maxDelay = 500;     // 最大延迟 (ms)
    this.targetDelay = 100;  // 目标延迟 (ms)
    this.currentDelay = 100;

    // 统计
    this.jitterHistory = [];
    this.lateLossCount = 0;
    this.totalPackets = 0;
  }

  // 插入包
  insert(packet) {
    this.totalPackets++;

    // 按时间戳排序插入
    let inserted = false;
    for (let i = this.buffer.length - 1; i >= 0; i--) {
      if (packet.timestamp > this.buffer[i].timestamp) {
        this.buffer.splice(i + 1, 0, packet);
        inserted = true;
        break;
      }
    }
    if (!inserted) {
      this.buffer.unshift(packet);
    }

    // 更新抖动估计
    this.updateJitterEstimate(packet);
  }

  // 获取可播放的包
  getPacket(now) {
    if (this.buffer.length === 0) return null;

    const packet = this.buffer[0];
    const delay = now - packet.arrivalTime;

    // 检查是否到了播放时间
    if (delay >= this.currentDelay) {
      this.buffer.shift();
      return packet;
    }

    return null;
  }

  // 更新抖动估计
  updateJitterEstimate(packet) {
    // 计算抖动 (RFC 3550)
    if (this.lastPacket) {
      const D = Math.abs(
        (packet.arrivalTime - this.lastPacket.arrivalTime) -
        (packet.timestamp - this.lastPacket.timestamp)
      );

      // 平滑抖动
      this.jitter = this.jitter
        ? this.jitter + (D - this.jitter) / 16
        : D;

      this.jitterHistory.push(this.jitter);
      if (this.jitterHistory.length > 100) {
        this.jitterHistory.shift();
      }
    }
    this.lastPacket = packet;
  }

  // 自适应调整延迟
  adaptDelay() {
    if (this.jitterHistory.length < 10) return;

    // 计算抖动的统计特性
    const avgJitter = this.jitterHistory.reduce((a, b) => a + b, 0) / this.jitterHistory.length;
    const maxJitter = Math.max(...this.jitterHistory);

    // 计算迟到率
    const lateRate = this.lateLossCount / this.totalPackets;

    // 调整策略
    if (lateRate > 0.01) {
      // 迟到率过高，增加缓冲
      this.targetDelay = Math.min(this.targetDelay * 1.1, this.maxDelay);
    } else if (avgJitter < this.currentDelay * 0.5) {
      // 抖动较小，可以减少缓冲
      this.targetDelay = Math.max(this.targetDelay * 0.95, this.minDelay);
    }

    // 平滑过渡
    this.currentDelay += (this.targetDelay - this.currentDelay) * 0.1;
  }
}
```

---

## 🔊 音频 Jitter Buffer

### NetEQ (WebRTC 音频 Jitter Buffer)

```javascript
// NetEQ 是 WebRTC 的音频抖动缓冲实现
// 主要功能：
// 1. 自适应抖动缓冲
// 2. 丢包隐藏 (PLC)
// 3. 加速/减速播放
// 4. 混合处理

class AudioJitterBuffer {
  constructor(sampleRate = 48000) {
    this.sampleRate = sampleRate;
    this.buffer = [];
    this.frameSize = 480; // 10ms @ 48kHz
    this.targetDelayMs = 60;
    this.minDelayMs = 20;
    this.maxDelayMs = 500;
  }

  // 插入音频包
  insert(packet) {
    const decoded = this.decode(packet);
    this.buffer.push({
      timestamp: packet.timestamp,
      samples: decoded,
      arrivalTime: performance.now()
    });

    // 排序
    this.buffer.sort((a, b) => a.timestamp - b.timestamp);
  }

  // 获取音频数据
  getAudio(now) {
    const delayMs = this.targetDelayMs;
    const targetTime = now - delayMs;

    // 找到目标帧
    for (let i = 0; i < this.buffer.length; i++) {
      const frame = this.buffer[i];
      if (frame.arrivalTime <= targetTime) {
        this.buffer.splice(0, i + 1);
        return frame.samples;
      }
    }

    // 没有数据，执行丢包隐藏
    return this.packetConcealment();
  }

  // 丢包隐藏 (PLC)
  packetConcealment() {
    // 使用前一帧生成平滑的噪声或重复
    if (this.lastFrame) {
      // 简单实现：重复最后一帧并衰减
      return this.lastFrame.map(s => s * 0.8);
    }

    // 静音
    return new Float32Array(this.frameSize);
  }

  // 加速播放（追赶）
  accelerate(samples, factor) {
    // 使用 WSOLA 等算法加速
    // 这里简化实现
    const newLength = Math.floor(samples.length / factor);
    const result = new Float32Array(newLength);
    for (let i = 0; i < newLength; i++) {
      result[i] = samples[Math.floor(i * factor)];
    }
    return result;
  }

  // 减速播放（延缓）
  stretch(samples, factor) {
    const newLength = Math.floor(samples.length * factor);
    const result = new Float32Array(newLength);
    for (let i = 0; i < newLength; i++) {
      result[i] = samples[Math.floor(i / factor)];
    }
    return result;
  }
}
```

---

## 🎬 视频 Jitter Buffer

### 视频缓冲特点

```javascript
class VideoJitterBuffer {
  constructor() {
    this.frames = new Map();  // timestamp -> frame
    this.readyFrames = [];
    this.lastRenderedTime = 0;
    this.targetDelay = 0;
    this.minDelay = 0;        // 视频可以更激进
    this.maxDelay = 1000;     // 允许更大延迟
  }

  // 插入帧
  insertFrame(frame) {
    this.frames.set(frame.timestamp, frame);

    // 检查是否有完整帧可以解码
    this.checkCompleteFrames();
  }

  // 检查完整帧
  checkCompleteFrames() {
    // 视频帧可能分多个 RTP 包
    // 需要检查是否所有包都已到达
    for (const [timestamp, frame] of this.frames) {
      if (frame.complete && !frame.decoded) {
        const decoded = this.decode(frame);
        this.readyFrames.push({
          timestamp,
          decoded,
          arrivalTime: frame.arrivalTime
        });
        frame.decoded = true;
      }
    }

    // 按时间戳排序
    this.readyFrames.sort((a, b) => a.timestamp - b.timestamp);
  }

  // 获取帧
  getFrame(now) {
    if (this.readyFrames.length === 0) return null;

    // 对于视频，通常直接取最早的可播放帧
    // 因为视频帧有依赖关系

    const frame = this.readyFrames.shift();
    return frame;
  }

  // 处理关键帧
  handleKeyFrame(frame) {
    // 收到关键帧后，清空之前的缓冲
    // 从关键帧重新开始
    this.frames.clear();
    this.readyFrames = [];

    this.insertFrame(frame);
  }
}
```

---

## 📈 抖动统计

### 计算抖动

```javascript
// RFC 3550 抖动计算
class JitterCalculator {
  constructor() {
    this.jitter = 0;
    this.lastArrival = 0;
    this.lastTimestamp = 0;
  }

  update(arrivalTime, timestamp, clockRate = 90000) {
    if (this.lastArrival === 0) {
      this.lastArrival = arrivalTime;
      this.lastTimestamp = timestamp;
      return this.jitter;
    }

    // 转换为相同单位
    const arrivalDiff = (arrivalTime - this.lastArrival) * clockRate / 1000;
    const timestampDiff = timestamp - this.lastTimestamp;

    // 计算相对传输时间差
    const D = arrivalDiff - timestampDiff;

    // 更新抖动（平滑）
    this.jitter = this.jitter + (Math.abs(D) - this.jitter) / 16;

    this.lastArrival = arrivalTime;
    this.lastTimestamp = timestamp;

    return this.jitter;
  }

  // 获取抖动（毫秒）
  getJitterMs(clockRate = 90000) {
    return this.jitter * 1000 / clockRate;
  }
}
```

### 获取 WebRTC 抖动统计

```javascript
async function getJitterStats(pc) {
  const stats = await pc.getStats();
  const jitterStats = {};

  stats.forEach(report => {
    if (report.type === 'inbound-rtp') {
      jitterStats[report.kind] = {
        jitter: report.jitter,
        jitterBufferMs: report.jitterBufferDelay / report.jitterBufferEmittedCount * 1000
      };
    }
  });

  return jitterStats;
}

// 使用
setInterval(async () => {
  const stats = await getJitterStats(pc);
  console.log('音频抖动:', stats.audio?.jitterBufferMs?.toFixed(2), 'ms');
  console.log('视频抖动:', stats.video?.jitterBufferMs?.toFixed(2), 'ms');
}, 1000);
```

---

## 🎯 最佳实践

### 1. 音视频同步

```javascript
class AVSynchronizer {
  constructor() {
    this.audioJitterBuffer = new AudioJitterBuffer();
    this.videoJitterBuffer = new VideoJitterBuffer();
    this.audioClock = 0;
    this.videoClock = 0;
  }

  sync(audioFrame, videoFrame) {
    // 基于 NTP 时间戳同步
    const audioTime = audioFrame.ntpTimestamp;
    const videoTime = videoFrame.ntpTimestamp;

    const diff = audioTime - videoTime;

    if (Math.abs(diff) > 10) { // 超过 10ms 需要调整
      if (diff > 0) {
        // 音频超前，等待视频
        this.videoJitterBuffer.reduceDelay();
      } else {
        // 视频超前，等待音频
        this.audioJitterBuffer.reduceDelay();
      }
    }
  }
}
```

### 2. 延迟质量平衡

```javascript
// 根据应用场景调整策略
const profiles = {
  // 实时通话：优先低延迟
  realtime: {
    minDelay: 20,
    maxDelay: 200,
    targetDelay: 60
  },

  // 在线教育：平衡延迟和质量
  education: {
    minDelay: 50,
    maxDelay: 500,
    targetDelay: 150
  },

  // 直播观看：优先质量
  streaming: {
    minDelay: 100,
    maxDelay: 2000,
    targetDelay: 500
  }
};
```

---

## 🔗 相关笔记

- [[RTP-RTCP协议]] - 时间戳和序列号
- [[FEC前向纠错]] - 丢包恢复
- [[音频处理]] - 音频 PLC
- [[质量控制]] - 延迟优化

---

## 📚 参考资料

- [RFC 3550 - RTP Jitter Calculation](https://tools.ietf.org/html/rfc3550#section-6.4.4)
- [WebRTC NetEQ](https://webrtc.googlesource.com/src/+/refs/heads/main/modules/audio_coding/neteq/)
- [Jitter Buffer Design](https://www.webrtc.org/getting-started/jitter-buffer)

---
#tech/webrtc/jitter
