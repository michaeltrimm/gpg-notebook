require 'spec_helper'

packages = [
       'haproxy'
]

describe "haproxy packages should be available" do
    packages.each do |p|
        describe package(p) do
            it { should be_installed }
        end
    end
end
