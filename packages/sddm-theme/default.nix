{ stdenv
, lib
, fetchFromCutefishGitHub
, cutefishUpdateScript
, cmake
, extra-cmake-modules
, wrapQtAppsHook
, qtbase
, qtquickcontrols2
, qtgraphicaleffects
, libcutefish
, fishui
}:

let
  name = "sddm-theme";
  version = "1";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name;
    version = "7da9648764bb8113a6a9b07b3ca48799861b4451";
    sha256 = "5XKbMcHs7L3v/cEO5hWKF90/1lmsDIqhMNAY3FNa2ps=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [
    qtbase
    qtquickcontrols2
    qtgraphicaleffects
    libcutefish
    fishui
  ];
  propagatedUserEnvPkgs = [ libcutefish fishui qtgraphicaleffects ];

  postPatch = ''
    for i in $(find -name CMakeLists.txt)
    do
      substituteInPlace $i \
        --replace /usr/ "" \
        --replace /etc/ etc/
    done

    for i in $(find -name '*.qml')
    do
      substituteInPlace $i \
        --replace /usr/share /run/current-system/sw/share
    done
  '';

  #passthru.updateScript = cutefishUpdateScript { inherit name version; };

  meta = with lib; {
    description = "CutefishOS - File manager";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
