project(
    'gd',
    ['cpp', 'c'],
    version: '0.72.0',
    default_options: ['cpp_std=c++20', 'c_std=c23', 'cpp_rtti=false', 'cpp_eh=none'],
    meson_version: '>=1.1',
)
add_global_arguments(
    '-DSDL2=1',
    '-DWI_UNORDERED_MAP_TYPE=2',
    '-mf16c',
    '-gsplit-dwarf',
    '-fms-extensions',
    '-msse2',
    '-mfpmath=sse',
    '-march=native',
    '-Wno-switch',
    '-Wno-unused-variable',
    # '-Wno-incompatible-pointer-types', # note for the future: keep disabled AND keep this reminder  =)

    language: ['cpp', 'c'],
)
add_global_link_arguments(
    '-lm',
    language: ['cpp', 'c'],
)

wi_build_dir = get_option('WICKED_BUILD_DIR')
cpp = meson.get_compiler('cpp')
dep_sdl2 = dependency('SDL2', include_type: 'system', static: false)
dep_pthread = dependency('threads', include_type: 'system', static: false)
dep_oidn = dependency('OpenImageDenoise', include_type: 'system', static: false)
dep_jolt = cpp.find_library(
    'Jolt',
    dirs: [meson.project_source_root() / wi_build_dir / 'WickedEngine'],
    required: true,
    static: true,
)
dep_faudio = cpp.find_library(
    'FAudio',
    dirs: [
        meson.project_source_root() / wi_build_dir / 'WickedEngine/Utility/FAudio',
    ],
    required: true,
    static: true,
)
dep_lua = cpp.find_library(
    'LUA',
    dirs: [meson.project_source_root() / wi_build_dir / 'WickedEngine/LUA'],
    required: true,
    static: true,
)
dep_wiutil = cpp.find_library(
    'Utility',
    dirs: [meson.project_source_root() / wi_build_dir / 'WickedEngine/Utility'],
    required: true,
    static: true,
)
dep_wicked = declare_dependency(
    dependencies: [
        cpp.find_library(
            'WickedEngine',
            dirs: [meson.project_source_root() / wi_build_dir / 'WickedEngine'],
            required: true,
            static: true,
        ),
        dep_sdl2,
        dep_pthread,
        dep_oidn,
        dep_jolt,
        dep_faudio,
        dep_lua,
        dep_wiutil,
    ],
    include_directories: include_directories('3rdparty/turanszkij_WickedEngine/WickedEngine'),
)

# lib_wiso = library(
#     'wiso',
#     dependencies: [
#         dep_pthread,
#         dep_sdl2,
#         dep_lua,
#         dep_jolt,
#         dep_faudio,
#         dep_wiutil,
#         dep_wicked,
#     ],
#     link_language: 'cpp',
#     implicit_include_directories: true,
#     cpp_pch: 'pch/wi_pch.h',
#     sources: [
#         'wiso/wiso.cpp',
#     ],
# )

executable(
    'gd00.exec',
    dependencies: [dep_sdl2],
    link_language: 'cpp',
    implicit_include_directories: true,
    sources: [
        'gd00/main.cpp',
    ],
)

executable(
    'gd01.exec',
    cpp_pch: 'pch/wi_pch.h',
    dependencies: [dep_sdl2, dep_wicked],
    link_language: 'cpp',
    implicit_include_directories: true,
    # link_with: [lib_wiso], # not anytime soon I guess =(
    sources: [
        'gd01/main.cpp',
    ],
)

executable(
    'gd02.exec',
    cpp_pch: 'pch/wi_pch.h',
    dependencies: [dep_sdl2, dep_wicked],
    link_language: 'cpp',
    implicit_include_directories: true,
    sources: [
        'gd02/main.cpp',
    ],
)

executable(
    'gd03_gdtv_01_project_boost.exec',
    cpp_pch: 'pch/wi_pch.h',
    dependencies: [dep_sdl2, dep_wicked],
    link_language: 'cpp',
    implicit_include_directories: true,
    sources: [
        'gd03/main.cpp',
    ],
)
