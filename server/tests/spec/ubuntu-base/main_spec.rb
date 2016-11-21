require 'spec_helper'

packages = [
  'tree',
  'which',
  'logrotate',
  'fail2ban'
]

files = [
  '/vagrant/tools/provision.sh'
]

describe "ubuntu-base packages should be available" do
  packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end

describe "vagrant files should be available" do
  files.each do |path|
    describe file(path) do
      it { should be_file}
    end
  end
end
