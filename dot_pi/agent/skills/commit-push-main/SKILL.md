---
name: commit-push-main
description: Use only when the user explicitly asks to commit the current repository and push it to the main branch. Reviews scope and staged content, runs relevant checks, synchronizes safely with origin/main, commits without bypassing hooks, and pushes without force.
---

# Commit and push to main

Commit the intended changes in the current Git repository and push them safely to `origin/main`.

## Activation boundary

Use this skill only after an explicit request to commit and push to `main`. A request to edit code, prepare a commit, show a diff, or open a merge request does not authorize a push.

## Non-negotiable safeguards

- Never use `--force`, `--force-with-lease`, `reset --hard`, `clean -fd`, `checkout -- .`, `restore .`, or another command that can discard work.
- Never bypass hooks with `--no-verify`.
- Never commit credentials, private keys, access tokens, `.env` files, registry auth files, generated secrets, or unrelated user changes.
- Never rewrite existing shared history. Rebase only a new local commit created during the current task, and only when the remote branch advanced after the initial fetch.
- Do not change branches while the worktree is dirty. If the current branch is not `main`, stop and ask before moving changes or pushing `HEAD:main`.
- Push only to the repository and branch the user named. This skill defaults to the existing `origin` remote and `main` branch.

## Workflow

### 1. Establish repository state

Run `git rev-parse --show-toplevel`, `git status --short --branch`, `git branch --show-current`, and `git remote -v`. Confirm the current branch is `main`, the `origin` remote is the intended destination, and all visible changes belong to the requested task.

Inspect `git diff --stat`, `git diff`, and untracked file names. Do not assume every dirty file should be committed. If unrelated changes exist, stage only explicit paths. If scope cannot be separated confidently, stop and ask one focused question.

### 2. Check for sensitive or accidental content

Review the staged file list and diff before committing. Pay special attention to `.env`, authentication files, private keys, kubeconfigs, registry configuration, large generated files, datasets, caches, build products, and editor state.

Use repository-aware secret scanning when available. At minimum, inspect `git diff --cached --name-status` and `git diff --cached` for credential material. A suspicious match must be investigated rather than automatically ignored or committed.

### 3. Synchronize before committing

Run `git fetch origin main`. Compare local and remote history with `git rev-list --left-right --count HEAD...origin/main`.

If local `main` is simply behind, attempt `git merge --ff-only origin/main` before staging. This must preserve the worktree; if Git refuses because local changes conflict, stop and report the blocker. If histories have diverged or local `main` already contains unexplained commits, stop rather than rewriting or force-pushing.

### 4. Run validation

Use the repository's own documented checks. Prefer existing scripts, task runners, lockfile checks, linters, tests, package builds, and configuration validation. Do not invent expensive integration tests that need unavailable infrastructure. Record any environmental validation that could not run.

Do not proceed after a failed relevant check unless the user explicitly accepts that failure.

### 5. Stage intentionally

Stage only the files belonging to the task. `git add -A` is acceptable only when the complete dirty worktree has been reviewed and all changes are in scope.

Review `git diff --cached --stat`, `git diff --cached --name-status`, and `git diff --cached`. Confirm renames are represented correctly and no generated artifacts or secrets are staged.

### 6. Commit

Choose a concise imperative commit message that describes the completed change. Use a user-supplied message when provided. Create one cohesive commit unless the user asks for a split history.

Run `git commit -m "<message>"` without bypassing hooks. If a hook changes files, review and stage those changes, rerun validation as needed, and commit normally.

### 7. Guard against a remote race

Fetch `origin/main` again after the commit. If `origin/main` is still an ancestor of `HEAD`, continue. If the remote advanced and the only local-only commit is the commit just created, rebase that commit onto `origin/main`, rerun affected checks, and continue only if the rebase is clean. Stop on conflicts or unexplained local history.

### 8. Push and verify

Run `git push origin HEAD:main`. Never add a force option.

Verify that the worktree is clean or contains only intentionally excluded changes. Compare `git rev-parse HEAD` with `git ls-remote origin refs/heads/main`. Report the commit hash, subject, remote branch, validation results, and any intentionally uncommitted files.

## Failure handling

Authentication failures, branch protection, rejected non-fast-forward pushes, failing hooks, conflicts, unavailable remotes, and failed validation are blockers. Leave the repository recoverable, state exactly what completed, and provide the smallest next action. Do not weaken safeguards to finish the push.
