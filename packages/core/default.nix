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
, kwindowsystem
, qtgraphicaleffects
, kglobalaccel
, polkit
, polkit-qt
, pulseaudio
, xorg
, pcre
, fishui
, libsForQt5
, util-linux
, libselinux
, libsepol
, mesa
}:

let
  name = "core";
  version = "0.8";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "sha256-yrs706ZmDvTADevCxSLk/ot5VkWyNi2wXxybumHUSDs=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [
    qtbase
    qtquickcontrols2
    qtx11extras
    qttools
    kwindowsystem
    qtgraphicaleffects
    kglobalaccel
    polkit
    polkit-qt
    pulseaudio
    pcre
    fishui
    libsForQt5.kidletime
    util-linux
    libselinux
    libsepol
    mesa
  ] ++ (with xorg; [
    libSM
    libXdmcp
    libXtst
    libXcursor
    xf86inputlibinput
    libxcb
    libxcvt
    xorgserver
    xf86inputsynaptics
  ]);

  cmakeFlags = [
    "-DXORGLIBINPUT_INCLUDE_DIRS=${lib.getDev xorg.xf86inputlibinput}/include/xorg"
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

    # desktop file is not loaded by GDM
    substituteInPlace session/cutefish-xsession.desktop \
      --replace "Application" "Xsession" \
      --replace "cutefish-session" "$out/bin/cutefish-session"
  '';

  passthru = {
    providedSessions = [ "cutefish-xsession" ];
    updateScript = cutefishUpdateScript { inherit name version; };
  };

  meta = with lib; {
    description = "CutefishOS - System components and backend";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
