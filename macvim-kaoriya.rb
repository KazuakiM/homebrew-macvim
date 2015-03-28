require 'formula'

class MacvimKaoriya < Formula
  homepage 'http://code.google.com/p/macvim-kaoriya/'
  head 'https://github.com/splhack/macvim.git', :branch => 'master'

  depends_on 'cmigemo'
  depends_on 'ctags'
  depends_on 'gettext'
  depends_on 'python'
# depends_on 'python3'
  depends_on 'ruby'
  depends_on 'lua'
  depends_on 'luajit'

  MAC_VERSION    = `sw_vers -productVersion|tr -d '\n'`
  PERL_VERSION   = `perl -v|grep version|awk '{print $9}'|sed 's/[(v|)]//g'`
  PYTHON_VERSION = `python --version 2>&1|awk '{print $2}'`
  PYTHON_CONFIG  = `python-config --prefix|tr -d '\n'`
# PYTHON3_CONFIG = `python3-config --prefix|tr -d '\n'`
  RUBY_WHICH     = `which ruby|tr -d '\n'`
  GETTEXT        = "#{HOMEBREW_PREFIX}/Cellar/gettext/0.19.4"

  def install
    ENV.remove_macosxsdk
    ENV.macosxsdk "#{MAC_VERSION}"
    ENV.append 'MACOSX_DEPLOYMENT_TARGET', "#{MAC_VERSION}"
    ENV.append 'CFLAGS',                   "-mmacosx-version-min=#{MAC_VERSION}"
    ENV.append 'LDFLAGS',                  "-mmacosx-version-min=#{MAC_VERSION} -headerpad_max_install_names"
    ENV.append 'VERSIONER_PERL_VERSION',   "#{PERL_VERSION}"
    ENV.append 'VERSIONER_PYTHON_VERSION', "#{PYTHON_VERSION}"
#   ENV.append 'vi_cv_path_python3',       "#{HOMEBREW_PREFIX}/bin/python3"

    system './configure',
      '--disable-netbeans',
      '--disable-selinux',
      '--disable-xim',
      '--disable-xsmp',
      '--disable-xsmp-interact',
      '--enable-cscope',
      '--enable-fail-if-missing',
      '--enable-fontset',
      '--enable-luainterp',
      '--enable-multibyte',
      '--enable-rubyinterp',
      '--enable-perlinterp',
      '--enable-pythoninterp',
#     '--enable-python3interp',
      "--prefix=#{prefix}",
      '--with-features=huge',
      "--with-ruby-command=#{RUBY_WHICH}",
      "--with-python-config-dir=#{PYTHON_CONFIG}/lib/python2.7/config",
#     "--with-python3-config-dir=#{PYTHON3_CONFIG}/lib/python3.4/config-3.4m",
      '--with-luajit',
      "--with-lua-prefix=#{HOMEBREW_PREFIX}",
      '--with-tlib=ncurses'

    `rm src/po/ja.sjis.po`
    `touch src/po/ja.sjis.po`

    gettext = "#{GETTEXT}/bin/"
    inreplace 'src/po/Makefile' do |s|
      s.gsub! /^(XGETTEXT\s*=.*)(xgettext.*)/, "\\1#{gettext}\\2"
      s.gsub! /^(MSGMERGE\s*=.*)(msgmerge.*)/, "\\1#{gettext}\\2"
    end

    Dir.chdir('src/po') {system 'make'}
    system 'make'

    prefix.install 'src/MacVim/build/Release/MacVim.app'

    app     = prefix + 'MacVim.app/Contents'
    macos   = app    + 'MacOS'
    runtime = app    + 'Resources/vim/runtime'

    macos.install 'src/MacVim/mvim'
    mvim = macos + 'mvim'
    ['vimdiff', 'view', 'mvimdiff', 'mview'].each do |t|
      ln_s 'mvim', macos + t
    end
    inreplace mvim do |s|
      s.gsub! /^# (VIM_APP_DIR=).*/, "\\1`dirname \"$0\"`/../../.."
      s.gsub! /^(binary=).*/, "\\1\"`(cd \"$VIM_APP_DIR/MacVim.app/Contents/MacOS\"; pwd -P)`/Vim\""
    end

    cp "#{HOMEBREW_PREFIX}/bin/ctags", macos

    dict = runtime + 'dict'
    mkdir_p dict
    Dir.glob("#{HOMEBREW_PREFIX}/share/migemo/utf-8/*").each do |f|
      cp f, dict
    end

    [
      "#{HOMEBREW_PREFIX}/opt/gettext-mk/lib/libintl.dylib",
      "#{HOMEBREW_PREFIX}/lib/libmigemo.dylib",
    ].each do |lib|
      newname = "@executable_path/../Frameworks/#{File.basename(lib)}"
      system "install_name_tool -change #{lib} #{newname} #{macos + 'Vim'}"
      cp lib, app + 'Frameworks'
    end
  end
end
