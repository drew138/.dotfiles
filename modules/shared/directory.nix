{ ... }:
let
  config = {
    owner = "drew";
    permissions = "0755";
  };
in
{
  home.file."dev".directory = config;
  home.file."work".directory = config;
}
