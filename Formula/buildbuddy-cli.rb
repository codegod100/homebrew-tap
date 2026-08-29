class BuildbuddyCli < Formula
  desc "Bazel wrapper CLI from BuildBuddy (installs the bb binary)"
  homepage "https://www.buildbuddy.io/cli"
  version "5.0.445"
  license "MIT"

  # Upstream's own installer (curl -fsSL https://install.buildbuddy.io | bash)
  # hardcodes `sudo mv ... /usr/local/bin/bb`, which fails outright on any
  # system where /usr/local/bin isn't writable (or doesn't have sudo at all,
  # e.g. NixOS-style setups). This formula fetches the same per-platform
  # release binaries BuildBuddy's own installer does, but lands `bb` in this
  # formula's own prefixed bin/ instead.
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/buildbuddy-io/bazel/releases/download/5.0.445/bazel-5.0.445-darwin-arm64"
      sha256 "9fb31ec2a308dfdaedf32d4bdf18b4b0bfb3e8126b873f913b0d28cb75ecc5fd"
    else
      url "https://github.com/buildbuddy-io/bazel/releases/download/5.0.445/bazel-5.0.445-darwin-x86_64"
      sha256 "4069e2faa965faead05b9f8b2b2d24db29b9bd18d72234e89cb6489729288dfe"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/buildbuddy-io/bazel/releases/download/5.0.445/bazel-5.0.445-linux-arm64"
      sha256 "0f7478d0cb4c0c4ae3ddefc01788e18261637f92c3a5e15a830186ee15156b68"
    else
      url "https://github.com/buildbuddy-io/bazel/releases/download/5.0.445/bazel-5.0.445-linux-x86_64"
      sha256 "130b35aaff238d24ba2b185469a4ddcac3fe6b6c9364e1234e41fcc0bef3a9e8"
    end
  end

  def install
    # Homebrew's URL-basename inference doesn't reliably land on the
    # "bazel-<version>-<os>-<arch>" asset name for this download URL shape
    # (see sleek.rb's install for the same caveat) -- since this is a raw
    # binary download (no archive to extract), the staged buildpath's only
    # child is always the downloaded file itself, whatever it got named.
    bin.install buildpath.children.first => "bb"
    chmod "+x", bin/"bb"
  end

  test do
    assert_predicate bin/"bb", :executable?
    assert_match version.to_s, shell_output("#{bin}/bb version --cli")
  end
end
