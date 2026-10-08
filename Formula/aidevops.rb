# Homebrew formula for aidevops
# To install: brew install marcusquinn/tap/aidevops
# Or: brew tap marcusquinn/tap && brew install aidevops

class Aidevops < Formula
  desc "AI DevOps Framework - AI-assisted development workflows and automation"
  homepage "https://aidevops.sh"
  url "https://github.com/marcusquinn/aidevops/archive/refs/tags/v3.38.36.tar.gz"
  sha256 "059a13a8ff4c99d4853da8645a23be1a4e67078f6a4e5c8dc66299e038a05aaa"
  license "MIT"
  head "https://github.com/marcusquinn/aidevops.git", branch: "main"

  depends_on "bash"
  depends_on "jq"
  depends_on "curl"

  def install
    # Install the CLI script to libexec (not bin, to avoid double-write conflict)
    libexec.install "aidevops.sh"
    (libexec/"aidevops.sh").chmod 0755
    
    # Install setup script for manual setup
    libexec.install "setup.sh"
    (libexec/"setup.sh").chmod 0755
    
    # Install agent files
    (share/"aidevops").install ".agents"
    (share/"aidevops").install "VERSION"
    
    # Create wrapper in bin that prefers the git repo copy (always current
    # via 'aidevops update') over the Homebrew-installed snapshot.
    (bin/"aidevops").write <<~EOS
      #!/usr/bin/env bash
      # Prefer git repo copy — always current via 'aidevops update'
      if [[ -f "$HOME/Git/aidevops/aidevops.sh" ]]; then
        exec bash "$HOME/Git/aidevops/aidevops.sh" "$@"
      fi
      # Fall back to Homebrew-installed copy
      export AIDEVOPS_SHARE="#{share}/aidevops"
      exec "#{libexec}/aidevops.sh" "$@"
    EOS
    (bin/"aidevops").chmod 0755
  end

  def post_install
    # Run setup to deploy agents (non-interactive)
    ENV["AIDEVOPS_NON_INTERACTIVE"] = "true"
    system "bash", "#{libexec}/setup.sh", "--non-interactive"
  end

  def caveats
    <<~EOS
      aidevops has been installed!

      Quick start:
        aidevops status    # Check installation
        aidevops init      # Initialize in a project
        aidevops help      # Show all commands

      Agents deployed to: ~/.aidevops/agents/

      To update:
        brew upgrade aidevops
        # or
        aidevops update
    EOS
  end

  test do
    assert_match "aidevops", shell_output("#{bin}/aidevops version")
  end
end
