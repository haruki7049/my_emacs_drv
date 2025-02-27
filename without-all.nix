{
  lib,
  stdenv,
  fetchFromGitHub,

  # Deps
  autoreconfHook,
  texinfo,
  ncurses,

  # macOS Deps
  gnutls,
  darwin,
}:

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

    "--without-all"
    "--with-toolkit-scroll-bars"
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "--with-ns"
  ];

  nativeBuildInputs = [
    autoreconfHook
    texinfo
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  buildInputs = [
    ncurses
  ];

  postInstall = lib.strings.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv nextstep/Emacs.app $out/Applications
  '';

  meta = {
    platforms = [
      # Here are Tested platforms
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
