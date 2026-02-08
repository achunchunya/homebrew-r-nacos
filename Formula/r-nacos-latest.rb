# r-nacos-latest Homebrew Formula
# Provides latest beta version with service management
class RNacosLatest < Formula
  desc "r-nacos latest"
  homepage "https://github.com/r-nacos/r-nacos"
  url "https://github.com/nacos-group/r-nacos/releases/download/v0.5.8-beta.1/rnacos-x86_64-apple-darwin.tar.gz"
  version "v0.5.8-beta.1"
  #sha256 "811f7f5d5f45f3ba9167093be4656bb610d9cc5e287c39f55af02cdaa56303e4"
  license "Apache-2.0 license"

  # depends_on "cmake" => :build
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/nacos-group/r-nacos/releases/download/v0.5.8-beta.1/rnacos-aarch64-apple-darwin.tar.gz"
    end
  end

  on_linux do
    url "https://github.com/nacos-group/r-nacos/releases/download/v0.5.8-beta.1/rnacos-x86_64-unknown-linux-musl.tar.gz"
    if Hardware::CPU.arm?
      url "https://github.com/nacos-group/r-nacos/releases/download/v0.5.8-beta.1/rnacos-aarch64-unknown-linux-musl.tar.gz"
    end
  end

  def install
    bin.install "rnacos"
  end

  def post_install
    if OS.mac?
      # Auto-sign the binary to avoid macOS security restrictions
      system "codesign", "--force", "--deep", "--sign", "-", bin/"rnacos"
    end
    
    # Create proper directories
    (var/"r-nacos/data").mkpath
    (var/"log").mkpath
    
    # Copy any existing data from default location to our managed location
    default_data_dir = Pathname.new(Dir.home) / ".local/share/r-nacos/nacos_db"
    managed_data_dir = var/"r-nacos/data"
    
    if default_data_dir.exist? && !managed_data_dir.children.any?
      ohai "Migrating existing r-nacos data to managed directory..."
      system "cp", "-R", "#{default_data_dir}/.", "#{managed_data_dir}/"
    end
    
    ohai "r-nacos installation completed!"
    ohai "To start the service: brew services start r-nacos"
    ohai "Service logs will be available at: #{var}/log/r-nacos.log"
  end

  service do
    run [opt_bin/"rnacos"]
    keep_alive true
    working_dir var/"r-nacos"
    log_path var/"log/r-nacos.log"
    error_log_path var/"log/r-nacos-error.log"
    run_at_load true
    environment_variables({
      "RNACOS_HTTP_PORT" => "8848",
      "RNACOS_GRPC_PORT" => "9848",
      "RNACOS_HTTP_CONSOLE_PORT" => "10848",
      "RNACOS_DATA_DIR" => (var/"r-nacos/data").to_s,
      "RUST_LOG" => "info"
    })
  end

  test do
    system "#{bin}/rnacos", "--help"
    assert_match "rnacos", shell_output("#{bin}/rnacos --version 2>&1", 0)
  end
end
