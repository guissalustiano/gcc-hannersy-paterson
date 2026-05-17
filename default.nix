{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "gcc-rvsc";
  hardeningDisable = [ "format" ];

  nativeBuildInputs = with pkgs; [
    # Build tools
    gcc
    gnumake
    flex
    bison
    texinfo
    perl
    python3
    gettext
    pkg-config
    autoconf
    automake
    m4
    libtool
    gperf

    # GCC prerequisites
    gmp
    gmp.dev
    mpfr
    mpfr.dev
    libmpc
    isl
    zstd

    # Other deps (zlib for --with-system-zlib)
    zlib
    zlib.dev

    # Build runner
    just

    # Document
    typst
    liberation_ttf
  ];

  shellHook = ''
    echo "GCC RISC-V (sc0–sc7) dev shell"
    echo "Build dirs: /home/salust/p/build-rv-sc{0..7}"
    echo "Source dir: /home/salust/p/gcc"
    export TYPST_FONT_PATHS="${pkgs.liberation_ttf}/share/fonts/truetype"
  '';
}
