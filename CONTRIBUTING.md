# Contributing

## Formula

`Formula/klspw.rb` defines a source build that doubles as the fallback when no bottle matches.

The source repo uses vcpkg for development builds, but the formula does not. It declares each dependency with `depends_on` and lets Homebrew provide them. All deps are in Homebrew core:

| Dependency | Role                                     |
| ---------- | ---------------------------------------- |
| cmake      | Build-time only                          |
| ninja      | Build-time only                          |
| cli11      | CLI parsing                              |
| fmt        | String formatting (indirect, via spdlog) |
| glaze      | JSON/YAML serialization                  |
| reproc     | Subprocess execution (reproc++)          |
| spdlog     | Logging                                  |
| gcc        | Linux only, GCC 15 for C++23 support     |

`doctest` (testing) is not needed because `std_cmake_args` passes `-DBUILD_TESTING=OFF`.

The formula runs a plain CMake build without presets:

```ruby
system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args
system "cmake", "--build", "build"
system "cmake", "--install", "build"
```

`std_cmake_args` provides `-DCMAKE_INSTALL_PREFIX`, `-DCMAKE_BUILD_TYPE=Release`, `-DBUILD_TESTING=OFF`, and other standard flags. CMake finds Homebrew-installed packages via `CMAKE_PREFIX_PATH` set by Homebrew's superenv.

## Formatting

```bash
just format
```

Runs `prettier` on YAML and markdown, `rufo` on Ruby formula files.

## Workflows

### ci.yml (CI)

Runs on PRs, pushes to `main` (when formula or workflow files change), and manual dispatch. Builds and tests the formula on two platforms:

| Runner          | Platform                              |
| --------------- | ------------------------------------- |
| `macos-26`      | macOS Apple Silicon (arm64)           |
| `ubuntu-latest` | Linux (via Homebrew Docker container) |

macOS Intel (`macos-26-intel`) is not included: Homebrew is phasing out Intel support (Tier 3 from Sep 2026) and homebrew-core no longer guarantees Intel bottles for all dependencies. Intel users can still build from source.

`macos-26` runners are required (not `macos-15`) because klspw uses C++23 features (`std::ranges::to`) that need the libc++ shipping with Xcode 26. Xcode 16.x on `macos-15` does not include `std::ranges::to`.

On PRs, the workflow builds bottles and uploads them as GitHub Actions artifacts. On pushes to `main`, it only runs syntax and setup checks (no bottle build). Path filters skip CI for README-only or docs-only changes. `fail-fast: false` ensures both platforms complete even if one fails.

### publish.yml (Publish)

Triggers automatically via `workflow_run` when CI completes successfully on a PR. Also supports manual dispatch with a PR number for retries. It extracts the PR number, checks whether the PR actually changed formula files (skips workflow-only PRs), then runs `brew pr-pull` to download bottle artifacts, adds the `bottle do` block to the formula, pushes to `main`, and uploads bottles to GitHub Releases. A concurrency lock prevents parallel publish runs from racing.

### verify.yml (Verify)

Triggers automatically via `workflow_run` when Publish completes successfully. Also supports manual dispatch for on-demand verification. Installs klspw from the tap on both platforms and runs basic smoke tests to confirm the bottle poured correctly and the binary works. `fail-fast: false` ensures both platforms report independently.

## Release flow

The source repo (`Unril/klspw`) has an `update-tap.yml` workflow that automates tap updates. When a release is published in the source repo, it computes the tarball sha256, updates the formula, and opens a PR on this tap repo automatically.

The automated flow:

1. Tag and push in the source repo: `git tag v0.2.0 && git push origin v0.2.0`
2. Source repo `release.yml` creates a GitHub Release
3. Source repo `update-tap.yml` opens a PR on this tap with the updated formula
4. Tap CI builds bottles automatically
5. On success, Publish runs `brew pr-pull` automatically
6. Verify confirms the install works on both platforms

### Manual release (fallback)

If the automated flow fails or you need to update the formula manually:

1. Get the new sha256:

   ```bash
   curl -sL https://github.com/Unril/klspw/archive/refs/tags/v0.2.0.tar.gz | shasum -a 256
   ```

2. Create a branch on this tap repo:

   ```bash
   git checkout -b klspw-0.2.0
   ```

3. Update `url` and `sha256` in `Formula/klspw.rb`, remove any existing `bottle do` block
4. Commit, push, and open a PR
5. CI builds bottles automatically
6. On success, Publish runs `brew pr-pull` automatically

## Documentation

- [Formula Cookbook](https://docs.brew.sh/Formula-Cookbook) -- formula structure, `std_cmake_args`, testing, auditing
- [Bottles](https://docs.brew.sh/Bottles) -- bottle format, `bottle do` DSL, creation and usage
- [Taps](https://docs.brew.sh/Taps) -- tap naming, installation, `brew tap-new`
- [How to Create and Maintain a Tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap) -- tap creation, workflows, best practices
- [BrewTestBot](https://docs.brew.sh/BrewTestBot) -- CI testing and bottle building
- [GitHub Actions runner images](https://github.com/actions/runner-images) -- available runners, installed software
