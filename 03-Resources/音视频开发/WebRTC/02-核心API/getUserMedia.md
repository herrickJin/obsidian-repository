---
title: getUserMedia API
date: 2026-03-02
tags:
  - WebRTC
  - API
  - 媒体采集
difficulty: ⭐⭐
status: 🌱 学习中
related:
  - MediaStream
  - RTCPeerConnection
---

# getUserMedia API

> getUserMedia 是 WebRTC 获取本地音视频流的入口 API

## 📌 核心作用

从用户的摄像头和麦克风获取媒体流（MediaStream），是所有 WebRTC 应用的第一步。

---

## 🔧 基本用法

### 获取音视频

```javascript
// 最简单的用法 - 获取摄像头和麦克风
const stream = await navigator.mediaDevices.getUserMedia({
  video: true,
  audio: true
});

// 绑定到 video 元素显示
const video = document.querySelector('video');
video.srcObject = stream;
await video.play();
```

### 仅获取音频

```javascript
const audioStream = await navigator.mediaDevices.getUserMedia({
  audio: true,
  video: false
});
```

### 仅获取视频

```javascript
const videoStream = await navigator.mediaDevices.getUserMedia({
  video: true,
  audio: false
});
```

---

## ⚙️ 约束条件 (Constraints)

### 视频约束

```javascript
const constraints = {
  video: {
    // 分辨率
    width: { ideal: 1920, max: 1920 },
    height: { ideal: 1080, max: 1080 },

    // 帧率
    frameRate: { ideal: 30, max: 60 },

    // 前置/后置摄像头 (移动端)
    facingMode: 'user',  // 'user' 前置, 'environment' 后置

    // 设备 ID（指定摄像头）
    deviceId: { exact: 'camera-device-id' }
  },
  audio: true
};

const stream = await navigator.mediaDevices.getUserMedia(constraints);
```

### 音频约束

```javascript
const constraints = {
  video: true,
  audio: {
    // 回声消除
    echoCancellation: true,

    // 噪声抑制
    noiseSuppression: true,

    // 自动增益控制
    autoGainControl: true,

    // 采样率
    sampleRate: 48000,

    // 声道数
    channelCount: 2,

    // 设备 ID（指定麦克风）
    deviceId: { exact: 'mic-device-id' }
  }
};

const stream = await navigator.mediaDevices.getUserMedia(constraints);
```

### 约束类型说明

| 约束类型 | 说明 | 示例 |
|----------|------|------|
| `exact` | 精确值，必须满足 | `{ width: { exact: 1920 } }` |
| `ideal` | 理想值，优先满足 | `{ width: { ideal: 1920 } }` |
| `min` | 最小值 | `{ frameRate: { min: 24 } }` |
| `max` | 最大值 | `{ frameRate: { max: 60 } }` |

---

## 📱 移动端特殊处理

### 切换前后摄像头

```javascript
let currentFacingMode = 'user'; // 'user' 前置, 'environment' 后置

async function switchCamera() {
  // 停止当前流
  const tracks = stream.getTracks();
  tracks.forEach(track => track.stop());

  // 切换摄像头
  currentFacingMode = currentFacingMode === 'user' ? 'environment' : 'user';

  // 重新获取流
  const newStream = await navigator.mediaDevices.getUserMedia({
    video: { facingMode: currentFacingMode },
    audio: true
  });

  video.srcObject = newStream;
}
```

### 移动端常见约束

```javascript
// 移动端推荐配置
const mobileConstraints = {
  video: {
    facingMode: 'user',
    width: { ideal: 640 },
    height: { ideal: 480 },
    frameRate: { ideal: 24, max: 30 }
  },
  audio: {
    echoCancellation: true,
    noiseSuppression: true
  }
};
```

---

## 🎤 枚举设备

### 获取所有媒体设备

```javascript
const devices = await navigator.mediaDevices.enumerateDevices();

devices.forEach(device => {
  console.log(`${device.kind}: ${device.label} (${device.deviceId})`);
});

// 输出示例:
// audioinput: MacBook Pro 麦克风 (default)
// videoinput: FaceTime HD Camera
// audiooutput: MacBook Pro 扬声器
```

### 设备类型

```typescript
interface MediaDeviceInfo {
  deviceId: string;    // 设备唯一标识
  kind: 'audioinput' | 'videoinput' | 'audiooutput';
  label: string;       // 设备名称（需要授权后才可获取）
  groupId: string;     // 设备组标识
}
```

### 选择特定设备

```javascript
async function getSpecificCamera(deviceId) {
  const stream = await navigator.mediaDevices.getUserMedia({
    video: { deviceId: { exact: deviceId } },
    audio: true
  });
  return stream;
}
```

---

## 🔄 流的管理

### 获取轨道 (Tracks)

```javascript
const stream = await navigator.mediaDevices.getUserMedia({
  video: true,
  audio: true
});

// 获取所有视频轨道
const videoTracks = stream.getVideoTracks();
console.log('Video track:', videoTracks[0].label);

// 获取所有音频轨道
const audioTracks = stream.getAudioTracks();
console.log('Audio track:', audioTracks[0].label);

// 获取所有轨道
const allTracks = stream.getTracks();
```

### 停止流

```javascript
// 停止所有轨道（释放摄像头/麦克风）
function stopStream(stream) {
  stream.getTracks().forEach(track => track.stop());
}

// 或者单独停止
stream.getVideoTracks()[0].stop();  // 关闭摄像头
stream.getAudioTracks()[0].stop();  // 关闭麦克风
```

### 静音/取消静音

```javascript
// 视频静音（黑屏）
function toggleVideo(stream, enabled) {
  stream.getVideoTracks().forEach(track => {
    track.enabled = enabled;
  });
}

// 音频静音
function toggleAudio(stream, enabled) {
  stream.getAudioTracks().forEach(track => {
    track.enabled = enabled;
  });
}

// 使用
toggleVideo(stream, false);  // 关闭视频
toggleAudio(stream, false);  // 静音
```

---

## 🖥️ 屏幕共享

### 获取屏幕流

```javascript
// 基本屏幕共享
const screenStream = await navigator.mediaDevices.getDisplayMedia({
  video: true,
  audio: true  // 可选：共享系统音频
});

// 带约束的屏幕共享
const screenStream = await navigator.mediaDevices.getDisplayMedia({
  video: {
    displaySurface: 'monitor', // 'monitor', 'window', 'application', 'browser'
    width: { ideal: 1920 },
    height: { ideal: 1080 },
    frameRate: { ideal: 30 }
  },
  audio: {
    echoCancellation: true,
    noiseSuppression: true
  }
});
```

### 检测共享结束

```javascript
const screenStream = await navigator.mediaDevices.getDisplayMedia({
  video: true
});

// 用户点击"停止共享"时触发
screenStream.getVideoTracks()[0].onended = () => {
  console.log('屏幕共享已停止');
  // 清理工作
};
```

---

## ⚠️ 错误处理

### 常见错误

```javascript
try {
  const stream = await navigator.mediaDevices.getUserMedia({
    video: true,
    audio: true
  });
} catch (error) {
  switch (error.name) {
    case 'NotFoundError':
      console.error('未找到摄像头或麦克风');
      break;

    case 'NotAllowedError':
    case 'PermissionDeniedError':
      console.error('用户拒绝了访问请求');
      break;

    case 'NotReadableError':
    case 'TrackStartError':
      console.error('设备被其他应用占用');
      break;

    case 'OverconstrainedError':
      console.error('约束条件无法满足', error.constraint);
      break;

    case 'TypeError':
      console.error('约束条件格式错误');
      break;

    case 'SecurityError':
      console.error('安全限制（可能不是 HTTPS）');
      break;

    default:
      console.error('获取媒体流失败:', error);
  }
}
```

### 权限检测

```javascript
async function checkPermission() {
  try {
    // 查询权限状态
    const cameraStatus = await navigator.permissions.query({
      name: 'camera'
    });
    const micStatus = await navigator.permissions.query({
      name: 'microphone'
    });

    console.log('摄像头权限:', cameraStatus.state); // 'granted', 'denied', 'prompt'
    console.log('麦克风权限:', micStatus.state);

    return {
      camera: cameraStatus.state,
      microphone: micStatus.state
    };
  } catch (e) {
    console.log('权限 API 不支持');
    return null;
  }
}
```

---

## 🔧 实用工具函数

### 完整的媒体获取封装

```javascript
class MediaManager {
  constructor() {
    this.stream = null;
  }

  // 获取媒体流
  async getMedia(constraints = { video: true, audio: true }) {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia(constraints);
      return this.stream;
    } catch (error) {
      console.error('获取媒体流失败:', error);
      throw error;
    }
  }

  // 获取屏幕流
  async getScreen(constraints = { video: true }) {
    try {
      return await navigator.mediaDevices.getDisplayMedia(constraints);
    } catch (error) {
      console.error('获取屏幕流失败:', error);
      throw error;
    }
  }

  // 切换视频
  toggleVideo() {
    if (this.stream) {
      this.stream.getVideoTracks().forEach(track => {
        track.enabled = !track.enabled;
      });
    }
  }

  // 切换音频
  toggleAudio() {
    if (this.stream) {
      this.stream.getAudioTracks().forEach(track => {
        track.enabled = !track.enabled;
      });
    }
  }

  // 释放资源
  release() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop());
      this.stream = null;
    }
  }

  // 获取设备列表
  async getDevices() {
    return await navigator.mediaDevices.enumerateDevices();
  }
}

// 使用示例
const mediaManager = new MediaManager();
const stream = await mediaManager.getMedia();
```

---

## 🔗 相关笔记

- [[MediaStream]] - 媒体流详解
- [[RTCPeerConnection]] - 添加轨道到连接
- [[03-基础概念/WebRTC概述]] - API 概览

---

## 📚 参考资料

- [MDN: getUserMedia](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia)
- [MDN: MediaStreamConstraints](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamConstraints)
- [WebRTC Samples: getUserMedia](https://webrtc.github.io/samples/src/content/getusermedia/)

---
#tech/webrtc/api
