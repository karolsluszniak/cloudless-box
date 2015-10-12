# cloudless-box

Cloudless box is an opinionated solution to run one or more Ruby on Rails, Node or Meteor applications on single server with PostgreSQL, MongoDB or Redis storage. Includes firewall, backup and more.

## Features

- configures one or many web applications on single server in efficient and secure way
- puts **Ruby on Rails**, **Node**, **Meteor** and static websites behind efficient Passenger server
- manages deployments in a centralized way (no need for Capistrano for each app)
- runs per-app cron tasks with [whenever](https://github.com/javan/whenever)
- have separate **PostgreSQL**, **MongoDB** and/or **Redis** databases for all your web apps
- just add S3 credentials to have all your data automatically backed up every night
- preconfigured essentials include Git, NTP, ImageMagick, FFmpeg and bower
- takes care of IPTables and SSH configuration

## Setup

### Bootstrapping

Visit the [Get Chef](https://www.chef.io/chef/get-chef/) page. There, do the following:

- sign up for a free Hosted Chef account
- install Chef Development Kit

After logging into Hosted Chef management page, do the following:

- create new environment for your server
    - cloudless-box as a dependency
    - configure environment attributes
- download the initial chef-repo

After obtaining chef-repo, `cd` into it and invoke the following command to bootstrap your new server:

    knife bootstrap <address> --ssh-user root --ssh-password <your-password> --sudo --use-sudo-password --node-name <node-name> --environment <env-name> --run-list 'recipe[cloudless-box]'

### Securing the server

##### Create new user

It's recommended to disable root user after completing the bootstrap. Invoke the following:

    adduser <myuser>
    gpasswd -a <myuser> wheel
    passwd <myuser>

Finish by entering your new user's password. Now you should be able to log into your server with new account. You can re-provision your server at any time using new account:

    sudo chef-client

This is usually done when web app updates have been pushed and they need re-deploy or when you have changed your server's Chef configuration.

##### Disable root access

Next, let's disable root user completely. Invoke the following:

    passwd -d root
    yum -y install nano
    nano /etc/ssh/sshd_config

Move to the end of the file and add the following:

    PermitRootLogin no

Hit `Ctrl+O` and `Ctrl+X`. Finish by restarting SSH:

    service sshd restart

## Configuration

Coming soon. Sorry for inconvenience.

### Application deployment

If some of your applications are stored on private repositories, their initial deploy will fail due to access denial. In such case, you'll see error messages but the whole Chef run will finish with remaining tasks. Among others, it will still create system accounts and SSH keys for these applications. You can display SSH key for specific app with the following command:

    sudo cat /home/deploy-<app-name>/.ssh/id_rsa.pub

Add this key as a deployment key in GitHub or BitBucket and re-provision to finish the deployment.

### Backup

Simply add S3 backup credentials to have a daily backup of all your PostgreSQL and MongoDB databases:

    node['cloudless-box']['backup'] = {
        'bucket' => '',
        'access_key_id' => '',
        'secret_access_key' => ''
    }

### Firewall

This cookbook will add exclusion rules for SSH and HTTP and close all other ports for security.
