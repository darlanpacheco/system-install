# #!/usr/bin/env bash
#
# HOME=$(cat /softwares/home)
#
# mkdir -p ${HOME}/Desktop ${HOME}/Documents ${HOME}/Downloads ${HOME}/Music ${HOME}/Videos ${HOME}/Projects
# mkdir -p ${HOME}/.local/npm
# mkdir -p ${HOME}/.themes ${HOME}/.fonts ${HOME}/.icons
#
# git clone https://github.com/darlanpacheco/system-files.git ${HOME}/system-files
#
# cp -r ${HOME}/system-files/.[!.]* ${HOME}
# cp -r ${HOME}/system-files/* ${HOME}
# rm -rf ${HOME}/system-files
# rm -rf ${HOME}/.git
#
# cp -r /usr/share/themes/* ${HOME}/.themes
# cp -r /usr/share/fonts/* ${HOME}/.fonts
# cp -r /usr/share/icons/* ${HOME}/.icons
#
# flatpak override --user --filesystem=${HOME}/.themes
# flatpak override --user --filesystem=${HOME}/.fonts
# flatpak override --user --filesystem=${HOME}/.icons
# flatpak override --user --env=GTK_THEME=adw-gtk3-dark
# flatpak override --user --env=GTK_FONT_NAME="JetBrains Mono 12"
# flatpak override --user --env=ICON_THEME=Papirus
