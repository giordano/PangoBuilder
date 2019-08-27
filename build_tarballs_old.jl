# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Pango"
version = v"1.42.4"

# Collection of sources required to build Pango
sources = [
    "http://ftp.gnome.org/pub/GNOME/sources/pango/$(version.major).$(version.minor)/pango-$(version).tar.xz" =>
    "1d2b74cd63e8bd41961f2f8d952355aa0f9be6002b52c8aa7699d9f5da597c9d"
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/pango-*/
./configure --prefix=$prefix --host=$target --enable-introspection=no
# The generated Makefile tries to build some examples in the "tests" directory,
# but this would fail.  Let's skip it.
sed -i 's/^\(SUBDIRS = .*\) tests/\1/' Makefile
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libpango", :libpango)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    # Pango-only dependencies
    "https://github.com/giordano/FriBidiBuilder/releases/download/v1.0.5/build_FriBidi.v1.0.5.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Libffi-v3.2.1-0/build_Libffi.v3.2.1.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Gettext-v0.19.8-0/build_Gettext.v0.19.8.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Libiconv-v1.15-0/build_Libiconv.v1.15.0.jl",
    # Freetype2-related dependencies
    "https://github.com/JuliaGraphics/FreeTypeBuilder/releases/download/v2.9.1-4/build_FreeType2.v2.10.0.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Bzip2-v1.0.6-2/build_Bzip2.v1.0.6.jl",
    # Glib-related dependencies
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Glib-v2.59.0%2B0/build_Glib.v2.59.0.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/PCRE-v8.42-2/build_PCRE.v8.42.0.jl",
    # Cairo-related dependencies
    "https://github.com/giordano/Yggdrasil/releases/download/Cairo-v1.14.12/build_Cairo.v1.14.12.jl",
    "https://github.com/JuliaPackaging/Yggdrasil/releases/download/Pixman-v0.36.0-0/build_Pixman.v0.36.0.jl",
    "https://github.com/JuliaIO/LibpngBuilder/releases/download/v1.0.3/build_libpng.v1.6.37.jl",
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.4/build_Zlib.v1.2.11.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
