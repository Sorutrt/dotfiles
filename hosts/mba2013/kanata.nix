{ lib, ... }:

let
  kanataUser = "kanata";
  kanataGroup = "kanata";

  # Prefer explicit devices once confirmed on the real machine:
  #   ls -l /dev/input/by-id/ /dev/input/by-path/
  # Example:
  #   [ "/dev/input/by-id/usb-Example_Keyboard-event-kbd" ]
  keyboardDevices = [ ];
in
{
  users.groups.${kanataGroup} = { };

  users.users.${kanataUser} = {
    isSystemUser = true;
    group = kanataGroup;
    extraGroups = [
      "input"
      "uinput"
    ];
    description = "kanata service user";
  };

  environment.etc."kanata.kbd".source = ../../device/kbd/kanata/kanata.kbd;

  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
  '';

  services.kanata = {
    enable = true;
    keyboards.default = {
      devices = keyboardDevices;
      configFile = "/etc/kanata.kbd";
    };
  };

  systemd.services.kanata-default = {
    aliases = [ "kanata.service" ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = kanataUser;
      Group = kanataGroup;
      SupplementaryGroups = lib.mkForce [
        "input"
        "uinput"
      ];
    };
  };
}
