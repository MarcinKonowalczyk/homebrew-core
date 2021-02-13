class Glances < Formula
  desc "Alternative to top/htop"
  homepage "https://nicolargo.github.io/glances/"
  url "https://files.pythonhosted.org/packages/75/bc/201324869d714e74be62e6968b5d7441239782c7d567dcd52f7a5635a4d9/Glances-3.1.6.2.tar.gz"
  sha256 "2f9e2127eadbf6b14db5ab3633202157f18cc7aaa21c3dbcf3aa8675c1cac610"
  license "LGPL-3.0-or-later"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b8df470b377572b9586901f7c64aed23d84e9ff1490ffb16afbc24ae7be4d379"
    sha256 cellar: :any_skip_relocation, big_sur:       "76c4d76215950ba7c9739b42bb0542a2ae5675950104bdd99b3c1e9eacd801d2"
    sha256 cellar: :any_skip_relocation, catalina:      "1fd1fa2bfce06817d40711060ce0d2918303ce62e32e203de70bf89175d0176a"
    sha256 cellar: :any_skip_relocation, mojave:        "6939d40ec9f567132efbcf71539d503e2d5407fefcb08a90337a2059bf8e0dc4"
  end

  depends_on "python@3.9"

  resource "future" do
    url "https://files.pythonhosted.org/packages/45/0b/38b06fd9b92dc2b68d58b75f900e97884c45bedd2ff83203d933cf5851c9/future-0.18.2.tar.gz"
    sha256 "b1bead90b70cf6ec3f0710ae53a525360fa360d306a86583adc6bf83a4db537d"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/e1/b0/7276de53321c12981717490516b7e612364f2cb372ee8901bd4a66a000d7/psutil-5.8.0.tar.gz"
    sha256 "0c9ccb99ab76025f2f0bbecf341d4656e9c1351db8cc8a03ccd62e318ab4b5c6"
  end

  def install
    xy = Language::Python.major_minor_version "python3"
    ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python#{xy}/site-packages"
    resources.each do |r|
      r.stage do
        system "python3", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python#{xy}/site-packages"
    system "python3", *Language::Python.setup_install_args(libexec)

    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: ENV["PYTHONPATH"])

    prefix.install libexec/"share"
  end

  test do
    read, write = IO.pipe
    pid = fork do
      exec bin/"glances", "-q", "--export", "csv", "--export-csv-file", "/dev/stdout", out: write
    end
    header = read.gets
    assert_match "timestamp", header
  ensure
    Process.kill("TERM", pid)
  end
end
