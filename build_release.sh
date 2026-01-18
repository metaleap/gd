cd .build/release_gcc/ && meson compile && cd ../.. || cd ../..
cd .build/release_clang/ && CXX=clang++ CC=clang CXX_LD=lld C_LD=lld meson compile && cd ../.. || cd ../..
