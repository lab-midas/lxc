lxc container setup
-------------------

This repository contains setup bahs scripts to create student/midas lxc containers. The student containers are recstricted to one gpu only, while the normal midas containers are able to access all GPUs. Additionally, there is no group mapping (sharegrp/datagrp) for student containers to restrict data access.

How to run the setup?
To install a lxc container, your user has to be in the lxc group!

./setupcontainer <container_name> <port> <host_user>

Here you can find a list with the assigned user ports: /mnt/share/midas/users. You can access the container's SSH server via ubuntu@127.0.0.1 -p <port>.

User rights mapping:
(container) <-> (host)
ubuntu <-> <host_user>
sharegrp <-> sharegrp (midas_lxc only)
datagrp <-> datagrp (midas_lxc only)

Mounts:
/mnt/share <-> /mnt/share
/mnt/data <-> /mnt/data
/mnt/home <-> /home

The /home/ubuntu user directory inside the container is no mount point!
So store your data on the mounted network volumes.
 
CUDA installation
-----------------
To get CUDA for tensorflow applications:

Copy the prepared CUDA libraries (and symlinks!) from the host into your container:
	sudo mkdir -p /midas
	sudo mkdir -p /midas/software
	sudo rsync -a /mnt/share/software/ /midas/software
	echo "module use /midas/software/modules" >> ~/.bashrc
module load ... sets the CUDA/CUDNN/TensorRT environment variables.
For older CUDA versions: There are also anaconda bundels to install tf/cuda in conda virtualenv.
