---
title: STUN/TURN 服务器
date: 2026-03-02
tags:
  - WebRTC
  - STUN
  - TURN
  - NAT穿透
difficulty: ⭐⭐⭐
status: 🌱 学习中
related:
  - ICE候选
  - NAT穿透
  - 信令服务器
---

# STUN/TURN 服务器

> STUN 和 TURN 服务器是 WebRTC 实现 NAT 穿透的关键基础设施

## 📌 核心作用

- **STUN**: 帮助客户端发现自己的公网地址
- **TURN**: 在 P2P 连接失败时提供中继服务

---

## 🌐 STUN 服务器

### 工作原理

```
┌────────────┐      STUN 请求       ┌────────────┐
│   客户端    │ ──────────────────► │ STUN 服务器  │
│  (内网IP)   │                      │  (公网IP)   │
│            │ ◄────────────────── │            │
└────────────┘   响应: 你的公网IP:port └────────────┘
     │
     │ 获得公网地址后
     ▼
┌────────────┐
│  生成 srflx │
│   候选地址   │
└────────────┘
```

### STUN 消息格式

```
┌─────────────────────────────────────────┐
│              STUN Header (20 bytes)      │
├─────────────────────────────────────────┤
│ Message Type (2 bytes)                   │
│   - 0x0001: Binding Request              │
│   - 0x0101: Binding Response             │
│ Message Length (2 bytes)                 │
│ Magic Cookie (4 bytes): 0x2112A442       │
│ Transaction ID (12 bytes)                │
├─────────────────────────────────────────┤
│              STUN Attributes             │
│   - MAPPED-ADDRESS: 映射地址             │
│   - XOR-MAPPED-ADDRESS: 异或映射地址     │
│   - SOFTWARE: 客户端信息                 │
└─────────────────────────────────────────┘
```

### 公共 STUN 服务器

```javascript
const iceServers = [
  // Google STUN 服务器
  { urls: 'stun:stun.l.google.com:19302' },
  { urls: 'stun:stun1.l.google.com:19302' },
  { urls: 'stun:stun2.l.google.com:19302' },
  { urls: 'stun:stun3.l.google.com:19302' },
  { urls: 'stun:stun4.l.google.com:19302' },

  // 其他公共 STUN
  { urls: 'stun:stun.stunprotocol.org:3478' },
  { urls: 'stun:stun.voip.eutelia.it:3478' }
];
```

---

## 🔄 TURN 服务器

### 工作原理

```
┌────────┐                     ┌────────────┐                     ┌────────┐
│ Peer A │ ◄─────── 中继 ─────►│ TURN 服务器 │◄─────── 中继 ──────►│ Peer B │
│(内网A) │                     │  (公网IP)   │                     │(内网B) │
└────────┘                     └────────────┘                     └────────┘
    │                               ▲
    │          TURN Allocate        │
    ├───────────────────────────────┤
    │          TURN CreatePerm      │
    ├───────────────────────────────┤
    │          TURN Send/Ind        │
    └───────────────────────────────┘
```

### TURN 协议流程

```
1. Allocate      - 分配中继地址
2. CreatePermission - 创建到对端的权限
3. ChannelBind   - 绑定通道（可选，提高效率）
4. Send/Data     - 发送和接收数据
```

### 配置 TURN

```javascript
const iceServers = [
  {
    urls: 'turn:your-turn-server.com:3478',
    username: 'username',
    credential: 'password'
  },
  {
    // TURN over TLS (更安全)
    urls: 'turns:your-turn-server.com:5349',
    username: 'username',
    credential: 'password'
  }
];
```

### TURN 认证方式

```javascript
// 方式1: 静态凭证
{
  urls: 'turn:server.com:3478',
  username: 'static-user',
  credential: 'static-password'
}

// 方式2: 临时凭证 (推荐)
// 服务端生成有时效性的凭证
{
  urls: 'turn:server.com:3478',
  username: 'timestamp:userId',
  credential: 'hmac-sha256-signature'
}
```

### TURN vs STUN 对比

| 特性 | STUN | TURN |
|------|------|------|
| **成本** | 低（仅用于查询） | 高（需要转发所有数据） |
| **延迟** | 低（P2P 直连） | 较高（经过服务器中继） |
| **成功率** | ~80%（受 NAT 类型影响） | 100%（兜底方案） |
| **带宽** | 不消耗服务器带宽 | 消耗服务器带宽 |
| **用途** | 获取公网地址 | 中继转发数据 |

---

## 🏗️ NAT 类型与穿透

### NAT 类型

```
┌─────────────────────────────────────────────────────────────┐
│                      NAT 类型                                │
├─────────────────┬───────────────────────────────────────────┤
│ Full Cone       │ 同一内网IP:端口 → 固定公网IP:端口          │
│                 │ 任何外部主机都可以发送数据                 │
├─────────────────┼───────────────────────────────────────────┤
│ Restricted Cone │ 同一内网IP:端口 → 固定公网IP:端口          │
│                 │ 只有内网发过的外部IP才能回复               │
├─────────────────┼───────────────────────────────────────────┤
│ Port Restricted │ 同上，但需要端口也匹配                     │
├─────────────────┼───────────────────────────────────────────┤
│ Symmetric NAT   │ 不同目标 → 不同的公网IP:端口               │
│                 │ 最难穿透，可能需要 TURN                    │
└─────────────────┴───────────────────────────────────────────┘
```

### 穿透成功率

| NAT 组合 | 穿透方式 | 成功率 |
|----------|----------|--------|
| Full Cone + Any | STUN | ✅ 100% |
| Restricted + Restricted | STUN | ✅ 100% |
| Symmetric + Non-Symmetric | STUN | ⚠️ 可能 |
| Symmetric + Symmetric | TURN | ✅ 需要 TURN |

---

## 🛠️ 自建 TURN 服务器

### coturn 安装

```bash
# Ubuntu/Debian
apt update
apt install coturn

# CentOS/RHEL
yum install coturn

# macOS
brew install coturn
```

### coturn 配置

```bash
# /etc/turnserver.conf

# 监听端口
listening-port=3478
tls-listening-port=5349

# 监听 IP（内网）
listening-ip=0.0.0.0

# 外网 IP
external-ip=YOUR_PUBLIC_IP

# Realm（域）
realm=your-domain.com

# 用户认证
user=username:password

# 或使用数据库认证
# userdb=/var/lib/turn/turndb

# TLS/DTLS 证书
cert=/path/to/cert.pem
pkey=/path/to/key.pem

# 日志
log-file=/var/log/turnserver.log
verbose

# 安全设置
no-multicast-peers
no-cli

# 启用指纹
fingerprint

# 启用长期凭证机制
lt-cred-mech
```

### 启动 coturn

```bash
# 直接启动
turnserver -c /etc/turnserver.conf

# 或使用 systemd
systemctl enable coturn
systemctl start coturn
systemctl status coturn
```

### 测试 TURN 服务器

```javascript
// 测试脚本
async function testTurnServer() {
  const pc = new RTCPeerConnection({
    iceServers: [{
      urls: 'turn:your-server.com:3478',
      username: 'test',
      credential: 'test'
    }],
    iceTransportPolicy: 'relay'  // 强制只使用 relay
  });

  pc.createDataChannel('test');
  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);

  return new Promise((resolve) => {
    pc.onicecandidate = (e) => {
      if (e.candidate === null) {
        // 收集完成
        resolve(true);
      } else if (e.candidate) {
        console.log('Candidate:', e.candidate.type);
        if (e.candidate.type === 'relay') {
          console.log('✅ TURN 服务器工作正常');
        }
      }
    };

    // 超时处理
    setTimeout(() => resolve(false), 10000);
  });
}

testTurnServer().then(success => {
  if (!success) {
    console.log('❌ TURN 服务器测试失败');
  }
});
```

---

## 📊 ICE 候选优先级

```
优先级排序（从高到低）:
1. host     - 本地地址（局域网直连最优）
2. prflx    - 对等反射地址
3. srflx    - 服务器反射地址
4. relay    - 中继地址（最后手段）
```

### 优先级计算

```javascript
// ICE 优先级公式
priority = (2^24) * typePreference +
           (2^8) * localPreference +
           (2^0) * componentId

// typePreference:
// host = 126, srflx = 100, prflx = 110, relay = 0
```

---

## 🔧 实战配置

### 生产环境推荐配置

```javascript
const config = {
  iceServers: [
    // 多个 STUN 服务器（负载均衡）
    { urls: 'stun:stun1.example.com:3478' },
    { urls: 'stun:stun2.example.com:3478' },

    // TURN 服务器（备用）
    {
      urls: [
        'turn:turn1.example.com:3478?transport=udp',
        'turn:turn1.example.com:3478?transport=tcp',
        'turns:turn1.example.com:5349?transport=tcp'
      ],
      username: dynamicUsername,
      credential: dynamicCredential
    }
  ],

  // 其他配置
  iceCandidatePoolSize: 10,
  bundlePolicy: 'max-bundle',
  rtcpMuxPolicy: 'require'
};
```

### 动态凭证生成（服务端）

```javascript
// Node.js 示例
const crypto = require('crypto');

function generateTurnCredentials(username, secret, ttl = 86400) {
  const timestamp = Math.floor(Date.now() / 1000) + ttl;
  const turnUsername = `${timestamp}:${username}`;

  const hmac = crypto.createHmac('sha1', secret);
  hmac.update(turnUsername);
  const credential = hmac.digest('base64');

  return {
    username: turnUsername,
    credential: credential,
    ttl: ttl
  };
}

// 使用
const credentials = generateTurnCredentials('user123', 'your-secret-key');
// 返回: { username: '1234567890:user123', credential: 'xxxx', ttl: 86400 }
```

---

## 🔗 相关笔记

- [[ICE候选]] - ICE 候选详解
- [[NAT穿透]] - NAT 穿透原理
- [[信令服务器]] - 信令流程
- [[RTCPeerConnection]] - 连接配置

---

## 📚 参考资料

- [RFC 5389 - STUN](https://tools.ietf.org/html/rfc5389)
- [RFC 8656 - TURN](https://tools.ietf.org/html/rfc8656)
- [coturn Documentation](https://github.com/coturn/coturn)
- [WebRTC ICE Configuration](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection)

---
#tech/webrtc/infrastructure
