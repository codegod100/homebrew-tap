class ClaudeDesktop < Formula
  desc "Desktop application for Claude.ai"
  homepage "https://claude.ai"
  version "1.32885.1"
  license :cannot_represent

  # Anthropic ships an official Debian package (Electron 42.9.2) at this apt
  # repo for the Linux desktop beta -- no third-party repackaging involved.
  # To bump: query the Packages index for the newest
  # pool/main/c/claude-desktop/claude-desktop_<ver>_<arch>.deb entry and its
  # sha256, per
  # https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-<arch>/Packages
  if Hardware::CPU.arm?
    url "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_1.32885.1_arm64.deb"
    sha256 "5da381569c5b09cacfc83c992920181207ca45fd1270e20654dd7bb21c5d8552"
  else
    url "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_1.32885.1_amd64.deb"
    sha256 "f8a5ddea7c8cbe769589cf19c2e1832d5d532ab19bf8202621ba957c9351a2fc"
  end

  def install
    # This is a raw .deb (ar archive of debian-binary/control.tar.xz/
    # data.tar.xz), which Homebrew doesn't auto-unpack -- the staged
    # buildpath's only child is the downloaded file itself.
    deb = buildpath.children.first
    system "ar", "x", deb
    system "tar", "xf", "data.tar.xz"

    # The app is a self-contained Electron/Chromium build (RPATH=$ORIGIN,
    # every .so it needs ships alongside the binary), so installing the
    # whole upstream lib dir verbatim and exec'ing the binary in place is
    # enough -- no LD_LIBRARY_PATH surgery, no extra depends_on for system
    # libs (glibc/GTK3/NSS/etc. already present on any GNOME desktop host).
    libexec.install Dir["usr/lib/claude-desktop/*"]
    bin.install_symlink libexec/"claude-desktop" => "claude-desktop"

    (share/"applications").install "usr/share/applications/com.anthropic.Claude.desktop"
    Dir["usr/share/icons/hicolor/*/apps/claude-desktop.png"].each do |icon|
      icon_size = icon.split("/")[-3]
      (share/"icons/hicolor/#{icon_size}/apps").install icon
    end
  end

  def caveats
    <<~EOS
      claude-desktop installed a .desktop file and icons under:
        #{share}/applications/com.anthropic.Claude.desktop
        #{share}/icons/hicolor/*/apps/claude-desktop.png

      Homebrew doesn't register these with your desktop's app menu on its
      own. Either make sure #{HOMEBREW_PREFIX}/share is in $XDG_DATA_DIRS,
      or symlink them in manually:
        ln -s "#{share}/applications/com.anthropic.Claude.desktop" ~/.local/share/applications/
        for d in #{share}/icons/hicolor/*/apps/claude-desktop.png; do
          sz=$(basename $(dirname $(dirname "$d")))
          mkdir -p ~/.local/share/icons/hicolor/$sz/apps
          ln -s "$d" ~/.local/share/icons/hicolor/$sz/apps/
        done

      This build is unsandboxed (no Flatpak/zypak), so Chromium falls back
      to its unprivileged user-namespace sandbox instead of the elevated
      chrome-sandbox helper apt's postinst would normally set up. That's
      the kernel default on Fedora/Bluefin, so it should just work; if the
      app refuses to start, launch it as `claude-desktop --no-sandbox`
      instead.

      If you were previously using the Flatpak build, your login and
      session data live at:
        ~/.var/app/com.anthropic.Claude/config/Claude/
      This build reads/writes the normal unsandboxed path instead:
        ~/.config/Claude/
      Copy the old directory over once to keep your existing login:
        cp -a ~/.var/app/com.anthropic.Claude/config/Claude ~/.config/Claude
    EOS
  end

  test do
    assert_predicate bin/"claude-desktop", :executable?
    assert_match version.to_s, shell_output("#{libexec}/claude-desktop --version 2>&1", 0..1)
  end
end
