class YubikeyAgent < Formula
  desc "Seamless ssh-agent for YubiKeys and other PIV tokens"
  homepage "https://filippo.io/yubikey-agent"
  url "https://github.com/FiloSottile/yubikey-agent/archive/v0.1.5.tar.gz"
  sha256 "724b21f05d3f822acd222ecc8a5d8ca64c82d5304013e088d2262795da81ca4f"
  license "BSD-3-Clause"
  head "https://filippo.io/yubikey-agent", using: :git

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "efffadb45cd18617afdd4ba682d8a198c17f37a45c4daceffe4233b1eb2b7cb4"
    sha256 cellar: :any_skip_relocation, big_sur:       "b6848be5e33c4a19beab0d30667e943eae86ebada5f411645e13216568e366fb"
    sha256 cellar: :any_skip_relocation, catalina:      "4610af306fa6ea29b93a290e3605822483cfd484c1ee2228dbed8a4c7eeff8f7"
    sha256 cellar: :any_skip_relocation, mojave:        "2b0c46b8938baa3fba070a23da7475e4d502cf9142330a8c42f102e782a90f64"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-X main.Version=v#{version}"
  end

  def post_install
    (var/"run").mkpath
    (var/"log").mkpath
  end

  def caveats
    <<~EOS
      To use this SSH agent, set this variable in your ~/.zshrc and/or ~/.bashrc:
        export SSH_AUTH_SOCK="#{var}/run/yubikey-agent.sock"
    EOS
  end

  plist_options manual: "yubikey-agent -l #{HOMEBREW_PREFIX}/var/run/yubikey-agent.sock"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>/usr/bin:/bin:/usr/sbin:/sbin</string>
        </dict>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/yubikey-agent</string>
          <string>-l</string>
          <string>#{var}/run/yubikey-agent.sock</string>
        </array>
        <key>RunAtLoad</key><true/>
        <key>KeepAlive</key><true/>
        <key>ProcessType</key>
        <string>Background</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/yubikey-agent.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/yubikey-agent.log</string>
      </dict>
      </plist>
    EOS
  end

  test do
    socket = testpath/"yubikey-agent.sock"
    fork { exec bin/"yubikey-agent", "-l", socket }
    sleep 1
    assert_predicate socket, :exist?
  end
end
