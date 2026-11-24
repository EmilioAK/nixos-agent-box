{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-twig";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/leostera/git-twig/releases/download/v${finalAttrs.version}/git-twig-v${finalAttrs.version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-gZ4evqADn8RA8lX8Wrsti+c1qDHlTJuT0IK9PgMB7qU=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 git-twig "$out/bin/git-twig"
    install -Dm644 git-twig.1 "$out/share/man/man1/git-twig.1"
    runHook postInstall
  '';

  meta = {
    description = "Lightweight Git worktree creation";
    homepage = "https://github.com/leostera/git-twig";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "git-twig";
  };
})
