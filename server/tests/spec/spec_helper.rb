require 'serverspec'
require 'excon'

# Bump the timeouts for Docker
Excon.defaults[:connect_timeout] = 600
Excon.defaults[:read_timeout] = 600

IMAGE_NAME = ENV['DOCKER_IMAGE_NAME'] || fail('DOCKER_IMAGE_NAME required!')
IMAGE_ID = ENV['DOCKER_IMAGE_ID'] || fail('DOCKER_IMAGE_ID required!')

# Load shared_examples from the various 'shared' directories. Each module
# must define a shared_examples behavior
base_spec_dir = Pathname.new(File.join(File.dirname(__FILE__)))
Dir[base_spec_dir.join('**/shared/**/*.rb')].sort.each{ |f| require f }

set :backend, :docker
set :docker_image, IMAGE_ID
set :docker_container_create_options, {
    'Cmd' => '/bin/bash'
}
set :request_pty, true

puts '-------------------------------------'
puts "Testing docker image: #{IMAGE_NAME} (#{IMAGE_ID})"
puts '-------------------------------------'
