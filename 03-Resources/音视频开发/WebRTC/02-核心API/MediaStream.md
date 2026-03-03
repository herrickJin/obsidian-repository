---
title: MediaStream API
date: 2026-03-02
tags:
  - WebRTC
  - API
  - 媒体流
difficulty: ⭐⭐
status: 🌱 学习中
related:
  - getUserMedia
  - RTCPeerConnection
  - Canvas
---

# MediaStream API

> MediaStream 表示一个媒体数据流，包含零个或多个 MediaStreamTrack

## 📌 核心概念

```
MediaStream (媒体流)
    │
    ├── MediaStreamTrack (视频轨道)
    │       │
    │       └── MediaStreamTrack (音频轨道)
    │
    └── 事件: addtrack, removetrack
```

---

## 🎥 MediaStream

### 创建 MediaStream

```javascript
// 方式1: getUserMedia
const stream = await navigator.mediaDevices.getUserMedia({
  video: true,
  audio: true
});

// 方式2: getDisplayMedia (屏幕共享)
const screenStream = await navigator.mediaDevices.getDisplayMedia({
  video: true
});

// 方式3: 从 video/canvas 捕获
const video = document.querySelector('video');
const stream = video.captureStream();

const canvas = document.querySelector('canvas');
const canvasStream = canvas.captureStream(30); // 30fps

// 方式4: 构造函数（组合轨道）
const newStream = new MediaStream([videoTrack, audioTrack]);
```

### 属性和方法

```javascript
const stream = await navigator.mediaDevices.getUserMedia({
  video: true,
  audio: true
});

// 属性
stream.id        // 流的唯一标识
stream.active    // 是否活跃

// 获取轨道
stream.getTracks()           // 所有轨道
stream.getVideoTracks()      // 视频轨道
stream.getAudioTracks()      // 音频轨道
stream.getTrackById(id)      // 通过 ID 获取

// 添加/移除轨道
stream.addTrack(track)
stream.removeTrack(track)

// 克隆
const clonedStream = stream.clone()

// 事件
stream.onaddtrack = (event) => {}
stream.onremovetrack = (event) => {}
```

---

## 🎞️ MediaStreamTrack

### 获取轨道信息

```javascript
const videoTrack = stream.getVideoTracks()[0];
const audioTrack = stream.getAudioTracks()[0];

// 属性
videoTrack.id              // 唯一标识
videoTrack.kind            // 'video' | 'audio'
videoTrack.label           // 设备名称
videoTrack.enabled         // 是否启用
videoTrack.muted           // 是否静音
videoTrack.readyState      // 'live' | 'ended'
videoTrack.muted           // 是否被系统静音

// 方法
videoTrack.getCapabilities()   // 获取设备能力
videoTrack.getSettings()       // 获取当前设置
videoTrack.getConstraints()    // 获取约束条件
```

### 轨道控制

```javascript
// 停止轨道（释放设备）
videoTrack.stop();

// 静音/取消静音（不释放设备）
videoTrack.enabled = false;  // 黑屏/静音
videoTrack.enabled = true;   // 恢复

// 应用新约束
await videoTrack.applyConstraints({
  width: 1280,
  height: 720,
  frameRate: 30
});

// 事件
videoTrack.onended = () => {
  console.log('轨道已停止');
};

videoTrack.onmute = () => {
  console.log('系统静音');
};

videoTrack.onunmute = () => {
  console.log('取消系统静音');
};
```

---

## 📊 获取设备能力

### 视频能力

```javascript
const videoTrack = stream.getVideoTracks()[0];
const capabilities = videoTrack.getCapabilities();

console.log(capabilities);
// 输出示例:
{
  width: { min: 320, max: 1920, step: 1 },
  height: { min: 240, max: 1080, step: 1 },
  frameRate: { min: 1, max: 60, step: 1 },
  facingMode: ['user', 'environment'],
  resizeMode: ['none', 'crop-and-scale'],
  deviceId: 'default',
  groupId: 'group-id'
}
```

### 音频能力

```javascript
const audioTrack = stream.getAudioTracks()[0];
const capabilities = audioTrack.getCapabilities();

console.log(capabilities);
// 输出示例:
{
  autoGainControl: [true, false],
  channelCount: { min: 1, max: 2 },
  echoCancellation: [true, false],
  latency: { min: 0, max: 0.5 },
  noiseSuppression: [true, false],
  sampleRate: { min: 44100, max: 48000 },
  sampleSize: { min: 16, max: 24 },
  deviceId: 'default',
  groupId: 'group-id'
}
```

---

## 🔄 动态切换设备

### 切换摄像头

```javascript
async function switchCamera() {
  // 获取所有视频设备
  const devices = await navigator.mediaDevices.enumerateDevices();
  const videoDevices = devices.filter(d => d.kind === 'videoinput');

  // 找到另一个摄像头
  const currentTrack = stream.getVideoTracks()[0];
  const nextDevice = videoDevices.find(d => d.deviceId !== currentTrack.getSettings().deviceId);

  if (nextDevice) {
    // 停止当前轨道
    currentTrack.stop();

    // 获取新流
    const newStream = await navigator.mediaDevices.getUserMedia({
      video: { deviceId: { exact: nextDevice.deviceId } },
      audio: false
    });

    // 替换轨道
    const newTrack = newStream.getVideoTracks()[0];

    // 如果已建立连接，替换 PeerConnection 中的轨道
    const sender = pc.getSenders().find(s => s.track?.kind === 'video');
    if (sender) {
      await sender.replaceTrack(newTrack);
    }

    // 更新本地流
    stream.removeTrack(currentTrack);
    stream.addTrack(newTrack);
  }
}
```

### 切换麦克风

```javascript
async function switchMicrophone(deviceId) {
  const currentTrack = stream.getAudioTracks()[0];
  currentTrack.stop();

  const newStream = await navigator.mediaDevices.getUserMedia({
    video: false,
    audio: { deviceId: { exact: deviceId } }
  });

  const newTrack = newStream.getAudioTracks()[0];

  // 替换 PeerConnection 中的轨道
  const sender = pc.getSenders().find(s => s.track?.kind === 'audio');
  if (sender) {
    await sender.replaceTrack(newTrack);
  }

  stream.removeTrack(currentTrack);
  stream.addTrack(newTrack);
}
```

---

## 🖥️ 屏幕共享

### 基本屏幕共享

```javascript
async function startScreenShare() {
  const screenStream = await navigator.mediaDevices.getDisplayMedia({
    video: {
      displaySurface: 'monitor',  // 'monitor' | 'window' | 'application' | 'browser'
      width: { ideal: 1920 },
      height: { ideal: 1080 },
      frameRate: { ideal: 30 }
    },
    audio: true  // 可选：共享系统音频
  });

  // 检测共享停止
  screenStream.getVideoTracks()[0].onended = () => {
    console.log('屏幕共享已停止');
  };

  return screenStream;
}
```

### 混合摄像头和屏幕

```javascript
async function startMixedStream() {
  // 获取摄像头
  const cameraStream = await navigator.mediaDevices.getUserMedia({
    video: true,
    audio: true
  });

  // 获取屏幕
  const screenStream = await navigator.mediaDevices.getDisplayMedia({
    video: true
  });

  // 使用 Canvas 合成
  const canvas = document.createElement('canvas');
  canvas.width = 1920;
  canvas.height = 1080;
  const ctx = canvas.getContext('2d');

  const cameraVideo = document.createElement('video');
  cameraVideo.srcObject = cameraStream;
  await cameraVideo.play();

  const screenVideo = document.createElement('video');
  screenVideo.srcObject = screenStream;
  await screenVideo.play();

  // 渲染循环
  function render() {
    // 屏幕（全屏）
    ctx.drawImage(screenVideo, 0, 0, 1920, 1080);

    // 摄像头（右下角小窗）
    ctx.drawImage(cameraVideo, 1920 - 320 - 20, 1080 - 180 - 20, 320, 180);

    requestAnimationFrame(render);
  }
  render();

  // 输出混合流
  const mixedStream = canvas.captureStream(30);
  mixedStream.addTrack(cameraStream.getAudioTracks()[0]);

  return mixedStream;
}
```

---

## 🎬 视频渲染

### 绑定到 video 元素

```javascript
const video = document.querySelector('video');

// 方式1: srcObject
video.srcObject = stream;
await video.play();

// 方式2: 自动播放
<video autoplay playsinline muted></video>
```

### 使用 Canvas 渲染

```javascript
const canvas = document.querySelector('canvas');
const ctx = canvas.getContext('2d');
const video = document.createElement('video');
video.srcObject = stream;
await video.play();

function render() {
  ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
  requestAnimationFrame(render);
}
render();
```

### 镜像显示

```javascript
// CSS 方式
video.style.transform = 'scaleX(-1)';

// Canvas 方式
ctx.save();
ctx.scale(-1, 1);
ctx.drawImage(video, -canvas.width, 0, canvas.width, canvas.height);
ctx.restore();
```

---

## 📸 截图

### 从视频流截图

```javascript
function takeScreenshot(stream) {
  const video = document.createElement('video');
  video.srcObject = stream;

  return new Promise((resolve) => {
    video.onloadedmetadata = () => {
      video.play();

      const canvas = document.createElement('canvas');
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;

      const ctx = canvas.getContext('2d');
      ctx.drawImage(video, 0, 0);

      const dataUrl = canvas.toDataURL('image/png');
      resolve(dataUrl);
    };
  });
}

// 使用
const screenshot = await takeScreenshot(stream);
```

---

## 🎛️ 工具类封装

```javascript
class StreamManager {
  constructor() {
    this.localStream = null;
    this.screenStream = null;
  }

  // 获取本地流
  async getLocalStream(constraints = { video: true, audio: true }) {
    this.localStream = await navigator.mediaDevices.getUserMedia(constraints);
    return this.localStream;
  }

  // 获取屏幕流
  async getScreenStream() {
    this.screenStream = await navigator.mediaDevices.getDisplayMedia({
      video: true,
      audio: true
    });

    this.screenStream.getVideoTracks()[0].onended = () => {
      this.screenStream = null;
    };

    return this.screenStream;
  }

  // 切换视频
  toggleVideo() {
    if (this.localStream) {
      this.localStream.getVideoTracks().forEach(track => {
        track.enabled = !track.enabled;
      });
    }
  }

  // 切换音频
  toggleAudio() {
    if (this.localStream) {
      this.localStream.getAudioTracks().forEach(track => {
        track.enabled = !track.enabled;
      });
    }
  }

  // 获取设备列表
  async getDevices() {
    return await navigator.mediaDevices.enumerateDevices();
  }

  // 切换摄像头
  async switchCamera(deviceId) {
    const currentTrack = this.localStream.getVideoTracks()[0];
    currentTrack.stop();

    const newStream = await navigator.mediaDevices.getUserMedia({
      video: { deviceId: { exact: deviceId } },
      audio: false
    });

    const newTrack = newStream.getVideoTracks()[0];
    this.localStream.removeTrack(currentTrack);
    this.localStream.addTrack(newTrack);

    return newTrack;
  }

  // 释放资源
  release() {
    if (this.localStream) {
      this.localStream.getTracks().forEach(track => track.stop());
      this.localStream = null;
    }

    if (this.screenStream) {
      this.screenStream.getTracks().forEach(track => track.stop());
      this.screenStream = null;
    }
  }
}
```

---

## 🔗 相关笔记

- [[getUserMedia]] - 获取媒体流
- [[RTCPeerConnection]] - 添加轨道到连接
- [[Canvas]] - Canvas 视频处理

---

## 📚 参考资料

- [MDN: MediaStream](https://developer.mozilla.org/en-US/docs/Web/API/MediaStream)
- [MDN: MediaStreamTrack](https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamTrack)
- [MDN: MediaDevices](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices)

---
#tech/webrtc/api
