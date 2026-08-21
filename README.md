# codegod100/tap

Homebrew tap for `codegod100` formulae.

```
brew tap codegod100/tap
brew install sleek
brew install claude-desktop
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
