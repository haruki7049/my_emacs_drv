{
  fetchurl,
  webkitgtk_4_0,

  libwpe,
  libwpe-fdo,
  xorg,
  openjpeg,
}:

webkitgtk_4_0.overrideAttrs (finalAttrs: prevAttrs: {
  version = "2.40.5";

  src = fetchurl {
    url = "https://webkitgtk.org/releases/webkitgtk-2.40.5.tar.xz";
    hash = "sha256-feBRomNmhiHZGmGl6xw3cdGnzskABD1K/vBsMmwWA38=";
  };

  buildInputs = (prevAttrs.buildInputs or []) ++ [
    libwpe
    libwpe-fdo
    xorg.libXt
    openjpeg
  ];

  cmakeFlags = (prevAttrs.cmakeFlags or []) ++ [
    "-DCMAKE_C_FLAGS=-Wno-missing-template-arg-list-after-template-kw"
    "-DCMAKE_CXX_FLAGS=-Wno-missing-template-arg-list-after-template-kw"
  ];

  #CFLAGS = "-Wno-missing-template-arg-list-after-template-kw";
})
