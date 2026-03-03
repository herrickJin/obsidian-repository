---
title: FEC 前向纠错
date: 2026-03-02
tags:
  - WebRTC
  - FEC
  - 纠错
  - 可靠性
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - 拥塞控制
  - RTP-RTCP协议
  - 码率自适应
---

# FEC 前向纠错

> FEC (Forward Error Correction) 是一种通过添加冗余数据来恢复丢失包的技术

## 📌 核心作用

- 无需重传即可恢复丢包
- 降低延迟（相比 NACK）
- 提高弱网下的通话质量

---

## 🔄 FEC vs NACK

```
┌─────────────────────────────────────────────────────────────┐
│                    丢包恢复策略对比                          │
├─────────────────┬─────────────────────┬─────────────────────┤
│                 │        NACK         │        FEC          │
├─────────────────┼─────────────────────┼─────────────────────┤
│ 原理            │ 请求重传丢失的包     │ 添加冗余包恢复      │
│ 延迟            │ 高（需要 RTT）       │ 低（无需等待）      │
│ 带宽开销        │ 仅丢包时消耗         │ 持续消耗           │
│ 适用场景        │ 低丢包率            │ 高丢包率           │
│ 实现复杂度      │ 简单                │ 复杂               │
└─────────────────┴─────────────────────┴─────────────────────┘
```

### 组合使用

```
丢包率:
  0-5%   → 不需要额外措施
  5-10%  → NACK
  10-20% → NACK + FEC
  >20%   → FEC 为主
```

---

## 📦 WebRTC 中的 FEC

### 音频 FEC - Opus

```javascript
// Opus 编解码器内置 FEC
// 在 SDP 中启用
a=fmtp:111 minptime=10;useinbandfec=1

// 启用后，Opus 会在每个包中包含前一帧的低比特率副本
// 丢包时可以用低质量版本恢复
```

### 视频 FEC - ULPFLEX

```javascript
// WebRTC 使用 ULPFLEX (Uneven Level Protection FEC)
// 对重要数据（如关键帧）提供更强保护

// SDP 中启用
a=rtpmap:116 red/90000    // RED (Redundant Encoding)
a=fmtp:116 96/97          // VP8/VP9
```

---

## 🧮 XOR FEC 原理

### 基本原理

```
原始包:  A  B  C
FEC 包:  F = A XOR B XOR C

如果 B 丢失:
恢复: B = A XOR C XOR F

示例:
A = 1010
B = 1100  (丢失)
C = 0110
F = 1010 XOR 1100 XOR 0110 = 0000

恢复 B = 1010 XOR 0110 XOR 0000 = 1100 ✓
```

### 编码示例

```javascript
class SimpleFEC {
  constructor(k, n) {
    this.k = k;  // 数据包数量
    this.n = n;  // 总包数量（数据 + FEC）
  }

  // 编码：生成 FEC 包
  encode(packets) {
    const fecPackets = [];

    for (let i = 0; i < this.n - this.k; i++) {
      let fecPacket = new Uint8Array(packets[0].length);

      // XOR 所有数据包
      for (const packet of packets) {
        for (let j = 0; j < packet.length; j++) {
          fecPacket[j] ^= packet[j];
        }
      }

      fecPackets.push(fecPacket);
    }

    return fecPackets;
  }

  // 解码：恢复丢失的包
  decode(receivedPackets, lostIndex) {
    let recovered = new Uint8Array(receivedPackets[0].length);

    for (const packet of receivedPackets) {
      for (let j = 0; j < packet.length; j++) {
        recovered[j] ^= packet[j];
      }
    }

    return recovered;
  }
}
```

---

## 📊 Reed-Solomon FEC

### 更强大的 FEC 算法

```javascript
// Reed-Solomon 可以恢复任意 k 个包中的任意丢失
// 比简单的 XOR FEC 更强大

// 使用示例（伪代码，实际需要专门的库）
class ReedSolomonFEC {
  constructor(dataShards, parityShards) {
    this.dataShards = dataShards;    // 数据分片数
    this.parityShards = parityShards; // 校验分片数
    this.totalShards = dataShards + parityShards;
  }

  encode(data) {
    // 将数据分成 k 个分片
    const shards = this.splitData(data);

    // 生成校验分片
    const parityShards = this.calculateParity(shards);

    return [...shards, ...parityShards];
  }

  decode(shards, missingIndices) {
    // 丢失的分片数不能超过校验分片数
    if (missingIndices.length > this.parityShards) {
      throw new Error('无法恢复：丢失过多');
    }

    // 使用矩阵运算恢复
    return this.reconstruct(shards, missingIndices);
  }
}

// 使用
const fec = new ReedSolomonFEC(4, 2);  // 4 数据 + 2 校验
const encoded = fec.encode(originalData);

// 即使丢失 2 个包也能恢复
const decoded = fec.decode(receivedShards, [1, 3]);
```

---

## 🎬 视频 FEC 实现

### ULPFLEX 结构

```
┌─────────────────────────────────────────────────────────────┐
│                    FEC 包结构                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   FEC Header                         │   │
│  │  E: 1 bit  - 扩展标志                                │   │
│  │  PT: 7 bits - 基础包的 Payload Type                  │   │
│  │  Length recovery: 16 bits                           │   │
│  │  E: 1 bit  - 扩展标志                                │   │
│  │  PT: 7 bits - 基础包的 Payload Type                  │   │
│  │  Mask: 16 bits - 指示哪些包被保护                    │   │
│  │  TS recovery: 32 bits - 时间戳恢复                   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  FEC Level 0                         │   │
│  │  保护 RTP 头部 + 载荷前部分                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                  FEC Level 1 (可选)                  │   │
│  │  保护载荷后部分                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 保护级别

```javascript
// 不同数据使用不同保护级别
const protectionLevels = {
  // 高优先级：关键帧数据
  high: {
    fecRate: 0.5,     // 50% 冗余
    protectedParts: ['header', 'keyframe']
  },

  // 中优先级：普通帧
  medium: {
    fecRate: 0.3,     // 30% 冗余
    protectedParts: ['header']
  },

  // 低优先级：非关键数据
  low: {
    fecRate: 0.1,     // 10% 冗余
    protectedParts: ['header']
  }
};
```

---

## 📈 FEC 开销计算

```javascript
class FECCalculator {
  // 计算需要的 FEC 比例
  static calculateFECRate(packetLossRate, targetRecoveryRate = 0.9) {
    // 简化公式：FEC 率应该略高于丢包率
    // 实际需要考虑突发丢包等因素

    if (packetLossRate < 0.05) {
      return 0; // 丢包率低，不需要 FEC
    }

    // 经验公式
    const fecRate = packetLossRate * 1.2;

    // 限制最大值
    return Math.min(fecRate, 0.5); // 最多 50% 冗余
  }

  // 计算实际带宽开销
  static calculateOverhead(dataRate, fecRate) {
    return dataRate * fecRate;
  }

  // 计算有效带宽
  static calculateEffectiveBitrate(totalBitrate, fecRate) {
    return totalBitrate / (1 + fecRate);
  }
}

// 使用示例
const packetLossRate = 0.15; // 15% 丢包
const fecRate = FECCalculator.calculateFECRate(packetLossRate);
console.log(`FEC 率: ${(fecRate * 100).toFixed(0)}%`); // 18%

const dataRate = 1000000; // 1 Mbps
const overhead = FECCalculator.calculateOverhead(dataRate, fecRate);
console.log(`FEC 开销: ${(overhead / 1000).toFixed(0)} kbps`); // 180 kbps
```

---

## 🔧 WebRTC FEC 配置

### 音频 FEC

```javascript
// 在 SDP 中启用 Opus FEC
const sdp = sdp.replace(
  'a=fmtp:111',
  'a=fmtp:111 minptime=10;useinbandfec=1'
);
```

### 视频 FEC

```javascript
// 使用 RED (Redundant Encoding)
// WebRTC 默认会根据网络条件自动调整

// 查看当前 FEC 状态
async function getFECStats(pc) {
  const stats = await pc.getStats();

  stats.forEach(report => {
    if (report.type === 'outbound-rtp' && report.kind === 'video') {
      console.log('FEC 统计:', {
        fecPacketsSent: report.fecPacketsSent,
        fecPacketsReceived: report.fecPacketsReceived
      });
    }
  });
}
```

---

## 🎯 最佳实践

### 1. 动态调整 FEC

```javascript
class AdaptiveFEC {
  constructor() {
    this.currentFecRate = 0;
    this.minFecRate = 0;
    this.maxFecRate = 0.5;
  }

  update(lossRate) {
    if (lossRate < 0.05) {
      // 低丢包，禁用 FEC
      this.currentFecRate = 0;
    } else if (lossRate < 0.1) {
      // 中等丢包，轻度 FEC
      this.currentFecRate = 0.1;
    } else if (lossRate < 0.2) {
      // 较高丢包，中度 FEC
      this.currentFecRate = 0.2;
    } else {
      // 高丢包，重度 FEC
      this.currentFecRate = 0.3;
    }

    return this.currentFecRate;
  }
}
```

### 2. 关键帧优先保护

```javascript
// 对关键帧使用更强的 FEC 保护
function getFrameFECRate(frameType, baseFecRate) {
  if (frameType === 'key') {
    return Math.min(baseFecRate * 2, 0.5);
  }
  return baseFecRate;
}
```

### 3. 结合 NACK

```javascript
// FEC + NACK 组合策略
class HybridLossRecovery {
  constructor() {
    this.fecEnabled = false;
    this.nackEnabled = true;
  }

  updateStrategy(lossRate, rtt) {
    if (lossRate > 0.1) {
      // 高丢包：启用 FEC
      this.fecEnabled = true;
    }

    if (rtt < 0.1) {
      // 低延迟：可以使用 NACK
      this.nackEnabled = true;
    } else {
      // 高延迟：依赖 FEC
      this.nackEnabled = false;
    }

    return {
      fec: this.fecEnabled,
      nack: this.nackEnabled
    };
  }
}
```

---

## 🔗 相关笔记

- [[拥塞控制]] - 带宽分配
- [[RTP-RTCP协议]] - NACK 重传
- [[JitterBuffer]] - 丢包后的处理

---

## 📚 参考资料

- [RFC 5109 - ULPFEC](https://tools.ietf.org/html/rfc5109)
- [RFC 2198 - RED](https://tools.ietf.org/html/rfc2198)
- [Opus FEC](https://tools.ietf.org/html/rfc6716)
- [WebRTC FEC](https://webrtc.org/getting-started/fec)

---
#tech/webrtc/fec
