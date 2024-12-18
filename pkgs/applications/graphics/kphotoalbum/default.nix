{
  mkDerivation,
  fetchpatch,
  fetchurl,
  lib,
  extra-cmake-modules,
  kdoctools,
  wrapGAppsHook3,
  exiv2,
  ffmpeg,
  libkdcraw,
  phonon,
  libvlc,
  kconfig,
  kiconthemes,
  kio,
  kinit,
  kpurpose,
}:

mkDerivation rec {
  pname = "kphotoalbum";
  version = "5.11.0";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${version}/${pname}-${version}.tar.xz";
    hash = "sha256-NWtOIHJXtc8PlltYbbp2YwDf/3QI3MdHNDX7WVQMig4=";
  };

  # Fix build against exiv2 0.28.1
  patches = [
    (fetchpatch {
      url = "https://invent.kde.org/graphics/kphotoalbum/-/commit/1ceb1ae37f3f95aa290b0846969af4b26f616760.patch";
      hash = "sha256-SfBJHyJZcysvemc/F09GPczBjcofxGomgjJ814PSU+c=";
    })
  ];

  # not sure if we really need phonon when we have vlc, but on KDE it's bound to
  # be on the system anyway, so there is no real harm including it
  buildInputs = [
    exiv2
    phonon
    libvlc
  ];

  nativeBuildInputs = [
    extra-cmake-modules
    kdoctools
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [
    kconfig
    kiconthemes
    kio
    kinit
    kpurpose
    libkdcraw
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ ffmpeg ]}"
  ];

  meta = with lib; {
    description = "Efficient image organization and indexing";
    homepage = "https://www.kphotoalbum.org/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ peterhoeg ];
    inherit (kconfig.meta) platforms;
  };
}
