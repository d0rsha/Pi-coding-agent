# Pi Home Assistant coding agent

An isolated Pi coding-agent environment for making reviewable changes to a source-controlled Home Assistant configuration repository.

The coding agent is deliberately separated from the running Home Assistant instance. Git branches, diffs and pull requests are the approval and rollback boundary.

## Security model

The default Compose service:

- runs as an unprivileged user;
- drops all Linux capabilities and enables `no-new-privileges`;
- uses a read-only container filesystem with limited tmpfs scratch space;
- does **not** mount the Docker socket;
- does **not** mount Home Assistant's live `/config`;
- refuses a workspace that looks like a live HA config directory (`.HA_VERSION` + `.storage`);
- keeps Pi state separate from the HA Git checkout;
- expects credentials to be injected at runtime, never committed.

See [AGENTS.md](AGENTS.md) for the rules the coding agent must follow.

## Prerequisites

- Docker with Compose
- a **separate Git checkout** of your Home Assistant configuration repository
- an API key for the model/provider you want Pi to use
- optionally a fine-grained GitHub token/GitHub App credential for push/PR creation

Do not use the live Home Assistant `/config` directory as `HA_REPO`.

## Quick start

```sh
cp .env.example .env
# Edit HA_REPO in .env so it points at a separate HA Git checkout.

docker compose build
docker compose run --rm pi-ha-agent
```

You can also run a one-shot command in the same sandbox:

```sh
docker compose run --rm pi-ha-agent pi-ha-validate
```

## Recommended task workflow

Inside the mounted HA repository:

```sh
git status --short
git switch -c agent/<task-name>
# Let Pi inspect/edit the requested files.
pi-ha-validate
git diff --check
git diff
git add <reviewed-files>
git commit -m "Describe the HA change"
git push -u origin HEAD
gh pr create
```

The agent must not merge its own PR.

## GitHub authentication

`gh` is installed in the container. Inject a narrowly scoped token at runtime, for example through your shell/secret manager as `GITHUB_TOKEN`. Do not put the real token in `.env.example`, Docker images, repository files, prompts, or logs.

For unattended use, prefer short-lived GitHub App credentials over a long-lived personal access token.

## Validation

`pi-ha-validate` currently performs checks that are safe inside the coding container:

- rejects tracked `secrets.yaml`, `SERVICE_ACCOUNT.JSON` and `.env`;
- detects merge-conflict markers;
- runs `yamllint` with HA-friendly settings;
- runs `git diff --check`;
- prints the working-tree status.

This is intentionally not presented as a complete Home Assistant configuration validation. Full HA validation should be added as a separate CI job or isolated validation service with dummy/template secrets. The coding-agent container should not receive the Docker socket merely to run that check.

## Project layout

```text
AGENTS.md                 Agent policy and safety rules
Dockerfile                Minimal Pi runtime
compose.yaml              Hardened container boundary
.env.example              Runtime configuration template
.yamllint                  HA-friendly YAML lint rules
scripts/entrypoint.sh      Live-config guard and Git setup
scripts/pi-ha-validate     Local validation pipeline
```

## Next steps

1. Test the image against a disposable clone of the real HA configuration repository.
2. Add isolated full Home Assistant configuration validation using dummy secrets.
3. Add a minimal GitHub App/token setup for branch push and PR creation.
4. Later, add narrowly scoped **read-only** Home Assistant/MCP awareness for entity/state debugging.
5. Later, expose the coding agent through Pi RPC/SDK for delegation from the runtime agent.
