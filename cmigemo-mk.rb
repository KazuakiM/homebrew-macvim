class CmigemoMk < Formula
  desc "Japanese increment search with 'Romanization of Japanese'"
  homepage "http://www.kaoriya.net/software/cmigemo"
  url "https://github.com/koron/cmigemo/archive/rel-1_2.tar.gz"
  #sha1 "0ae4c8d3229644d8e7caad2b99596ff032e70a7c"
  revision 1
  head "https://github.com/koron/cmigemo.git"

  depends_on "nkf" => :build

  def install
    ENV.append "LDFLAGS", "-headerpad_max_install_names"

    system "./configure", "--prefix=#{prefix}"
    system "make", "osx-dict"
    cd "dict" do
      system "make", "utf-8"
    end
    ENV.deparallelize
    system "make", "osx-install"
  end

  test do
    system bin/"cmigemo", "--help"
  end
end
