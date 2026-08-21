class Buck2 < Formula
  desc "Build system, successor to Buck (installed via DotSlash)"
  homepage "https://buck2.build/"

  # facebook/buck2 doesn't publish an official DotSlash file as a release
  # asset (unlike reindeer.rb's upstream one) -- only raw per-platform
  # `buck2-<target>.zst` binaries. So this tap hosts a hand-assembled one
  # (resources/buck2.dotslash), pinned to the commit that added it; the
  # actual buck2 binary is fetched+hash-verified by DotSlash itself on
  # first run, not by Homebrew's downloader here.
  #
  # To bump: regenerate resources/buck2.dotslash (see its own commit
  # message for how), commit it, then update this url/sha256/version.
  url "https://raw.githubusercontent.com/codegod100/homebrew-tap/4c42fdcefb61a9450d563af700f2f7e32c89ecf0/resources/buck2.dotslash"
  version "2026-08-01"
  sha256 "994c8f90cbfa062c5e40c5d13697d5e611b5305861df9124095b0792ebc8c518"
  license "Apache-2.0"

  depends_on "dotslash"

  def install
    # Raw single-file download -- Homebrew's URL-basename inference doesn't
    # reliably land on "buck2.dotslash" for this URL shape (see sleek.rb's
    # install for the same caveat), so the staged buildpath's only child is
    # whatever it got named, always.
    bin.install buildpath.children.first => "buck2"
    chmod "+x", bin/"buck2"
  end

  test do
    assert_predicate bin/"buck2", :executable?
    # First run triggers DotSlash's fetch-and-cache of the real binary.
    assert_match "buck2 ", shell_output("#{bin}/buck2 --version")
  end
end
