# Example configurations to get started :
# https://www.chrisportela.com/posts/home-manager-flake/
# https://www.bekk.christmas/post/2021/16/dotfiles-with-nix-and-home-manager
{
  description = "Test flake-based home-manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, home-manager, ...}: {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

    homeConfigurations = {
      "houston" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./home.nix
          ./nix/host_configs/houston.nix
        ];
        # Stuff in this directive is accessible in modules imported above
        extraSpecialArgs = {
          # inherit inputs;
          hostSpecificVars = import ./nix/host_vars/houston.nix;
        };
      };
      "spacerig" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
        modules = [
          ./home.nix
          ./nix/host_configs/spacerig.nix
        ];
        extraSpecialArgs = {
          # inherit inputs;
          hostSpecificVars = import ./nix/host_vars/spacerig.nix;
        };
      };
    };
  };
}
