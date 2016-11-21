require 'spec_helper'

packages = [
       'redis-server',
       'redis-cli',
]

describe "redis packages should be available" do
    packages.each do |p|
        describe package(p) do
            it { should be_installed }
        end
    end
end
