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