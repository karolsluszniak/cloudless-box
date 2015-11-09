# Cloudless Box

**Cloudless Box** is an opinionated Chef cookbook that allows to run one or more Ruby on Rails, Node, Meteor or Middleman applications on single server with databases, backup and more. It's targeted at VPS and dedicated servers that run CentOS Linux.

##### Who is it for?

1. Everyone who wants to have one or more Ruby on Rails, Node, Meteor, Middleman applications or static websites on single, blazing fast and secure web server without spending a dozen days configuring it and committing suicide on server or data failure.
2. Everyone who got used to easy deployments, such as those on Heroku, but wants it faster, cheaper and under control. With **Cloudless Box**, deploying new app is a matter of adding few lines to server's JSON config plus you get similar env variables like DATABASE_URL.
3. Everyone who is tired of configuring and executing deployment for each app separately (ie. Capistrano) - **Cloudless Box** can handle all deployments at once. Of course you can still opt for custom deployment strategies by omitting single configuration line.
4. Everyone who don't know their way around Chef - **Cloudless Box** comes with complete setup guide, possible to follow by people unfamiliar with server cookery. You are assumed to have basic *NIX terminal skills and a shiny new server with CentOS on it.

##### What do you get?

1. Nginx web server with Passenger for running Rack and Node apps.
2. Ability to access apps with server's subdomains or with custom domains.
3. Separate PostgreSQL, MongoDB and/or Redis databases for all apps.
4. Automatic solution to backup all databases to S3 on daily basis.
5. Per-app scalable workers with `Procfile` and scaling support.
6. Per-app cron tasks with [Whenever](https://github.com/javan/whenever)'s expressive syntax.
7. Preconfigured server essentials: SSH, IPTables and NTP.
8. Preconfigured web development essentials: Git, Bower, ImageMagick and FFmpeg.

## Installation

This section guides users unfamiliar with Chef through a complete process of setting up **Cloudless Box** on their own server conveniently managed by the Hosted Chef server. If you've already wrapped your head around Hosted Chef, Berkshelf and Knife, you can skip this section and just use this cookbook as usually.

### Prepare Chef

First, visit the [Get Chef](https://downloads.chef.io/chef-dk/) page, download Chef Development Kit for your operating system and install it. Then, visit the [Hosted Chef](https://manage.chef.io/login) page and sign in to Chef Manage or register for a free account.

If you've just created new account, you'll have to authorize your computer with the Chef server. Visit [Chef Manage](https://manage.chef.io/) and navigate to *Administration* » *Organizations*. There, you can download the *Starter Kit*. Do so. After downloading it, copy Chef credentials to your home directory:

    mkdir ~/.chef
    cp <starter-kit-path>/.chef/* ~/.chef/

You are now ready to work with your Hosted Chef server.

### Prepare cookbooks

Next step is to upload **Cloudless Box** to your Hosted Chef server. Invoke the following:

    git clone https://github.com/karolsluszniak/cloudless-box.git
    cd cloudless-box
    berks install
    berks upload

Now you have **Cloudless Box** cookbook and all its dependencies ready on your Hosted Chef server.

### Bootstrap new server

Go back to [Chef Manage](https://manage.chef.io/) page and create configuration for your server:

1. Navigate to *Policy* » *Environments* and click *Create*.
2. Name the environment and click *Next*.
3. On **Constraints** tab, select *cloudless-box* and enter current version of **Cloudless Box** (you can find it at *Policy* » *Cookbooks*).
4. Next is **Default attributes** tab. It's here where you write JSON that lists and configures your server's apps according to the [Configuration](#configuration) section below.

You can leave attributes empty and start by bootstrapping **Cloudless Box** without any apps. It'll still take a while to install server essentials so you'll have the time to read the [Configuration](#configuration) section and fill needed attributes.

Finally, you can bootstrap your server with the following command:

    knife bootstrap <address> --ssh-user root --ssh-password <your-password> --sudo --use-sudo-password --node-name <node-name> --environment <env-name> --run-list 'recipe[cloudless-box]'

That's it! You can re-provision the server by logging into it and executing:

    chef-client

This is usually done when your web apps were updated and they need re-deploy or when you have changed your server's environment attributes.

> You can repeat this step for each server that you want to govern with **Cloudless Box**. You can manage up to 5 servers with a free Hosted Chef server.

### Secure new server

It's recommended to disable root user after completing the bootstrap and using sudo-enabled account for future server visits. This step is not directly related to this cookbook, nor is it required, but it's strongly recommended for improving security.

In order to create new user, invoke the following:

    adduser <myuser>
    gpasswd -a <myuser> wheel
    passwd <myuser>

Finish by entering your new user's password. Now you should be able to log into your server with new account. You can re-provision your server at any time using new account with:

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

Cookbook is configured via attributes, usually set as JSON in server's environment attributes on the Chef Manage page. They may also be set as role default/override attributes or in any other fashion available in Chef.

After changing attributes, re-run `chef-client` on your server in order to apply new ones.

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
        },
        "nginx": {
          "client_max_body_size": "2M"
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

Below, you'll find a complete list of attributes available for configuring applications and other aspects of the **Cloudless Box** cookbook.

### Applications

You should list your applications in the `node["cloudless-box"]["applications"]` object. Object key specifies an application name, while object value may have the following per-app attributes:

Attribute | Description
----------|------------
`bower` | requests Bower support; if set, Bower will be available and `bower install --production` will be run on app's deployment
`env` | object with custom enviroment variables; if set, variables will be added to Bash profile, `.env` and Passenger ([read more](#environment-variables))
`layout` | specifies the application layout; can be one of `static`, `rails`, `node`, `meteor` or `middleman`; defaults to `static`
`mongodb` | requests MongoDB database for the application; if set to `true`, MONGO_URL environment variable will become available
`nginx` | object with custom Nginx options; if set, options will be added to application's Nginx site configuration
`postgresql` | requests PostgreSQL database for the application; if set to `true`, DATABASE_URL environment variable will become available
`public` | allows to change public sub-directory within app directory; defaults to `public`; if set to blank string, root directory will be served
`redis` | requests Redis database for the application; if set to `true`, REDIS_URL environment variable will become available
`repository` | enables deployment from specified repo; if unset, app deployment will not be managed by Chef; read [this](#private-repositories) if your repo is private
`repository_path` | uses specified path within repository as deployment root path; if unset, repository root will be used
`ruby` | requests specific Ruby version available for the application; if unset, default system Ruby will be available
`schedule` | allows to specify Whenever file or to disable the scheduling (with `false`); if unset, `config/schedule.rb` will be used
`secret` | sets additional secret component for generating SECRET_KEY_BASE in order to improve application security
`shared_dirs` | array of additional shared directories for on-deployment creation and symlinking; defaults to `log pids system` (plus per-layout additions)
`sticky_sessions` | enables sticky sessions Passenger setting; by default, it's enabled only for `meteor` layout; this comes useful when using WebSockets in an app
`symlinks` | object with custom symlinks for on-deployment linking; defaults to `.env`; allows to change or remove the defaults (with `false`)
`url` | sets custom domain for the application; if unset, app will be available at `<app-name>.domain.com` subdomain
`workers` | allows to add and control per-app workers; if unset, one worker process per line in app's Procfile will be configured

All attributes are optional and have sensible defaults. If none will be set, you'll end up with a system account for static, undeployed website without any database or addon on your server.

Packages like PostgreSQL, MongoDB, Redis, Ruby version manager, Meteor or Bower will not be installed on your system until any of your apps requests them. This will keep your system as lightweight as possible.

Removing applications from the `node["cloudless-box"]["applications"]` list will not remove them from your server. You'll have to do that manually by removing the `deploy-<app-name>` account along with all its files as well as Nginx site configuration.

### Global settings

In addition to application configuration, you can configure some aspects of **Cloudless Box** that are not related to any specific app. Following attributes are available:

Attribute | Description
----------|------------
`backup`  | object with `bucket`, `access_key_id` and `secret_access_key` keys that enables daily PostgreSQL and MongoDB database backup
`secret`  | sets additional secret component for generating various secret hashes across the server in order to improve overall security

## Usage

It may prove useful to know what **Cloudless Box** is doing under the hood for successful maintenance and customization of the server. Below, you'll find a more detailed description and some practical tips for your server's key functionalities.

### Deployment procedure

Here's what happens during the deployment:

1. Clone repository to a subdirectory in `releases`.
2. Purge shared directories from release.
3. Execute `bower install` (if requested).
4. Execute application build sub-procedure.
5. Create symlinks to shared directories and files.
6. Execute application release sub-procedure.
7. Create `current` symlink pointing to new release.
8. Restart the webserver.
9. Update cron table using Whenever (if configured).
10. Update and restart worker services.

Here's what happens during the application build sub-procedure:

Layout | Procedure
-------|----------
`meteor` | call `meteor build`, apply Node layout
`middleman` | call `middleman build`
`node` | link `node_modules` shared directory, call `npm install`
`rails` | call `bundle install`, call `rake assets:precompile`

Here's what happens during the application release sub-procedure:

Layout | Procedure
-------|----------
`rails` | remove `database.yml`, call `rake db:migrate`

### Private repositories

If some of your applications are stored on private repositories, their initial deploy will fail due to SSH access denial. In such case, you'll see error messages but the whole chef-client run will finish with remaining tasks. Among others, it will still create system accounts and SSH keys for these applications. You can display SSH key for specific app with the following command:

    sudo cat /home/deploy-<app-name>/.ssh/id_rsa.pub

Add this key as a deployment key in your app's repo settings on GitHub or BitBucket and re-provision with `chef-client` to finish the deployment.

### Environment variables

A number of default environment variables will be set for you in each app's:

- Bash profile
- `shared/.env` file
- Passenger settings
- worker services

Built-in variables include:

Variable | Example | Notes
---------|---------|------
APP_ROOT | `/home/deploy-<app-name/(...)` |
DATABASE_URL | `postgres://(...)` | only if PostgreSQL was requested
HOME | `/home/deploy-<app-name>` |
MONGO_URL | `mongodb://(...)` | only if MongoDB was requested
NODE_ENV | `production` | only for `node` layout
RAILS_ENV | `production` | only for `rails` layout
REDIS_URL | `redis://(...)` | only if Redis was requested
ROOT_URL | `http://<app-name>.domain.com` | only for `meteor` layout
SECRET_KEY_BASE | `6984cb8190(...)` | only for `rails` layout

You can add your own environment variables by listing them in the `node["cloudless-box"]["applications"]["<app-name>"]["env"]` object. Keys in this object will be automatically converted to upper case and your variables will be set in all places mentioned above.

See [example](#example) for a more clear picture of setting environment variables.

##### Tip: go to app root directory fast

In order to execute commands from your application instance, just type:

    cd $APP_ROOT
    # execute rake, npm or whatever

With this, here's how the whole procedure of logging in and executing rake task may look:

    ssh <my-user>@<my-server-address>
    sudo su - deploy-rails-app
    cd $APP_ROOT
    rake db:seed

### Cron schedule

[Whenever](https://github.com/javan/whenever) allows to write cron jobs with a human-readable, clean syntax. Support for Whenever is already built into **Cloudless Box**, so all you have to do is add `config/schedule.rb` file to your application and its cron table will get updated at the end of every deployment.

You can change the schedule file name or disable Whenever completely by setting the `schedule` per-app attribute to a path string or `false`, respectively.

### Worker services

**Cloudless Box** will process your app's `Procfile` and create system services for processes listed in this file. `Procfile` should be located in your project's root and it should look like this:

```
sidekiq: bundle exec sidekiq
queue: bundle exec rake queue
```

You can also use the `workers` per-app attribute to further customize your workers. Here's what you can achieve with the `workers` attribute.

##### Add additional workers

You can add workers that are not listed in `Procfile` like this:

```json
"workers": {
  "sidekiq": "bundle exec sidekiq",
  "queue": {
    "command": "bundle exec rake queue",
    "scale": 3
  }
}
```

If process with the same name appears in the `Procfile`, then attributes override the command.

##### Remove unneeded workers

You can also remove unneded workers from the `Procfile`. This may be useful if your application includes a web worker that is not needed for **Cloudless Box** (built in support for Nginx and Passenger will cover that for you). Here's how to do that:

```json
"workers": {
  "web": false
}
```

##### Scale workers

And of course, you can scale workers to run more than one instance. This can be achieved only via the attribute as `Procfile` doesn't have syntax for this. This can be achieved in two ways:

```json
"workers": {
  "queue1": 3,
  "queue2": {
    "scale": 5
  }
}
```

##### Tip: re-scale without Procfile change

Worker settings will only be applied at the end of every app deployment. This means that if you've only modified the attributes and not `Procfile`, you may need to push an empty commit to trigger the re-deployment and re-scaling of your app. Here's how to do that:

    git commit --allow-empty -m 'Trigger worker re-scale'

Alternatively, you can remove the `current` release link to trigger the re-deployment without polluting your repository:

    cd $HOME
    rm -f current

Remember that this will break your app's webserver until the next deployment finishes.
