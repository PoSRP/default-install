#!/bin/bash


user_no_sudo () {
  printf "Adding user to NO PASSWORD SUDO [NOT SECURE] ....................... "
  printf "%s ALL=(ALL) NOPASSWD:ALL\n" $user > /etc/sudoers.d/$user-nopasswd
  chmod 0440 /etc/sudoers.d/$user-nopasswd
  printf "OK\n"
}

set_mesa_i965_driver () {
  printf "Switching to i965 MESA driver for legacy support ................... "
  printf "MESA_LOADER_DRIVER_OVERRIDE=i965" >> /etc/environment
  printf "OK\n"
}

initial_apt () {
  printf "Updating apt ....................................................... "
  apt-get update &> /dev/null
  printf "OK\n"
  
  printf "Upgrading apt ...................................................... "
  apt-get upgrade -y &> /dev/null
  printf "OK\n"
  
  printf "Adding the universe repository ..................................... "
  add-apt-repository -y universe &> /dev/null
  apt-get update &> /dev/null
  printf "OK\n"
}

install_apt_packages_essential () {
  apt_essentials="\
    build-essential \
    cmake \
    curl \
    dconf-cli \
    default-jdk \
    diffutils \
    dosfstools \
    findutils \
    git \
    gnupg \
    libboost-all-dev \
    libgtk-3-dev \
    libgl1-mesa-glx \
    locales \
    lsb-release \
    make \
    mesa-utils \
    ntfs-3g \
    openssh-client \
    rsync \
    tmux \
    tree \
    unzip \
    wget \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    thunar-archive-plugin \
    xfce4-cpugraph-plugin \
    xfce4-netload-plugin \
    xfce4-systemload-plugin \
    python3-colcon-common-extensions \
    "

  printf "Installing apt packages [essentials] ............................... "
  apt-get install -y $apt_essentials &> /dev/null
  printf "OK\n"
}

install_apt_packages_devtools () {
  apt_devtools="\
    ccache \
    clang-format \
    clang-tidy \
    designer-qt6 \
    distcc \
    docker \
    docker-compose \
    docker.io \
    libpq-dev \
    libspdlog-dev \
    meld \
    net-tools \
    npm \
    odb \
    postgresql-14 \
    postgresql-contrib \
    python3-pip \
    python3-tk \
    python3-venv \
    r-base \
    software-properties-common \
    travis \
    "

  printf "Installing apt packages [devtools] ................................. "
  apt-get install -y $apt_devtools &> /dev/null
  printf "OK\n"
}

install_apt_packages_nice_desktop () {
  apt_nice_desktop_apps="\
    audacity \
    engrampa \
    filezilla \
    gimp \
    gparted \
    keepassxc xdotool \
    mpv \
    pinta \
    sxiv \
    texstudio \
    texlive-extra-utils \
    texlive-font-utils \
    texlive-fonts-recommended \
    texlive-latex-extra \
    texlive-latex-recommended \
    thunar-dropbox-plugin \
    thunar-media-tags-plugin \
    transmission \
    usb-creator-gtk \
    virt-manager \
    vlc \
    "

  printf "Installing apt packages [desktop apps] ............................. "
  apt-get install -y $apt_nice_desktop_apps &> /dev/null
  printf "OK\n"
}

install_apt_packages_nice_terminal () {
  apt_nice_terminal_apps="\
    htop \
    ipython3 \
    lm-sensors \
    neofetch \
    nmap \
    psensor \
    telnet \
    vsftpd \
    "

  printf "Installing apt packages [terminal apps] ............................ "
  apt-get install -y $apt_nice_terminal_apps &> /dev/null
  printf "OK\n"
}

install_apt_packages_gaming () {
  apt_gaming="\
    playonlinux \
    steam \
    "

  printf "Installing apt packages [gaming] ................................... "
  apt-get install -y $apt_gaming &> /dev/null
  printf "OK\n"
}

install_apt_package_wireshark () {
  printf "Installing wireshark - This adds the user to the wireshark group ... "
  printf "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
  DEBIAN_FRONTEND=noninteractive apt-get install -y wireshark &> /dev/null
  usermod -aG wireshark $user
  printf "OK\n"
}

ending_apt () {
  printf "Running apt auto-remove ............................................ "
  apt-get autoremove -y &> /dev/null
  printf "OK\n"
}

replace_firefox_snap_with_dpkg () {
  if [[ $user == "" ]]; then
    printf "Missing user environment variable when installing firefox!"
    exit 1
  fi

  snap remove --purge firefox
  apt-get remove -y --purge firefox
  rm -r /home/$user/snap/firefox
  rm -r /home/$user/Downloads/firefox.tmp
  add-apt-repository -y ppa:mozillateam/firefox-next 
  
  firefox_apt_preference="\
Package: firefox*
Pin: release o=Ubuntu*
Pin-Priority: -1"

  printf $firefox_apt_preference >> /etc/apt/preferences.d/firefox-no-snap
  apt-get update
  apt-get install -y firefox
}

configure_xfconf () {
  printf "Configuring xfconf settings ........................................ "
  
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/blank-on-ac -t int -s 0" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/blank-on-battery -t int -s 0" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/dpms-enabled -t bool -s false" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/dpms-on-ac-off -t int -s 0" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/dpms-on-ac-sleep -t int -s 0" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/dpms-on-battery-off -t int -s 0" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/dpms-on-battery-sleep -t int -s 0" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/inactivity-sleep-mode-on-ac -t int -s 1" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-power-manager -pn /xfce4-power-manager/inactivity-sleep-mode-on-battery -t int -s 1" &> /dev/null
  
  su $user sh -c "xfconf-query -c xfce4-screensaver -pn /lock/enabled -t bool -s false" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-screensaver -pn /saver/enabled -t bool -s false" &> /dev/null
  
  su $user sh -c "xfconf-query -c xfce4-keyboard-shortcuts -pn /commands/custom/\<Primary\>\<Alt\>t -t string -s alacritty" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>t -t string -s alacritty" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-keyboard-shortcuts -pn /commands/custom/\<Super\>e -t string -s subl" &> /dev/null
  
  su $user sh -c "xfconf-query -c xfce4-appfinder -pn /actions/action-2/command -t string -s 'alacritty %s'" &> /dev/null
  su $user sh -c "xfconf-query -c xfce4-appfinder -pn /actions/action-4/command -t string -s 'alacritty man %s'" &> /dev/null
  
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/cycle_preview -t bool -s true" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/cycle_tabwin_mode -t int -s 1" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/easy_click -t string -s Super" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/frame_opacity -t int -s 95" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/move_opacity -t int -s 85" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/resize_opcaity -t int -s 85" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/snap_to_windows -t bool -s true" &> /dev/null
  su $user sh -c "xfconf-query -c xfwm4 -pn /general/theme -t string -s Greybird-dark" &> /dev/null
  
  su $user sh -c "xfconf-query -c keyboards -pn /Default/KeyRepeat/Delay -t int -s 300" &> /dev/null
  su $user sh -c "xfconf-query -c keyboards -pn /Default/KeyRepeat/Rate -t int -s 80" &> /dev/null
  
  su $user sh -c "xfconf-query -c xfce4-notifyd -pn /theme -t string -s 'Greybird-dark'" &> /dev/null
  
  sh $user sh -c "xfconf-query -c xsettings -pn /Net/ThemeName -t string -s 'Greybird-dark'" &> /dev/null  # GETS OVERWRITTEN OR DOES NOT WORK
  
  sh $user sh -c "xfconf-query -c thunar -pn /last-view -t string -s ThunarDetailsView" &> /dev/null
  
  printf "OK\n"
}

install_default_panel () {
  printf "Moving default panel configuration ................................. "
  cp -f $working_dir/xfce4-panel.default /home/$user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
  chown $user:$user /home/$user/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
  cp -rf $working_dir/panel-rc/* /home/$user/.config/xfce4/panel/
  chown -R $user:$user /home/$user/.config/xfce4/panel
  printf "OK\n"  
}

install_default_wallpaper () {
  printf "Installing wallpaper ............................................... "
  cp -f $working_dir/wallpaper.png /usr/share/xfce4/backdrops/xubuntu-wallpaper.png
  printf "OK\n"  
}

install_sublime_text () {
  printf "Installing sublime-text from snap .................................. "
  snap install sublime-text --classic &> /dev/null
  printf "OK\n"

  printf "Installing sublime-text configuration file ......................... "
  su $user sh -c "mkdir -p /home/$user/.config/sublime-text/Packages/User"
  su $user sh -c "cp -f $working_dir/sublime-text.default \
    /home/$user/.config/sublime-text/Packages/User/Preferences.sublime-settings"
  printf "OK\n"
}

install_sublime_merge () {
  printf "Installing sublime-merge from snap ................................. "
  snap install sublime-merge --classic &> /dev/null
  printf "OK\n"
}
install_pycharm_community () {
  printf "Installing pycharm-community from snap ............................. "
  snap install pycharm-community --classic &> /dev/null
  printf "OK\n"
}
install_spotify () {
  printf "Installing spotify from snap ....................................... "
  snap install spotify &> /dev/null
  printf "OK\n"
}

disable_udisks2 () {
  printf "Disabling udisks2 (auto-mounting) .................................. "
  systemctl -q stop udisks2
  systemctl -q disable udisks2
  systemctl -q mask udisks2
  printf "OK\n"
}

install_meslo_lgs_font () {
  printf "Installing Meslo font .............................................. "
  su $user sh -c "mkdir /home/$user/.fonts"
  su $user sh -c "cp -rf $working_dir/fonts/MesloLGS_NF_Bold.ttf \
    $working_dir/fonts/MesloLGS_NF_Bold_Italic.ttf \
    $working_dir/fonts/MesloLGS_NF_Italic.ttf \
    $working_dir/fonts/MesloLGS_NF_Regular.ttf /home/$user/.fonts/"
  su $user sh -c "fc-cache -f -v" &> /dev/null
  printf "OK\n"
}

install_alacritty_source () {
  printf "Installing alacritty from source ................................... "

  # Clone repo
  cd /home/$user
  su $user -c "git clone https://github.com/alacritty/alacritty.git"
  cd /home/$user/alacritty

  # Install rustup
  su $user -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  source /home/$user/.cargo/env
  su $user -c "rustup override set stable"
  su $user -c "rustup update stable"

  # Build alacritty
  apt-get install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
  su $user -c "cargo build --release"

  # Add terminfo
  if [[ ! $(infocmp alacritty) ]]; then
    tic -xe alacritty,alacritty-direct extra/alacritty.info
  fi

  # Add desktop entry
  cp target/release/alacritty /usr/local/bin
  cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
  desktop-file-install extra/linux/Alacritty.desktop
  update-desktop-database

  cd $working_dir
  printf "OK\n"
}

install_terminal () {
  # Add check for zsh installed in dpkg

  # printf "Installing alacritty from snap ..................................... "
  # snap install alacritty --classic &> /dev/null
  # printf "OK\n"
  install_alacritty_source

  printf "Downloading oh-my-zsh install script ...............................\n"
  wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh\
    -q --show-progress --progress=bar:force:noscroll -O $tmp_dir/install.sh
  printf "Installing oh-my-zsh ............................................... "
  chmod +x $tmp_dir/install.sh
  su $user sh -c "$tmp_dir/install.sh --unattended" &> /dev/null
  chsh -s /usr/bin/zsh $user
  printf "OK\n"

  printf "Downloading zsh theme .............................................. "
  su $user sh -c "git clone --depth=1 \
    https://github.com/romkatv/powerlevel10k.git \
    /home/$user/.oh-my-zsh/custom/themes/powerlevel10k" &> /dev/null
  printf "OK\n"

  printf "Installing terminal configuration files ............................ "
  su $user sh -c "cp -f $working_dir/zshrc.default /home/$user/.zshrc"
  su $user sh -c "mkdir -p /home/$user/.config/alacritty"
  su $user sh -c "cp -f $working_dir/alacritty.default \
    /home/$user/.config/alacritty/alacritty.yml"
  su $user sh -c "cp -f $working_dir/tmux.default /home/$user/.tmux.conf"
  printf "OK\n"

  printf "Setting alacritty as default user terminal ......................... "
  xdg_alacritty_desktop="\
[Desktop Entry]
NoDisplay=true
Version=1.0
Encoding=UTF-8
Type-X-XFCE-Helper
X-XFCE-Category=TerminalEmulator
X-XFCE-CommandsWithParameter=/usr/local/bin/alacritty \"%s\"
X-XFCE-Commands=/usr/local/bin/alacritty
Icon=alacritty
Name=alacritty"
  printf "%s" $xdg_alacritty_desktop >> /home/$user/.local/share/xfce4/helpers/alacritty-TerminalEmulator.desktop
  printf "TerminalEmulator=alacritty-TerminalEmulator.desktop" >> /home/$user/.config/xfce4/helpers.rc
  printf "OK\n"
}

install_user_aliases () {
  printf "Adding user aliases ................................................ "
  user_aliases[1]="aptupg='sudo apt-get update && sudo apt-get upgrade -y && \
    sudo apt-get autoremove -y'"
  user_aliases[2]="cdw='cd /home/$user/workspace'"
  user_aliases[3]="ipy='ipython3'"
  user_aliases[4]="py='python3'"
  user_aliases[5]="zrcros='source /opt/ros/humble/setup.zsh'"
  for ualias in "${user_aliases[@]}"; do
    echo "alias $ualias" >> /home/$user/.oh-my-zsh/custom/aliases.zsh
  done
  chown $user:$user /home/$user/.oh-my-zsh/custom/aliases.zsh
  printf "OK\n"
}

install_windscribe () {
  printf "Starting windscribe download .......................................\n"
  wget "https://windscribe.com/install/desktop/linux_deb_x64/beta" -q \
    --show-progress --progress=bar:force:noscroll -O $tmp_dir/windscribe.deb
  printf "Installing windscribe .............................................. "
  dpkg -i $tmp_dir/windscribe.deb &> /dev/null
  apt-get install -f -y &> /dev/null
  rm $tmp_dir/windscribe.deb
  printf "OK\n"
}

install_ros2_humble () {
  printf "Preparing ROS2 Humble install ...................................... "
  apt-get update &> /dev/null
  apt-get install -y locales &> /dev/null
  locale-gen en_US en_US.UTF-8 &> /dev/null
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 &> /dev/null
  echo "# User added - ROS2" >> /home/$user/.zshrc
  echo "export LANG=en_US.UTF-8" >> /home/$user/.zshrc
  echo "export ROS_DOMAIN_ID=0" >> /home/$user/.zshrc
  curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o \
    /usr/share/keyrings/ros-archive-keyring.gpg &> /dev/null
  echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu \
    $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | \
    tee /etc/apt/sources.list.d/ros2.list &> /dev/null
  apt-get update &> /dev/null
  apt-get upgrade -y &> /dev/null
  printf "OK\n"
  
  printf "Installing ROS2 Humble ............................................. "
  apt-get install -y ros-humble-desktop &> /dev/null
  printf "OK\n"

  printf "Installing ROS2 Extras ............................................. "
  apt-get install -y \
    python3-colcon-ros \
    python3-colcon-zsh \
    python3-rosdep &> /dev/null
  rosdep init &> /dev/null
  su $user -c "rosdep update &> /dev/null"
  printf "OK\n"
}

install_kicad6 () {
  printf "Installing kicad 6.0 ............................................... "
  add-apt-repository --yes ppa:kicad/kicad-6.0-releases &> /dev/null
  apt-get install --install-recommends -y kicad &> /dev/null
  printf "OK\n"
}

install_eclipse_cpp_2022_03 () {
  printf "Starting eclipse C++ 2022.03 download ..............................\n"
  wget "https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/2022-03/R/eclipse-cpp-2022-03-R-linux-gtk-x86_64.tar.gz" \
    -q --show-progress --progress=bar:force:noscroll -O $tmp_dir/eclipse.tar.gz
  printf "Installing eclipse c++ 2022.03 ..................................... "
  tar -xf $tmp_dir/eclipse.tar.gz -C /home/$user &> /dev/null
  chown -R $user:$user /home/$user
  rm -rf $tmp_dir/eclipse.tar.gz
  mkdir -p /home/$user/.local/share/applications
  echo "[Desktop Entry]
  Encoding=UTF-8
  Version=2022.03
  Type=Application
  Categories=Development;Building;Debugger;IDE;
  Terminal=false
  Exec=/home/$user/eclipse/eclipse
  Name=Eclipse 2022.03
  Icon=/home/$user/eclipse/icon.xpm
  " >> /home/$user/.local/share/applications/eclipse.desktop
  chown -R $user:$user /home/$user/.local/share/applications
  printf "OK\n"
}

install_binance () {
  printf "Starting binance download ..........................................\n"
  wget "https://ftp.binance.com/electron-desktop/linux/production/binance-amd64-linux.deb" \
    -q --show-progress --progress=bar:force:noscroll -O $tmp_dir/binance.deb
  printf "Installing binance ................................................. "
  dpkg -i $tmp_dir/binance.deb &> /dev/null
  apt-get install -f -y &> /dev/null
  rm $tmp_dir/binance.deb
  printf "OK\n"
}

install_rstudio () {
  printf "Starting r-studio download .........................................\n"
  wget "https://download1.rstudio.org/desktop/jammy/amd64/rstudio-2022.02.3-492-amd64.deb" \
    -q --show-progress --progress=bar:force:noscroll -O $tmp_dir/rstudio.deb
  printf "Installing r-studio ................................................ "
  dpkg -i $tmp_dir/rstudio.deb &> /dev/null
  apt-get install -f -y &> /dev/null
  rm $tmp_dir/rstudio.deb
  printf "OK\n"
}





###############################################################################
### Beginning of script
###############################################################################

if [[ $UID != 0 || $# != 1 || $(users | grep -w "$1" | cut -f 1 -d " ") != $1 ]]; then
  printf "Usage: sudo %s <user>" $0
  exit 1
fi
if [[ ! $(source /etc/os-release && printf "%s" $UBUNTU_CODENAME) == "jammy" && ! -d /etc/xdg/xdg-xubuntu ]]; then
  printf "This script is only intended for Xubuntu 22.04 - Jammy Jellyfish"
  exit 1
fi
if [[ -f /home/$1/.config/.defaultinstallscripthasrun ]]; then
  printf "This script has been run before, and is NOT safe to run again"
  exit 1
fi
touch /home/$1/.config/.defaultinstallscripthasrun

export user=$1
export working_dir=$PWD
export tmp_dir=/home/$user/.srinstalltmp
mkdir -p $tmp_dir
##

user_no_sudo
set_mesa_i965_driver
disable_udisks2

initial_apt
install_apt_packages_essential
install_apt_packages_devtools
install_apt_packages_nice_desktop
install_apt_packages_nice_terminal
#install_apt_packages_gaming
install_apt_package_wireshark
ending_apt

configure_xfconf
install_default_panel
install_meslo_lgs_font
install_default_wallpaper

install_terminal
install_user_aliases

install_sublime_text
install_sublime_merge

install_pycharm_community
install_spotify
install_windscribe
install_ros2_humble
install_kicad6
install_eclipse_cpp_2022_03
install_binance
install_rstudio

##
rm -rf $tmp_dir  
printf "Script done, press ENTER to REBOOT .. \n"
read
printf "Rebooting .. \n"
reboot
