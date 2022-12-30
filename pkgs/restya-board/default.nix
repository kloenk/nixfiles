{ lib, stdenv, fetchzip }:

let

in stdenv.mkDerivation rec {
  pname = "rstya-board";
  version = "1.7";

  src = fetchzip {
    url =
      "https://github.com/RestyaPlatform/board/releases/download/v${version}/board-v${version}.zip";
    sha256 = "sha256-UQ+x7hvBLiHykYCmjJZU8QBwoQn8qi8M6B8h/JA1ZbI=";
    stripRoot = false;
  };

  buildCommand = ''
    mkdir $out
    cp -r "$src"/* "$out"

    chmod +x $out/server/php/shell/*.sh
  '';

  meta = with lib; {
    description = "Web-based kanban board";
    license = licenses.osl3;
    homepage = "https://restya.com";
    maintainers = with maintainers; [ tstrobel ];
    platforms = platforms.unix;
  };
}

