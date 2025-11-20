# Repository Standards & Config Files Plan

This plan outlines the addition of repository standards and configuration files based on the bun-fork repository structure.

## Config Files to Add/Update

### 1. EditorConfig (`.editorconfig`)

- Purpose: Ensure consistent coding standards across different editors
- Standard: UTF-8, LF line endings, trim trailing whitespace, insert final newline
- Priority: High

### 2. Cursor Ignore (`.cursorignore`)

- Purpose: Exclude files from Cursor IDE indexing
- Should exclude: test fixtures, build artifacts, vendor files
- Priority: Medium

### 3. Prettier Configuration Update (`.prettierrc`)

- Current: 80 width, basic settings
- Update to match bun-fork: 120 width (80 for markdown), arrowParens "avoid", trailingComma "all"
- Priority: High

### 4. Prettier Ignore (`.prettierignore`)

- Purpose: Exclude files from Prettier formatting
- Should exclude: test snapshots, generated files, lock files
- Priority: Medium

### 5. Git Ignore Update (`.gitignore`)

- Current: Basic ignore patterns
- Add: More comprehensive patterns from bun-fork (OS files, build artifacts, temporary files)
- Priority: Medium

### 6. Typos Configuration (`.typos.toml`)

- Purpose: Spell checking configuration
- Standard: Basic config for English (en-US)
- Priority: Low

### 7. CodeRabbit Configuration (`.coderabbit.yaml`)

- Purpose: AI code review integration
- Configure: ShellCheck enabled, markdownlint enabled, simplified for shell script project
- Priority: Low (optional)

### 8. Package.json Scripts Update

- Current: Basic scripts
- Update: Align naming conventions (fmt instead of format, lint/format consistency)
- Priority: Medium

## Implementation Details

### EditorConfig

```ini
root = true

[*]
charset = utf-8
insert_final_newline = true
trim_trailing_whitespace = true
end_of_line = lf

[*.{zsh,sh,bash}]
indent_style = space
indent_size = 2

[*.md]
max_line_length = 80
```

### Cursor Ignore

```
tests/
*.tmp
*.log
.bats
```

### Prettier RC Update

- Change printWidth from 80 to 120
- Add arrowParens: "avoid"
- Keep markdown at 80 width
- Add trailingComma: "all"

### Prettier Ignore

```
tests/
bun.lockb
*.min.js
```

### Git Ignore Additions

- OS-specific files (.DS_Store, Thumbs.db)
- Editor files (.idea, .vscode/settings.json)
- Build/test artifacts
- Lock files (bun.lockb already there)

### Typos Config

- Basic English spell checking
- Ignore technical terms (zsh, GPG, 1Password, etc.)

### CodeRabbit Config

- Enable ShellCheck
- Enable markdownlint
- Disable TypeScript/JavaScript tools
- Configure for shell script project

## Files to Create/Update

1. ✅ `.editorconfig` - NEW
2. ✅ `.cursorignore` - NEW
3. ⚙️ `.prettierrc` - UPDATE
4. ✅ `.prettierignore` - NEW
5. ⚙️ `.gitignore` - UPDATE
6. ✅ `.typos.toml` - NEW
7. ✅ `.coderabbit.yaml` - NEW (optional)
8. ⚙️ `package.json` - UPDATE scripts

## Priority Order

1. EditorConfig (ensures consistency)
2. Prettier config update (affects all formatted files)
3. Git ignore update (cleaner repository)
4. Cursor ignore (better IDE performance)
5. Prettier ignore (faster formatting)
6. Package.json scripts (better workflow)
7. Typos config (nice to have)
8. CodeRabbit config (optional tool)

## Testing After Changes

- Verify Prettier still formats correctly
- Test that EditorConfig is respected
- Ensure git ignore patterns work
- Verify package.json scripts run correctly
