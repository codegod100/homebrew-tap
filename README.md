# codegod100/tap

Homebrew tap for `codegod100` formulae.

```
brew tap codegod100/tap
brew install sleek
brew install claude-desktop
brew install buildbuddy-cli
```

`sleek` here is the [freeq](https://tangled.org/nandi.uk/sleek) mobile
client (egui desktop host) — source lives at
https://tangled.org/nandi.uk/sleek (mirrored at
https://github.com/codegod100/sleek). This tap repo only holds the
formula; it does not build/host the app itself.

`claude-desktop` installs Anthropic's official Linux desktop app
(https://downloads.claude.ai/claude-desktop/apt/stable) as a normal
unsandboxed Homebrew formula instead of via Flatpak — same upstream
`.deb`, just unpacked straight into the Cellar with a `bin/` symlink
and a `.desktop`/icon set, no Flatpak sandbox involved. See the
formula's `caveats` for one-time desktop-menu registration and how to
carry over an existing Flatpak login.

`buildbuddy-cli` installs BuildBuddy's `bb` CLI
(https://www.buildbuddy.io/cli), a Bazel wrapper built on Bazelisk.
Upstream's own install script (`curl -fsSL https://install.buildbuddy.io
| bash`) hardcodes `sudo mv ... /usr/local/bin/bb`, which fails on any
system where `/usr/local/bin` is read-only or there's no `sudo` at all.
This formula fetches the same per-platform release binaries from
https://github.com/buildbuddy-io/bazel/releases and installs `bb` into
this formula's own prefixed `bin/` instead.
