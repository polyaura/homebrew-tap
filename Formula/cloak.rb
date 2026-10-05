# Homebrew formula for cloak. Rendered by packaging/homebrew/render-formula in
# Cloak's repository from its template there; edit the template, not this.
class Cloak < Formula
  desc "Run a small language model (Gemma 3 1B) locally from the command line"
  homepage "https://github.com/polyaura/homebrew-tap"
  # Proprietary: the Cloak CLI & Brain Beta License (LICENSE in the archive).
  # Commercial use permitted. Redistribution, sublicensing, and resale of
  # Cloak CLI or Brain require Polyaura LLC’s prior written permission.
  # Third-party dependencies remain subject to their respective licenses.
  license :cannot_represent
  url "https://github.com/polyaura/homebrew-tap/releases/download/v0.2.0/cloak-0.2.0-macos-arm64.tar.gz"
  sha256 "2ce1c0b5467ba2c25679d9c09b4de51dbb6df278a88da1f30fcb69a03f643f1d"
  version "0.2.0"

  # The release is built for Apple silicon, macOS 14 or later (cli/release).
  depends_on arch: :arm64
  depends_on macos: :sonoma

  # The binaries and llama.framework are signed with Polyaura's Developer ID
  # (hardened runtime, library validation) and notarized; both binaries find
  # the framework beside them through @rpath and @loader_path. Without this,
  # Homebrew would rewrite the framework's @rpath install name to an absolute
  # path, re-signing it ad hoc, and library validation would then refuse to
  # load it.
  preserve_rpath

  def install
    # bin/ keeps cloak, cloak-local and llama.framework together, as the
    # archive has them; the links in Homebrew's bin point into it, and dyld
    # resolves @loader_path from the real file.
    libexec.install "bin", "CLIENTS.md", "CONTRACT-v2.md", "CONTRACT.md", "SECURITY.md",
                    "sample-request-v2.json", "sample-request.json"
    # LICENSE and LICENSE-llama.cpp go to the prefix, as Homebrew does with
    # every license.
    bin.install_symlink libexec/"bin/cloak", libexec/"bin/cloak-local"
  end

  def caveats
    <<~EOS
      Run this once to download and verify the model (Gemma 3 1B, 806 MB, from
      Hugging Face) into ~/Library/Application Support/Polyaura/Cloak/Models:
        cloak setup
      Then:
        cloak "Explain what a mutex is in two sentences."
        cat notes.txt | cloak "Summarize this in three bullet points"
      `brew uninstall cloak` leaves the model; remove that folder to delete it.
    EOS
  end

  test do
    assert_match "cloak #{version} (", shell_output("#{bin}/cloak --version")
    assert_match "cloak-local #{version} (", shell_output("#{bin}/cloak-local --version")
    assert_match "cloak setup", shell_output("#{bin}/cloak --help")
    %w[CLIENTS.md CONTRACT-v2.md CONTRACT.md SECURITY.md sample-request-v2.json sample-request.json].each do |doc|
      assert_predicate libexec/doc, :exist?
    end
    assert_predicate prefix/"LICENSE", :exist?
    # The test's HOME has no model: told to set up, nothing downloaded.
    assert_match "Run: cloak setup", shell_output("#{bin}/cloak hello 2>&1 < /dev/null", 1)
  end
end
