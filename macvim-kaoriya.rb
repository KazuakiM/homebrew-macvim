class MacvimKaoriya < Formula
  desc "GUI for vim, made for OS X"
  homepage "https://github.com/splhack/macvim-kaoriya"
  url "https://github.com/splhack/macvim/archive/20151225.tar.gz"
  #sha1 "40da9b5f8ff5b757e3597fdbd0bab0f5c8c06ee4"
  revision 1
  head "https://github.com/splhack/macvim.git"

  depends_on "universal-ctags/universal-ctags/universal-ctags" => :build
  depends_on "cmigemo" => :build
  depends_on "gettext" => :build
  depends_on "perl"    => :build
  depends_on "python3" => :build
  depends_on "lua"     => :build
  depends_on "luajit"  => :build

  def install
    ENV.clang if MacOS.version >= :lion

    system "./configure",
      "--disable-netbeans",
      "--disable-selinux",
      "--disable-xim",
      "--disable-xsmp",
      "--disable-xsmp-interact",
      "--enable-cscope",
      "--enable-fail-if-missing",
      "--enable-luainterp",
      "--enable-multibyte",
      "--enable-rubyinterp=dynamic",
      "--enable-perlinterp",
      "--enable-python3interp",
      "--enable-terminal",
      "--prefix=#{prefix}",
      "--with-features=huge",
      "--with-python3-config-dir=#{HOMEBREW_PREFIX}/Frameworks/Python.framework/Versions/3.6/lib/python3.6/config-3.6m-darwin",
      "--with-luajit",
      "--with-lua-prefix=#{HOMEBREW_PREFIX}",
      "--with-tlib=ncurses"
    system "make"

    prefix.install "src/MacVim/build/Release/MacVim.app"

    app = prefix + "MacVim.app/Contents"
    bin = prefix + "bin"
    runtime = app + "Resources/vim/runtime"

    mkdir_p bin
    [
      "gview",   "gvim",     "gvimdiff",
      "mview",   "mvim",     "mvimdiff",
      "view",    "vim",      "vimdiff"
    ].each do |t|
      ln_s "../MacVim.app/Contents/bin/mvim", bin + t
    end

    dict = runtime + "dict"
    mkdir_p dict
    Dir.glob("#{HOMEBREW_PREFIX}/share/migemo/utf-8/*").each do |f|
      cp f, dict
    end
  end

  test do
    system bin/"vim", "--version"
  end
end
