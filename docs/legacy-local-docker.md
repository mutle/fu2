# Legacy Red Cursor Docker reference

This stack runs the pinned legacy Red Cursor image with isolated PostgreSQL 13
and Redis services. Only the web UI is published, on the IPv4 loopback
interface. PostgreSQL and Redis are reachable only on the internal Compose
network.

Production backups remain outside the repository. The setup script creates an
ignored `.env`, an ignored decompressed Redis RDB, and an ignored PostgreSQL
restore log. Never commit any of those files.

## Prerequisites

- Docker with Compose v2
- `bash`, `bzip2`, `curl`, and `openssl`
- Local readable copies of the PostgreSQL plain SQL backup and Redis RDB backup

The application image is pinned by digest and currently targets `linux/amd64`.
Docker Desktop can run it under emulation on Apple silicon.

## Restore and run

```sh
script/legacy-stack setup
```

Edit `docker/legacy/.env` if the backup locations or port differ, then run:

```sh
script/legacy-stack restore
script/legacy-stack start
```

Open <http://127.0.0.1:3080/session/new>, or the port selected in `.env`.
Re-running `restore` deletes only this Compose project's isolated database
volume and ignored Redis working copy before restoring both backups again.
The original compressed backups are only read.

The PostgreSQL dump contains compatibility helper functions from an older
application era, including many `concat_ws` overloads. PostgreSQL 13 already
provides some equivalent built-ins, so restore errors for those obsolete
definitions are tolerated by `psql`; the complete output is retained only in
the ignored `.local/postgres-restore.log`. Restore success is determined from
non-empty aggregate table, user, and Redis key counts, without printing data.

Elasticsearch is intentionally omitted. Rails boot only constructs its client;
normal page rendering does not connect to it. Legacy advanced search and
background index jobs remain unavailable unless an Elasticsearch version
compatible with the old Elastomer client and mappings is added separately.

Do not set `REDIS_DB` for the web service. The legacy initializer has an
operator-precedence bug that treats any configured value as the test database
(DB 7). Leaving it unset correctly selects the production data in DB 6.

## Health, testing, and cleanup

```sh
script/legacy-stack health
script/legacy-stack stop
script/legacy-stack clean
```

`health` checks Compose health and requests the login page without submitting
credentials. `stop` preserves restored state. `clean` removes this stack's
PostgreSQL volume and ignored generated files.

Useful stable routes for later Playwright or screenshot comparisons include:

- `/session/new` for anonymous login rendering
- `/` after login for the channel list and recent activity
- `/channels/:id` for a representative thread
- `/users/:id` for a user profile
- `/notifications` for notification behavior
- `/api/info` and `/api/users/current` for authenticated API shape checks

Use a locally known test account if one exists. Do not put credentials in
scripts, screenshots, committed fixtures, logs, or documentation.

## Image-to-repository runtime differences

The pinned image contains an older Git checkout plus uncommitted deployment
patches. The meaningful differences are:

- Ruby 2.3.0, Bundler 1.11.2, vendored gems, precompiled assets, and Unicorn
  scripts/configuration are baked into the image.
- Production database configuration is environment-driven and supports
  PostgreSQL; this stack replaces it with a local environment-only config.
- Production can serve static assets and log to stdout when environment flags
  are set.
- StatsD/Trashed metrics were removed for the container deployment.
- Websocket metrics were removed; websocket startup remains opt-in and is
  disabled in this local reference stack.
- Small application fixes restrict allowed accounts, preserve the last-post
  user, improve X/Twitter embeds, and reject bad embed API responses.
- Runtime upload URL rewrites changed over time; they are unrelated to local
  boot and are not copied into the repository.

The Compose setup deliberately uses the pinned image rather than copying its
vendored gems, generated assets, runtime configuration, or data into Git.
