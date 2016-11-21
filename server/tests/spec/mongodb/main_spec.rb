require 'spec_helper'

packages = [
       'mongodb',
       'mongodb-server',
]

describe "mongodb packages should be available" do
    packages.each do |p|
        describe package(p) do
            it { should be_installed }
        end
    end
end
