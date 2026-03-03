---
title: SRTP 加密
date: 2026-03-02
tags:
  - WebRTC
  - SRTP
  - 安全
  - 加密
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - RTP-RTCP协议
  - DTLS
  - RTCPeerConnection
---

# SRTP 加密

> SRTP (Secure RTP) 是 WebRTC 强制使用的媒体加密协议，确保音视频传输安全

## 📌 核心作用

- 加密 RTP 媒体数据
- 保护数据完整性
- 防止重放攻击
- 保证消息认证

---

## 🔐 WebRTC 安全架构

```
┌─────────────────────────────────────────────────────────────┐
│                    WebRTC 安全层次                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 信令层 (HTTPS/WSS)                   │   │
│  │         保护 SDP 交换的安全性                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 DTLS (Datagram TLS)                  │   │
│  │         协商加密密钥、建立安全通道                    │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 SRTP (Secure RTP)                    │   │
│  │         加密实际的音视频数据                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 密钥协商流程

### DTLS 握手

```
Peer A                                      Peer B
   │                                           │
   │  1. DTLS ClientHello                      │
   │  (包含支持的加密套件、指纹)                │
   │ ────────────────────────────────────────► │
   │                                           │
   │  2. DTLS ServerHello                      │
   │  (选择的加密套件、指纹)                    │
   │ ◄───────────────────────────────────────  │
   │                                           │
   │  3. Certificate Exchange                  │
   │  (通过 SDP fingerprint 验证)              │
   │ ◄───────────────────────────────────────► │
   │                                           │
   │  4. Key Exchange                          │
   │  (ECDHE 密钥交换)                         │
   │ ◄───────────────────────────────────────► │
   │                                           │
   │  5. Finished                              │
   │ ◄───────────────────────────────────────► │
   │                                           │
   │  ====== DTLS 连接建立 ======              │
   │                                           │
   │  导出 SRTP 密钥材料                        │
   │                                           │
```

### SDP 中的 DTLS 指纹

```
a=fingerprint:sha-256 AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90
a=setup:actpass
```

---

## 📦 SRTP 包结构

### SRTP 包格式

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
|                         Payload                               |
|                             ....                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         MKI (可选)                            |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Auth Tag                              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

### 加密部分

```
RTP Header (12字节) - 不加密
    │
    ├── Version, Padding, Extension, CC
    ├── Marker, Payload Type
    ├── Sequence Number
    ├── Timestamp
    └── SSRC

RTP Payload - 加密
    │
    └── 实际的音视频数据

Auth Tag (10字节) - 认证标签
    │
    └── 用于验证数据完整性
```

---

## 🔧 SRTP 加密算法

### 加密套件

| 套件 | 加密算法 | 认证算法 | 密钥长度 |
|------|----------|----------|----------|
| AES_CM_128_HMAC_SHA1_80 | AES-CTR | HMAC-SHA1 | 128位 |
| AES_CM_128_HMAC_SHA1_32 | AES-CTR | HMAC-SHA1 | 128位 |
| AEAD_AES_128_GCM | AES-GCM | - | 128位 |
| AEAD_AES_256_GCM | AES-GCM | - | 256位 |

### 密钥派生

```javascript
// SRTP 密钥从 DTLS 导出
// 使用 TLS Exporter (RFC 5705)

// 伪代码
const srtpKeyMaterial = dtls.exportKeyingMaterial(
  'EXTRACTOR-dtls_srtp',  // 标签
  clientWriteKey + serverWriteKey + clientWriteSalt + serverWriteSalt
);

// 分割密钥材料
const clientWriteKey = srtpKeyMaterial.slice(0, 16);
const serverWriteKey = srtpKeyMaterial.slice(16, 32);
const clientWriteSalt = srtpKeyMaterial.slice(32, 38);
const serverWriteSalt = srtpKeyMaterial.slice(38, 44);
```

---

## 🔒 加密过程

### AES-CTR 加密

```javascript
// 简化的 SRTP 加密过程

function encryptRtpPacket(packet, key, salt) {
  // 1. 生成 IV (Initialization Vector)
  const iv = generateIv(packet.ssrc, packet.sequenceNumber, salt);

  // 2. 生成密钥流
  const keystream = aesCtr(key, iv, packet.payload.length);

  // 3. XOR 加密
  const encryptedPayload = xor(packet.payload, keystream);

  // 4. 计算认证标签
  const authTag = hmacSha1(key, packet.header + encryptedPayload);

  return {
    header: packet.header,
    payload: encryptedPayload,
    authTag: authTag
  };
}

function generateIv(ssrc, seqNum, salt) {
  // IV = SSRC || SeqNum || ROC (Roll Over Counter)
  return xor(
    concat(ssrc, seqNum, roc),
    salt
  );
}
```

### 解密验证

```javascript
function decryptRtpPacket(encryptedPacket, key, salt) {
  // 1. 验证认证标签
  const expectedAuthTag = hmacSha1(key,
    encryptedPacket.header + encryptedPacket.payload
  );

  if (expectedAuthTag !== encryptedPacket.authTag) {
    throw new Error('认证失败');
  }

  // 2. 生成 IV
  const iv = generateIv(
    encryptedPacket.ssrc,
    encryptedPacket.seqNum,
    salt
  );

  // 3. 生成密钥流
  const keystream = aesCtr(key, iv, encryptedPacket.payload.length);

  // 4. XOR 解密
  const payload = xor(encryptedPacket.payload, keystream);

  return payload;
}
```

---

## 🛡️ 重放保护

### Replay Protection

```javascript
// SRTP 使用滑动窗口防止重放攻击

class ReplayProtection {
  constructor(windowSize = 64) {
    this.windowSize = windowSize;
    this.highestSeqNum = 0;
    this.window = new BigInt64Array(windowSize / 64);
  }

  check(seqNum) {
    // 检查是否在窗口范围内
    if (seqNum > this.highestSeqNum) {
      // 新的序列号，更新窗口
      const shift = seqNum - this.highestSeqNum;
      this.shiftWindow(shift);
      this.highestSeqNum = seqNum;
      this.markReceived(seqNum);
      return true;
    }

    // 检查是否太旧
    if (this.highestSeqNum - seqNum >= this.windowSize) {
      return false; // 拒绝
    }

    // 检查是否已接收
    if (this.isReceived(seqNum)) {
      return false; // 重放攻击
    }

    this.markReceived(seqNum);
    return true;
  }

  markReceived(seqNum) {
    const index = (this.highestSeqNum - seqNum) % this.windowSize;
    const word = Math.floor(index / 64);
    const bit = index % 64;
    this.window[word] |= (1n << BigInt(bit));
  }

  isReceived(seqNum) {
    const index = (this.highestSeqNum - seqNum) % this.windowSize;
    const word = Math.floor(index / 64);
    const bit = index % 64;
    return (this.window[word] & (1n << BigInt(bit))) !== 0n;
  }

  shiftWindow(shift) {
    // 移动窗口
    // 实现略
  }
}
```

---

## 📊 WebRTC 中的 SRTP

### 强制加密

```javascript
// WebRTC 强制使用 SRTP，无法禁用
const pc = new RTCPeerConnection({
  iceServers: [{ urls: 'stun:stun.l.google.com:19302' }]
});

// 所有媒体数据自动加密
// 不需要手动配置

// 查看加密信息
const stats = await pc.getStats();
stats.forEach(report => {
  if (report.type === 'transport') {
    console.log('加密套件:', report.selectedCandidatePairId);
  }
});
```

### DTLS 角色

```javascript
// SDP 中的 DTLS 设置
a=setup:actpass    // 可以是 client 或 server
a=setup:active     // 主动连接（client）
a=setup:passive    // 被动连接（server）

// WebRTC 自动处理角色协商
```

---

## 🔍 安全检查

### 验证 DTLS 指纹

```javascript
// 在 SDP 交换时验证指纹
function verifyFingerprint(sdp, certificate) {
  const fingerprint = extractFingerprintFromSdp(sdp);
  const expectedFingerprint = calculateFingerprint(certificate);

  if (fingerprint !== expectedFingerprint) {
    throw new Error('指纹验证失败！可能存在中间人攻击');
  }

  return true;
}
```

### 检查加密状态

```javascript
async function checkEncryption(pc) {
  const stats = await pc.getStats();

  stats.forEach(report => {
    if (report.type === 'transport') {
      console.log('安全状态:', {
        dtlsState: report.dtlsState,
        selectedCandidatePair: report.selectedCandidatePairId,
        srtpCipher: report.srtpCipher
      });
    }
  });
}
```

---

## 📋 安全最佳实践

### 1. 使用 HTTPS

```javascript
// WebRTC 要求 HTTPS 环境
if (location.protocol !== 'https:' && location.hostname !== 'localhost') {
  throw new Error('WebRTC 需要 HTTPS');
}
```

### 2. 验证远程指纹

```javascript
// 不要信任未验证的 SDP
pc.onconnectionstatechange = async () => {
  if (pc.connectionState === 'connected') {
    // 验证远程证书指纹
    const stats = await pc.getStats();
    // 检查指纹匹配
  }
};
```

### 3. 保护信令通道

```javascript
// 信令服务器必须使用 WSS
const signaling = new WebSocket('wss://your-server.com');

// 验证消息来源
signaling.onmessage = (event) => {
  const data = JSON.parse(event.data);

  // 验证消息完整性
  if (!verifyMessage(data)) {
    console.error('消息验证失败');
    return;
  }

  // 处理消息
  handleMessage(data);
};
```

---

## 🔗 相关笔记

- [[RTP-RTCP协议]] - RTP 基础协议
- [[RTCPeerConnection]] - DTLS 配置
- [[ICE候选]] - 安全的 ICE 协商

---

## 📚 参考资料

- [RFC 3711 - SRTP](https://tools.ietf.org/html/rfc3711)
- [RFC 5764 - DTLS-SRTP](https://tools.ietf.org/html/rfc5764)
- [RFC 5705 - TLS Key Material Exporters](https://tools.ietf.org/html/rfc5705)
- [WebRTC Security](https://webrtc.org/getting-started/security)

---
#tech/webrtc/security
