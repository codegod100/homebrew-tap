class ChatgptLinux < Formula
  desc "ChatGPT desktop application with Codex support"
  homepage "https://developers.openai.com/codex/app"
  url "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"
  version "26.818.61809"
  sha256 "1bba62a6dbd2d49975c62850d8eddaad605da193557b194982225e56b1941891"
  license :cannot_represent

  depends_on arch: :x86_64
  depends_on :linux

  def install
    # Homebrew does not automatically unpack raw Debian archives.
    deb = buildpath.children.first
    system "ar", "x", deb
    system "tar", "xf", Dir["data.tar.*"].fetch(0)

    libexec.install Dir["usr/lib/chatgpt/*"]
    bin.install_symlink libexec/"ChatGPT" => "chatgpt"
    (share/"applications").install "usr/share/applications/chatgpt.desktop"
    (share/"pixmaps").install "usr/share/pixmaps/chatgpt.png"
  end

  def caveats
    <<~EOS
      ChatGPT installed desktop integration files under:
        #{share}/applications/chatgpt.desktop
        #{share}/pixmaps/chatgpt.png

      Make sure #{HOMEBREW_PREFIX}/share is in $XDG_DATA_DIRS, or link the
      desktop entry manually:
        mkdir -p ~/.local/share/applications
        ln -s "#{share}/applications/chatgpt.desktop" ~/.local/share/applications/

      The upstream URL is mutable. When OpenAI publishes a new build, this
      formula will reject it until its version and SHA-256 are updated.
    EOS
  end

  test do
    assert_predicate bin/"chatgpt", :executable?
  end
end
