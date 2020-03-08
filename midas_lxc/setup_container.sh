#!/bin/bash
# variables
# ($1): container name
# ($2): ssh proxy host port
# ($3): host user 
container=$1
sshproxyport=$2
host_user=$3
#host_uid=$5
#host_gid=$6

# Check input
# If no username is given ($3) get uid , gid from current user.
if [[ -z $host_user ]]; then
  host_user=$(whoami)
  host_uid=$(id -u)
  host_gid=$(id -g)
  echo "Using current UID $host_uid"
  echo "Using current GID $host_gid"
else
  host_uid=$(id -u $host_user)
  host_gid=$(id -g $host_user)
  echo "Using passed UID $host_uid"
  echo "Using passed GID $host_gid"
fi

# Prepare envs
cont_user=ubuntu
cont_home=/home/$cont_user

# Setup container
lxc init ubuntu:18.04 $container
lxc start $container

echo "start upgrade but wait around 1 minute before pushing enter... (push enter)"
read tmp 

# Set standard password for ubuntu user
echo "Enter password for user:"
lxc exec $container -- /bin/bash -c "passwd $cont_user" 
echo "Enter password for root:"
lxc exec $container -- /bin/bash -c "passwd root" 

# Setup container content
lxc exec $container -- sudo apt -y update
lxc exec $container -- sudo apt -y upgrade
lxc restart $container

echo "configure ssh/mounting but wait around 1 minute before pushing enter...(push enter)"
read tmp

# Ssh setup, port forwarding
lxc exec $container -- sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
lxc exec $container -- systemctl restart ssh

# Configure proxy port
lxc config device add $container ssh_proxy proxy listen=tcp:0.0.0.0:$sshproxyport connect=tcp:127.0.0.1:22

# Share data with host system
lxc config device add $container homes_disk disk source=/home path=/mnt/home
lxc config device add $container share_disk disk source=/mnt/share path=/mnt/share
lxc config device add $container data_disk disk source=/mnt/data path=/mnt/data

# Configure user/group id mapping, available after restart(!)
# container ids / atm. known to be 1000 / 1000
echo -en "uid $host_uid 1000\ngid $host_gid 1000" | lxc config set $container raw.idmap -

# Configure share group - map to 1001
rawtemp=$(lxc config get $container raw.idmap) # Get current raw-idmap
lxc exec $container -- /bin/bash -c  "sudo addgroup sharegrp --gid 1001" # Add group with the same id as on host
echo -en "$rawtemp\ngid $(getent group sharegrp | cut -d: -f3) 1001" | lxc config set $container raw.idmap - # Map the group
lxc exec $container -- /bin/bash -c  "sudo adduser ubuntu sharegrp" # Add user in container to the group

# Configure data group - map to 1002
rawtemp=$(lxc config get $container raw.idmap) # Get current raw-idmap
lxc exec $container -- /bin/bash -c  "sudo addgroup datagrp --gid 1002" # Add group with the same id as on host
echo -en "$rawtemp\ngid $(getent group datagrp | cut -d: -f3) 1002" | lxc config set $container raw.idmap - # Map the group
lxc exec $container -- /bin/bash -c  "sudo adduser ubuntu datagrp" # Add user in container to the group

# (short break between restart and exec)
echo "push setup files but wait around 1 minute before pushing enter ... (push enter)"
read tmp

# Copy setup scripts to the container
lxc exec $container -- sudo --login --user ubuntu mkdir $cont_home/setup
lxc file push setup_content.sh $container $cont_home/setup/setup_content.sh
lxc exec $container -- chown -R $cont_user:$cont_user $cont_home/setup

echo "run setup but wait around 1 minute before pushing enter... (push enter)"
read tmp

# Run setup inside the container
lxc exec $container -- sudo --login --user $cont_user bash -c "cd $cont_home/setup && ./setup_content.sh"

# Gpu configuration
lxc stop $container
lxc config set $container nvidia.runtime true
# Restrict student container to gpu id=4
# lxc config device add $container gpu gpu
lxc config device add $container gpu gpu id=4
lxc start $container

echo "Restarting the container..."
lxc restart $container

