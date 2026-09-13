# HARNESS.md — 多 Agent 协作调度系统

> 本文档定义 "AI时代的架构师养成之路" 项目的基础设施层（Harness）。
> 目标：让 Hermes 作为调度者，协调 3+ 个免费 AI 编码代理协同开发，具备故障转移、重试、验证门等生产级能力。

---

## 一、系统架构

```
┌─────────────────────────────────────────────────────────┐
│                    Hermes (调度者)                        │
│  职责：任务拆分 → 路由 → 派发 → 验证 → 合并 → 更新看板     │
│  禁止：编写业务代码                                       │
├─────────────────────────────────────────────────────────┤
│                   Harness Layer                         │
│  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Task    │  │ Router   │  │ Retry    │  │ Verify  │ │
│  │ Queue   │  │ (路由)   │  │ Engine   │  │ Gate    │ │
│  └─────────┘  └──────────┘  └──────────┘  └─────────┘ │
├─────────────────────────────────────────────────────────┤
│              Agent Pool (子代理池)                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ OpenCode │  │ CodeBuddy│  │  Codex   │  │ 更多…  │ │
│  │ (主力)   │  │ (腾讯)   │  │ (OpenAI) │  │        │ │
│  └──────────┘  └──────────┘  └──────────┘  └────────┘ │
├─────────────────────────────────────────────────────────┤
│              Infrastructure Layer                        │
│  GitHub (Repo/Issue/PR/Pages) │  Workspace (git worktree)│
└─────────────────────────────────────────────────────────┘
```

---

## 二、子代理池（Agent Pool）

### 2.1 工具清单

| 工具 | 版本 | 调用方式 | 免费模型 | 状态 |
|------|------|----------|----------|------|
| **OpenCode** | 1.18.18 | `opencode run "prompt"` | `ling-3.0-flash-fin-free` (内置免费) | ⚠️ 证书错误排查中 |
| **CodeBuddy** | 2.150.0 | `codebuddy -p "prompt"` / `cbc -p` | 需腾讯云 Coding Plan key 或登录态 | ✅ 可交互 |
| **Codex** | 0.154.0 | `codex exec "prompt"` | 需 OpenAI key 或 OmniRoute | ⚠️ 需配置 auth |

### 2.2 工具特性对比

| 特性 | OpenCode | CodeBuddy | Codex |
|------|----------|-----------|-------|
| LSP 集成 | ✅ 自动诊断 | ❌ | ❌ |
| 多模型路由 | ✅ 75+ providers | ✅ 腾讯云系 | ✅ OpenAI系 |
| 沙箱模式 | ✅ `--sandbox workspace-write` | ✅ 权限控制 | ✅ `--sandbox workspace-write` |
| 非交互模式 | ✅ `run` | ✅ `-p` | ✅ `exec` |
| 会话恢复 | ✅ `--continue` / `-s` | ✅ `-c` / `-r` | ✅ `resume` |
| MCP 支持 | ✅ 内置 | ✅ 内置 | ✅ 内置 |
| 中文 UI | ❌ 英文 | ✅ 全汉化 | ❌ 英文 |
| 免费程度 | ⭐⭐⭐ 完全免费 | ⭐⭐ 需key/登录 | ⭐ 需key/OmniRoute |

### 2.3 路由策略

```
任务类型          → 首选代理        → 备选代理
────────────────────────────────────────────
前端页面/动画     → OpenCode        → CodeBuddy
代码重构/修复     → CodeBuddy       → OpenCode
代码审查/测试     → Codex           → CodeBuddy
文档/元数据       → OpenCode        → CodeBuddy
紧急/简单任务     → CodeBuddy       → OpenCode
```

---

## 三、任务调度协议

### 3.1 任务粒度

- **最小任务单元** = 1 个知识单元（KU）的 1 个交付物
- **标准任务** = 1 个 KU 的完整开发（5 个文件）
- **最大任务** = 不超过 1 个 KU，避免上下文爆炸

### 3.2 任务描述模板（Task Spec）

```yaml
task_id: L1-KU04
title: 架构思维入门
type: ku_development
priority: P1  # P0=紧急 P1=正常 P2=低优

# 路由
routing:
  primary: opencode
  fallback: codebuddy
  fallback_chain: [opencode, codebuddy, codex]

# 工作空间
workspace:
  branch: feat/L1-KU04-architecture-mindset
  directory: units/L1/L1-KU04/
  worktree: false  # 是否隔离到 worktree

# 交付物
deliverables:
  - file: index.html
    type: webpage
    required: true
  - file: animation.html
    type: animation
    required: true
  - file: quiz.html
    type: interactive
    required: true
  - file: diagram.svg
    type: diagram
    required: true
  - file: meta.json
    type: metadata
    required: true

# 验收标准
acceptance:
  - "浏览器打开 index.html 可正常交互"
  - "animation.html 5阶段动画自动播放"
  - "quiz.html 5题可作答并判分"
  - "无 console 报错"
  - "meta.json 格式正确"

# 重试策略
retry:
  max_attempts: 3
  backoff: exponential  # 1min → 2min → 4min
  fallback_on_failure: true

# 引用规范
references:
  - "《代码大全2》Steve McConnell"
  - "《架构整洁之道》Robert C. Martin"
  - "https://cloud.tencent.com/developer/article/2548289"
```

### 3.3 任务状态机

```
[PENDING] → [DISPATCHED] → [RUNNING] → [VERIFYING] → [MERGED]
    ↓            ↓             ↓            ↓
[RETRY] ← [FAILED]      [TIMEOUT]    [REJECTED]
    ↓
[FALLBACK] → [DISPATCHED] (下一个代理)
    ↓
[ESCALATE] → Hermes 人工介入
```

---

## 四、故障处理系统

### 4.1 故障分类

| 类型 | 示例 | 处理策略 |
|------|------|----------|
| **瞬时故障** | 网络超时、API 429、证书错误 | 指数退避重试 |
| **永久故障** | API key 无效、模型不存在 | 立即切换备选代理 |
| **质量故障** | 代码不达标、缺交付物 | 重发任务 + 更详细指令 |
| **环境故障** | 磁盘满、git 冲突 | Hermes 人工修复后重试 |

### 4.2 重试策略

```python
# 伪代码
def execute_task(task, agent_chain):
    for agent in agent_chain:
        for attempt in range(task.max_attempts):
            try:
                result = agent.run(task.spec, timeout=task.timeout)
                if verify(result, task.acceptance):
                    return result
                else:
                    task.spec = enrich_prompt(task.spec, result.feedback)
            except TransientError:
                sleep(exponential_backoff(attempt))
            except PermanentError:
                break  # 换下一个代理
            except TimeoutError:
                agent.kill()
                break
    escalate_to_hermes(task)
```

### 4.3 断路器（Circuit Breaker）

- 同一代理连续失败 3 次 → 标记为 `UNHEALTHY`，30 分钟内不分配任务
- 所有代理均不可用 → Hermes 暂停派发，通知用户

---

## 五、验证门（Verification Gate）

### 5.1 自动化验证

每个 KU 交付后自动执行：

```bash
# 1. HTML 结构检查
python3 -c "
import re, sys
with open('$file') as f:
    content = f.read()
    for tag in ['<!DOCTYPE', '<html', '</html>', '<head>', '</head>', '<body>', '</body>']:
        assert tag in content, f'Missing {tag}'
    print('HTML structure OK')
"

# 2. JSON 格式检查
python3 -c "import json; json.load(open('$meta_file'))"

# 3. 文件大小检查（非空）
test -s "$file" || exit 1

# 4. 引用署名检查
grep -q "引用\|reference\|《》" "$file" || echo "WARNING: missing attribution"
```

### 5.2 Hermes 审阅

- 代码质量（可读性、注释、语义化）
- 引用源署名完整性
- 与站首页风格一致性
- 互动功能可用性

---

## 六、GitHub 限流应对

### 6.1 限流配额

| API | 限制 | 本项目用量 | 风险 |
|-----|------|-----------|------|
| GitHub API (认证) | 5,000/h | ~50/h (正常调度) | 低 |
| GitHub Pages 构建 | 10/h | ~2/h | 低 |
| GitHub Actions | 2,000 min/月 | 0 (静态站不走 Actions) | 无 |
| `curl` 未认证 | 60/h | 不使用 | 无 |

### 6.2 节流策略

- Hermes 派发间隔 ≥ 30 秒（避免 burst）
- 批量 PR 创建时串行，不并行
- 使用 `gh` CLI（已认证），不走裸 curl
- 缓存 `gh api` 结果，避免重复查询

---

## 七、工作空间管理

### 7.1 Git 分支策略

```
main (稳定，可部署)
├── feat/L1-KU04-architecture-mindset
├── feat/L1-KU02-solid-principles
├── feat/L2-KU01-cap-theorem
└── ...
```

- 每个 KU 一个分支，开发完合入 main
- 合入后自动删除远端分支

### 7.2 并行执行隔离（关键！）

> ⚠️ 2026-09-13 事故：两个子代理并行跑时共享了同一工作目录，导致 L1-KU02 和 L2-KU01 混在同一个 commit 里。

**规则**：

1. **每个子代理必须 cd 到自己的 KU 目录**，不能共享项目根目录
2. **delegate_task 的 context 里必须明确指定**：`工作目录：cd ~/projects/ai-architect-roadmap/units/{level}/{KU-id}/`
3. **子代理写文件必须用绝对路径**，不能用相对路径
4. **Hermes 在派发并行任务前，先确保各分支已创建并 push**
5. **子代理完成后，Hermes 先 `git checkout main && git pull`，再合并分支**

```bash
# 正确流程：
# 1. Hermes 创建分支
git checkout -b feat/{KU-id} && git push -u origin feat/{KU-id}

# 2. 子代理 cd 到独立目录
cd ~/projects/ai-architect-roadmap/units/{level}/{KU-id}/
opencode run "..."

# 3. 子代理只提交自己目录下的文件
git add units/{level}/{KU-id}/ && git commit -m "..."
git push origin feat/{KU-id}

# 4. Hermes 合并
git checkout main && git pull
git merge feat/{KU-id} --no-edit
git push origin main
```

### 7.3 目录结构

```
ai-architect-roadmap/
├── HARNESS.md              # 本文档
├── MASTER_PLAN.md          # 知识大纲 + 任务看板
├── .hermes.md              # Hermes 调度规则
├── units/
│   ├── L1/
│   │   ├── L1-KU04/
│   │   │   ├── index.html
│   │   │   ├── animation.html
│   │   │   ├── quiz.html
│   │   │   ├── diagram.svg
│   │   │   └── meta.json
│   │   └── ...
│   ├── L2/
│   ├── L3/
│   └── IQ/
├── assets/
└── scripts/
    └── verify.sh           # 验证脚本
```

---

## 八、运行手册

### 8.1 启动新 KU 开发

```bash
# 1. Hermes 从 MASTER_PLAN 选 ⬜ KU
# 2. 创建分支
git checkout -b feat/{KU-id}
git push -u origin feat/{KU-id}

# 3. 派发任务（按路由策略选代理）
cd units/{level}/{KU-id}/
opencode run "$(cat /tmp/{KU-id}-task.txt)" 2>&1 | tee /tmp/{KU-id}-output.log

# 4. 验证交付物
bash ../../../../scripts/verify.sh units/{level}/{KU-id}/

# 5. 提交 + PR
git add -A && git commit -m "feat({KU-id}): ..."
git push origin feat/{KU-id}
gh pr create --base main --head feat/{KU-id} --title "..." --body "..."

# 6. 审阅 → 合并 → 更新 MASTER_PLAN
gh pr merge {PR#} --squash --delete-branch
```

### 8.2 故障排查

| 问题 | 排查命令 | 解决方案 |
|------|----------|----------|
| OpenCode 证书错误 | `opencode run "test"` | 检查系统时间/CA 证书 |
| CodeBuddy 无响应 | `codebuddy --version` | 检查登录态 |
| Codex 无 auth | `codex doctor` | 配 key 或 OmniRoute |
| gh 限流 | `gh api rate_limit` | 等 1 小时或降频 |
| git push 失败 | `gh auth status` | `gh auth refresh` |

---

## 九、扩展性

### 9.1 未来可接入的代理

| 工具 | 特点 | 接入方式 |
|------|------|----------|
| Claude Code | 最强 unattended PR | `claude -p "..."` |
| Gemini CLI | 1M 上下文 | `gemini -p "..."` |
| Aider | 本地模型友好 | `aider --message "..."` |
| Continue | VS Code 集成 | ACP 协议 |
| Kilo Code | 开源 | `kilo "..."` |

### 9.2 未来增强

- [ ] 引入 Kanban 看板（Hermes 内置）可视化任务状态
- [ ] 引入 Cron 定时任务自动派发
- [ ] 引入 Prometheus 监控代理健康度
- [ ] 引入成本追踪（token 消耗统计）

---

## 十、决策记录

### 2026-09-13
- 选择 OpenCode 作为主力（内置免费模型，LSP 集成）
- 选择 CodeBuddy 作为备选（腾讯生态，中文 UI）
- 选择 Codex 作为第三备选（需配置 OmniRoute 或 key）
- MiMo Code 已卸载（免费 API 不可用）
- 每个 KU 一个分支，不走 worktree（简化）
- 验证门自动化 + Hermes 人工审阅双层保障
