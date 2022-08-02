#!/usr/bin/bash

set -e

case $SHELL in 
  */bash)
    SHELL_TYPE=bash;;
    RCFILE=/home/$USER/.bashrc;;
  */zsh)
    SHELL_TYPE=zsh;;
    RCFILE=/home/$USER/.zshrc;;
  *)
    SHELL_TYPE=sh;;
esac

[ -f /opt/ros/humble/setup.$SHELL_TYPE ] && exit 1
[ -f $RCFILE ] && printf "NO RC FILE FOUND!\n"

rosdep init
rosdep update
  
printf "
# User added - ROS2
export LANG=en_US.UTF-8
export ROS_DOMAIN_ID=0
export ROSCONSOLE_FORMAT='\${logger}: \${message}'
export ROS_SECURITY_KEYSTORE=
export ROS_SECURITY_ENABLE=
export ROS_SECURITY_STRATEGY=
" >> $RCFILE

exit 0
