require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin:/usr/bin:/usr/local/bin'
  end
end

%w{httpd php mysql-server}.each do |p|
  describe package p do
    it { should be_installed }
  end
end

%w{httpd mysqld}.each do |s|
  describe service s do
    it { should be_enabled }
  end
end

%w{composer oil}.each do |c|
  describe command "which #{c}" do
    it { should return_exit_status 0 }
  end
end
