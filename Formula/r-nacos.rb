# r-nacos Homebrew Formula
# Provides service management and macOS compatibility
class RNacos < Formula
  desc "r-nacos"
  homepage "https://github.com/r-nacos/r-nacos"
  url "https://github.com/nacos-group/r-nacos/releases/download/v0.8.0/rnacos-x86_64-apple-darwin-v0.8.0.tar.gz"
  version "v0.8.0"
  #sha256 "20d215565fefadd2369508e50972aed68d1b7f1b1cc6722d338c6187c830e0e4"
  license "Apache-2.0 license"

  # depends_on "cmake" => :build

  on_macos do
    if Hardware::CPU.arm?
      #sha256 "6153293768db8105b65297871636a8e8550d13be76877babe1202efd39cd5789"
      url "https://github.com/nacos-group/r-nacos/releases/download/v0.8.0/rnacos-aarch64-apple-darwin-v0.8.0.tar.gz"
    end
  end

  on_linux do
    #sha256 "ba9ef6504b1a4fd3786d1a56d2a175762b6b5546861e9fdc984b58091379bef2"
    url "https://github.com/nacos-group/r-nacos/releases/download/v0.8.0/rnacos-x86_64-unknown-linux-musl-v0.8.0.tar.gz"
    if Hardware::CPU.arm?
      #sha256 "2186605c6b0b995ebf037f59c3148d250f680bf21352e009aa095a1194da0cdb"
      url "https://github.com/nacos-group/r-nacos/releases/download/v0.8.0/rnacos-aarch64-unknown-linux-musl-v0.8.0.tar.gz"
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
    assert_match "r-nacos", shell_output("#{bin}/rnacos --version 2>&1", 0)
  end
end
