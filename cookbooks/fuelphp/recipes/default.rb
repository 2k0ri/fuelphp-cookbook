#
# Cookbook Name:: fuelphp
# Recipe:: default
#
# Copyright (C) 2014 
#
# 
#
%w{httpd php mysql-server php-mysql php-pdo git sudo vim}.each do |p|
  package p
end

%w{httpd mysqld}.each do |s|
  service s do
    action [:enable, :start]
  end
end

# allow sudo from chef, without tty
bash 'visudo' do
  only_if 'grep -P \'^[^#]*Defaults[\t\s]+requiretty$\' /etc/sudoers'
  code 'sed -i -Ee "s/^([^#]*requiretty)$/# \1/" /etc/sudoers'
end

bash 'composer' do
  not_if { File.exists? "/usr/local/bin/composer" }
  #user node['fuelphp']['user']
  cwd '/tmp'
  code <<-EOD
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  EOD
end

bash 'fuelphp' do
  not_if { File.exists? "/usr/bin/oil" }
  #user node['fuelphp']['user']
  code 'curl get.fuelphp.com/oil | sh'
end

