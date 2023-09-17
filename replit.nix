{ pkgs }: {
  deps = [
		pkgs.nodePackages.prettier
    pkgs.bashInteractive
    pkgs.nodePackages.bash-language-server
    pkgs.man
  ];
}