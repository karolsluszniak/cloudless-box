# Server prerequisites

Package/library prerequisites ([install guide for 1-4](https://gorails.com/deploy/ubuntu/14.04)):

1. Ubuntu Server 14.04 LTS
2. Ruby development dependencies
3. Nginx server with Passenger
4. PostgreSQL server
5. ImageMagick

User/group prerequisites to allow user-per-app deployment:

1. `deploy` group and sudo-enabled user in it
2. `/var/www` directory owned by `root:deploy`
3. `/etc/ssh/sshd_config` with `AllowGroups deploy` and `Port 51022`

# Project setup

### Add Capistrano

Add to `Gemfile`:

    group :development do
      gem "airbrussh", :require => false
      gem 'capistrano'
      gem 'capistrano-bundler'
      gem 'capistrano-passenger'
      gem 'capistrano-rails'
      gem 'capistrano-rbenv', github: "capistrano/rbenv"
    end

Install Capfiles:

    cap install STAGES=production

Edit `Capfile`:

    require 'capistrano/setup'
    require 'capistrano/deploy'
    require 'capistrano/bundler'
    require 'capistrano/rails'
    require 'capistrano/rbenv'
    require 'capistrano/passenger'
    require "airbrussh/capistrano"

    set :rbenv_type, :user
    set :rbenv_ruby, '<ruby-version>'

Edit `config/deploy.rb`:

    set :application, '<app>'
    set :repo_url, 'git@bitbucket.org:karolsluszniak/<app>.git'
    set :deploy_to, '/var/www/<app>'
    set :linked_files, %w{config/database.yml .env}
    set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
    set :keep_releases, 10

Edit `config/deploy/production.rb`:

    set :stage, :production

    server 'cloudless.pl', user: '<app>', roles: %w{web app db},
      ssh_options: { port: 51022 }

### Remove unneeded Heroku gems

Remove from `Gemfile` (to have log file and use passenger):

    group :production do
      gem 'rails_12factor'
      gem 'unicorn'
    end

### Configure logger

Add to `Gemfile`:

    gem 'lograge'

Add to `config/environments/production.rb`:

    config.lograge.enabled = true
    config.active_record.logger = nil

### Set Ruby version for rbenv

Add `.ruby-version`:

    <ruby-version>

# Server setup

All commands, except those with `# dev machine` comment, should be executed on the deployment server from the sudo enabled, `deploy` belonging account.

### Create user

    sudo adduser --ingroup deploy --home /var/www/<app> <app>
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 # generate <password>
    sudo -u postgres psql
      CREATE USER <app> WITH PASSWORD '<password>';
      CREATE DATABASE <app>;
      GRANT ALL PRIVILEGES ON DATABASE <app> TO <app>;
      \q

### Authorize dev machine's & project repo SSH

    ssh-copy-id <app>@cloudless.pl -p 51022 # dev machine
    ssh <app>@cloudless.pl -p 51022         # dev machine
    ssh-keygen
    cat ~/.ssh/id_rsa.pub # add as bitbucket/github deployment key

### Install rbenv

    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
    rbenv install <ruby-version>
    rbenv global <ruby-version>
    rbenv rehash
    ruby -v

    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    gem install bundler

### Add linked files

    cap production deploy:check # dev machine
    cd /var/www/<app>/shared/
    nano config/database.yml # and others

### Deploy & enable Passenger

    cap production deploy # dev machine

    cd /etc/nginx/sites-available/
    sudo cp default <app>
    sudo nano <app>
    cd ../sites-enabled/
    sudo ln -s ../sites-available/<app> ./
    sudo service nginx restart

### Migrate database from Heroku

    pg_dump <heroku_database_url> -Fc --no-acl --no-owner > heroku.dump
    pg_restore -d <app> -Fc -c --no-acl --no-owner --schema public heroku.dump
    rm heroku.dump
