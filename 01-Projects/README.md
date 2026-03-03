# 🚀 Projects 项目

> 有明确目标和截止日期的任务

## 进行中的项目

```dataview
TABLE 
  status as 状态,
  start_date as 开始日期,
  end_date as 截止日期,
  priority as 优先级
FROM "01-Projects"
WHERE status = "🚀 进行中" AND file.name != "README"
SORT priority ASC, end_date ASC
```

## 已完成的项目

```dataview
LIST
FROM "01-Projects"
WHERE status = "✅ 已完成"
SORT end_date DESC
LIMIT 10
```

## 项目状态说明

| 状态 | 含义 |
|------|------|
| 🚀 进行中 | 正在执行 |
| ⏸️ 暂停 | 临时搁置 |
| ✅ 已完成 | 已达成目标 |
| ❌ 已取消 | 不再执行 |

---

使用 QuickAdd → 🚀 新建项目
