#!/bin/bash
# verify.sh — KU 交付物验证脚本
# 用法: bash verify.sh <ku-directory>

set -e

KU_DIR="${1:-.}"
ERRORS=0

echo "=== 验证 KU: $KU_DIR ==="

# 1. 检查必需文件
REQUIRED_FILES=("index.html" "animation.html" "quiz.html" "diagram.svg" "meta.json")
for f in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$KU_DIR/$f" ]; then
    echo "❌ 缺少文件: $f"
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ $f 存在"
  fi
done

# 2. 检查文件非空
for f in "${REQUIRED_FILES[@]}"; do
  if [ -f "$KU_DIR/$f" ] && [ ! -s "$KU_DIR/$f" ]; then
    echo "❌ 文件为空: $f"
    ERRORS=$((ERRORS + 1))
  fi
done

# 3. HTML 结构检查
for html in "$KU_DIR/index.html" "$KU_DIR/animation.html" "$KU_DIR/quiz.html"; do
  if [ -f "$html" ]; then
    for tag in '<!DOCTYPE' '<html' '</html>' '<head>' '</head>' '<body>' '</body>'; do
      if ! grep -q "$tag" "$html"; then
        echo "⚠️  $html 可能缺少 $tag"
      fi
    done
  fi
done

# 4. JSON 格式检查
if [ -f "$KU_DIR/meta.json" ]; then
  if python3 -c "import json; json.load(open('$KU_DIR/meta.json'))" 2>/dev/null; then
    echo "✅ meta.json 格式正确"
  else
    echo "❌ meta.json 格式错误"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 5. SVG 检查
if [ -f "$KU_DIR/diagram.svg" ]; then
  if grep -q "svg" "$KU_DIR/diagram.svg"; then
    echo "✅ diagram.svg 看起来有效"
  else
    echo "⚠️  diagram.svg 可能无效"
  fi
fi

# 6. 引用署名检查
for html in "$KU_DIR/index.html" "$KU_DIR/quiz.html"; do
  if [ -f "$html" ]; then
    if grep -qE "引用|reference|《》|腾讯云|Martin|McConnell" "$html"; then
      echo "✅ $html 包含引用署名"
    else
      echo "⚠️  $html 可能缺少引用署名"
    fi
  fi
done

# 7. 总结
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "🎉 验证通过！KU 交付物完整。"
  exit 0
else
  echo "💥 验证失败：$ERRORS 个错误"
  exit 1
fi
