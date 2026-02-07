# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
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
    # ENV.deparallelize  # if your formula fails when building in parallel
    # Remove unrecognized options if warned by configure
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    #system "./configure", *std_configure_args, "--disable-silent-rules"
    # system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    bin.install "rnacos"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test r-nacos`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "#{bin}/rnacos", "--version" 
  end
end
