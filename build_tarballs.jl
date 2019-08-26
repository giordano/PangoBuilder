# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Pango"
version = v"1.44.5"

# Collection of sources required to build Pango
sources = [
    "http://ftp.gnome.org/pub/GNOME/sources/pango/1.44/pango-1.44.5.tar.xz" =>
    "8527dfcbeedb4390149b6f94620c0fa64e26046ab85042c2a7556438847d7fc1",
    "https://github.com/mesonbuild/meson/releases/download/0.51.1/meson-0.51.1.tar.gz" =>
    "f27b7a60f339ba66fe4b8f81f0d1072e090a08eabbd6aa287683b2c2b9dd2d82",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/pango-*/
MESON="$(readlink -f ../meson-0.*/meson.py)"
mkdir build
cd build

cat << EOF > cross_compile.txt
[binaries]
c = '${CC}'
cpp = '${CXX}'
ar = '${AR}'
strip = '${STRIP}'
pkgconfig = '/usr/bin/pkg-config'

[host_machine]
system = 'linux'
cpu_family = 'x86_64'
cpu = 'i686'
endian = 'little'

[target_machine]
system = 'linux'
cpu_family = 'x86'
cpu = 'i686'
endian = 'little'

[paths]
prefix = '${prefix}'
libdir = 'lib'
bindir = 'bin'
EOF

$MESON .. -Dintrospection=false --cross-file cross_compile.txt
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libpango", :libpango)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/staticfloat/GlibBuilder/releases/download/v2.54.2-2/build.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
