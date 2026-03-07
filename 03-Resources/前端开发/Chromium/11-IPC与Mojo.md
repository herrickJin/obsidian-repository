---
title: 进程间通信 IPC/Mojo
date: 2026-03-06
tags:
  - chromium
  - ipc
  - mojo
difficulty: ⭐⭐⭐⭐
status: 📋 待学习
---

# 进程间通信 IPC/Mojo

## 🎯 学习目标

- 理解 Chromium 进程间通信的演进
- 掌握 Mojo 框架的核心概念
- 了解消息管道和数据序列化
- 理解安全边界的实现

---

## 📜 IPC 演进历史

### 从 Legacy IPC 到 Mojo

```
┌─────────────────────────────────────────────────────────────┐
│                   Chromium IPC 演进                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Legacy IPC (2008-2014):                                    │
│  ├── 基于自定义消息格式                                      │
│  ├── 手动序列化/反序列化                                    │
│  ├── 紧耦合                                                 │
│  └── 难以扩展                                                │
│                                                             │
│  Mojo (2014-至今):                                          │
│  ├── IDL 定义接口                                           │
│  ├── 自动生成代码                                           │
│  ├── 松耦合                                                 │
│  ├── 支持同步/异步                                          │
│  └── 跨语言支持 (C++, Java, JavaScript)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 架构对比

```
Legacy IPC:

┌─────────────┐                    ┌─────────────┐
│  Process A  │                    │  Process B  │
│             │                    │             │
│  Send(Msg)  │ ─────────────────> │  OnMsg()   │
│             │                    │  (手动解析) │
└─────────────┘                    └─────────────┘

Mojo:

┌─────────────┐                    ┌─────────────┐
│  Process A  │                    │  Process B  │
│             │                    │             │
│  proxy->X() │ ─────────────────> │  impl->X() │
│  (自动生成)  │                    │  (自动生成) │
└─────────────┘                    └─────────────┘
        │                                  │
        └──────── Message Pipe ────────────┘
```

---

## 🔧 Mojo 框架

### 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                    Mojo 核心概念                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Mojo Interface:                                            │
│  ├── .mojom 文件定义                                        │
│  ├── 定义方法和消息                                          │
│  └── 跨进程服务接口                                          │
│                                                             │
│  Message Pipe:                                               │
│  ├── 双向通信通道                                            │
│  ├── 两个端点 (Endpoints)                                   │
│  └── 可传输消息和数据                                        │
│                                                             │
│  Remote:                                                     │
│  ├── 客户端代理                                              │
│  ├── 调用远程方法                                            │
│  └── 发送消息到管道                                          │
│                                                             │
│  Receiver / PendingReceiver:                                 │
│  ├── 服务端实现                                              │
│  ├── 接收消息                                                │
│  └── 调用实际实现                                            │
│                                                             │
│  Shared Buffer:                                              │
│  ├── 共享内存                                                │
│  └── 高效传输大数据                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Mojo IDL

```mojom
// example.mojom

module example.mojom;

// 接口定义
interface DatabaseService {
  // 异步方法
  Query(string sql) => (array<Row> results, bool success);

  // 带错误处理的异步方法
  [Sync]
  GetVersion() => (string version);

  // 事件 (服务端向客户端发送)
  OnDataChanged(string table_name);
};

// 数据结构
struct Row {
  array<string> columns;
  array<string> values;
};

// 枚举
enum ErrorCode {
  kNone = 0,
  kNotFound = 1,
  kInvalidQuery = 2,
};
```

### 生成的代码

```cpp
// 从 .mojom 自动生成的 C++ 代码

// DatabaseService 代理 (客户端使用)
class DatabaseServiceProxy {
 public:
  // 异步调用
  void Query(const std::string& sql,
             QueryCallback callback);

  // 同步调用
  bool GetVersion(std::string* version);
};

// DatabaseService 接口 (服务端实现)
class DatabaseService {
 public:
  virtual void Query(const std::string& sql,
                     QueryCallback callback) = 0;
  virtual void GetVersion(GetVersionCallback callback) = 0;
};

// 使用示例
// 客户端
mojo::Remote<example::mojom::DatabaseService> service;
service->Query("SELECT * FROM users",
    [](const std::vector<example::mojom::RowPtr>& results, bool success) {
      // 处理结果
    });

// 服务端
class DatabaseServiceImpl : public example::mojom::DatabaseService {
  void Query(const std::string& sql, QueryCallback callback) override {
    // 执行查询
    std::vector<example::mojom::RowPtr> results = ExecuteQuery(sql);
    std::move(callback).Run(std::move(results), true);
  }
};
```

---

## 🔄 消息管道

### 管道通信模型

```
┌─────────────────────────────────────────────────────────────┐
│                    Message Pipe                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Process A                          Process B               │
│  ┌─────────────────┐               ┌─────────────────┐     │
│  │                 │               │                 │     │
│  │   Remote<IFace> │               │  Receiver<IFace>│     │
│  │       │         │               │       │         │     │
│  │       ▼         │               │       ▼         │     │
│  │  ┌─────────┐    │               │    ┌─────────┐  │     │
│  │  │Endpoint │    │               │    │Endpoint │  │     │
│  │  │   (0)   │────┼───────────────┼────│   (1)   │  │     │
│  │  └─────────┘    │  Message Pipe │    └─────────┘  │     │
│  │                 │               │                 │     │
│  └─────────────────┘               └─────────────────┘     │
│                                                             │
│  消息类型:                                                   │
│  ├── 普通消息 (Message)                                     │
│  ├── 消息管道 (可嵌套)                                      │
│  ├── 共享缓冲区                                             │
│  └── 文件描述符                                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 管道创建和传输

```cpp
// 创建消息管道
mojo::MessagePipe pipe;

// 创建 Remote 和 PendingReceiver
mojo::Remote<example::mojom::DatabaseService> remote(
    mojo::PendingRemote<example::mojom::DatabaseService>(
        std::move(pipe.handle0), 0));

mojo::PendingReceiver<example::mojom::DatabaseService> receiver(
    mojo::PendingReceiver<example::mojom::DatabaseService>(
        std::move(pipe.handle1)));

// 将 receiver 发送到另一个进程
// 另一个进程绑定到实现
service_manager_->Bind(std::move(receiver));
```

### 管道传输

```cpp
// 通过消息管道传输另一个管道

interface Parent {
  // 参数中包含 PendingReceiver
  CreateChild(pending_receiver<Child> receiver);
};

// 调用时
mojo::PendingRemote<Child> child_remote;
parent->CreateChild(child_remote.InitWithNewPipeAndPassReceiver());
// 现在 child_remote 可以调用 Child 接口
```

---

## 📦 数据序列化

### Mojo 序列化

```
┌─────────────────────────────────────────────────────────────┐
│                   Mojo 序列化                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  支持的类型:                                                 │
│  ├── 基本类型: bool, int8-64, uint8-64, float, double       │
│  ├── 字符串: string                                         │
│  ├── 数组: array<T>                                         │
│  ├── 映射: map<K, V>                                        │
│  ├── 可选: T?                                               │
│  ├── 枚举: enum                                             │
│  ├── 结构体: struct                                         │
│  ├── 接口: interface, pending_remote, pending_receiver      │
│  └── 句柄: handle, shared_buffer                            │
│                                                             │
│  序列化过程:                                                 │
│  1. 参数打包                                                 │
│  2. 类型验证                                                 │
│  3. 写入消息缓冲区                                           │
│  4. 附加句柄 (如果有)                                        │
│  5. 发送                                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 序列化示例

```cpp
// 复杂类型序列化

// struct 定义
struct User {
  string name;
  int32 age;
  array<string> tags;
  map<string, string> metadata;
};

// 序列化
example::mojom::UserPtr user = example::mojom::User::New();
user->name = "Alice";
user->age = 30;
user->tags = {"developer", "designer"};
user->metadata = {{"location", "US"}, {"team", "chrome"}};

// 发送
service->AddUser(std::move(user));

// 接收
void AddUser(example::mojom::UserPtr user) {
  // user->name, user->age 等自动反序列化
}
```

---

## 🔒 安全边界

### 进程隔离与安全

```
┌─────────────────────────────────────────────────────────────┐
│                    安全边界                                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Browser Process                        │   │
│  │           (高权限, 受信任)                           │   │
│  │                                                     │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │            Mojo Policy                       │   │   │
│  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐       │   │   │
│  │  │  │Allow A  │ │Allow B  │ │Deny C   │       │   │   │
│  │  │  └─────────┘ └─────────┘ └─────────┘       │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                    (Mojo 消息)                              │
│                          │                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Renderer Process                       │   │
│  │           (低权限, 沙箱隔离)                         │   │
│  │                                                     │   │
│  │  ┌─────────────────────────────────────────────┐   │   │
│  │  │           只能访问被允许的接口                 │   │   │
│  │  └─────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Mojo Policy

```cpp
// Mojo 接口权限控制

// 在服务清单中定义
// chrome/browser/resources/browser_resources.grd

{
  "name": "browser",
  "interfaces": {
    // 完全开放
    "example.mojom.PublicService": "all",

    // 只允许特定进程
    "example.mojom.PrivilegedService": [
      "browser",
      "utility_process"
    ],

    // 需要特定权限
    "example.mojom.SensitiveService": {
      "permissions": ["file_system", "network"]
    }
  }
}

// 运行时检查
void SensitiveOperation() {
  // 检查调用者权限
  if (!CheckPermission(caller, "file_system")) {
    mojo::ReportBadMessage("Permission denied");
    return;
  }
  // 执行操作
}
```

### 消息验证

```cpp
// 消息验证机制

// 1. 结构验证 (自动)
// - 检查字段类型
// - 检查必需字段

// 2. 语义验证 (手动)
void ProcessUrl(const GURL& url) {
  // 验证 URL 来源
  if (!url.is_valid()) {
    mojo::ReportBadMessage("Invalid URL");
    return;
  }

  // 验证权限
  if (!url.SchemeIsHTTPOrHTTPS()) {
    mojo::ReportBadMessage("URL scheme not allowed");
    return;
  }

  // 处理 URL
}

// 3. BadMessage 处理
// 当检测到恶意消息时:
// - 记录错误
// - 终止连接
// - 可能终止进程 (渲染进程)
```

---

## 🌐 跨语言支持

### JavaScript 绑定

```javascript
// Mojo JavaScript 绑定

// 定义接口 (通过 .mojom 自动生成)
// example.mojom-web.js

// 创建 Remote
const service = new example.mojom.DatabaseServiceRemote();

// 调用方法
service.query("SELECT * FROM users").then((result) => {
  console.log(result.results);
});

// 同步调用 (不推荐在渲染进程使用)
const version = service.getVersion();

// 实现接口
class DatabaseServiceImpl {
  query(sql) {
    return {results: executeQuery(sql), success: true};
  }
}

// 绑定实现
const receiver = new example.mojom.DatabaseServiceReceiver(
    new DatabaseServiceImpl());
```

### Java 绑定

```java
// Mojo Java 绑定

// 创建 Remote
DatabaseService service = DatabaseService.Remote.makeRemote();

// 调用方法
service.query("SELECT * FROM users", (results, success) -> {
    // 处理结果
});

// 实现接口
public class DatabaseServiceImpl implements DatabaseService {
    @Override
    public void query(String sql, QueryResponse callback) {
        List<Row> results = executeQuery(sql);
        callback.call(results, true);
    }
}
```

---

## 🔄 服务框架

### Service Manager

```
┌─────────────────────────────────────────────────────────────┐
│                    Service Manager                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               Service Manager                       │   │
│  │                                                     │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐              │   │
│  │  │  Service│ │  Service│ │  Service│              │   │
│  │  │   A     │ │   B     │ │   C     │              │   │
│  │  │         │ │         │ │         │              │   │
│  │  │ Manifest│ │ Manifest│ │ Manifest│              │   │
│  │  └─────────┘ └─────────┘ └─────────┘              │   │
│  │                                                     │   │
│  │  职责:                                              │   │
│  │  ├── 服务发现                                      │   │
│  │  ├── 服务启动                                      │   │
│  │  ├── 权限管理                                      │   │
│  │  └── 连接建立                                      │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  服务类型:                                                   │
│  ├── Browser Service (主进程)                               │
│  ├── Renderer Service (渲染进程)                            │
│  ├── Utility Service (工具进程)                             │
│  └── Network Service (网络进程)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 实践练习

- [ ] 编写一个简单的 Mojo 接口
- [ ] 理解 Mojo 生成的代码
- [ ] 使用 Chrome DevTools 查看 Mojo 消息
- [ ] 分析 Chromium 中的 Mojo 使用

---

## 🔗 相关链接

- [[02-多进程架构]] - 进程模型
- [[12-安全模型]] - 安全边界
- [[../Electron/02-进程通信|Electron 进程通信]] - Electron IPC
- [Mojo 文档](https://chromium.googlesource.com/chromium/src/+/HEAD/mojo/README.md)

---

#tech/chromium/ipc
