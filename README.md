# cloudless-box

Cloudless box is an opinionated solution to run one or more Ruby on Rails, Node or Meteor applications on single server with PostgreSQL, MongoDB or Redis databases. Includes firewall, backup and more.

## Features

- comes with complete setup guide, possible to follow by people unfamiliar with Chef
- configures one or many web applications on single server in efficient and secure way
- puts **Ruby on Rails**, **Node**, **Meteor** and static websites behind efficient Passenger proxy
- manages deployments in a centralized way (no need for Capistrano for each app)
- configures separate **PostgreSQL**, **MongoDB** and/or **Redis** databases for all apps
- comes with an automatic solution to backup all app databases to S3 every night
- includes preconfigured essentials like NTP, ImageMagick, FFmpeg and bower
- runs per-app cron tasks with [whenever](https://github.com/javan/whenever)'s intuitive syntax
- takes care of IPTables and SSH configuration

## Setup

This section guides users new to Chef through a complete process of setting up cloudless-box on their own server, while managing the whole process with a Hosted Chef server. If you've already wrapped your head around Hosted Chef, Berkshelf and Knife, you can skip this section and just use this cookbook as usually.

### Prepare Chef

First, visit the [Get Chef](https://downloads.chef.io/chef-dk/) page, download Chef Development Kit for your operating system and install it. Then, visit the [Hosted Chef](https://manage.chef.io/login) page and sign in to Chef Manage or register for a free account.

If you've just created new account, you'll have to authorize your computer with the Chef server. Visit [Chef Manage](https://manage.chef.io/) and click *Administration* and *Organizations*. There, you can download the *Starter Kit*. Do so. After downloading it, copy the `.chef` directory inside it to your home directory:

    mkdir ~/.chef
    cp <starter-kit-path>/.chef/* ~/.chef/

You are now ready to work with your Hosted Chef account.

### Install cloudless-box

Next step is to upload cloudless-box to your Hosted Chef account. Invoke the following:

    git clone https://github.com/karolsluszniak/cloudless-box.git
    cd cloudless-box
    berks install
    berks upload

Now you have cloudless-box cookbook and all its dependencies ready on your Hosted Chef account.

### Bootstrap new server

Go back to [Chef Manage](https://manage.chef.io/) page in order to create configuration for your server. Click *Policy*, *Environments* and *Create*. Name the environment and click *Next*. On *Constraints* tab, select *cloudless-box* and enter current version of cloudless-box (you can find it at *Policy*/*Cookbooks*). Next is *Default attributes* tab. It's here where you write JSON that lists and configures your server's apps according to the **Configuration** section below. You can also leave it empty for now and start by bootstrapping cloudless-box without any apps.

Finally, you can bootstrap your server with the following command:

    knife bootstrap <address> --ssh-user root --ssh-password <your-password> --sudo --use-sudo-password --node-name <node-name> --environment <env-name> --run-list 'recipe[cloudless-box]'

That's it! You can re-provision the server by logging into it and executing:

    chef-client

This is usually done when your web apps were updated and they need re-deploy or when you have changed your server's environment attributes.

### Secure new server

It's recommended to disable root user after completing the bootstrap and using sudo-enabled account for future server visits. This step is not directly related to this cookbook, nor is it required, but it's strongly recommended for improving security.

In order to create new user, invoke the following:

    adduser <myuser>
    gpasswd -a <myuser> wheel
    passwd <myuser>

Finish by entering your new user's password. Now you should be able to log into your server with new account. You can re-provision your server at any time using new account:

    sudo chef-client

Next, let's disable root user completely. Invoke the following:

    passwd -d root
    yum -y install nano
    nano /etc/ssh/sshd_config

Move to the end of the file and add the following:

    PermitRootLogin no

Hit `Ctrl+O` and `Ctrl+X`. Finish by restarting SSH:

    service sshd restart

## Configuration

### Applications

Complete attribute description coming soon. In the meantime, this is a sample JSON with attributes for sample multi-app setup:

    {
      "cloudless-box": {
        "applications": {
          "my-rails-app": {
            "layout": "rails",
            "ruby": "2.2.2",
            "postgresql": true,
            "url": "my-rails-app.com",
            "repository": "git@bitbucket.org:user/repo.git",
            "env": {
              "aws_s3_bucket": "(...)",
              "aws_access_key_Id": "(...)",
              "aws_secret_access_key": "(...)"
            }
          },
          "my-meteor-app": {
            "layout": "meteor",
            "mongodb": true,
            "repository": "git@github.com:user/repo.git"
          },
          "my-node-app": {
            "layout": "node",
            "bower": true,
            "repository": "git@bitbucket.org:user/repo.git",
            "env": {
              "google_analytics_id": "(...)"
            }
          }
        }
      }
    }

#### Private repos

If some of your applications are stored on private repositories, their initial deploy will fail due to SSH access denial. In such case, you'll see error messages but the whole chef-client run will finish with remaining tasks. Among others, it will still create system accounts and SSH keys for these applications. You can display SSH key for specific app with the following command:

    sudo cat /home/deploy-<app-name>/.ssh/id_rsa.pub

Add this key as a deployment key in your app's repo settings on GitHub or BitBucket and re-provision with `chef-client` to finish the deployment.

### Backup

Simply add S3 backup credentials to have a daily backup of all your PostgreSQL and MongoDB databases:

    node['cloudless-box']['backup'] = {
        'bucket' => '',
        'access_key_id' => '',
        'secret_access_key' => ''
    }

### Firewall

This cookbook will add exclusion rules for SSH and HTTP and close all other ports for security. You can disable this by setting:

    node['cloudless-box']['firewall'] = false
