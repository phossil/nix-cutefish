{ stdenv
, lib
, fetchFromCutefishGitHub
, cutefishUpdateScript
, cmake
, extra-cmake-modules
, wrapQtAppsHook
, qtbase
, qtquickcontrols2
, qttools
, qtgraphicaleffects
, libcutefish
, fishui
}:

let
  name = "calculator";
  version = "0.4";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "sha256-DMsRVI9QGDYLoJW99FofQHAztnIEVyJ2PT4xBOq5rbg=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [
    qtbase
    qtquickcontrols2
    qttools
    qtgraphicaleffects
    libcutefish
    fishui
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
    description = "CutefishOS - Calculator";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
