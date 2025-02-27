{
  lib,
  stdenv,
  replaceVars,
  fetchFromGitHub,

  # Deps tools
  autoconf,
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
    # Optional Features
    "--enable-profiling"
    "--enable-check-lisp-object-type"
    "--enable-gtk-deprecation-warnings"

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
    "--with-ns"
    "--with-gconf"
    "--with-small-ja-dic"
    "--with-xwidgets"
    "--with-native-compilation"

    "--with-sound=yes"
  ];

  patches = [
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
    autoconf
    pkg-config
    texinfo
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  buildInputs = [
    libgccjit
    zlib
    gnutls
    ncurses
    imagemagick
    tree-sitter
  ];

  postInstall = lib.strings.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir $out/Application
    mkdir $out/bin
    cp -r nextstep/Emacs.app $out/Application
    cp nextstep/Emacs.app/Contents/MacOS/bin/{ctags,ebrowse,emacsclient,etags} $out/bin/
  '';
}