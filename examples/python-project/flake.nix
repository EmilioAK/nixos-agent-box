{
  description = "Python project shell for the x86_64 Linux developer VMs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          python313
          uv
          postgresql_17.out
          redis
          pkg-config
        ];

        UV_PYTHON_DOWNLOADS = "never";
        UV_PYTHON = "${pkgs.python313}/bin/python3.13";
      };
    };
}
