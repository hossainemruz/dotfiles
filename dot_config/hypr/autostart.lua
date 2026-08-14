-- Start the hyprscrolling plugin and then launch personal session apps.
o.exec_on_start("hyprpm reload")
o.exec_on_start("~/.config/hypr/autostart.sh")
