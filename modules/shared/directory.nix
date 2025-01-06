{ user, ... }:
let
  config = {
    owner = user;
    permissions = "0755";
  };
in
{
  home.file."dev".directory = config;
  home.file."work".directory = config;
}
