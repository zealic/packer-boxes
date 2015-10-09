require 'rake'
require 'json'
require 'fileutils'

DEFAULT_TARGET  = 'generic'
RELEASE_VERSION =  IO.read('VERSION')


###########################################################
# Helpers
###########################################################
def normalize_target(target)
  unless  ["generic", "devenv"].include?(target) then
    fail("Invalid target '#{target}', must be in [generic, devenv].") 
  end
  return target
end

def load_template(target)
  filename = "#{target}/centos-7-#{target}.json"
  generated_file = "#{target}/centos-7-#{target}.generated.json"

  template = nil
  File.open(filename, "r" ) do |f|
    template = JSON.load(f)
  end

  # Remove local builder
  index = template['builders'].find_index { |e| e['name'] == 'local' }
  unless index.nil?
    template['builders'].delete_at(index)
  end

  # Set variables
  template['variables']['version'] = RELEASE_VERSION

  # Generate template
  IO.write(generated_file, JSON.dump(template))
  return generated_file
end


###########################################################
# Tasks
###########################################################
task :default => [:build]

task :build, [:target] do |t, args|
  target = args[:target] || DEFAULT_TARGET
  target = normalize_target(target)

  template_file = "centos-7-#{target}.json"
  Dir.chdir(target) do
    FileUtils.rm_rf(Dir.glob('output-local'))
    exec "sh", "-c", "packer build -only=local -var RELEASE_VERSION=0.0.0 -var-file=../variables-local.json #{template_file}"
  end
end

task :push, [:target] do |t, args|
  target = normalize_target(args[:target])
  template_file = load_template(target)
  exec 'packer', 'push', template_file
  File.delete(template_file)
end
