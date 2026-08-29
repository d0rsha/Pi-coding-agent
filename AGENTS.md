# Home Assistant coding-agent policy

## Mission
Work only on source-controlled Home Assistant configuration/code in the mounted workspace. Produce small, reviewable, validated changes for a human to approve.

## Hard safety boundaries
- Never edit or mount the live Home Assistant `/config` directory.
- Never request or use the Docker socket, host root, privileged mode, or unrestricted host filesystem access.
- Never read, modify, print, copy, or commit `secrets.yaml`, service-account JSON, private keys, tokens, passwords, or credentials.
- Use `secrets-template.yaml`, fixtures, or dummy values when validation needs secret keys to exist.
- Never deploy, restart, reload, or call Home Assistant services unless the user explicitly authorizes a future integration designed for that purpose.
- Never merge your own pull request or push directly to the protected/default branch.
- Treat future Home Assistant/MCP access as read-only unless the architecture is explicitly changed and reviewed.

## Editing rules
- Inspect relevant files before editing.
- Prefer existing entity IDs and repository conventions.
- Preserve Home Assistant automation IDs.
- Do not delete automations, scripts, entities, or configuration unless explicitly requested.
- Avoid unrelated formatting or refactors.
- Keep secrets referenced through `!secret`; never replace them with literal values.
- Do not add credentials to `.env`, examples, logs, tests, commits, or PR descriptions.

## Git workflow
1. Start from a clean working tree.
2. Create/use a task-specific branch; never work directly on the default branch.
3. Make the smallest change that satisfies the request.
4. Run `pi-ha-validate` before considering the task complete.
5. Inspect `git diff --check` and the complete final diff.
6. Summarize changed files, validation results, assumptions, and remaining risks.
7. Commit only after the diff has been reviewed.
8. Opening a PR is allowed when credentials are provided; merging is not.

## Validation
Run:

```sh
pi-ha-validate
```

The local validator performs repository-safe checks available inside the agent container. A full Home Assistant configuration check should run in CI or another isolated validation environment that does not expose the live HA instance or Docker socket to the coding agent.

If validation cannot run because repository-specific dependencies or dummy secrets are missing, report that clearly instead of claiming success.

## Completion format
Before finishing, provide:
- what changed and why;
- commands/checks run and whether they passed;
- `git status --short`;
- a concise final diff review;
- any validation that still requires CI/human review.
