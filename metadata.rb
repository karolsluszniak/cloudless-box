name 'cloudless-box'
version '1.4.1'
maintainer 'Karol Słuszniak'
maintainer_email 'karol@cloudless.pl'
license 'MIT'
description 'Cloudless box is an opinionated solution to run one or more Ruby on Rails, Node or Meteor applications on single server with databases, backup, firewall and more.'

recipe "cloudless-box", "configure everything in cloudless box."

supports 'centos', '>= 7.0'

depends 'build-essential', '~> 2.2.3'
depends 'database', '~> 4.0.8'
depends 'git', '~> 4.3.3'
depends 'imagemagick', '~> 0.2.3'
depends 'iptables', '~> 1.0.0'
depends 'mongodb', '~> 0.16.2'
depends 'nodejs', '~> 2.4.0'
depends 'ntp', '~> 1.8.6'
depends 'postgresql', '~> 3.4.20'
depends 'rbenv', '~> 1.7.1'
depends 'redisio', '~> 2.3.0'
depends 'selinux', '~> 0.9.0'
depends 'ssh', '~> 0.10.6'
depends 'yum', '~> 3.6.3'
depends 'yum-epel', '~> 0.6.2'

