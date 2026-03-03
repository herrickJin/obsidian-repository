---
title: RTCDataChannel API
date: 2026-03-02
tags:
  - WebRTC
  - API
  - 数据通道
difficulty: ⭐⭐⭐
status: 🌱 学习中
related:
  - RTCPeerConnection
  - MediaStream
---

# RTCDataChannel API

> RTCDataChannel 是 WebRTC 中用于点对点传输任意数据的 API，支持低延迟、高吞吐量的数据传输

## 📌 核心特点

- ✅ P2P 直连传输
- ✅ 低延迟（比 WebSocket 更低）
- ✅ 支持可靠/不可靠传输
- ✅ 支持有序/无序传输
- ✅ 可与媒体流共用连接

---

## 🔧 创建 DataChannel

### 发起方创建

```javascript
const pc = new RTCPeerConnection(config);

// 创建数据通道
const channel = pc.createDataChannel('myChannel', {
  ordered: true,         // 是否保证顺序
  maxRetransmits: 3,     // 最大重传次数（与 maxPacketLifeTime 互斥）
  // maxPacketLifeTime: 3000,  // 最大生存时间（毫秒）
  protocol: 'json',      // 子协议标识
  negotiated: false,     // 是否通过协商创建
  id: null               // 通道 ID（negotiated: true 时需要）
});

channel.onopen = () => {
  console.log('数据通道已打开');
};

channel.onmessage = (event) => {
  console.log('收到消息:', event.data);
};
```

### 接收方监听

```javascript
const pc = new RTCPeerConnection(config);

pc.ondatachannel = (event) => {
  const channel = event.channel;
  console.log('收到数据通道:', channel.label);

  channel.onopen = () => {
    console.log('数据通道已打开');
  };

  channel.onmessage = (event) => {
    console.log('收到消息:', event.data);
  };
};
```

---

## ⚙️ 配置选项

### 传输模式

```javascript
// 可靠传输（类似 TCP）
const reliableChannel = pc.createDataChannel('reliable', {
  ordered: true,         // 保证顺序
  maxRetransmits: 3      // 重传确保可靠性
});

// 部分可靠 - 时间限制
const timeLimitedChannel = pc.createDataChannel('timeLimited', {
  ordered: true,
  maxPacketLifeTime: 3000  // 3秒后不再重传
});

// 部分可靠 - 重传限制
const retryLimitedChannel = pc.createDataChannel('retryLimited', {
  ordered: true,
  maxRetransmits: 3        // 最多重传3次
});

// 不可靠传输（类似 UDP）
const unreliableChannel = pc.createDataChannel('unreliable', {
  ordered: false,        // 不保证顺序
  maxRetransmits: 0      // 不重传
});
```

### 配置选项说明

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `ordered` | boolean | true | 是否保证消息顺序 |
| `maxRetransmits` | number | null | 最大重传次数 |
| `maxPacketLifeTime` | number | null | 最大生存时间（ms） |
| `protocol` | string | '' | 子协议标识 |
| `negotiated` | boolean | false | 是否带外协商 |
| `id` | number | null | 通道 ID |
| `priority` | string | 'low' | 优先级: high/medium/low |

---

## 📤 发送数据

### 发送字符串

```javascript
channel.send('Hello World!');
```

### 发送 JSON

```javascript
channel.send(JSON.stringify({
  type: 'message',
  content: 'Hello',
  timestamp: Date.now()
}));

// 接收时解析
channel.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log(data);
};
```

### 发送二进制数据

```javascript
// ArrayBuffer
const buffer = new ArrayBuffer(1024);
channel.send(buffer);

// Blob
const blob = new Blob(['Hello'], { type: 'text/plain' });
channel.send(blob);

// TypedArray
const view = new Uint8Array([1, 2, 3, 4, 5]);
channel.send(view.buffer);
```

### 发送文件

```javascript
async function sendFile(channel, file, chunkSize = 16384) {
  // 发送文件信息
  channel.send(JSON.stringify({
    type: 'file-start',
    name: file.name,
    size: file.size,
    mimeType: file.type
  }));

  // 分块发送
  const reader = new FileReader();
  let offset = 0;

  reader.onload = (e) => {
    channel.send(e.target.result);
    offset += e.target.result.byteLength;

    if (offset < file.size) {
      readNextChunk();
    } else {
      // 发送结束标记
      channel.send(JSON.stringify({ type: 'file-end' }));
    }
  };

  function readNextChunk() {
    const slice = file.slice(offset, offset + chunkSize);
    reader.readAsArrayBuffer(slice);
  }

  readNextChunk();
}
```

---

## 📥 接收数据

### 基本接收

```javascript
channel.onmessage = (event) => {
  // 字符串
  if (typeof event.data === 'string') {
    console.log('收到字符串:', event.data);
  }

  // Blob
  else if (event.data instanceof Blob) {
    console.log('收到 Blob:', event.data);
  }

  // ArrayBuffer
  else if (event.data instanceof ArrayBuffer) {
    console.log('收到 ArrayBuffer:', event.data);
  }
};
```

### 接收文件

```javascript
let receivingFile = null;
let receivedChunks = [];

channel.onmessage = (event) => {
  if (typeof event.data === 'string') {
    const data = JSON.parse(event.data);

    if (data.type === 'file-start') {
      receivingFile = {
        name: data.name,
        size: data.size,
        mimeType: data.mimeType
      };
      receivedChunks = [];
    }

    else if (data.type === 'file-end') {
      // 合并所有块
      const blob = new Blob(receivedChunks, { type: receivingFile.mimeType });

      // 创建下载链接
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = receivingFile.name;
      a.click();

      // 清理
      receivingFile = null;
      receivedChunks = [];
    }
  }

  else if (event.data instanceof ArrayBuffer) {
    receivedChunks.push(event.data);
  }
};
```

---

## 📊 状态和事件

### 状态属性

```javascript
// 通道状态
channel.readyState  // 'connecting' | 'open' | 'closing' | 'closed'

// 传输信息
channel.label       // 通道名称
channel.ordered     // 是否有序
channel.protocol    // 子协议
channel.id          // 通道 ID

// 缓冲区
channel.bufferedAmount  // 待发送的数据量（字节）
```

### 事件

```javascript
// 打开
channel.onopen = () => {
  console.log('通道已打开');
};

// 关闭
channel.onclose = () => {
  console.log('通道已关闭');
};

// 错误
channel.onerror = (error) => {
  console.error('通道错误:', error);
};

// 消息
channel.onmessage = (event) => {
  console.log('收到消息:', event.data);
};

// 缓冲区变化
channel.onbufferedamountlow = () => {
  console.log('缓冲区已清空，可以继续发送');
};
```

### 流量控制

```javascript
// 监控缓冲区
const MAX_BUFFERED_AMOUNT = 1024 * 1024; // 1MB

function sendWithFlowControl(channel, data) {
  // 检查缓冲区
  if (channel.bufferedAmount > MAX_BUFFERED_AMOUNT) {
    console.log('缓冲区已满，等待...');

    // 等待缓冲区清空
    return new Promise((resolve) => {
      channel.onbufferedamountlow = () => {
        channel.send(data);
        resolve();
      };
    });
  }

  channel.send(data);
}
```

---

## 🔄 使用场景

### 1. 实时聊天

```javascript
class ChatChannel {
  constructor(pc) {
    this.channel = pc.createDataChannel('chat');
    this.setupChannel();
  }

  setupChannel() {
    this.channel.onopen = () => {
      console.log('聊天通道已连接');
    };

    this.channel.onmessage = (event) => {
      const message = JSON.parse(event.data);
      this.onMessage?.(message);
    };
  }

  send(text) {
    const message = {
      type: 'chat',
      text,
      timestamp: Date.now()
    };
    this.channel.send(JSON.stringify(message));
  }
}
```

### 2. 游戏同步

```javascript
class GameSync {
  constructor(pc) {
    // 使用不可靠传输降低延迟
    this.channel = pc.createDataChannel('game', {
      ordered: false,
      maxRetransmits: 0
    });

    this.channel.onmessage = (event) => {
      const state = JSON.parse(event.data);
      this.onStateUpdate?.(state);
    };
  }

  sendPosition(x, y, rotation) {
    this.channel.send(JSON.stringify({
      type: 'position',
      x, y, rotation,
      timestamp: performance.now()
    }));
  }
}
```

### 3. 远程桌面控制

```javascript
class RemoteControl {
  constructor(pc) {
    this.channel = pc.createDataChannel('control', {
      ordered: true,
      maxRetransmits: 3
    });

    this.channel.onmessage = (event) => {
      const command = JSON.parse(event.data);
      this.executeCommand(command);
    };
  }

  sendMouseMove(x, y) {
    this.channel.send(JSON.stringify({
      type: 'mousemove',
      x, y
    }));
  }

  sendClick(button, x, y) {
    this.channel.send(JSON.stringify({
      type: 'click',
      button, x, y
    }));
  }

  sendKey(key, pressed) {
    this.channel.send(JSON.stringify({
      type: 'key',
      key, pressed
    }));
  }
}
```

---

## 🔧 完整示例

```javascript
class DataChannelManager {
  constructor(pc) {
    this.pc = pc;
    this.channels = new Map();
  }

  // 创建通道
  createChannel(label, options = {}) {
    const channel = this.pc.createDataChannel(label, {
      ordered: true,
      ...options
    });

    this.setupChannelEvents(channel);
    this.channels.set(label, channel);

    return channel;
  }

  // 监听远程通道
  listenRemoteChannels() {
    this.pc.ondatachannel = (event) => {
      const channel = event.channel;
      this.setupChannelEvents(channel);
      this.channels.set(channel.label, channel);
    };
  }

  // 设置事件
  setupChannelEvents(channel) {
    channel.onopen = () => {
      console.log(`通道 ${channel.label} 已打开`);
    };

    channel.onclose = () => {
      console.log(`通道 ${channel.label} 已关闭`);
      this.channels.delete(channel.label);
    };

    channel.onerror = (error) => {
      console.error(`通道 ${channel.label} 错误:`, error);
    };
  }

  // 发送 JSON
  send(label, data) {
    const channel = this.channels.get(label);
    if (channel && channel.readyState === 'open') {
      channel.send(JSON.stringify(data));
    }
  }

  // 发送二进制
  sendBinary(label, buffer) {
    const channel = this.channels.get(label);
    if (channel && channel.readyState === 'open') {
      channel.send(buffer);
    }
  }

  // 设置消息处理
  onMessage(label, callback) {
    const channel = this.channels.get(label);
    if (channel) {
      channel.onmessage = (event) => {
        callback(event.data);
      };
    }
  }

  // 关闭通道
  close(label) {
    const channel = this.channels.get(label);
    if (channel) {
      channel.close();
    }
  }

  // 关闭所有
  closeAll() {
    this.channels.forEach(channel => channel.close());
    this.channels.clear();
  }
}
```

---

## 🔗 相关笔记

- [[RTCPeerConnection]] - 创建 DataChannel
- [[信令服务器]] - 交换 SDP

---

## 📚 参考资料

- [MDN: RTCDataChannel](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel)
- [WebRTC Data Channels](https://webrtc.org/getting-started/data-channels)
- [RFC 8831 - WebRTC Data Channels](https://tools.ietf.org/html/rfc8831)

---
#tech/webrtc/api
