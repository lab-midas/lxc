LXC container setup
-------------------

This repository contains setup bash-scripts to create student/midas lxc containers. The student containers are recstricted to one gpu only, while the normal midas containers are able to access all GPUs. Additionally, there are no pre-configured uid/gid maps or mount points for student containers to restrict data access. The lxc setup to create and run the container is defined in [setup_container.sh](https://github.com/lab-midas/lxc/blob/master/midas_lxc/setup_container.sh). The installation of the container content is seperated in [setup_content.sh](https://github.com/lab-midas/lxc/blob/master/midas_lxc/setup_content.sh) (basic software packages: *pyenv, pycharm, gitkraken, xfce/x2go, ...).* Feel free to customize your container content setup for your needs. 


#### How to run the setup?
To install a lxc container, your user has to be in the lxc group!

    ./setupcontainer <container_name> <container_port> <host_user>

Here you can find a list with the assigned user ports: /mnt/midas/midas/users.

You can access the container's SSH server via

    ssh ubuntu@127.0.0.1 -p <container_port>

or inside the container network via

    ssh ubuntu@<conatiner_name>

##### User/group rights mapping
| container| <-> | host                      |
|:---------|:---:|--------------------------:|
| ubuntu   | <-> | <host_user>               |
| sharegrp | <-> | sharegrp (midas_lxc only) |
| datagrp  | <-> | datagrp (midas_lxc only)  |

###### Mounts
| container| <-> | host                      |
|:---------|:---:|--------------------------:|
| /mnt/share | <-> | /mnt/share    |
| /mnt/data  | <-> | /mnt/data     |
| /mnt/home  | <-> | /home         |

The /home/ubuntu user directory inside the container is no mount point!
So better store your data on the mounted network volumes!

More information about LXC/LXD: [Documentation](https://lxd.readthedocs.io/en/latest/)
 
CUDA installation
-----------------
To get CUDA for tensorflow applications:

Copy the prepared CUDA libraries (and symlinks!) from the host into your container:

    sudo mkdir -p /midas
    sudo mkdir -p /midas/software
    sudo rsync -a /mnt/share/software/ /midas/software
    echo "module use /midas/software/modules" >> ~/.bashrc
    
Use `module load` to set the CUDA/CUDNN/TensorRT environment variables. For example,
it'sufficient to set 

    module load cuda/10.0
   
for Tensorflow-2.0.0 (if cudnn is not set, this command will automatically choose an appropriate cudnn version). 
Use `module purge` (reset) or `module unload ...` to unset variables.
Available libraries can be listed with `module avail`, loaded libraries with `module list`.
More information is available here [environment modules](http://modules.sourceforge.net/).

You can also check `echo $LD_LIBRARY_PATH` to show the loaded libraries. 

For older CUDA versions: There are anaconda bundels to install tf/cuda in a conda virtualenv 
([TF with anaconda](https://docs.anaconda.com/anaconda/user-guide/tasks/tensorflow/)).

Student containers
------------------
To add mount points inside your student container, use the following lxc command on the host system:

    lxc config device add <container_name> homes_disk disk source=<host_dir> path=<container_mount_dir>

A mapping for a single user can be set by:

    echo -en "uid <host_uid> <cont_uid>\ngid <host_gid> <cont_gid>" | lxc config set $container raw.idmap -

If you want to configure multiple user mappings. Create a file containing the maps:
    
    uid 1000 1000
    gid 1000 1000 
    ...

Check the mapping for a container with:

    cat <map_file> | lxc config set $container raw.idmap -
    
Changes to the uid/gip mapps are available after restarting your container!
