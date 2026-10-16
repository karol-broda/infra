{
  pkgs,
  arg,
  ...
}: {
  description = "copy the config to a server and switch to it";
  args = [arg.host];
  runtimeInputs = with pkgs; [rsync openssh];
  text = builtins.readFile ./rebuild.bash;
}
