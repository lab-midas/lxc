### Prerequisites on the **host system**

Remove old packages and replace by snap version

    sudo apt -y remove --auto-remove lxd
    sudo snap install lxd

Install ZFS storage backend (optional)

    sudo apt -y install zfsutils-linux

Setting up LXD group

    sudo newgrp lxd
    sudo adduser $USER lxd

Configure the demon     
TODO: is there a way to do this automatically?

    lxd init

### Container setup

GPU setup to be added to a container

    lxc config device add <container> gpu gpu
    lxc config set <container> nvidia.runtime true


### Network

Set bridge ip address and subnet and configure dhcp-ranges

    lxc network set lxdbr0 ipv4.address 10.0.10.1/24
    lxc network set lxdbr0 ipv4.dhcp.ranges 10.0.10.100-10.0.10.200

Set static IP address to container eth interface

    lxc stop <container>
    lxc network attach lxdbr0 <container> eth0 eth0
    lxc config device set <container> eth0 ipv4.address 10.0.10.10
    lxc start <container>

Port forwarding with proxy device

    lxc config device add <container> <device-name> proxy listen=<type>:<addr>:<port>[-<port>][,<port>] connect=<type>:<addr>:<port> bind=<host/container>

    lxc config device add <container> sshproxy proxy listen=tcp:0.0.0.0:<host port> connect=tcp:127.0.0.1:<container port>

### Mounting

Mount host folder in container

    lxc config device add $container homes_disk disk source=$host_homes path=/opt

Configure appropriate user id mapping as described by [ID Mapping in LXD Documentation](https://lxd.readthedocs.io/en/latest/userns-idmap/).
It is possible to MAP id globally (/etc/subuid and /etc/subguid) or
per container. The following example demonstrates how to map both the uid and
gid 1000 on the host to 1000 inside the container:

  echo -en "both 1000 1000" | lxc config set <container> raw.idmap -

Other examples:

  both 1000 1000
  uid 50-60 500-510
  gid 100000-110000 10000-20000


### Pool / disk management

zfs and zpool might be needed to check current status
