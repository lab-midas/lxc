LXC container setup
-------------------

This repository contains setup bash-scripts to create student/midas lxc containers. The student containers are recstricted to one gpu only, while the normal midas containers are able to access all GPUs. Additionally, there are no pre-configured uid/gid maps or mount points for student containers to restrict data access and a restriction for memory/CPU usage. The lxc setup to create and run the container is defined in [setup_container.sh](https://github.com/lab-midas/lxc/blob/master/midas_lxc/setup_container.sh). The installation of the container content is seperated in [setup_content.sh](https://github.com/lab-midas/lxc/blob/master/midas_lxc/setup_content.sh) (basic software packages: *pyenv, pycharm, gitkraken, xfce/x2go, ...).* Feel free to customize your container content setup for your needs. 


#### How to run the setup?
To install a lxc container, your user has to be in the lxc group!

    ./setupcontainer <container_name> <container_port> <host_user>

Allowed port ranges for each user are [UID x 10] : [UID x 10 + 99] (e.g. UID 3000, associated port range 30000-30099)

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

Mount the prepared CUDA libraries from the host into your container:

    lxc config device add <container_name> software disk source=/mnt/midas/software path=/midas/software
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
To start a student container run

    ./setupcontainer <container_name> <container_port>

The name of the container should have the following format "contstudent01".
To add mount points inside your student container, use the following lxc command on the host system (for each device you can define a <disk_name>):

    lxc config device add <container_name> <disk_name> disk source=<host_dir> path=<container_mount_dir>

The mapping for a users and groups can be set by (the used port range is just an example):

    echo -en "both 1000-1099 1000-1099" | lxc config set contstudent01 raw.idmap -
    echo -en "both 1003 1003\ngid 1004 1004" | lxc config set contstudent01 raw.idmap -


Use the same uid/gid for container and host!   
Changes to the uid/gip maps are available after restarting your container!
