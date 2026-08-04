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
    nixgl = {
      url = "github:nix-community/nixGL";
    };
  };

  outputs = {nixpkgs, home-manager, nixgl, ...}: {
    defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

    homeConfigurations = {
      "houston" = home-manager.lib.homeManagerConfiguration {
        # TODO (ideas):
        # * move this declaration above the per-host declaration ? (to avoid duplication)
        # * declare the overlayed pkg store in a separate variable ? (to avoid "polluting" the "main" pkg namespace)
        # * directly overlay/wrap the few binaries that actually require it (alacritty)
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          # It's a bit unclear to me what exactly this does.
          # I don't think it means each package gets overlayed, only the package index object itself, which only means that extra packages are added to it
          overlays = [ nixgl.overlay ];
        };
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
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ nixgl.overlay ];
        };
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
