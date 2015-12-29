homebrew-macvim
===

[![Build Status](https://travis-ci.org/KazuakiM/homebrew-macvim.svg)](https://travis-ci.org/KazuakiM/homebrew-macvim)

This repository is inspired at [splhack](https://github.com/splhack/homebrew-splhack).

## Usage
```bash
$ brew tap 'kazuakim/macvim'
$ brew install --HEAD macvim-kaoriya
```

## Warning
If you get universal-ctags error, check [here](https://github.com/universal-ctags/homebrew-universal-ctags/pull/4).
```ruby
#/usr/local/Library/Taps/universal-ctags/homebrew-universal-ctags/universal-ctags.rb

   homepage 'https://github.com/universal-ctags/ctags'
   head 'https://github.com/universal-ctags/ctags.git'
   depends_on :autoconf
+  depends_on :automake
   conflicts_with 'ctags', :because => 'this formula installs the same executable as the ctags formula'

   def install
-    system "autoheader"
-    system "autoconf"
+    system "./autogen.sh"
     system "./configure",
       "--prefix=#{prefix}",
       "--enable-macro-patterns",
```

##Author

[KazuakiM](https://github.com/KazuakiM/)

##License

This software is released under the MIT License, see LICENSE.
