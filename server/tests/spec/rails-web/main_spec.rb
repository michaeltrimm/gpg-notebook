require 'spec_helper'

packages = [
   'nginx'
]

describe "rails-web packages should be available" do
  packages.each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
