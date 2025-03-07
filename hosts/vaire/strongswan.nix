{ ... }:

{
  k.strongswan = {
    enable = true;
    acme.enable = true;
    babel = {
      enable = true;
      public = true;
      id = {
        v4 = 3;
        v6 = "C8F1";
      };
    };
  };
}
