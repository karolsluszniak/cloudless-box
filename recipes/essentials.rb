include_recipe "yum"
include_recipe "yum-epel"
include_recipe "build-essential"
include_recipe 'selinux::permissive'
