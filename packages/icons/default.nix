{ stdenv
, lib
, fetchFromCutefishGitHub
, cutefishUpdateScript
, cmake
}:

let
  name = "icons";
  version = "0.8";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "sha256-X5Hobhe4+nUnDbQYqa+PCMvXRotGwWmJ79QVnsUl4EE=";
  };

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    for i in $(find -name CMakeLists.txt)
    do
      substituteInPlace $i \
        --replace /usr/ "" \
        --replace /etc/ etc/
    done
  '';

  passthru.updateScript = cutefishUpdateScript { inherit name version; };

  meta = with lib; {
    description = "CutefishOS - System default icon theme";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
