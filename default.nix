{
  lib,
  stdenv,
  callPackage,
  replaceVars,
  fetchFromGitHub,
  autoreconfHook,

  # Deps tools
  pkg-config,
  texinfo,
  darwin,
  apple-sdk,

  # Deps
  libgccjit,
  zlib,
  gnutls,
  ncurses,
  imagemagick,
  tree-sitter,

  # Linux Deps
  gtk3,
  xorg,
  giflib,
}:

let
  libGccJitLibraryPaths =
    [
      "${lib.getLib libgccjit}/lib/gcc"
      "${lib.getLib stdenv.cc.libc}/lib"
    ]
    ++ lib.optionals (stdenv.cc ? cc.lib.libgcc) [
      "${lib.getLib stdenv.cc.cc.lib.libgcc}/lib"
    ];

in

stdenv.mkDerivation {
  pname = "emacs";
  version = "30.1";

  src = fetchFromGitHub {
    owner = "emacs-mirror";
    repo = "emacs";
    rev = "emacs-30.1";
    hash = "sha256-wBuWLuFzwB77FqAYAUuNe3CuJFutjqp0XGt5srt7jAo=";
  };

  enableParallelBuilding = true;

  configureFlags = [
    # Optional Packages
    "--with-mailutils"
    "--with-xpm"
    "--with-jpeg"
    "--with-tiff"
    "--with-gif"
    "--with-png"
    "--with-rsvg"
    "--with-webp"
    "--with-sqlite3"
    "--with-lcms2"
    "--with-cairo"
    "--with-cairo-xcb"
    "--with-xml2"
    "--with-tree-sitter"
    "--with-gconf"
    "--with-small-ja-dic"
    "--with-native-compilation"

    "--with-sound=yes"
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # I don't know the reason but this feature cannot use on x86_64-linux, Perhaps WebkitGTK & GTK3 is the reason
    # This feature can use on aarch64-darwin
    "--with-xwidgets"

    "--with-ns"
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    "--with-x-toolkit=gtk3"
  ];

  patches = [
    #./fix-webkitgtk-version.patch
    (replaceVars (./native-comp-driver-options-30.patch) {
      backendPath = (
        lib.concatStringsSep " " (
          builtins.map (x: ''"-B${x}"'') (
            [
              # Paths necessary so the JIT compiler finds its libraries:
              "${lib.getLib libgccjit}/lib"
            ]
            ++ libGccJitLibraryPaths
            ++ [
              # Executable paths necessary for compilation (ld, as):
              "${lib.getBin stdenv.cc.cc}/bin"
              "${lib.getBin stdenv.cc.bintools}/bin"
              "${lib.getBin stdenv.cc.bintools.bintools}/bin"
            ]
            ++ lib.optionals stdenv.hostPlatform.isDarwin [
              # The linker needs to know where to find libSystem on Darwin.
              "${apple-sdk.sdkroot}/usr/lib"
            ]
          )
        )
      );
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    texinfo
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    #webkitgtk_4_0
  ];

  env = {
    NATIVE_FULL_AOT = "1";
    LIBRARY_PATH = lib.concatStringsSep ":" libGccJitLibraryPaths;
  };

  buildInputs = [
    libgccjit
    zlib
    gnutls
    ncurses
    imagemagick
    tree-sitter
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    xorg.libXpm
    giflib
    #webkitgtk_4_0
  ];

  postInstall = lib.strings.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv nextstep/Emacs.app $out/Applications
  '';

  meta = {
    platforms = lib.platforms.unix;
  };
}
