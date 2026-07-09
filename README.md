# bash

Bash config + an AI commit-message generator.

- `.bashrc` — shell config; sources `.git_ai_commit.sh` by relative path.
- `.git_ai_commit.sh` — Tab-completion that inserts an AI-generated commit message.

## Install

```bash
git clone git@github.com:Pranjalkaushik/bash.git ~/bash
echo '[ -f ~/bash/.bashrc ] && source ~/bash/.bashrc' >> ~/.bashrc
source ~/.bashrc
```

## Usage

```bash
git commit -m "<TAB>
```

Inserts `[AMG-<ticket>] <description>` — ticket from the branch name, description from the staged diff.

## Requires

- `claude` CLI on `PATH` (falls back to `[AMG-<ticket>] updated <files>` if absent).
