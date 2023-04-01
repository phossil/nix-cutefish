{ stdenv
, lib
, fetchFromCutefishGitHub
, cutefishUpdateScript
, cmake
, extra-cmake-modules
, wrapQtAppsHook
, qtbase
, qtquickcontrols2
, libkscreen
, kio
, qtsensors
, bluez-qt
, networkmanager-qt
, modemmanager-qt
, libcanberra
, libpulseaudio
, util-linux
, libselinux
, libsepol
, pcre
, fetchpatch
, accountsservice
}:

let
  name = "libcutefish";
  version = "0.7";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "sha256-MOmVPoDTyzk7cHmXXhG+794A81cDVkju0OvWCR2RtcQ=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];

  buildInputs = [
    qtbase
    qtquickcontrols2
    libkscreen
    kio
    qtsensors
    bluez-qt
    networkmanager-qt
    modemmanager-qt
    libcanberra
    libpulseaudio
    util-linux
    libselinux
    libsepol
    pcre
    accountsservice
  ];

  patches = [
    ./cmake.patch
    (fetchpatch {
      name = "libkscreen-5.27.patch";
      url = "https://raw.githubusercontent.com/archlinux/svntogit-community/c7cc31d00d5b8c3c44dad14977d29078379136c3/trunk/libkscreen-5.27.patch";
      sha256 = "0KCoaSboTuJ2LJfUDYxoNxIu17WUeohsc4dJZWaNAWE=";
    })
  ];

  postPatch = ''
    for i in $(find -name CMakeLists.txt)
    do
      substituteInPlace $i \
        --replace /usr/ "" \
        --replace /etc/ etc/
    done

    for i in $(find -name '*.cpp')
    do
      substituteInPlace $i \
        --replace /usr/share /run/current-system/sw/share
    done

    # kscreen related fix
    substituteInPlace CMakeLists.txt \
        --replace "CMAKE_CXX_STANDARD 14" "CMAKE_CXX_STANDARD 17"
  '';

  passthru.updateScript = cutefishUpdateScript { inherit name version; };

  meta = with lib; {
    description = "CutefishOS - System Library";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
