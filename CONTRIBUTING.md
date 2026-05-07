# Contributing

Thanks for helping improve `macos-app-dual-open`.

## Development environment

Use macOS with Bash available. Keep changes portable across the shell scripts already used by the project.

## Local configuration

Keep local application paths, private app bundles, logs, temporary files, and generated local artifacts out of git unless they are intentionally documented as generic examples.

## Run

```bash
./bin/app-dual --help
```

## Tests

Run syntax checks and the repository test suite before submitting a pull request:

```bash
bash -n ./bin/app-dual ./lib/*.sh
bash ./tests/run.sh
```

## Pull requests

Keep pull requests focused. Include what changed, why it changed, and the verification commands you ran.

## Commit messages

Use Conventional Commits, for example `fix: 修复应用打开判断` or `docs: 更新安装说明`.

## Releases

Maintainers handle release packaging and tags. Do not publish release tags from pull request branches.
