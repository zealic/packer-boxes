require 'rake'
require 'json'
require 'yaml'
require 'fileutils'
require './lib/helpers'

STDOUT.sync = true

# Load rake tasks
Dir.glob('lib/tasks/*.rake').each { |r| load r}

# Setup default tasks
task :default => [:build]
