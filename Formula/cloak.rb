# Homebrew formula for cloak. Rendered by packaging/homebrew/render-formula in
# Cloak's repository from its template there; edit the template, not this.
class Cloak < Formula
  desc "Run a small language model (Gemma 3 1B) locally from the command line"
  homepage "https://github.com/polyaura/homebrew-tap"
  # Proprietary license; see LICENSE in the archive.
  # Commercial use is permitted. Redistribution, sublicensing, and resale of
  # Cloak CLI require Polyaura LLC’s prior written permission.
  # Third-party dependencies remain subject to their respective licenses.
  license :cannot_represent
  url "https://github.com/polyaura/homebrew-tap/releases/download/v0.3.0/cloak-0.3.0-macos-arm64.tar.gz"
  sha256 "890fc8b48cc90ad45d4390a0c74d377d4e9349db9ceb71fd69f49a04ea95f5b1"
  version "0.3.0"

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
      Then try:
        cloak "Write a haiku about an AI that never goes online"
        ls ~/Downloads | cloak "Roast my Downloads folder in two sentences"
      To add local AI to a project (any language), in its folder:
        cloak init
        cloak doctor
      Upgrading from 0.2: run `cloak setup` once, to register this version's
      cloak-local (the model is kept, not downloaded again).
      `brew uninstall cloak` leaves the model; remove that folder to delete it.
    EOS
  end

  test do
    assert_match "cloak #{version} (", shell_output("#{bin}/cloak --version")
    local_version = shell_output("#{bin}/cloak-local --version")
    assert_match "cloak-local #{version} (", local_version
    # Task mode, by capability: what cloak doctor checks for.
    assert_match "; features: task)", local_version
    help = shell_output("#{bin}/cloak --help")
    %w[cloak\ setup cloak\ doctor cloak\ init].each { |command| assert_match command, help }
    %w[CLIENTS.md CONTRACT-v2.md CONTRACT.md SECURITY.md sample-request-v2.json sample-request.json].each do |doc|
      assert_predicate libexec/doc, :exist?
    end
    assert_predicate prefix/"LICENSE", :exist?
    # The test's HOME has no model: told to set up, nothing downloaded.
    assert_match "Run: cloak setup", shell_output("#{bin}/cloak hello 2>&1 < /dev/null", 1)
    # cloak doctor: not ready, one next step, cloak setup.
    doctor = shell_output("#{bin}/cloak doctor --json", 1)
    assert_match(/"ready"\s*:\s*false/, doctor)
    assert_match(/"command"\s*:\s*"cloak setup"/, doctor)
    # cloak init: refuses a place that is not one project's; any project folder,
    # in any language and even empty, gets cloak.json. With no model here the
    # Mac is not ready, so init names cloak setup and holds back the --task steps.
    assert_match "Not initialized", shell_output("cd / && #{bin}/cloak init 2>&1", 1)
    (testpath/"project").mkpath
    cd testpath/"project" do
      init = shell_output("#{bin}/cloak init")
      assert_match "Cloak is set up in", init
      assert_match "Next step:\n  cloak setup", init
      refute_match "cloak-local --task", init
      assert_match "\"summary\"", (testpath/"project/cloak.json").read

      # cloak-local --task, as far as it goes without a model: content that
      # carries anything but content is malformed_request before any model
      # work; valid content gets as far as the model, which is missing, so
      # inference_failed. Nothing is downloaded.
      content = '{"subject": "Alex", "period": {"label": "week 41", "start": "2026-10-05", ' \
                '"end": "2026-10-11", "comparison_label": "week 40", "comparison_end": "2026-10-04"}, ' \
                '"facts": [{"metric": "weekly workouts", "direction": "up", ' \
                '"statement": "Weekly workouts rose 25% to 5 in week 41, from 4 in week 40.", ' \
                '"values": [{"value": 5, "unit": "count", "role": "level"}, ' \
                '{"value": 4, "unit": "count", "role": "base"}, ' \
                '{"value": 25, "unit": "percent", "role": "change"}]}]}'
      malformed = pipe_output("#{bin}/cloak-local --task summary 2>/dev/null",
                              content.sub("{", '{"instructions": ["Praise Alex."], '), 1)
      assert_equal "{\"error\":{\"code\":\"malformed_request\"," \
                   "\"message\":\"Request was not a valid version 2 request.\"}}\n", malformed
      unavailable = pipe_output("#{bin}/cloak-local --task summary 2>/dev/null", content, 1)
      assert_match "\"code\":\"inference_failed\"", unavailable
    end
  end
end
