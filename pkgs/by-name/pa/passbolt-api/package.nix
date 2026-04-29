{
  lib,
  fetchFromGitHub,
  php84,
  dataDir ? "/var/lib/passbolt",
}:

let
  php = php84.withExtensions (
    { enabled, all }:
    enabled
    ++ [
      all.gnupg
    ]
  );
in
php.buildComposerProject2 (finalAttrs: {
  pname = "passbolt-api";
  version = "5.11.0";

  src = fetchFromGitHub {
    owner = "passbolt";
    repo = "passbolt_api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UztKY1lEZiZ1xHUUWNQKYhmCvbTRuZqDDdDANRgXqmo=";
  };

  composerNoPlugins = false;
  composerStrictValidation = false;
  vendorHash = "sha256-wcCy7biYuzEMKWRuVDBUZazPa3oGqaQADDx25SCTvA8=";

  postInstall = ''
    chmod -R u+w $out/share
    mv $out/share/php/passbolt-api/* $out
    cp $out/config/app.default.php $out/config/app.php
    substituteInPlace $out/bin/cake \
      --replace-fail "for TESTEXEC in php php-cli /usr/local/bin/php" "for TESTEXEC in ${php}/bin/php"
    rm -r $out/share $out/tmp
    ln -s ${dataDir}/tmp $out/tmp
    ln -s ${dataDir}/logs $out/logs
  '';

  passthru.phpPackage = php;

  meta = {
    description = "Open source password manager for teams";
    homepage = "https://www.passbolt.com/";
    changelog = "https://github.com/passbolt/passbolt_api/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
  };
})
