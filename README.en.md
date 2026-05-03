# macos-app-dual-open

A small Bash CLI for creating and managing `secondary` copies of macOS apps.

[Landing Page](./README.md) | [中文](./README.zh-CN.md)

## Features

- Create a `-secondary.app` copy from an original `.app`
- Read the original `CFBundleIdentifier` and rewrite it with a `.secondary` suffix
- Re-sign the copied app locally
- Provide a unified `clone / launch / update / remove` CLI
- Keep the source app untouched and avoid deleting user `~/Library` data by default

## Quick Start

```bash
bin/app-dual clone "/Applications/WeChat.app"
bin/app-dual launch "/Applications/WeChat.app"
bin/app-dual update "/Applications/WeChat.app"
bin/app-dual remove "/Applications/WeChat.app"
```

For apps under `/Applications`, typical macOS usage requires `sudo` for `clone`, `update`, and `remove`:

```bash
sudo bin/app-dual clone "/Applications/WeChat.app"
sudo bin/app-dual update "/Applications/WeChat.app"
sudo bin/app-dual remove "/Applications/WeChat.app"
```

## Naming Rules

Given:

```text
/Applications/WeChat.app
com.tencent.xinWeChat
```

The derived secondary copy becomes:

```text
/Applications/WeChat-secondary.app
com.tencent.xinWeChat.secondary
```

Rules:

- the copied app name always appends `-secondary`
- the copied Bundle ID always appends `.secondary`
- `clone`, `update`, and `remove` expect the original `.app` path and reject an existing `-secondary.app` as the source input

## Commands

### `bin/app-dual clone <app-path>`

- validate the original app path
- copy the app bundle to `-secondary.app`
- rewrite the copied `CFBundleIdentifier`
- re-sign the copied app

Example:

```bash
sudo bin/app-dual clone "/Applications/WeChat.app"
```

### `bin/app-dual launch <app-path>`

- derive the `-secondary.app` path from the original app path
- launch the secondary app through `open -a`
- keep path-first behavior: if the secondary copy exists, launch can still work even when the original app path does not currently exist

Example:

```bash
bin/app-dual launch "/Applications/WeChat.app"
```

### `bin/app-dual update <app-path>`

- remove the old secondary copy
- rebuild the secondary copy from the original app
- keep user data directories untouched; do not clean `~/Library`

Example:

```bash
sudo bin/app-dual update "/Applications/WeChat.app"
```

### `bin/app-dual remove <app-path>`

- remove the derived `-secondary.app`
- do not remove `~/Library`, Keychain, or other user data

Example:

```bash
sudo bin/app-dual remove "/Applications/WeChat.app"
```

## Behavior Notes

- `clone` creates a new secondary app copy
- `launch` behaves similarly to manually opening `WeChat-secondary.app`
- `update` rebuilds the secondary app by removing the old secondary app (if it exists) and recreating it
- `remove` deletes only the copied app bundle and does not affect the source app

## Safety Boundaries

- the source app bundle is never modified
- the source app `Info.plist` is never modified
- the source app signature is never modified
- the tool never deletes `~/Library`, Keychain, or other user data
- not every macOS app can run as a second instance

## Development / Testing

Run the tests with:

```bash
bash tests/run.sh
```

Current automated coverage includes:

- shared path and naming helpers
- `clone` behavior and copied Bundle ID rewriting
- `launch` behavior and the path-first contract
- `update` / `remove` behavior
- the safety guarantee that the source app is not modified

## License

See [LICENSE](./LICENSE).
