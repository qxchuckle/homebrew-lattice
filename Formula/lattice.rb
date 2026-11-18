# Generated for the Lattice-owned tap.
require "tmpdir"

class Lattice < Formula
  desc "Local-first engineering memory and workflow"
  homepage "https://lattice.qcqx.cn"
  version "1.30.0"
  license "MIT"
  on_macos do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.0/lattice-1.30.0-darwin-arm64.tar.gz", using: :nounzip
      sha256 "85548f3eb68c55ccfb6525a0defae782f820cd9329927d4491db5068a485c073"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.0/lattice-1.30.0-darwin-x64.tar.gz", using: :nounzip
      sha256 "bc62e196333fcd3d1893eb4626d6f64d2df92a463db428cdbf056b7e5e3aa1a4"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.0/lattice-1.30.0-linux-arm64.tar.gz", using: :nounzip
      sha256 "f8a3ca75e2fd5124980ff0a3e434c9b50275b198ba926141f81ad27cae99cbfb"
    end
    on_intel do
      url "https://github.com/qxchuckle/lattice/releases/download/v1.30.0/lattice-1.30.0-linux-x64.tar.gz", using: :nounzip
      sha256 "310140bb2e41607acaef5a3a73e59795430d05cc1419254ae8a6fe066198a68c"
    end
  end

  def install
    libexec.install Dir["*.tar.gz"].fetch(0) => "payload.tar.gz"
    bin.write_exec_script libexec/"payload/bin/ltc", libexec/"payload/bin/lattice"
  end

  # Homebrew fixes Mach-O linkage before post_install. Keep native files inside
  # the archive until that step has finished so their checksums stay intact.
  def post_install
    archive = libexec/"payload.tar.gz"
    destination = libexec/"payload"
    if destination.directory?
      verify_payload(destination)
    else
      Dir.mktmpdir(".lattice-payload-", libexec.to_s) do |stage|
        system "tar", "-xzf", archive, "-C", stage
        payload = Pathname(stage)/"payload"
        verify_payload(payload)
        payload.rename(destination)
      end
    end
    archive.unlink if archive.file?
  end

  def verify_payload(payload)
    with_env(NODE_OPTIONS: nil, NODE_PATH: nil) do
      system payload/"runtime/node", payload/"scripts/payload.cjs", version.to_s
    end
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/ltc --version").strip
    assert_match "--no-open", shell_output("#{bin}/ltc web --help")
    verify_payload(libexec/"payload")
  end
end
