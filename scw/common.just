gcc_src   := justfile_directory() + "/../.."
build_dir := justfile_directory() + "/build"
prefix    := justfile_directory() + "/install"

default: build install

configure:
    mkdir -p {{build_dir}}
    cd {{build_dir}} && {{gcc_src}}/configure \
        --target={{target}} \
        --prefix={{prefix}} \
        --enable-languages=c \
        --with-newlib

build:
    cd {{build_dir}} && make all-gcc -j$(nproc)

install:
    cd {{build_dir}} && make install-gcc

test:
    PATH={{prefix}}/bin:$PATH \
    python3 {{justfile_directory()}}/../test/run_tests.py {{target}} {{justfile_directory()}}/instructions.txt
