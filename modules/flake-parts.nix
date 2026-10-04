{ inputs, ... }:
{
  # Enables the flake.modules.<class>.<name> option that every feature file uses.
  imports = [ inputs.flake-parts.flakeModules.modules ];

  systems = [ "x86_64-linux" ];
}
