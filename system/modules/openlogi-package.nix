{ lib, stdenv, fetchurl, autoPatchelfHook, zstd, patchelf
, libxkbcommon, libxcb, fontconfig, freetype, libGL, wayland, vulkan-loader
}:

let
  version = "0.8.9";
in
stdenv.mkDerivation {
  pname = "openlogi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/AprilNEA/OpenLogi/releases/download/v${version}/openlogi-v${version}-linux-amd64.pkg.tar.zst";
    sha256 = "fa3f2a0d0ed0ee711742f7e436e0cd2ce2b3789b99171611f124e46cbd464897";
  };

  nativeBuildInputs = [ autoPatchelfHook zstd patchelf ];
  buildInputs = [ stdenv.cc.cc.lib libxkbcommon libxcb fontconfig freetype ];

  # GL/wayland/vulkan-loader are dlopen'd by GPUI at runtime, not linked, so
  # autoPatchelfHook's NEEDED-entry scan can't discover them on its own.
  # runtimeDependencies forces them onto the rpath regardless — and unlike a
  # manual patchelf in postFixup, it survives autoPatchelfHook's own rpath
  # rewrite (which runs later and otherwise clobbers it).
  runtimeDependencies = [ libGL wayland vulkan-loader ];

  unpackPhase = ''
    mkdir source
    tar --use-compress-program=unzstd -xf "$src" -C source
  '';

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    for binary in openlogi openlogi-agent openlogi-desktop openlogi-overlay; do
      install -Dm755 "source/usr/bin/$binary" "$out/bin/$binary"
    done

    install -Dm644 source/etc/udev/rules.d/70-openlogi.rules \
      "$out/lib/udev/rules.d/70-openlogi.rules"

    mkdir -p "$out/share"
    cp -r source/usr/share/applications "$out/share/"
    cp -r source/usr/share/icons "$out/share/"
    cp -r source/usr/share/licenses "$out/share/"

    runHook postInstall
  '';

  meta = {
    description = "Local-first companion for Logitech HID++ peripherals (prebuilt release binary)";
    homepage = "https://github.com/AprilNEA/OpenLogi";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "openlogi";
    platforms = [ "x86_64-linux" ];
  };
}
