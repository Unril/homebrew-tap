class Klspw < Formula
  desc "Generate workspace.json for kotlin-lsp from Gradle builds"
  homepage "https://github.com/Unril/klspw"
  url "https://github.com/Unril/klspw/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "6e8f3d48d847deb05f41619146dca14a0e58f3433638b8ace6bc76a1dbe6f525"
  license "MIT"

  bottle do
    root_url "https://github.com/Unril/homebrew-tap/releases/download/klspw-0.1.1"
    sha256 cellar: :any,                 arm64_tahoe:  "5d2b544f21b93f249ae13bbf2f935fa9ee2b67a030cc137f492e75d92463ab8d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4f1f0abd5a3d6a9b250c070b5e78b76ca2dd17335c30aeb39a9fcfdcf7d3f6d5"
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
