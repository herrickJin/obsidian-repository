#!/bin/bash
# 每日知识库检查脚本

VAULT=~/Documents/jinmo-obsidian

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📅 $(date '+%Y-%m-%d %A')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Inbox 检查
inbox=$(find "$VAULT/00-Inbox" -name "*.md" ! -name "README.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$inbox" -gt 0 ]; then
    echo "📥 Inbox 待整理: $inbox 条"
    find "$VAULT/00-Inbox" -name "*.md" ! -name "README.md" -exec basename {} .md \; 2>/dev/null | head -5 | sed 's/^/   • /'
    [ "$inbox" -gt 5 ] && echo "   ... 还有 $((inbox - 5)) 条"
else
    echo "✅ Inbox 已清空"
fi
echo ""

# 进行中的学习
learning=$(grep -rl "status: 🌱 学习中" "$VAULT/03-Resources" 2>/dev/null | wc -l | tr -d ' ')
if [ "$learning" -gt 0 ]; then
    echo "📚 学习中: $learning 个主题"
fi

# 活跃项目
projects=$(grep -rl "status: 🚀 进行中" "$VAULT/01-Projects" 2>/dev/null | wc -l | tr -d ' ')
if [ "$projects" -gt 0 ]; then
    echo "🚀 进行中项目: $projects 个"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
