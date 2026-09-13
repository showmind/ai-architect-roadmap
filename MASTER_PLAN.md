# MASTER_PLAN.md — 架构师养成之路 · 主控大纲

> 这是整个项目的**知识蓝图**和**任务派发源**。Hermes 按本文件调度子代理协作开发。
> 每条知识单元（KU）对应一个独立网页 + 动画 + 测验题。

---

## 一、知识体系三层架构

### Level 1 · 架构师基石

| KU编号 | 知识点 | 载体 | 状态 |
|--------|--------|------|------|
| L1-KU01 | 设计模式在架构中的应用（23种精选） | 互动卡片 + 代码可视化 | ⬜ |
| L1-KU02 | 编码规范与 SOLID 原则 | 互动检测题 | ⬜ |
| L1-KU03 | 数据结构与算法工程应用 | 动画演示 | ⬜ |
| L1-KU04 | 架构思维入门（DRY/YAGNI/KISS/分离关注点） | 互动网页 | ⬜ |
| L1-KU05 | 代码复用与模块化设计 | 互动演示 | ⬜ |

### Level 2 · 分布式与架构设计

| KU编号 | 知识点 | 载体 | 状态 |
|--------|--------|------|------|
| L2-KU01 | CAP 定理与 BASE 理论 | 动画 + 交互题 | ⬜ |
| L2-KU02 | 共识算法（Paxos/Raft） | 动画演示 | ⬜ |
| L2-KU03 | 分布式事务（2PC/3PC/Seata/TCC） | 时序图 + 互动网页 | ⬜ |
| L2-KU04 | 微服务拆分策略 | 架构图 + 案例分析 | ⬜ |
| L2-KU05 | 服务治理（注册发现/限流/熔断/降级） | 互动演示 | ⬜ |
| L2-KU06 | API 网关设计 | 架构图 | ⬜ |
| L2-KU07 | 负载均衡策略 | 动画演示 | ⬜ |
| L2-KU08 | 缓存设计（Redis/Memcached） | 互动网页 + 面试题 | ⬜ |
| L2-KU09 | 消息队列（Kafka/RocketMQ） | 时序动画 + 架构图 | ⬜ |
| L2-KU10 | 数据库分库分表 | 动画演示 | ⬜ |
| L2-KU11 | 高并发架构（秒杀/限流/削峰） | 完整案例网页 | ⬜ |
| L2-KU12 | 高可用设计（多活/容灾/故障转移） | 互动演示 | ⬜ |
| L2-KU13 | 云原生与 K8s 编排 | 架构图 + 动画 | ⬜ |
| L2-KU14 | Service Mesh（Istio/Envoy） | 架构图 | ⬜ |
| L2-KU15 | 可观测性（Metrics/Logging/Tracing） | 互动仪表盘 | ⬜ |

### Level 3 · 战略与前沿

| KU编号 | 知识点 | 载体 | 状态 |
|--------|--------|------|------|
| L3-KU01 | 企业架构框架（TOGAF/ADM） | 互动网页 | ⬜ |
| L3-KU02 | C4 Model 架构文档法 | 绘图交互 | ⬜ |
| L3-KU03 | 架构评估方法（ATAM/CBAM） | 互动演示 | ⬜ |
| L3-KU04 | AI + 架构融合（LLM辅助设计/Prompt） | 视频 + 案例 | ⬜ |
| L3-KU05 | MCP 协议与 AI Agent 架构 | 互动演示 | ⬜ |
| L3-KU06 | 混沌工程与系统韧性 | 动画 + 实验环境 | ⬜ |
| L3-KU07 | 架构师的决策力与软技能 | 视频 | ⬜ |
| L3-KU08 | 从单体到微服务到中台的架构演进 | 完整案例网页 | ⬜ |

### 🎓 面试专题（穿插于各级）

| KU编号 | 专题 | 载体 |
|--------|------|------|
| IQ-01 | 系统设计面试题精练（URL Shortener/Twitter/Chat） | 互动白板 + 评分 |
| IQ-02 | 分布式系统高频 50 题 | 答题系统 |
| IQ-03 | 高并发场景题精选 | 互动题 |
| IQ-04 | 微服务面试 33 问 | 卡片翻转题 |
| IQ-05 | 真实大厂面经拆解 | 案例分析 |

---

## 二、可视化技能清单

| 技能 | 工具 | 用途 | 收集状态 |
|------|------|------|----------|
| SVG 架构图 | architecture-diagram skill / draw.io | 系统拓扑 | ✅ |
| HTML 互动 | Web Components + Canvas | 知识点交互 | ✅ |
| 动画生成 | p5.js / Manim / CSS Animation | 流程演示 | ✅ |
| 视频生成 | Manim + TTS | 深度讲解 | 📋 待确认免费 TTS |
| 交互式题目 | 自建 quiz engine | 测验 | ✅ |

---

## 三、载体设计规范

每个知识单元（KU）交付物：

```
units/{level}/{ku-id}/
├── index.html        # 主页面（含互动演示）
├── animation.*.html  # 动画页（p5.js / CSS / SVG）
├── diagram.svg       # 架构图
├── quiz.html         # 交互式测验题
├── meta.json         # 知识点元信息（标题/难度/标签/引用源）
└── assets/           # 静态资源
```

---

## 四、开发工作流（Hermes 调度规则）

```
1. Hermes 从 MASTER_PLAN 挑 ⬜ 状态 KU
2. 派发给子代理（MiMo Code / OpenCode / CodeBuddy）
3. 子代理按 KU 模板开发完整交付物
4. Hermes review → 合并 → 部署 GitHub Pages
5. 更新本文件状态为 ✅
```

详细调度规则见 `.hermes.md`。

---

## 五、参考资源

### 博客 & 系列文章
- 腾讯云《架构师成长全景学习路线》：https://cloud.tencent.com/developer/article/2548289
- 阿里云《Java架构师面试核心技术栈》：https://developer.aliyun.com/article/1432175
- 阿里云《耗时一晚上梳理出2023年微服务必会知识点》：https://developer.aliyun.com/article/1270387
- 牛客博客《老王：如何成为主力架构师》：https://blog.nowcoder.net/n/c0965a7902e24764bc5d406367f37ddf
- javabetter.cn 微服务面试33问：https://javabetter.cn/sidebar/sanfene/weifuwu.html

### 书籍
- 《设计数据密集型应用》Martin Kleppmann
- 《凤凰架构》周志明
- 《AI时代架构师修炼之道》关东升
- 《云原生架构》吕昭波
- 《架构演变实战：从单体到微服务再到中台》潘志伟

### 认证
- AWS Solutions Architect Professional
- 阿里云 ACE 认证
- TOGAF 9.2

---

## 六、进度看板

- [x] Phase 0：项目起骨架 + 知识大纲 MASTER_PLAN
- [ ] Phase 1：首个 Demo KU（L1-KU04 架构思维入门）上线
- [ ] Phase 2：Level 1 全部 KU
- [ ] Phase 3：Level 2 核心 KU（分布式+微服务+高并发）
- [ ] Phase 4：Level 3 + 面试专题
- [ ] Phase 5：全站整合 + 视频管线

---

> **维护规则**：每完成一个 KU，Hermes 把 ⬜ 改为 ✅，并在下方记录完成日期与 PR 链接。

### 已完成记录
（暂无）
