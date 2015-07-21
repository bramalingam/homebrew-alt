class BioformatsCpp51 < Formula
  desc "Microscopy file formats including OME-TIFF"
  homepage "http://www.openmicroscopy.org/site/products/bio-formats"
  url "http://downloads.openmicroscopy.org/bio-formats/5.1.3/artifacts/bioformats-dfsg-5.1.3.zip"
  sha256 "765137c548d9f4fdc111e22eec4d413effebbee273d8bba7392b59ad1499f41b"
  head "https://github.com/openmicroscopy/bioformats.git", :branch => "develop", :shallow => false

  option "without-check", "Skip build time tests (not recommended)"
  option "with-qt5", "Build with Qt5 (used for OpenGL image rendering)"
  option "without-docs", "Build API reference and manual pages"

  depends_on "boost"
  depends_on "cmake" => :build
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "xerces-c"
  depends_on "graphicsmagick" => :optional if build.with? "check"
  depends_on "qt5" => :optional if build.with? "qt5"
  depends_on "glm" => :build if build.with? "qt5"
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "graphviz" => :build if build.with? "docs"

  # Needs clang/libc++ toolchain; mountain lion is too broken
  depends_on MinimumMacOSRequirement => :mavericks

  needs :cxx11

  resource "sphinx" do
    url "https://pypi.python.org/packages/source/S/Sphinx/Sphinx-1.2.3.tar.gz"
    sha256 "94933b64e2fe0807da0612c574a021c0dac28c7bd3c4a23723ae5a39ea8f3d04"
  end

  resource "docutils" do
    url "https://pypi.python.org/packages/source/d/docutils/docutils-0.12.tar.gz"
    sha256 "c7db717810ab6965f66c8cf0398a98c9d8df982da39b4cd7f162911eb89596fa"
  end

  resource "pygments" do
    url "https://pypi.python.org/packages/source/P/Pygments/Pygments-2.0.2.tar.gz"
    sha256 "7320919084e6dac8f4540638a46447a3bd730fca172afc17d2c03eed22cf4f51"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.3.tar.gz"
    sha256 "2e24ac5d004db5714976a04ac0e80c6df6e47e98c354cb2c0d82f8879d4f8fdb"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.23.tar.gz"
    sha256 "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"
  end

  resource "genshi" do
    url "https://pypi.python.org/packages/source/G/Genshi/Genshi-0.7.tar.gz"
    sha256 "1d154402e68bc444a55bcac101f96cb4e59373100cc7a2da07fbf3e5cc5d7352"
  end

  def install
    ENV.prepend_create_path "PYTHONPATH", buildpath/"python/lib/python2.7/site-packages"
    ENV.prepend_path "PATH", buildpath/"python/bin"
    ENV.prepend_create_path "CMAKE_PROGRAM_PATH", buildpath/"python/bin"
    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(buildpath/"python")
      end
    end
    ENV.prepend_path "PATH", "#{HOMEBREW_PREFIX}/opt/qt5/bin" if build.with? "qt5"

    args = ["-DCMAKE_INSTALL_PREFIX=#{prefix}",
            "-DCMAKE_BUILD_TYPE=Release",
            "-DCMAKE_VERBOSE_MAKEFILE=ON",
            "-Wno-dev",
            "-Dsphinx-pdf=OFF"]

    args << "-Dtest=OFF" if build.without? "check"
    args << "-Dsphinx=OFF" if build.without? "docs"
    args << "-DQt5Core_FOUND=OFF" if build.without? "qt5"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"

      if build.with? "check"
        system "ctest", "-V"
      end

      system "make", "install"
    end
  end

  test do
    system "bf-test", "--usage"
    system "bf-test", "info", "--usage"
  end
end
