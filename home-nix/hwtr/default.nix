{ config, pkgs,... }@input:
{
    home.user = "hwtr";
    home.homeDirectory = "/home/hwtr";
    module = [./../common];
}
