---
title: Composition API
date: 2026-03-01
tags:
  - Vue
  - Composition API
  - 前端
difficulty: ⭐⭐
status: ✅ 已掌握
related:
  - 响应式系统
  - 自定义 Hooks
---

# Composition API

> Vue 3 引入的全新组件逻辑组织方式

## 📌 核心概念

Composition API 是一组函数，允许在 `setup()` 函数或 `<script setup>` 中组织组件逻辑。

### 与 Options API 对比

| 特性 | Options API | Composition API |
|------|-------------|-----------------|
| 代码组织 | 按选项类型分散 | 按逻辑功能聚合 |
| 逻辑复用 | Mixins (有缺陷) | 组合式函数 |
| TypeScript | 支持有限 | 完美支持 |
| 代码量 | 较多 | 更精简 |
| 适用场景 | 简单组件 | 复杂组件 |

---

## 🚀 快速开始

### setup 函数

```vue
<script>
import { ref, reactive, onMounted } from 'vue'

export default {
  setup() {
    // 响应式数据
    const count = ref(0)
    const state = reactive({ name: 'Vue' })

    // 方法
    function increment() {
      count.value++
    }

    // 生命周期
    onMounted(() => {
      console.log('mounted')
    })

    // 返回模板需要的内容
    return {
      count,
      state,
      increment
    }
  }
}
</script>
```

### `<script setup>` 语法糖 (推荐)

```vue
<script setup>
import { ref, onMounted } from 'vue'

// 响应式数据 - 自动暴露给模板
const count = ref(0)
const state = reactive({ name: 'Vue' })

// 方法 - 自动暴露给模板
function increment() {
  count.value++
}

// 生命周期
onMounted(() => {
  console.log('mounted')
})
</script>

<template>
  <button @click="increment">{{ count }}</button>
</template>
```

---

## 📦 核心 API

### 1. 响应式 API

#### ref - 基础类型响应式

```typescript
import { ref } from 'vue'

// 基础类型
const count = ref(0)
const message = ref('hello')

// 访问/修改需要 .value
console.log(count.value)  // 0
count.value++

// 对象也可以，但会自动解包
const user = ref({ name: 'Vue' })
console.log(user.value.name)  // 'Vue'

// 在模板中自动解包，不需要 .value
// <div>{{ count }}</div>
```

#### reactive - 对象响应式

```typescript
import { reactive } from 'vue'

// 只能用于对象类型
const state = reactive({
  count: 0,
  user: {
    name: 'Vue',
    age: 3
  }
})

// 直接访问，不需要 .value
state.count++
state.user.name = 'Vue 3'

// 解构会失去响应性！
const { count } = state  // ❌ 失去响应性

// 使用 toRefs 保持响应性
import { toRefs } from 'vue'
const { count } = toRefs(state)  // ✅ 保持响应性
```

#### ref vs reactive 对比

| 特性 | ref | reactive |
|------|-----|----------|
| 适用类型 | 任意类型 | 仅对象类型 |
| 访问方式 | `.value` | 直接访问 |
| 解构 | 安全 | 需 `toRefs` |
| 重新赋值 | ✅ 可以 | ❌ 会丢失响应性 |
| 推荐场景 | 基础类型、需要重新赋值 | 复杂对象 |

```typescript
// ref - 可以重新赋值
const user = ref(null)
user.value = { name: 'Vue' }  // ✅

// reactive - 不能重新赋值
const state = reactive({ count: 0 })
state = { count: 1 }  // ❌ 丢失响应性！
```

---

### 2. 计算属性 computed

```typescript
import { ref, computed } from 'vue'

const firstName = ref('Vue')
const lastName = ref('3')

// 只读计算属性
const fullName = computed(() => {
  return `${firstName.value} ${lastName.value}`
})

// 可写计算属性
const fullNameWritable = computed({
  get() {
    return `${firstName.value} ${lastName.value}`
  },
  set(newValue) {
    [firstName.value, lastName.value] = newValue.split(' ')
  }
})

// 使用
fullNameWritable.value = 'Vue 4'
```

---

### 3. 侦听器 watch / watchEffect

#### watch - 精确侦听

```typescript
import { ref, watch } from 'vue'

const count = ref(0)
const user = reactive({ name: 'Vue', age: 3 })

// 侦听 ref
watch(count, (newVal, oldVal) => {
  console.log(`count: ${oldVal} -> ${newVal}`)
})

// 侦听 reactive 属性 - 需要 getter
watch(
  () => user.age,
  (newVal, oldVal) => {
    console.log(`age: ${oldVal} -> ${newVal}`)
  }
)

// 侦听多个源
watch([count, () => user.age], ([newCount, newAge], [oldCount, oldAge]) => {
  console.log('count or age changed')
})

// 侦听对象 - 深度侦听
watch(
  () => user,
  (newVal) => {
    console.log('user changed', newVal)
  },
  { deep: true }  // 深度侦听
)

// 立即执行
watch(
  count,
  (newVal) => {
    console.log('immediate:', newVal)
  },
  { immediate: true }
)
```

#### watchEffect - 自动追踪依赖

```typescript
import { ref, watchEffect } from 'vue'

const count = ref(0)
const name = ref('Vue')

// 自动追踪回调中使用的所有响应式依赖
watchEffect(() => {
  console.log(`count: ${count.value}, name: ${name.value}`)
  // 自动追踪 count 和 name
})

// 停止侦听
const stop = watchEffect(() => {
  console.log(count.value)
})
stop()  // 手动停止

// 清理副作用
watchEffect((onCleanup) => {
  const timer = setInterval(() => {}, 1000)
  
  onCleanup(() => {
    clearInterval(timer)  // 下次执行前或停止时清理
  })
})
```

#### watch vs watchEffect

| 特性 | watch | watchEffect |
|------|-------|-------------|
| 依赖声明 | 显式指定 | 自动追踪 |
| 获取旧值 | ✅ 可以 | ❌ 不能 |
| 立即执行 | 需要 `immediate` | 默认立即执行 |
| 使用场景 | 需要精确控制 | 自动收集依赖 |

---

### 4. 生命周期钩子

```typescript
import {
  onBeforeMount,
  onMounted,
  onBeforeUpdate,
  onUpdated,
  onBeforeUnmount,
  onUnmounted,
  onErrorCaptured
} from 'vue'

// Options API → Composition API
// beforeCreate → setup()
// created → setup()
// beforeMount → onBeforeMount
// mounted → onMounted
// beforeUpdate → onBeforeUpdate
// updated → onUpdated
// beforeUnmount → onBeforeUnmount
// unmounted → onUnmounted

onMounted(() => {
  console.log('组件已挂载')
})

onUnmounted(() => {
  console.log('组件已卸载')
  // 清理工作
})
```

---

### 5. 依赖注入 provide/inject

```vue
<!-- 父组件 -->
<script setup>
import { provide, ref } from 'vue'

const theme = ref('dark')
const updateTheme = (newTheme) => {
  theme.value = newTheme
}

// 提供值
provide('theme', theme)
provide('updateTheme', updateTheme)

// 提供响应式对象时，建议使用只读
import { readonly } from 'vue'
provide('config', readonly(config))
</script>

<!-- 子组件 -->
<script setup>
import { inject } from 'vue'

// 注入值
const theme = inject('theme', 'light')  // 第二个参数是默认值
const updateTheme = inject('updateTheme')

// 使用 Symbol 避免冲突
const ThemeKey = Symbol('theme')
provide(ThemeKey, theme)
</script>
```

---

### 6. 模板引用 ref

```vue
<script setup>
import { ref, onMounted } from 'vue'

// 创建模板引用
const inputRef = ref(null)
const listRef = ref([])

onMounted(() => {
  // 访问 DOM 元素
  inputRef.value.focus()
  console.log(listRef.value)  // 数组
})
</script>

<template>
  <input ref="inputRef" />
  
  <!-- v-for 中的 ref -->
  <div v-for="item in list" :ref="el => listRef.push(el)">
    {{ item }}
  </div>
</template>
```

---

### 7. 其他常用 API

#### toRef / toRefs

```typescript
import { reactive, toRef, toRefs } from 'vue'

const state = reactive({
  count: 0,
  name: 'Vue'
})

// toRef - 单个属性转为 ref
const countRef = toRef(state, 'count')

// toRefs - 所有属性转为 ref
const { count, name } = toRefs(state)
// 解构后仍保持响应性
```

#### shallowRef / shallowReactive

```typescript
import { shallowRef, shallowReactive } from 'vue'

// shallowRef - 只有 .value 是响应式的
const state = shallowRef({ count: 0 })
state.value.count++  // ❌ 不会触发更新
state.value = { count: 1 }  // ✅ 触发更新

// shallowReactive - 只有根级别是响应式的
const shallow = shallowReactive({
  level1: '响应式',
  nested: {
    level2: '非响应式'
  }
})
```

#### readonly

```typescript
import { reactive, readonly } from 'vue'

const original = reactive({ count: 0 })
const readonlyObj = readonly(original)

readonlyObj.count++  // ❌ 警告，无法修改
```

---

## 🎯 最佳实践

### 1. 组合式函数 (Composables)

```typescript
// useCounter.ts
import { ref, computed } from 'vue'

export function useCounter(initial = 0) {
  const count = ref(initial)
  const double = computed(() => count.value * 2)
  
  function increment() {
    count.value++
  }
  
  function decrement() {
    count.value--
  }
  
  function reset() {
    count.value = initial
  }
  
  return {
    count,
    double,
    increment,
    decrement,
    reset
  }
}

// 使用
import { useCounter } from './useCounter'

const { count, double, increment } = useCounter(10)
```

### 2. 命名规范

```typescript
// 组合式函数以 use 开头
function useCounter() {}
function useMouse() {}
function useLocalStorage() {}

// ref 变量以 Ref 结尾或直接用语义化名称
const countRef = ref(0)
const count = ref(0)  // 推荐

// 响应式对象用 state 或语义化名称
const state = reactive({})
const user = reactive({})

// 命名导出的组合式函数
export function useFeature() {
  // 私有状态
  const internal = ref(0)
  
  // 公开状态和方法
  const public = ref(0)
  function doSomething() {}
  
  return {
    public,
    doSomething
  }
}
```

### 3. 响应式丢失问题

```typescript
import { reactive, toRefs, toRef } from 'vue'

// ❌ 错误：解构会丢失响应性
const state = reactive({ count: 0 })
let { count } = state

// ✅ 正确：使用 toRefs
const state = reactive({ count: 0 })
let { count } = toRefs(state)

// ✅ 正确：使用 toRef
const count = toRef(state, 'count')

// ✅ 正确：直接传递整个对象
function useFeature(state) {
  // state.count 仍然响应式
}
```

---

## ⚠️ 常见陷阱

### 1. 在 setup 外使用组合式 API

```typescript
// ❌ 错误
const count = ref(0)  // 在组件外部

export default {
  setup() {
    // count 在这里不会工作
  }
}

// ✅ 正确
export default {
  setup() {
    const count = ref(0)
    return { count }
  }
}
```

### 2. 修改 props

```typescript
// ❌ 错误：直接修改 props
const props = defineProps(['count'])
props.count++  // 警告

// ✅ 正确：使用本地副本或 emit
const props = defineProps(['count'])
const localCount = ref(props.count)

const emit = defineEmits(['update:count'])
emit('update:count', props.count + 1)
```

### 3. 异步 setup

```typescript
// ❌ 错误：setup 不能是 async
export default {
  async setup() {  // 不推荐
    const data = await fetchData()
    return { data }
  }
}

// ✅ 正确：在生命周期中处理异步
export default {
  setup() {
    const data = ref(null)
    
    onMounted(async () => {
      data.value = await fetchData()
    })
    
    return { data }
  }
}

// ✅ 正确：使用 Suspense (Vue 3+)
// <Suspense> 配合 async setup
```

---

## 🔗 相关笔记

- [[响应式系统]] - 深入理解响应式原理
- [[自定义 Hooks]] - 组合式函数最佳实践
- [[组件通信]] - 组件间数据传递

---

## 📚 参考资料

- [Vue 3 Composition API 官方文档](https://cn.vuejs.org/api/composition-api-setup.html)
- [Vue 3 响应式基础](https://cn.vuejs.org/guide/essentials/reactivity-fundamentals.html)

---
#vue/composition-api
