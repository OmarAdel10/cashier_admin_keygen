# Development Environment

## Git Workflow
- Branch: `development` (primary)
- No new branches without explicit approval
- All commits drafted for review before `git commit`

## Commit Format
```
<emoji> <type>(<scope>): <summary under 50 chars>

* Bullet list of functional implementations
* Architectural impacts or state engine changes

WARNINGS (include ONLY if secrets, console logs, or outstanding TODOs)
```

### Legend
- 🐣 feat, 🐞 fix, 📄 docs, 🎨 style, ✏️ refactor, ⚡ perf, 🏗️ chore

### Rules
- Subject line: under 50 absolute characters, imperative mood
- No double quotes (`"`) in commit payload — single quotes only
