---
name: plan-mode
description: Use when the user asks for a plan, implementation plan, migration plan, refactor plan, or says to enter plan mode, especially when they want the repository investigated before any changes are made. Produces an evidence-based, executable plan without modifying the project.
---

# Plan Mode

Investigate first, then produce a concrete implementation plan. Do not modify the repository while this skill is active.

## Core Rules

- Treat the task as read-only. Do not create, edit, delete, move, format, or generate project files.
- Do not run commands that install dependencies, update lockfiles, apply infrastructure, alter services, mutate databases, or otherwise change local or remote state.
- Read relevant code, configuration, tests, documentation, and version-control history before planning.
- Base the plan on the repository as it exists. Do not invent files, APIs, symbols, or architecture.
- Resolve non-blocking uncertainty through investigation. Ask at most one focused question only when a product decision or missing requirement materially changes the plan.
- Do not begin implementation unless the user explicitly exits plan mode or asks you to execute the plan.

## Investigation Workflow

### 1. Establish scope

Restate the requested outcome internally. Identify the likely subsystems, constraints, compatibility requirements, and success criteria.

### 2. Map the repository

Inspect the project structure and locate relevant entry points, configuration, domain logic, interfaces, tests, scripts, and documentation. Prefer targeted searches over reading the entire repository.

### 3. Trace current behavior

Follow the execution or data flow from entry point to side effects. Identify the exact files and symbols responsible for the behavior. Check callers, consumers, shared types, and error handling.

### 4. Check conventions and history

Look for nearby implementations that establish naming, architecture, test style, configuration patterns, and deployment practices. Use version-control history when it helps explain why the current design exists.

### 5. Identify impact and risk

Determine affected interfaces, persisted data, backwards compatibility, security boundaries, operational concerns, rollout needs, and likely regression areas.

### 6. Design the change

Choose one recommended approach that fits existing patterns. Mention alternatives only when they involve a meaningful tradeoff the user may need to decide.

## Read-Only Tooling

Safe operations generally include listing files, reading files, searching text, inspecting metadata, viewing diffs, and querying version-control history. Before running a command, confirm that it cannot mutate project or external state.

Avoid commands with side effects, including package installation, code generation, auto-fixing, formatting, migrations, deployments, infrastructure application, service restarts, commits, pushes, and destructive version-control operations.

Tests, builds, and linters may create caches or generated output. Do not run them in plan mode unless the user explicitly permits it and the side effects are understood.

## Plan Quality Standard

The final plan must be specific enough for another engineer to implement without repeating the investigation. Each implementation step should include:

- the file path or component to change;
- the relevant symbol, section, or configuration key;
- the intended logic or structural change;
- important dependencies or ordering constraints;
- the tests or validation that prove the step works.

Prefer cohesive implementation steps over a list of tiny edits. Order steps by dependency and execution sequence. Distinguish confirmed repository facts from assumptions.

## Final Response Format

Use this structure unless the user requests another format:

### Summary

Briefly state the recommended approach and the main areas affected.

### Implementation plan

Provide a numbered sequence of actionable steps. Include exact paths and symbols where available.

### Validation

Describe targeted automated tests, integration checks, and any manual verification. Include rollback or deployment checks when relevant.

### Risks and open questions

List only material risks, assumptions, or decisions that remain unresolved. Omit this section when there are none.

End after the plan. Do not offer to start implementation unless the user asks.
