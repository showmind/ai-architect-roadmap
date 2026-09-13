# AI时代的架构师养成之路 🏗️

> 一个以**互动网页、动画、视频、交互式题目**为载体，系统化拆解架构师知识体系的开放式学习平台。
>
> 整个项目开发由 Hermes 作为调度者，调度免费 AI 编码代理（MiMo Code / OpenCode / CodeBuddy 等）协作完成。

---

## 项目定位

为希望**从程序员进阶到架构师**的学习者提供：

- **结构化知识大纲**：覆盖从基础到前沿的完整架构师知识体系
- **互动式学习载体**：不再只有文字——每个知识单元都有交互式网页、动画、视频讲解
- **面向面试**：拆解高频架构师面试题，配互动测验

## 知识架构（三层）

```
Level 1 · 架构师基石（0-2年 → 筑基）
├── 计算机基础 / 设计模式 / 编码规范
├── 数据结构与算法在架构中的应用
└── 软件工程思维（SOLID、DRY、TDD）

Level 2 · 分布式与架构设计（3-5年 → 进阶）
├── 分布式系统理论（CAP、BASE、共识算法）
├── 微服务架构（Spring Cloud / Dubbo / Service Mesh）
├── 高并发、高可用、高性能设计
├── 数据库分库分表 / 缓存 / 消息队列
└── 云原生（Docker / K8s / Serverless）

Level 3 · 战略与前沿（6年+ → 突破）
├── 企业架构方法论（TOGAF、C4 Model、ATAM）
├── AI 与架构融合（LLM 辅助设计、MCP、Agent）
├── 系统韧性工程（混沌工程、容错设计）
└── 架构师软技能（决策力、沟通力、技术影响力）
```

## 载体形态

| 载体 | 用途 | 工具/技术 |
|------|------|-----------|
| 📊 互动网页 | 知识点交互演示、动态可视化 | HTML5 Canvas / SVG / p5.js |
| 🎬 动画 | 架构演变流程、系统交互时序 | Manim / CSS Animation / p5.js |
| 🎥 视频 | 深度讲解、案例分析 | 语音合成 + 动画拼接 |
| 🖱️ 交互题 | 面试测验、知识巩固 | HTML 互动组件 |
| 📐 架构图 | 系统拓扑、数据流 | SVG / architecture-diagram |

## 技术栈（前端）

- **纯静态站**：HTML5 + CSS3 + Vanilla JS / Web Components
- **动画层**：SVG + Canvas + p5.js / Manim（视频）
- **部署**：GitHub Pages
- **子代理**：MiMo Code（小米限时免费通道）/ OpenCode / CodeBuddy

## 路线图

- [ ] Phase 1：知识大纲 + 项目脚手架 + 首个知识单元 Demo
- [ ] Phase 5：Level 1 全部知识单元上线（互动网页 + 动画 + 题目）
- [ ] Phase 3：Level 2 核心模块
- [ ] Phase 4：Level 3 + AI融合专题
- [ ] Phase 5：视频生成管线 + 全站整合

## 参与贡献

本项目由 Hermes 调度多个免费 AI Coding Agent 协作开发。详见 [MASTER_PLAN.md](./MASTER_PLAN.md)。

## License

MIT
