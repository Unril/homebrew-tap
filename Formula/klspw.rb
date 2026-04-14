class Klspw < Formula
  desc "Generate workspace.json for kotlin-lsp from Gradle builds"
  homepage "https://github.com/Unril/klspw"
  url "https://github.com/Unril/klspw/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a415cd1b791c892f78be25f1bc2a3ae1ddd2757843236b9dc2f1d87578917929"
  license "MIT"

  bottle do
    root_url "https://github.com/Unril/homebrew-tap/releases/download/klspw-0.1.0"
    rebuild 1
    sha256 cellar: :any,                 arm64_tahoe:  "f9e1f87e719c8dccede16c7b1316f60d81631527b34bc615fad431a9985fce63"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "663280c135b0e7c273327522f7934f5a2445813bbbfa645c7af93a128b2631cf"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "cli11"
  depends_on "fmt"
  depends_on "glaze"
  depends_on "reproc"
  depends_on "spdlog"

  on_linux do
    depends_on "gcc"
  end

  fails_with :gcc do
    version "14"
    cause "Requires C++23 <format> and std::ranges::to (GCC 15+)"
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/klspw --version")

    (testpath / "fake-root").mkpath
    (testpath / "fake-root/build.gradle.kts").write("")
    output = shell_output("#{bin}/klspw init #{testpath}/fake-root")
    assert_match "version: 1", output
    assert_match "roots:", output
  end
end
