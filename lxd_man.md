### Minor Tutorial for use of LXD/LXC

In the following your container name will be noted as \<container\>.
    
See [lxc/doc](https://github.com/lxc/lxd/tree/master/doc) for a detailed list of all commands

### Basic Commands

#### user access

    sudo adduser <USER> lxd

#### life-cycle managment

Show available images

    lxc image list
    lxc image info <image>
    
Editing images
    
    lxc image edit <image>
    
Deleting an image

    lxc image delete <image>

Show available containers, snapshots and details

    lxc list
    lxc info <container>
    lxc config show <container>

Create container from an image

    lxc init ubuntu:18.04 <container>

Start a container

    lxc start <container>

Create and start a container from an image

    lxc launch ubuntu:18.04 <container>
    
Stop

    lxc stop <container> [--force]
    
Delete

    lxc delete <container>

Restart

    lxc restart <container> [--force]

Pause (SIGSTOP)

    lxc pause <container>
    
#### bash and file management
    
Bash commands via

    lxc exec <container> -- <cmd>
 
or after entering a bash (no SSH needed for quick access)

    lxc exec <container> -- bash

Snapshot via

    lxc snapshot <container> [<snapsoht name>]
    
Restore snapshot

    lxc restore <container> <snapshot name
    
Creating container from snapshot (- loses volatile information)

    lxc copy <source container>/<snapshot name> <destination container>
    
Creating image from container

    lxc publish <container>[/<snap name>] -- alias <new name>


#### managing files

Push pull files via

    lxc file push <source> <container>/<path>
    lxc file pull <container>/<path> <dest>

#### profiles and configs

profiles (for all)

    lxc profile list
    lxc profile show <profile>
    lxc profile edit <profile>
    lxc profile apply <container> <profile1>,<profil2>,...
    lxc profile copy <profile> <new profile>
    lxc profile device add <profile> <name> <type>
    
configs (local)

    lxc config edit <container>
    lxc config set <container> <key> <value>
    lxc config show <container>


#### GPU setup
based on https://stgraber.org/2017/03/21/cuda-in-lxd/


