# 📦 Archives 归档

> 已完成或不再活跃的内容

## 归档来源

- ✅ 已完成的项目
- 🗓️ 过期的内容
- 📁 不再需要但想保留的笔记

## 归档规则

1. **保持结构**: 移动时保持原有文件夹结构
2. **添加说明**: 在归档文件夹中添加 README 说明来源
3. **定期清理**: 每年清理一次，删除无价值内容

## 归档索引

```dataview
TABLE 
  file.ctime as 归档时间,
  file.folder as 来源
FROM "04-Archives"
WHERE file.name != "README"
SORT file.ctime DESC
LIMIT 20
```

---

归档不等于删除，需要时仍可检索
