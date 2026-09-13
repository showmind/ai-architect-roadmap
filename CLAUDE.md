# AI时代的架构师养成之路

交互式建筑师学习平台。

## 结构

```
├── index.html              # 站首页
├── MASTER_PLAN.md          # 知识大纲（派发源）
├── .hermes.md              # Hermes 子代理调度规则
├── units/                  # 知识单元目录
│   ├── L1/                 # Level 1 基石
│   ├── L2/                 # Level 2 进阶
│   ├── L3/                 # Level 3 战略
│   └── IQ/                 # 面试专题
├── assets/                 # 全局静态资源
└── scripts/                # 辅助脚本
```

## 本地预览

```bash
python3 -m http.server 8000
# 打开 http://localhost:8000
```

## 技术

- 纯前端（无构建步骤）
- HTML5 + CSS3 + Vanilla JS / Web Components
- SVG + Canvas 可视化
- GitHub Pages 部署

## 子代理协作

由 Hermes 调度 MiMo Code / OpenCode / CodeBuddy 等免费编码代理协作开发。
详见 `.hermes.md`。
