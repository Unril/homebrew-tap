# Unril Tap

[![CI](https://github.com/Unril/homebrew-tap/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Unril/homebrew-tap/actions/workflows/ci.yml)
[![Publish](https://github.com/Unril/homebrew-tap/actions/workflows/publish.yml/badge.svg?branch=main)](https://github.com/Unril/homebrew-tap/actions/workflows/publish.yml)
[![Verify](https://github.com/Unril/homebrew-tap/actions/workflows/verify.yml/badge.svg?branch=main)](https://github.com/Unril/homebrew-tap/actions/workflows/verify.yml)
[![Release](https://img.shields.io/github/v/release/Unril/homebrew-tap?sort=semver)](https://github.com/Unril/homebrew-tap/releases)

Homebrew formula for [klspw](https://github.com/Unril/klspw) -- a CLI tool that generates `workspace.json` for kotlin-lsp from Gradle builds.

## Install

```bash
brew install Unril/tap/klspw
```

Or `brew tap Unril/tap` and then `brew install klspw`.

Or, in a `brew bundle` `Brewfile`:

```ruby
tap "Unril/tap"
brew "klspw"
```

## How it works

Prebuilt binaries by default, source build as fallback. Homebrew bottles handle this: if a matching bottle exists for the user's platform, `brew install` downloads the binary; otherwise it builds from source. Users can force source with `--build-from-source`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for formula details, workflow documentation, and release instructions.
