class Sleek < Formula
  desc "Mobile freeq client (egui desktop host)"
  homepage "https://tangled.org/nandi.uk/sleek"
  license "MIT"
  version "0.1.6"

  on_linux do
    url "https://tangled.org/nandi.uk/sleek/tags/a1ff841976a185104747b9fc40a72a119f093ba5/download/sleek-x86_64-linux"
    sha256 "fdde2443459dad11fa875e2f64becdda5e7031097434587841889a5bfc81967d"

    depends_on "patchelf" => :build
    depends_on "alsa-lib"
    depends_on "libxi"
    depends_on "libxkbcommon"
    depends_on "libxrandr"
    depends_on "mesa"
    depends_on "openssl@3"
    depends_on "pipewire"
    depends_on "vulkan-loader"
    depends_on "wayland"
  end

  # Desktop-menu integration assets (.desktop/icon/.metainfo). Not part of
  # the prebuilt binary artifact, so pulled from the same tag's source tree.
  resource "assets" do
    url "https://tangled.org/nandi.uk/sleek/archive/v0.1.6.tar.gz"
    sha256 "c4b45f0bfd9887d763383f64a465239554de5a26803e6ad263b9cacb0fda290a"
  end

  def install
    # Homebrew's URL-basename inference doesn't reliably land on
    # "sleek-x86_64-linux" for this download URL shape (it's named the
    # cached/staged file something else, e.g. "nandi.uk", in practice) --
    # since this is a raw binary download (no archive to extract), the
    # staged buildpath's only child is always the downloaded file itself,
    # whatever it got named.
    bin.install buildpath.children.first => "sleek"

    # This binary was compiled on BuildBuddy's remote-execution sandbox, so
    # its baked-in RUNPATH points at a build-container-only path
    # (/buildbuddy-execroot/...) that doesn't exist on a real machine. A
    # missing RUNPATH entry is silently skipped by the loader rather than
    # erroring, so it "works" by accident only on machines that happen to
    # have libpipewire/libasound on the default system search path.
    # Homebrew doesn't rewrite RPATHs on binaries it didn't compile itself
    # (that only happens via superenv during an in-formula build), so patch
    # it explicitly to point at this formula's own deps instead.
    rpath_deps = %w[alsa-lib pipewire vulkan-loader wayland libxkbcommon libxi libxrandr mesa openssl@3]
    system "patchelf", "--set-rpath", rpath_deps.map { |d| Formula[d].opt_lib }.join(":"), bin/"sleek"

    resource("assets").stage do
      (share/"applications").install "assets/uk.nandi.sleek.desktop"
      (share/"metainfo").install "assets/uk.nandi.sleek.metainfo.xml"
      (share/"icons/hicolor/scalable/apps").install "assets/uk.nandi.sleek.svg"
    end
  end

  def caveats
    <<~EOS
      sleek installed a .desktop file and icon under:
        #{share}/applications/uk.nandi.sleek.desktop
        #{share}/icons/hicolor/scalable/apps/uk.nandi.sleek.svg

      Homebrew doesn't register these with your desktop's app menu on its
      own. Either make sure #{HOMEBREW_PREFIX}/share is in $XDG_DATA_DIRS,
      or symlink it in manually:
        ln -s "#{share}/applications/uk.nandi.sleek.desktop" ~/.local/share/applications/
        ln -s "#{share}/icons/hicolor/scalable/apps/uk.nandi.sleek.svg" ~/.local/share/icons/hicolor/scalable/apps/
    EOS
  end

  test do
    assert_predicate bin/"sleek", :executable?
  end
end
