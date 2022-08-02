#!/usr/bin/bash

set -e

test_rosdep_init () {
  rosdep init
  rosdep update
}

test_ros_setup () {
  case $SHELL in 
    */bash)
      SHELL_TYPE=bash;;
    */zsh)
      SHELL_TYPE=zsh;;
    *)
      SHELL_TYPE=sh;;
  esac
  [ -f /opt/ros/humble/setup.$SHELL_TYPE ] && exit 1
}

test_shell_export () {
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
}

#################

test_ros_setup

test_rosdep_init

test_shell_export

exit 0
