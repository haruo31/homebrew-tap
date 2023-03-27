class Gmime < Formula
  desc "MIME mail utilities"
  homepage "https://github.com/jstedfast/gmime"
  url "https://github.com/jstedfast/gmime/archive/557d20499152a532d062bf96142593997722ef11.zip"
  version "3.2.13-1"
  sha256 "5563fe7828e932715b4858660da4eea3cde0ec302b53612da9404764286f9635"
  license "LGPL-2.1-or-later"

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "gtk-doc" => :build
  depends_on "glib"
  depends_on "gpgme"

  def install
    args = %w[
      --enable-largefile
      --disable-vanilla
      --disable-glibtest
      --enable-crypto
      --enable-introspection
    ]

    system "./autogen.sh", *std_configure_args, *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <gmime/gmime.h>
      int main (int argc, char **argv)
      {
        g_mime_init();
        if (gmime_major_version>=3) {
          return 0;
        } else {
          return 1;
        }
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    pcre = Formula["pcre"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/gmime-3.0
      -I#{pcre.opt_include}
      -D_REENTRANT
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lgio-2.0
      -lglib-2.0
      -lgmime-3.0
      -lgobject-2.0
    ]
    flags << "-lintl" if OS.mac?
    system ENV.cc, "-o", "test", "test.c", *flags
    system "./test"
  end
end

