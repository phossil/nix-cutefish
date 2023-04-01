{ stdenv
, lib
, fetchFromCutefishGitHub
, cutefishUpdateScript
, cmake
}:

let
  name = "gtk-themes";
  version = "0.7";
in

stdenv.mkDerivation {
  inherit version;
  pname = "cutefish-${name}";

  src = fetchFromCutefishGitHub {
    inherit name version;
    sha256 = "sha256-aqJysBgtO2VxPiEVBMVqB+V7FnCsxLAeWYFcs7WfrbU=";
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = cutefishUpdateScript { inherit name version; };

  meta = with lib; {
    description = "CutefishOS - Calculator";
    homepage = "https://cutefishos.com/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ mdevlamynck ];
  };
}
