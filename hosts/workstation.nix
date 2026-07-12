{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;

  security.sudo.wheelNeedsPassword = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tokyo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
      ];
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
    ];
    fontconfig = {
      enable = true;
      antialias = true;
      hinting.enable = true;
      defaultFonts.sansSerif = [
        "Noto Sans"
        "Noto Sans CJK JP"
      ];
    };
  };

  services.power-profiles-daemon.enable = true;

  users.users.sorutrt = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  programs = {
    firefox.enable = true;
    niri.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    pciutils
    usbutils
    kitty
    rofi
  ];

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  hardware.enableRedistributableFirmware = true;
}
