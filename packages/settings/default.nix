{ stdenv
, lib
, fetchFromCutefishGitHub
, cutefishUpdateScript
, cmake
, extra-cmake-modules
, wrapQtAppsHook
, qtbase
, qtquickcontrols2
, qtx11extras
, qttools
, qtgraphicaleffects
, networkmanager-qt
, modemmanager-qt
, xorg
, libcutefish
, fishui
, libxcrypt
, libsForQt5
}:

let
  name = "settings";
  version = "0.8";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "tkJeAiZwyHoVnC9uYa0INGWHgKvXsrge//GqBctKoKU=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [
    qtbase
    qtquickcontrols2
    qtx11extras
    qttools
    qtgraphicaleffects
    networkmanager-qt
    modemmanager-qt
    xorg.libXcursor
    libcutefish
    fishui
    libxcrypt
    libsForQt5.kconfig
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
  '';

  passthru.updateScript = cutefishUpdateScript { inherit name version; };

  meta = with lib; {
    description = "CutefishOS - System settings";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
