# cloudless-box

## Features

(list of features)

## Setup

(info about chef server preparations, devkit installation and bootstrapping)

    knife bootstrap <address> --ssh-user root --ssh-password <your-password> --sudo --use-sudo-password --node-name node1 --environment node1 --run-list 'recipe[cloudless-box]'

(note about server securing after bootstrap)

It's recommended to disable root user after completing the bootstrap:

    adduser myuser
    passwd myuser
    gpasswd -a myuser wheel

    yum -y install nano
    nano /etc/ssh/sshd_config
        PermitRootLogin no

    passwd -d root
    service sshd restart

Afterwards, account myuser should be used to re-provision:

    sudo chef-client

## Configuration

(description of all supported attributes)

### Applications

(note about failure allowance as a chance to copy SSH keys)

### Backup

### Firewall

