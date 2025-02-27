{
  lib,
  stdenv,
  fetchFromGitHub,

  # Deps
  autoreconfHook,
  texinfo,
  ncurses,
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
  ];

  nativeBuildInputs = [
    autoreconfHook
    texinfo
  ];

  buildInputs = [
    ncurses
  ];
}
