{ ... }:

{
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    # LC_COLLATE # How to sort stuff
    # LC_CTYPE # Character recognition of bytes
    # LC_IDENTIFICATION # What to show as system locale
    LC_MONETARY = "de_DE.UTF-8"; # Currency formats
    # LC_MEASSAGES # General message lang
    LC_MEASUREMENT = "de_DE.UTF-8"; # Units used for numbers
    LC_NAME = "de_DE.UTF-8"; # Names of persons
    # LC_NUMERIC # Punctiation of numbers
    LC_PAPER = "de_DE.UTF-8"; # Paper size
    LC_TELEPHONE = "de_DE.UTF-8"; # Phone number formats
    LC_TIME = "de_DE.UTF-8"; # Time format
  };
}
