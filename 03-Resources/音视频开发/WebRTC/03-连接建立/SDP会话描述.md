---
title: SDP 会话描述
date: 2026-03-02
tags:
  - WebRTC
  - SDP
  - 协议
difficulty: ⭐⭐⭐⭐
status: 🌱 学习中
related:
  - RTCPeerConnection
  - 编解码器
  - ICE候选
---

# SDP 会话描述

> SDP (Session Description Protocol) 是 WebRTC 中描述媒体会话的文本协议

## 📌 核心作用

- 描述媒体能力（编解码器、格式）
- 传输地址和端口信息
- 协商媒体参数
- 携带 ICE 候选信息
- 建立 DTLS 加密参数

---

## 📄 SDP 结构

### 基本格式

SDP 由多行 `type=value` 组成：

```
v=0
o=- 123456789 2 IN IP4 127.0.0.1
s=-
t=0 0
a=group:BUNDLE 0 1
a=msid-semantic: WMS
m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
...
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 125 107 108 109 124 120 123 119
...
```

### 字段说明

| 字段 | 名称 | 说明 |
|------|------|------|
| `v=` | Version | 版本号，固定为 0 |
| `o=` | Origin | 会话发起者信息 |
| `s=` | Session Name | 会话名称 |
| `t=` | Timing | 会话时间 |
| `m=` | Media | 媒体描述行 |
| `a=` | Attribute | 属性行 |
| `c=` | Connection | 连接信息 |
| `b=` | Bandwidth | 带宽信息 |

---

## 🔍 详细解析

### Origin 行 (o=)

```
o=<username> <session-id> <session-version> <nettype> <addrtype> <unicast-address>

示例:
o=- 123456789012345678 2 IN IP4 192.168.1.100
```

| 字段 | 说明 |
|------|------|
| username | 用户名，通常为 `-` |
| session-id | 会话唯一标识（时间戳） |
| session-version | 会话版本号（每次修改递增） |
| nettype | 网络类型，通常为 `IN` (Internet) |
| addrtype | 地址类型：`IP4` 或 `IP6` |
| unicast-address | IP 地址 |

### Media 行 (m=)

```
m=<media> <port> <proto> <fmt> ...

示例:
m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100
```

| 字段 | 说明 |
|------|------|
| media | 媒体类型：`audio`、`video`、`application` |
| port | 端口，WebRTC 中通常为 9（由 ICE 决定实际端口） |
| proto | 协议：`UDP/TLS/RTP/SAVPF`（安全 RTP） |
| fmt | 格式列表（Payload Type），按优先级排序 |

### 协议说明

| 协议 | 说明 |
|------|------|
| `RTP/AVP` | 基础 RTP |
| `RTP/SAVP` | 安全 RTP (SRTP) |
| `UDP/TLS/RTP/SAVPF` | UDP + DTLS + SRTP + RTCP 反馈 |

---

## 🏷️ Attribute 行 (a=)

### 全局属性

```
a=group:BUNDLE 0 1          # BUNDLE: 多路复用
a=msid-semantic: WMS        # Media Stream ID 语义
a=ice-options:trickle       # ICE 选项
```

### 媒体级属性

#### 编解码映射 (rtpmap)

```
a=rtpmap:<payload-type> <encoding-name>/<clock-rate>[/<encoding-params>]

示例:
a=rtpmap:111 opus/48000/2     # Opus, 48kHz, 2声道
a=rtpmap:96 VP8/90000         # VP8, 90kHz
a=rtpmap:100 H264/90000       # H.264, 90kHz
```

#### 格式参数 (fmtp)

```
a=fmtp:<payload-type> <format-specific-params>

示例:
a=fmtp:111 minptime=10;useinbandfec=1
a=fmtp:100 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
```

#### RTCP 反馈 (rtcp-fb)

```
a=rtcp-fb:<payload-type> <feedback-type>

示例:
a=rtcp-fb:96 goog-remb       # Google REMB (带宽估计)
a=rtcp-fb:96 transport-cc    # 传输拥塞控制
a=rtcp-fb:96 ccm fir         # 完整帧请求
a=rtcp-fb:96 nack            # 负面确认
a=rtcp-fb:96 nack pli        # 图像丢失指示
```

#### ICE 相关

```
a=ice-ufrag:abcd                    # ICE 用户名片段
a=ice-pwd:abcdefghijklmnopqrstuvwx  # ICE 密码
a=candidate:...                     # ICE 候选
a=ice-options:trickle               # 支持 Trickle ICE
```

#### DTLS 相关

```
a=fingerprint:sha-256 AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90
a=setup:actpass                     # DTLS 角色: actpass | active | passive
```

#### 方向控制

```
a=sendrecv     # 发送和接收
a=sendonly     # 只发送
a=recvonly     # 只接收
a=inactive     # 不活跃
```

#### SSRC 相关

```
a=ssrc:<ssrc-id> cname:<cname>
a=ssrc:<ssrc-id> msid:<stream-id> <track-id>
a=ssrc:<ssrc-id> mslabel:<stream-id>
a=ssrc:<ssrc-id> label:<track-id>

示例:
a=ssrc:123456789 cname:user1
a=ssrc:123456789 msid:stream track
a=ssrc:123456789 mslabel:stream
a=ssrc:123456789 label:track
```

#### RTX (重传)

```
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96    # apt: 关联的 payload type
```

---

## 🎤 完整音频 SDP 示例

```
m=audio 9 UDP/TLS/RTP/SAVPF 111 103 104 9 0 8 106 105 13 110 112 113 126
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:abcd
a=ice-pwd:abcdefghijklmnopqrstuvwx
a=ice-options:trickle
a=fingerprint:sha-256 AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90
a=setup:actpass
a=mid:0
a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=sendrecv
a=rtcp-mux
a=rtpmap:111 opus/48000/2
a=fmtp:111 minptime=10;useinbandfec=1
a=rtpmap:103 ISAC/16000
a=rtpmap:104 ISAC/32000
a=rtpmap:9 G722/8000
a=rtpmap:0 PCMU/8000
a=rtpmap:8 PCMA/8000
a=rtpmap:106 CN/32000
a=rtpmap:105 CN/16000
a=rtpmap:13 CN/8000
a=rtpmap:110 telephone-event/48000
a=rtpmap:112 telephone-event/32000
a=rtpmap:113 telephone-event/16000
a=rtpmap:126 telephone-event/8000
a=ssrc:123456789 cname:user1
a=ssrc:123456789 msid:stream track
```

---

## 🎬 完整视频 SDP 示例

```
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 102 122 127 121 125 107 108 109 124
c=IN IP4 0.0.0.0
a=rtcp:9 IN IP4 0.0.0.0
a=ice-ufrag:abcd
a=ice-pwd:abcdefghijklmnopqrstuvwx
a=ice-options:trickle
a=fingerprint:sha-256 AB:CD:EF:12:34:56:78:90
a=setup:actpass
a=mid:1
a=extmap:14 urn:ietf:params:rtp-hdrext:toffset
a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time
a=extmap:13 urn:3gpp:video-orientation
a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01
a=sendrecv
a=rtcp-mux
a=rtcp-rsize
a=rtpmap:96 VP8/90000
a=rtcp-fb:96 goog-remb
a=rtcp-fb:96 transport-cc
a=rtcp-fb:96 ccm fir
a=rtcp-fb:96 nack
a=rtcp-fb:96 nack pli
a=rtpmap:97 rtx/90000
a=fmtp:97 apt=96
a=rtpmap:98 VP9/90000
a=rtcp-fb:98 goog-remb
a=rtcp-fb:98 transport-cc
a=rtcp-fb:98 ccm fir
a=rtcp-fb:98 nack
a=rtcp-fb:98 nack pli
a=rtpmap:99 rtx/90000
a=fmtp:99 apt=98
a=rtpmap:100 H264/90000
a=rtcp-fb:100 goog-remb
a=rtcp-fb:100 transport-cc
a=rtcp-fb:100 ccm fir
a=rtcp-fb:100 nack
a=rtcp-fb:100 nack pli
a=fmtp:100 level-asymmetry-allowed=1;packetization-mode=1;profile-level-id=42e01f
a=rtpmap:101 rtx/90000
a=fmtp:101 apt=100
a=ssrc:987654321 cname:user1
a=ssrc:987654321 msid:stream track
```

---

## 📊 BUNDLE 与 多路复用

### BUNDLE 机制

```
a=group:BUNDLE 0 1
a=mid:0   # 音频
a=mid:1   # 视频
```

**作用**：
- 将多个媒体流（音频、视频）复用到同一个传输连接
- 减少 NAT 穿透的复杂性
- 节省端口资源
- 提高连接成功率

### MID (Media Identification)

```
a=mid:<identifier>
```

- 标识不同的媒体流
- 与 BUNDLE 配合使用
- 用于在重新协商时匹配媒体描述

---

## 🔄 Plan B vs Unified Plan

### Plan B (旧版，已废弃)

```
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98
a=ssrc:111 cname:user1
a=ssrc:222 cname:user1
a=ssrc:333 cname:user1
```

- 一个 m= 行包含多个 SSRC
- 多个 track 共享一个媒体描述
- 已废弃

### Unified Plan (推荐)

```
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98
a=ssrc:111 cname:user1
m=video 9 UDP/TLS/RTP/SAVPF 96 97 98
a=ssrc:222 cname:user1
```

- 每个 track 对应一个 m= 行
- 更好的语义化
- 浏览器默认使用

```javascript
// 强制使用 Unified Plan
const pc = new RTCPeerConnection({
  sdpSemantics: 'unified-plan'
});
```

---

## 🔧 SDP 操作

### 查看当前 SDP

```javascript
const pc = new RTCPeerConnection();

// 创建 offer 后
const offer = await pc.createOffer();
await pc.setLocalDescription(offer);

console.log('Local SDP:', pc.localDescription.sdp);
console.log('Local Type:', pc.localDescription.type);
```

### 解析 SDP

```javascript
function parseSDP(sdp) {
  const lines = sdp.split('\n');
  const result = {
    origins: [],
    medias: [],
    candidates: []
  };

  lines.forEach(line => {
    if (line.startsWith('o=')) result.origins.push(line);
    if (line.startsWith('m=')) result.medias.push(line);
    if (line.startsWith('a=candidate:')) result.candidates.push(line);
  });

  return result;
}
```

### 使用 SDP 语义 API（推荐）

```javascript
// 推荐: 使用标准 API 而非直接修改 SDP

// 获取收发器
const transceivers = pc.getTransceivers();

// 修改编解码器偏好
const transceiver = transceivers.find(t => t.receiver.track.kind === 'video');
if (transceiver) {
  const capabilities = RTCRtpReceiver.getCapabilities('video');
  const codecs = capabilities.codecs;

  // 过滤和排序编解码器
  const preferredCodecs = codecs.filter(c => c.mimeType === 'video/VP9');

  transceiver.setCodecPreferences(preferredCodecs);
}
```

### SDP Munging（不推荐）

```javascript
// ⚠️ 警告: SDP munging 是非标准做法，可能不兼容
// 仅用于调试或特殊需求

function preferCodec(sdp, codec) {
  const lines = sdp.split('\n');
  // 实现编解码器重排序逻辑
  // 注意: 这种方法不推荐在生产环境使用
  return lines.join('\n');
}
```

---

## 🔗 相关笔记

- [[RTCPeerConnection]] - SDP 协商流程
- [[编解码器]] - rtpmap 和 fmtp 详解
- [[RTP-RTCP协议]] - 底层传输协议
- [[ICE候选]] - candidate 属性

---

## 📚 参考资料

- [RFC 4566 - SDP](https://tools.ietf.org/html/rfc4566)
- [RFC 3264 - Offer/Answer Model](https://tools.ietf.org/html/rfc3264)
- [WebRTC SDP Anatomy](https://webrtchacks.com/sdp-anatomy/)
- [RFC 8851 - Unified Plan](https://tools.ietf.org/html/rfc8851)

---
#tech/webrtc/sdp
