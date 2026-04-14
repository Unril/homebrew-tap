# Unril Tap

Homebrew formulae for [klspw](https://github.com/Unril/klspw) -- a CLI tool that generates `workspace.json` for kotlin-lsp from Gradle builds.

## How do I install these formulae?

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

## Formula

`Formula/klspw.rb` defines a source build that doubles as the fallback when no bottle matches.

The source repo uses vcpkg for development builds, but the formula does not. It declares each dependency with `depends_on` and lets Homebrew provide them. All deps are in Homebrew core:

| Dependency | Role                                      |
| ---------- | ----------------------------------------- |
| cmake      | Build-time only                           |
| ninja      | Build-time only                           |
| cli11      | CLI parsing                               |
| fmt        | String formatting (indirect, via spdlog)  |
| glaze      | JSON/YAML serialization                   |
| reproc     | Subprocess execution (reproc++)           |
| spdlog     | Logging                                   |
| gcc        | Linux only, GCC 15 for C++23 support      |

`doctest` (testing) is not needed because `std_cmake_args` passes `-DBUILD_TESTING=OFF`.

The formula runs a plain CMake build without presets:

```ruby
system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args
system "cmake", "--build", "build"
system "cmake", "--install", "build"
```

`std_cmake_args` provides `-DCMAKE_INSTALL_PREFIX`, `-DCMAKE_BUILD_TYPE=Release`, `-DBUILD_TESTING=OFF`, and other standard flags. CMake finds Homebrew-installed packages via `CMAKE_PREFIX_PATH` set by Homebrew's superenv.

The `sha256` is `TODO_REPLACE_WITH_ACTUAL_SHA256` until the v0.1.0 tag is pushed on the source repo.

## Workflows

### tests.yml (brew test-bot)

Runs on every push to `main`, on PRs, and on manual dispatch. Builds and tests the formula on three platforms:

| Runner           | Platform                              |
| ---------------- | ------------------------------------- |
| `macos-26-intel` | macOS Intel (x86_64)                  |
| `macos-26`       | macOS Apple Silicon (arm64)           |
| `ubuntu-latest`  | Linux (via Homebrew Docker container) |

`macos-26` runners are required (not `macos-15`) because klspw uses C++23 features (`std::ranges::to`) that need the libc++ shipping with Xcode 26. Xcode 16.x on `macos-15` does not include `std::ranges::to`.

On PRs, the workflow builds bottles and uploads them as GitHub Actions artifacts. On pushes to `main`, it only runs syntax and setup checks (no bottle build).

### publish.yml (brew pr-pull)

Triggers when a PR is labeled `pr-pull`. It downloads the bottle artifacts built by `tests.yml`, adds the `bottle do ... end` block to the formula, and pushes to `main`. Bottles are uploaded to the tap repo's GitHub Releases.

This workflow does not support `workflow_dispatch` because `brew pr-pull` requires the `github.event.pull_request` context (PR number, head ref) which is only available from the `pull_request_target` event.

## Release flow

Updates must go through a PR, not a direct push to `main`. The bottle build pipeline depends on this:

- `tests.yml` only builds bottles on `pull_request` events (the `--only-formulae` and upload steps are skipped on pushes to `main`)
- `publish.yml` needs a PR to label with `pr-pull` so `brew pr-pull` can download bottle artifacts and commit the `bottle do` block

Pushing directly to `main` would produce a working source-build formula but no bottles, forcing every user to compile from source.

### Initial release

1. Push the `v0.1.0` tag on [Unril/klspw](https://github.com/Unril/klspw) (the existing `release.yml` creates a GitHub Release)
2. Get the source tarball sha256:

   ```bash
   curl -sL https://github.com/Unril/klspw/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256
   ```

3. Create a branch on this tap repo:

   ```bash
   git checkout -b klspw-0.1.0
   ```

4. Replace `TODO_REPLACE_WITH_ACTUAL_SHA256` in `Formula/klspw.rb` with the actual sha256
5. Optionally test the source build locally:

   ```bash
   HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source Unril/tap/klspw
   brew test klspw
   brew audit --strict Unril/tap/klspw
   ```

6. Commit, push, and open a PR
7. Wait for `tests.yml` to build bottles (all three platforms must pass)
8. Label the PR `pr-pull`
9. `publish.yml` runs `brew pr-pull`, which adds the `bottle do` block to the formula and pushes to `main`

### Updating to a new version

1. Update version in `CMakeLists.txt` and `vcpkg.json` in the source repo
2. Tag and push:

   ```bash
   git tag v0.2.0 && git push origin v0.2.0
   ```

3. Get the new sha256:

   ```bash
   curl -sL https://github.com/Unril/klspw/archive/refs/tags/v0.2.0.tar.gz | shasum -a 256
   ```

4. Create a branch on this tap repo:

   ```bash
   git checkout -b klspw-0.2.0
   ```

5. Update `url` and `sha256` in `Formula/klspw.rb`, remove any existing `bottle do` block
6. Commit, push, and open a PR
7. Wait for `tests.yml` to build bottles
8. Label the PR `pr-pull` to publish

## Documentation

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) -- formula structure, `std_cmake_args`, testing, auditing
- [Bottles](https://docs.brew.sh/Bottles) -- bottle format, `bottle do` DSL, creation and usage
- [Taps](https://docs.brew.sh/Taps) -- tap naming, installation, `brew tap-new`
- [How to Create and Maintain a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap) -- tap creation, workflows, best practices
- [BrewTestBot](https://docs.brew.sh/BrewTestBot) -- CI testing and bottle building
- [GitHub Actions runner images](https://github.com/actions/runner-images) -- available runners, installed software
