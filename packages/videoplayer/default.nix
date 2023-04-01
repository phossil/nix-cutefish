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
, mpv
}:

let
  name = "videoplayer";
  version = "0.5";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "sha256-Lwdp4NxixAJwNjvIaXRjJyy6BcbE/AuWVgbbOsHDlgM=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = [
    qtbase
    qtquickcontrols2
    qttools
    mpv
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

    # `error: too many initializers for 'mpv_opengl_init_params'`    
    substituteInPlace src/mpvobject.cpp \
      --replace "nullptr, nullptr" "nullptr"
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
