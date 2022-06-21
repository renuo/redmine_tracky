{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    # keep this line if you use bash
    pkgs.bashInteractive

    pkgs.ruby_2_7
    pkgs.nodePackages.yarn
    pkgs.nodejs
    pkgs.rake
  ];
}

