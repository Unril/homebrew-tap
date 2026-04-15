class Klspw < Formula
  desc "Generate workspace.json for kotlin-lsp from Gradle builds"
  homepage "https://github.com/Unril/klspw"
  url "https://github.com/Unril/klspw/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "9c2c750ebfed8133ccba2d6de55da7ba7f1556f33e5a80843529bc81373c46b3"
  license "MIT"

  bottle do
    root_url "https://github.com/Unril/homebrew-tap/releases/download/klspw-0.1.2"
    sha256 cellar: :any,                 arm64_tahoe:  "6b6041be22ee0c70aa17bbc033a63bd4266052570fc2510e52bd4fe56b7b6455"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "719258be2711ff4faf0221c323807b1aadce73a25e652492a3b66fff46f0741f"
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
