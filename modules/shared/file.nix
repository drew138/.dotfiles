{ user, ... }:
let
  config = {
    text = "";
    owner = user;
    permissions = "0755";
  };
in
{
  home.file.".workrc.zsh".create = config;
  home. file."workrc.gitconfig". create = config;
}
