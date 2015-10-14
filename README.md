# cloudless-box

Cloudless box is an opinionated Chef cookbook that allows to run one or more Ruby on Rails, Node or Meteor applications on single server with databases, backup and more. It's targeted at VPS and dedicated servers that run the CentOS Linux.

##### Who is it for?

1. Everyone who wants to have one or more Ruby on Rails, Node, Meteor applications or static websites on single, blazing fast and secure web server without spending a dozen days configuring it and committing suicide on server/data failure.
2. Everyone who got used to easy deployments, such as those on Heroku, but wants it faster, cheaper and under control. With **cloudless-box**, deploying new app is a matter of adding few lines to server's JSON config plus you get similar env variables like DATABASE_URL.
3. Everyone who is tired of configuring and executing deployment for each app separately (ie. Capistrano) - **cloudless-box** can handle all deployments at once. Of course you can still opt for custom deployment strategies by omitting single configuration line.
4. Everyone who don't know their way around Chef - **cloudless-box** comes with complete setup guide, possible to follow by people unfamiliar with server cookery. You are assumed to have basic *nix terminal skills and a shiny new server with CentOS on it.

##### What do you get?

1. Nginx web server with Passenger for running Rack and Node apps.
2. Ability to access apps with server's subdomains or with custom domains.
3. Separate PostgreSQL, MongoDB and/or Redis databases for all apps.
4. Automatic solution to backup all databases to S3 on daily basis.
5. Preconfigured server essentials: NTP, SSH and IPTables,
6. Preconfigured web development essentials: Git, Bower, ImageMagick and FFmpeg.
7. Per-app cron tasks with [whenever](https://github.com/javan/whenever)'s expressive syntax.

## Installation

This section guides users new to Chef through a complete process of setting up **cloudless-box** on their own server, while managing the whole process with a Hosted Chef server. If you've already wrapped your head around Hosted Chef, Berkshelf and Knife, you can skip this section and just use this cookbook as usually.

### Prepare Chef

First, visit the [Get Chef](https://downloads.chef.io/chef-dk/) page, download Chef Development Kit for your operating system and install it. Then, visit the [Hosted Chef](https://manage.chef.io/login) page and sign in to Chef Manage or register for a free account.

If you've just created new account, you'll have to authorize your computer with the Chef server. Visit [Chef Manage](https://manage.chef.io/) and click *Administration* and *Organizations*. There, you can download the *Starter Kit*. Do so. After downloading it, copy the `.chef` directory inside it to your home directory:

    mkdir ~/.chef
    cp <starter-kit-path>/.chef/* ~/.chef/

You are now ready to work with your Hosted Chef account.

### Install cloudless-box

Next step is to upload **cloudless-box** to your Hosted Chef account. Invoke the following:

    git clone https://github.com/karolsluszniak/cloudless-box.git
    cd cloudless-box
    berks install
    berks upload

Now you have **cloudless-box** cookbook and all its dependencies ready on your Hosted Chef account.

### Bootstrap new server

Go back to [Chef Manage](https://manage.chef.io/) page in order to create configuration for your server. Navigate to *Policy* » *Environments* and click *Create*. Name the environment and click *Next*. On **Constraints** tab, select *cloudless-box* and enter current version of **cloudless-box** (you can find it at *Policy* » *Cookbooks*). Next is **Default attributes** tab. It's here where you write JSON that lists and configures your server's apps according to the [Usage](#usage) section below. You can also leave it empty for now and start by bootstrapping **cloudless-box** without any apps.

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

## Usage

Cookbook is configured via attributes, usually set as JSON in server's environment attributes on the Chef Manage page. They may also be set as role default/override attributes or in any other fashion available in Chef.

After changing attributes, you should re-run `chef-client` on your server in order to apply new ones.

### Example

A complete JSON configuration may look like this:

```json
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
    },
    "backup": {
      "bucket": "(...)",
      "access_key_id": "(...)",
      "secret_access_key": "(...)"
    },
    "secret": "my-server-secret"
  }
}
```

Below, you'll find a complete list of attributes available for configuring applications and other aspects of the **cloudless-box** cookbook.

### Applications

You should list your applications in the `node["cloudless-box"]["applications"]` object. Object key specifies an application name, while object value may have the following attributes:

Attribute | Description
----------|------------
`bower` | requests Bower support; if set, Bower will be available and `bower install --production` will be run on app's deployment
`env` | object with custom enviroment variables; if set, variables will be added to Bash profile, `.env` and Passenger ([read more](#environment-variables))
`layout` | specifies the application layout; can be one of `static`, `rails`, `node` or `meteor`; defaults to `static`
`mongodb` | requests MongoDB database for the application; if set to `true`, MONGO_URL environment variable will become available
`postgresql` | requests PostgreSQL database for the application; if set to `true`, DATABASE_URL environment variable will become available
`public` | allows to change public sub-directory within app directory; defaults to `public`; if set to blank string, root directory will be served
`redis` | requests Redis database for the application; if set to `true`, REDIS_URL environment variable will become available
`repository` | enables deployment from specified repo; if unset, app deployment will not be managed by Chef; read [this](#private-repositories) if your repo is private
`ruby` | requests specific Ruby version available for the application; if unset, default system Ruby will be available
`secret` | sets additional secret component for generating SECRET_KEY_BASE in order to improve application security
`sticky_sessions` | enables sticky sessions Passenger setting; by default, it's enabled only for `meteor` layout; this comes useful when using WebSockets in an app
`url` | sets custom domain for the application; if unset, app will be available at `<app-name>.domain.com` subdomain

All attributes are optional and have sensible defaults. If none will be set, you'll end up with an user account for static, undeployed website without any database or addon on your server.

Packages like PostgreSQL, MongoDB, Redis, Ruby version manager, Meteor or Bower will not be installed on your system until any of your apps requests them. This will keep your system as lightweight as possible.

Removing applications from the `node["cloudless-box"]["applications"]` list will not remove them from your server. You'll have to do that manually by removing the `deploy-<app-name>` account along with all its files as well as Nginx site configuration.

#### Environment variables

A number of default environment variables will be set for you in each app's:

- Bash profile
- `shared/.env` file
- Passenger settings

Built-in variables include:

Variable | Example | Notes
---------|---------|------
DATABASE_URL | `postgres://(...)` | only if PostgreSQL was requested
HOME | `/home/deploy-<app-name>` | always set
MONGO_URL | `mongodb://(...)` | only if MongoDB was requested
NODE_ENV | `production` | only for `node` layout
RAILS_ENV | `production` | only for `rails` layout
REDIS_URL | `redis://(...)` | only if Redis was requested
ROOT_URL | `http://<app-name>.domain.com` | only for `meteor` layout
SECRET_KEY_BASE | `6984cb8190(...)` | only for `rails` layout

You can add your own environment variables by listing them in the `node["cloudless-box"]["applications"]["<app-name>"]["env"]` object. Keys in this object will be automatically converted to upper case and your variables will be set in all places mentioned above.

See [example](#example) for a more clear picture of setting environment variables.

#### Private repositories

If some of your applications are stored on private repositories, their initial deploy will fail due to SSH access denial. In such case, you'll see error messages but the whole chef-client run will finish with remaining tasks. Among others, it will still create system accounts and SSH keys for these applications. You can display SSH key for specific app with the following command:

    sudo cat /home/deploy-<app-name>/.ssh/id_rsa.pub

Add this key as a deployment key in your app's repo settings on GitHub or BitBucket and re-provision with `chef-client` to finish the deployment.

### Secret base

You should set `node["cloudless-box"]["secret"]` to add additional secret component for generating various secret hashes across your server in order to improve its security. You can also configure [per-app](#applications) secrets for even more security.

### Backup

Simply add S3 backup credentials to have a daily backup of all your PostgreSQL and MongoDB databases. Set `node["cloudless-box"]["backup"]` to an object with `bucket`, `access_key_id` and `secret_access_key` keys.

Backup will only be enabled for database types that are actually used by configured [applications](#applications).

### Whenever

[Whenever](https://github.com/javan/whenever) allows you to write cron jobs with a human-readable, clean syntax. All you have to do is put `config/schedule.rb` file into your application and **cloudless-box** will automatically update your app's crontab at the end of every deployment.

### Firewall

This cookbook will add exclusion rules for SSH and HTTP and close all other ports for security. You can stop **cloudless-box** from touching your firewall settings by setting `node["cloudless-box"]["firewall"]` to `false`.

