#!/usr/bin/bash

set -e

apt-get update
apt-get install -y libssl-dev

case $SHELL in 
  */sh)
    exit 1;;
  */bash)
    RCFILE=/home/$USER/.bashrc;;
  */zsh)
    RCFILE=/home/$USER/.zshrc;;
  *)
    exit 1;;
esac

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
