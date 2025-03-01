class Pgbouncer < Formula
  desc "Lightweight connection pooler for PostgreSQL"
  homepage "https://www.pgbouncer.org/"
  url "https://www.pgbouncer.org/downloads/files/1.15.0/pgbouncer-1.15.0.tar.gz"
  sha256 "e05a9e158aa6256f60aacbcd9125d3109155c1001a1d1c15d33a37c685d31380"

  livecheck do
    url "https://github.com/pgbouncer/pgbouncer"
  end

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_big_sur: "8107249d240e1a53f6ae84587c08129acf5c294c4022f92d5f1c731ea6956ea3"
    sha256 cellar: :any,                 big_sur:       "09f21ff3e7b2c125d793da2ba64110392227650ae8157ef987f041959af8fe7c"
    sha256 cellar: :any,                 catalina:      "fad76f523bac43aaf7859fa0085ab7c6582f9d4aeb682e677db8f5acd9c4159a"
    sha256 cellar: :any,                 mojave:        "4187ceded551fad5801a26f790e61dd7d654acc675de73a1b4bf2858920d0734"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1ccfa644aaba6da6067f31485cdbef1d1a5978b8f093e02eee5078a84569891d"
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"
  depends_on "openssl@1.1"

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make", "install"
    bin.install "etc/mkauth.py"
    inreplace "etc/pgbouncer.ini" do |s|
      s.gsub!(/logfile = .*/, "logfile = #{var}/log/pgbouncer.log")
      s.gsub!(/pidfile = .*/, "pidfile = #{var}/run/pgbouncer.pid")
      s.gsub!(/auth_file = .*/, "auth_file = #{etc}/userlist.txt")
    end
    etc.install %w[etc/pgbouncer.ini etc/userlist.txt]
  end

  def post_install
    (var/"log").mkpath
    (var/"run").mkpath
  end

  def caveats
    <<~EOS
      The config file: #{etc}/pgbouncer.ini is in the "ini" format and you
      will need to edit it for your particular setup. See:
      https://pgbouncer.github.io/config.html

      The auth_file option should point to the #{etc}/userlist.txt file which
      can be populated by the #{bin}/mkauth.py script.
    EOS
  end

  service do
    run [opt_bin/"pgbouncer", "-q", etc/"pgbouncer.ini"]
    keep_alive true
    working_dir HOMEBREW_PREFIX
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pgbouncer -V")
  end
end
