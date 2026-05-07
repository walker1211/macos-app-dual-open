# Security Policy

## Reporting a vulnerability

Please do not publish vulnerability details, exploit steps, tokens, credentials, private local application paths, private app bundle paths, logs, screenshots, shell output, or other sensitive local data in a public issue, pull request, discussion, or commit.

This project does not currently publish a dedicated security email address. If you need to report a security issue, use GitHub's private vulnerability reporting for this repository if it is available from the repository Security tab.

If private vulnerability reporting is unavailable, open a minimal public GitHub issue so a maintainer can arrange private follow-up. Keep the public issue limited to:

* The affected area at a high level.
* A statement that you can share details privately with a maintainer.
* No secrets, private local paths, private app bundle paths, logs, screenshots, shell output, temporary files, or generated local artifacts.
* No step-by-step exploit instructions or weaponized proof-of-concept details.

## Supported scope

Security fixes are generally handled for the current `main` branch and the latest released version when releases are available. Older unreleased snapshots or local forks may not receive separate fixes.

## Project security boundaries

`macos-app-dual-open` is a local macOS Bash tool for creating, updating, launching, and removing secondary copies of app bundles. It works with local `.app` paths, uses macOS command-line tools, and may operate on paths that reveal private application names, local directory layouts, or user-specific workflows.

Important boundaries and assumptions:

* The tool is intended for local use on macOS and is not a network service.
* The source app bundle should remain untouched; the tool operates on a derived `-secondary.app` copy.
* The tool should not delete `~/Library`, Keychain, or other user data as part of normal `remove` or `update` flows.
* Do not commit private local application paths, private app bundle paths, logs, screenshots, shell output, temporary files, or generated local artifacts.
* Treat command examples, reproduction steps, screenshots, and logs as potentially private because they can reveal local paths, installed apps, account names, or workspace structure.
* Review any issue, pull request, log excerpt, screenshot, or shell output for sensitive data before publishing it.

## Secret and local data handling

Before contributing, run local checks and review the diff for sensitive data when possible:

```bash
bash -n ./bin/app-dual ./lib/*.sh
bash ./tests/run.sh
```

If you accidentally commit or publish a secret or private local data, rotate or revoke any exposed credentials immediately and remove the sensitive details from public places. Removing it from a later commit is not enough once it has been exposed.
