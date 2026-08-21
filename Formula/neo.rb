class Neo < Formula
  desc "GTK4/libadwaita Matrix chat client"
  homepage "https://github.com/codegod100/neo"
  url "https://github.com/codegod100/neo/releases/download/v0.1.0/neo-x86_64-linux"
  sha256 "fae480b216d11f1c2d88e78536d99f7880dfdda1d30b3d25d20381dc248974f9"

  depends_on "patchelf" => :build
  depends_on "glib"
  depends_on "gtk4"
  depends_on "libadwaita"
  depends_on "sqlite"

  def install
    # Homebrew's URL-basename inference doesn't reliably land on
    # "neo-x86_64-linux" for this download URL shape (see sleek.rb's install
    # for the same caveat) -- since this is a raw binary download (no
    # archive to extract), the staged buildpath's only child is always the
    # downloaded file itself, whatever it got named.
    bin.install buildpath.children.first => "neo"

    # This binary was built via buck2 against Homebrew's own gtk4/libadwaita/
    # glib/sqlite (see neo's BUCK file, GTK4_LIB_DIRS), but ships with no
    # RPATH of its own -- without one, the loader falls through to whatever
    # happens to be on the system's default search path, which "works" by
    # accident only on a machine that already has ABI-compatible system
    # copies of these libraries installed (see sleek.rb's install for the
    # same footgun). Patch it explicitly to this formula's own deps instead.
    rpath_deps = %w[glib gtk4 libadwaita sqlite]
    system "patchelf", "--set-rpath", rpath_deps.map { |d| formula_opt_lib(d) }.join(":"), bin/"neo"
  end

  test do
    assert_predicate bin/"neo", :executable?
  end
end
