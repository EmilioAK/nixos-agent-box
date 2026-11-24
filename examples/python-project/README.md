# Example Python project

Copy this directory's files into a new project, including `.envrc` and `.gitignore`. Its flake pins Python 3.13 and uv. From the checkout, run `direnv allow`, then `uv init --bare` and `uv sync` for a new project. If the project already has a `uv.lock`, use `uv sync --locked`.

To run the example PostgreSQL 17 and Redis 7.4 services, use a fresh env file for the checkout. Give its private file a name unique to the project or worktree.

```sh
(
  set -eu
  umask 077
  set -C
  mkdir -p "$HOME/.agents/secrets"
  env_file="$HOME/.agents/secrets/my-project-local.env"
  sed "s/^POSTGRES_PASSWORD=$/POSTGRES_PASSWORD=$(openssl rand -hex 24)/" .env.example > "$env_file"
  ln -s "$env_file" .env
)
docker compose up -d --wait
```

PostgreSQL listens on `127.0.0.1:15432` with database and user `app`. Redis listens on `127.0.0.1:16379`. Give concurrent stacks distinct Compose project names and host ports using `.env`. From other containers in the same Compose project, use `postgres:5432` and `redis:6379`.

`docker compose down` keeps the named volumes. The same Compose project name reuses them when you start the stack again. `docker compose down -v` deletes the volumes and their data.
