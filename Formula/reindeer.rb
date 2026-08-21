class Reindeer < Formula
  desc "Generates Buck2 build rules from a Cargo.toml crate graph (installed via DotSlash)"
  homepage "https://github.com/facebookincubator/reindeer"
  version "2026.08.10.00"
  license "Apache-2.0"

  # Unlike buck2.rb, facebookincubator/reindeer publishes an official
  # DotSlash file as a release asset (a bare "reindeer" asset alongside the
  # per-platform archives) -- fetched and verified here like any other
  # formula resource. The actual reindeer binary it points at is fetched
  # +hash-verified by DotSlash itself on first run, not by Homebrew.
  url "https://github.com/facebookincubator/reindeer/releases/download/v2026.08.10.00/reindeer"
  sha256 "1332de73c9e953ce247a4b15be1a8091da41187847d2c52664f556b330b88907"

  depends_on "dotslash"

  def install
    # Raw single-file download -- Homebrew's URL-basename inference doesn't
    # reliably land on "reindeer" for this URL shape (see sleek.rb's
    # install for the same caveat), so the staged buildpath's only child is
    # whatever it got named, always.
    bin.install buildpath.children.first => "reindeer"
    chmod "+x", bin/"reindeer"
  end

  test do
    assert_predicate bin/"reindeer", :executable?
    # First run triggers DotSlash's fetch-and-cache of the real binary.
    # reindeer has no --version flag; exercise --help instead.
    assert_match "Usage: reindeer", shell_output("#{bin}/reindeer --help")
  end
end
