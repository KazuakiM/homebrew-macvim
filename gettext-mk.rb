require 'formula'

class GettextMk < Formula
  homepage 'http://www.gnu.org/software/gettext/'
  url 'http://ftpmirror.gnu.org/gettext/gettext-0.18.1.1.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/gettext/gettext-0.18.1.1.tar.gz'
  sha1 '5009deb02f67fc3c59c8ce6b82408d1d35d4e38f'

  keg_only "OS X provides the BSD gettext library and some software gets confused if both are in the library path."

  #option :universal
  option 'with-examples', 'Keep example files'
  option 'with-binary-release', ''

  def patches
    # Patch to allow building with Xcode 4; safe for any compiler.
    p = {:p0 => ['https://trac.macports.org/export/79617/trunk/dports/devel/gettext/files/stpncpy.patch']}

    unless build.include? 'with-examples'
      # Use a MacPorts patch to disable building examples at all,
      # rather than build them and remove them afterwards.
      p[:p0] << 'https://trac.macports.org/export/79183/trunk/dports/devel/gettext/files/patch-gettext-tools-Makefile.in'
    end

    return p
  end

  def install
    ENV.libxml2
    ENV["HOMEBREW_OPTFLAGS"] = "-march=core2" if build.with? 'binary-release'
    ENV.append 'LDFLAGS', '-headerpad_max_install_names'

    system "./configure",
      "--disable-dependency-tracking",
      "--disable-debug",
      "--prefix=#{prefix}",
      "--with-included-gettext",
      "--with-included-glib",
      "--with-included-libcroco",
      "--with-included-libunistring",
      "--without-emacs",
      # Don't use VCS systems to create these archives
      "--without-git",
      "--without-cvs"

    system "make"
    ENV.deparallelize # install doesn't support multiple make jobs
    system "make install"
  end
end
