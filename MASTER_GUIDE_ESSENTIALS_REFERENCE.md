# MASTER GUIDE REFERENCE

**⚠️ IMPORTANT: Project-Level Documentation Reference**

---

## 🚨 STOP: Read the Shared Documentation

This project is part of the **asafebgi organization** and follows the shared agent workflow documented in:

**📖 Shared Documentation Wiki:**
https://github.com/a5af/shared-docs/wiki/guides-Master-Guide-Agent-Essentials

**📄 Local Copy:**
```
/d/Code/shared-docs/_docs/MASTER_GUIDE_AGENT_ESSENTIALS.md
```

---

## Current Architecture (2025-10-18)

### Project Structure

This project is located in:
```
/d/Code/projects/cc.asaf.PhraseCraft.xrnx/
```

### Worktree Structure

Each agent works in their own worktree:
```
/d/Code/projects/cc.asaf.PhraseCraft.xrnx/
├── .git/                  # Shared git repository
└── worktrees/             # Agent worktrees
    ├── agentx/
    ├── agent1/
    ├── agent2/
    ├── agent3/
    ├── agent4/
    └── agent5/
```

### Agent Workspaces

Agents access projects via symlinked workspaces:
```
/d/Code/agent-workspaces/agent1/
├── pulse -> /d/Code/projects/pulse/worktrees/agent1
├── askbase -> /d/Code/projects/askbase/worktrees/agent1
└── (other projects...)
```

---

## Why This Matters

The shared documentation contains:

✅ **Complete agent startup procedures**
✅ **Security requirements and rules**
✅ **Engineering principles**
✅ **GitHub workflow and PR requirements**
✅ **Authentication and credential management**
✅ **Troubleshooting guides**

**This project follows the organization-wide agent workflow.**

---

## Navigation

### To Read the Master Guide

```bash
# View online (always up-to-date):
# https://github.com/a5af/shared-docs/wiki/guides-Master-Guide-Agent-Essentials

# Or read local copy:
cat /d/Code/shared-docs/_docs/MASTER_GUIDE_AGENT_ESSENTIALS.md
```

### To Navigate to Your Worktree

```bash
# Example for Agent1 working on this project:
cd /d/Code/projects/cc.asaf.PhraseCraft.xrnx/worktrees/agent1

# Or via agent workspace:
cd /d/Code/agent-workspaces/agent1/cc.asaf.PhraseCraft.xrnx
```

---

## Quick Context Check

**Which worktree am I in?**
```bash
pwd
basename $(pwd)  # Should show: agentx, agent1, agent2, etc.
```

**What project am I working on?**
```bash
basename $(dirname $(dirname $(pwd)))
# Or just look at the parent directory name
```

---

## What This File Is NOT

❌ This is NOT a replacement for the master guide
❌ This is NOT comprehensive documentation
❌ This is NOT the complete agent workflow guide

**This is simply a pointer** to help you find the shared documentation.

---

## Project-Specific Documentation

For **cc.asaf.PhraseCraft.xrnx**-specific documentation (architecture, setup, API docs), see:
- `README.md` (this repository)
- `docs/` directory (if exists)
- Project-specific guides in this repo

For **agent workflow, security rules, and startup procedures**, always refer to:
- **Wiki:** https://github.com/a5af/shared-docs/wiki/guides-Master-Guide-Agent-Essentials
- **Local:** `/d/Code/shared-docs/_docs/MASTER_GUIDE_AGENT_ESSENTIALS.md`

---

## Key Documentation Links

**Main Wiki:** https://github.com/a5af/shared-docs/wiki

**Essential Guides:**
- [MASTER GUIDE v2.0](https://github.com/a5af/shared-docs/wiki/guides-Master-Guide-Agent-Essentials) - Complete startup procedure
- [Architecture Overview](https://github.com/a5af/shared-docs/wiki/architecture-Overview) - System architecture
- [Agent Engineering Principles](https://github.com/a5af/shared-docs/wiki/guides-Agent-Engineering-Principles)
- [GitHub Credentials](https://github.com/a5af/shared-docs/wiki/guides-Agent-GitHub-Credentials)
- [Security Hooks](https://github.com/a5af/shared-docs/wiki/guides-Security-Hooks)

---

**Remember:** Always refer to the shared documentation wiki for the most up-to-date agent workflow information.

**Last Updated:** 2025-10-19
