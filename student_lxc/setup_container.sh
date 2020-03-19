#!/bin/bash
# variables
# ($1): container name
# ($2): ssh proxy host port
container=$1
sshproxyport=$2

# Get GID/UID for the host user
host_uid=$(id -u $host_user)
host_gid=$(id -g $host_user)
echo "Using passed UID $host_uid"
echo "Using passed GID $host_gid"

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

# SSH setup
lxc exec $container -- sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
lxc exec $container -- systemctl restart ssh

# Configure proxy port
lxc config device add $container ssh_proxy proxy listen=tcp:0.0.0.0:$sshproxyport connect=tcp:127.0.0.1:22

# Share data with host system
#lxc config device add $container homes_disk disk source=/home path=/mnt/home
#lxc config device add $container share_disk disk source=/mnt/share path=/mnt/share
#lxc config device add $container data_disk disk source=/mnt/data path=/mnt/data

# Configure user/group id mapping, available after restart(!)
# container ids / atm. known to be 1000 / 1000
#echo -en "uid $host_uid 1000\ngid $host_gid 1000" | lxc config set $container raw.idmap -

# (short break between restart and exec)
echo "push setup files but wait around 1 minute before pushing enter ... (push enter)"
read tmp

# Copy setup scripts to the container
lxc exec $container -- sudo --login --user ubuntu mkdir $cont_home/setup
lxc file push setup_content.sh $container$cont_home/setup/setup_content.sh
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
# Restrict memory
lxc config set $container limits.memory 64GB
# Restrict CPU
lxc config set $container limits.cpu.allowance 20%

lxc start $container

echo "Restarting the container..."
lxc restart $container

