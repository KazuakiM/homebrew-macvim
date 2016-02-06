require 'formula'

class MacvimKaoriya < Formula
  desc 'GUI for vim, made for OS X'
  homepage 'https://github.com/splhack/macvim-kaoriya'
  head 'https://github.com/splhack/macvim.git'

  option 'with-override-system-vim', 'Override system vim'

  deprecated_option 'override-system-vim' => 'with-override-system-vim'

  depends_on 'cmigemo-mk'                                      => :build
  depends_on 'universal-ctags/universal-ctags/universal-ctags' => :build
  depends_on 'gettext'                                         => :build
  depends_on 'perl'                                            => :build
  depends_on 'python3'                                         => :build
  depends_on 'ruby'                                            => :build
  depends_on 'lua'                                             => :build
  depends_on 'luajit'                                          => :build

  PYTHON3_CONFIG = `python3-config --prefix|tr -d '\n'`
  RUBY_WHICH     = `which ruby|tr -d '\n'`

  def install
    ENV.clang if MacOS.version >= :lion

    system './configure',
      '--disable-netbeans',
      '--disable-selinux',
      '--disable-xim',
      '--disable-xsmp',
      '--disable-xsmp-interact',
      '--enable-cscope',
      '--enable-fail-if-missing',
      '--enable-luainterp',
      '--enable-multibyte',
      '--enable-rubyinterp',
      '--enable-perlinterp',
      '--enable-python3interp',
      "--prefix=#{prefix}",
      '--with-features=huge',
      "--with-ruby-command=#{RUBY_WHICH}",
      "--with-python3-config-dir=#{PYTHON3_CONFIG}/lib/python3.5/config-3.5m",
      '--with-luajit',
      "--with-lua-prefix=#{HOMEBREW_PREFIX}",
      '--with-tlib=ncurses'
    system 'make'

    prefix.install 'src/MacVim/build/Release/MacVim.app'

    app     = prefix + 'MacVim.app/Contents'
    macos   = app    + 'MacOS'
    runtime = app    + 'Resources/vim/runtime'

    macos.install 'src/MacVim/mvim'
    mvim = macos + 'mvim'
    [
      'gview',   'gvim',     'gvimdiff',
      'mview',   'mvimdiff',
      'vimdiff', 'view'
    ].each do |t|
      ln_s 'mvim', macos + t
    end
    inreplace mvim do |s|
      s.gsub! /^# (VIM_APP_DIR=).*/, "\\1`dirname \"$0\"`/../../.."
      s.gsub! /^(binary=).*/, "\\1\"`(cd \"$VIM_APP_DIR/MacVim.app/Contents/MacOS\"; pwd -P)`/Vim\""
    end

    dict = runtime + 'dict'
    mkdir_p dict
    Dir.glob("#{HOMEBREW_PREFIX}/share/migemo/utf-8/*").each do |f|
      cp f, dict
    end
  end
end
