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

bash 'php-timezone' do
  only_if 'grep -P \'^;.*date.timezone =\' /etc/php.ini'
  code 'sed -i -Ee "s/^;.*date.timezone =.*$/date.timezone = \'Asia\/Tokyo\'/" /etc/php.ini'
end

bash 'apache-allowoverride' do
  only_if '[ `grep -Pc \'^[^#]*AllowOverride[\t\s]+None$\' /etc/httpd/conf/httpd.conf` -eq 5 ]'
  code 'grep -Pn \'^[^#]*AllowOverride[\t\s]+None$\' /etc/httpd/conf/httpd.conf | head -n 2 | grep -o ^[0-9]* | xargs -i sed -i -Ee "{}c\    AllowOverride All" /etc/httpd/conf/httpd.conf'
end

bash 'apache-namevirtualhost' do
  only_if 'grep -P \'^#.*NameVirtualHost \*:80.*$\' /etc/httpd/conf/httpd.conf'
  code 'sed -i -Ee "s/^#([^#]*NameVirtualHost \*:80)$/\1/" /etc/httpd/conf/httpd.conf'
end

bash 'JST' do
  not_if 'date | grep -q JST'
  code 'cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime'
end

# allow root sudo from chef, without tty
bash 'visudo' do
  not_if 'grep -P "^[^#]*Defaults[\t\s]+\!requiretty" /etc/sudoers'
  code 'sed -i -Ee "s/^([^#][^!]*)(requiretty).*$/\1!\2/" /etc/sudoers'
end

# bash 'visudo-root' do
#   not_if '[ `sudo grep -Pc "^[^#]*Defaults:(root|%wheel)[\t\s]+\!requiretty" /etc/sudoers` -eq 2 ]'
#   code 'echo -e "Defaults:root    !requiretty\nDefaults:%wheel    !requiretty" >> /etc/sudoers'
# end

bash 'composer' do
  not_if { File.exists? "/usr/local/bin/composer" }
  user node['fuelphp']['user']
  cwd '/tmp'
  code <<-EOD
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
  chown #{node['fuelphp']['user']} /usr/local/bin/composer
  EOD
end

bash 'fuelphp' do
  not_if { File.exists? "/usr/bin/oil" }
  user node['fuelphp']['user']
  code 'sudo sh -c "curl get.fuelphp.com/oil | sh"'
end

