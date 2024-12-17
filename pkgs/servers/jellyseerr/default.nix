{
  lib,
  fetchFromGitHub,
  makeWrapper,
  node-pre-gyp,
  nodejs,
  pnpm_9,
  python3,
  stdenv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jellyseerr";
  version = "2.1.0";

  src =
    with finalAttrs;
    fetchFromGitHub {
      owner = "Fallenbagel";
      repo = "jellyseerr";
      rev = "v${version}";
      hash = "sha256-5kaeqhjUy9Lgx4/uFcGRlAo+ROEOdTWc2m49rq8R8Hs=";
    };

  nativeBuildInputs = [
    nodejs
    makeWrapper
    pnpm_9.configHook

    # Needed for compiling sqlite3 and bcrypt from source
    node-pre-gyp
    python3
  ];

  pnpmDeps = pnpm_9.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-xu6DeaBArQmnqEnIgjc1DTZujQebSkjuai9tMHeQWCk=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm build

    # Fixes "SQLite package has not been found installed" at launch
    pushd node_modules/sqlite3
    export CPPFLAGS="-I${nodejs}/include/node"
    npm run install --build-from-source --nodedir=${nodejs}/include/node
    popd

    pushd node_modules/bcrypt
    export CPPFLAGS="-I${nodejs}/include/node"
    npm run install --build-from-source --nodedir=${nodejs}/include/node
    popd

    runHook postBuild
  '';

  preInstall = ''
    mkdir $out
    cp ./package.json $out
    rm -r .next/cache
    cp -R ./.next $out
    cp -R ./dist $out
    cp ./overseerr-api.yml $out
    cp -R ./node_modules $out
  '';

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/jellyseerr" \
      --chdir $out \
      --add-flags "$out/dist/index.js" \
      --set NODE_ENV production
  '';

  meta = with lib; {
    description = "Fork of overseerr for jellyfin support";
    homepage = "https://github.com/Fallenbagel/jellyseerr";
    longDescription = ''
      Jellyseerr is a free and open source software application for managing
      requests for your media library. It is a a fork of Overseerr built to
      bring support for Jellyfin & Emby media servers!
    '';
    license = licenses.mit;
    maintainers = with maintainers; [
      camillemndn
      pizzapim
    ];
    platforms = platforms.linux;
    mainProgram = "jellyseerr";
  };
})
