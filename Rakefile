require 'rake'
require 'json'
require 'yaml'
require 'fileutils'

DEFAULT_TARGET  = 'generic'
CONFIG          = YAML.load(IO.read('config.yml'))


###########################################################
# Helpers
###########################################################
def normalize_target(target)
  unless  ["generic", "devenv"].include?(target) then
    fail("Invalid target '#{target}', must be in [generic, devenv].") 
  end
  return target
end

def load_template(target, location)
  generated_file = "centos-7-#{target}.generated.json"

  template = nil
  File.open("#{target}/centos-7-#{target}.json", "r" ) do |f|
    template = JSON.load(f)
  end

  if template["builders"].count != 1 then
    fail("Invalid template builders count, must be 1.") 
  end

  # For Atlas remote build
  template['builders'][0]['name'] = location
  if location == "local-ova" then
    location = "local"
    template['builders'][0]['hard_drive_interface'] = "scsi"
    template['builders'][0]['guest_additions_mode'] = "disable"
    template['builders'][0]['format'] = "ova"
    template['builders'][0]['export_opts'] = ["--options", "manifest,nomacs"]
  end
  if location == "local" then
    remote_builder = template['builders'][0].clone
    remote_builder['name'] = "remote"
    template['builders'].push(remote_builder)
  end

  # Set variables
  CONFIG["variables"][location].each do |k,v|
    template['variables'][k] = v
  end
  template['variables']['version'] = CONFIG['version']
  template['variables']['build_location'] = location

  # Generate template
  Dir.chdir(target) do
    IO.write(generated_file, JSON.dump(template))
  end
  return generated_file
end

def run_build(target, template_file, location)
  Dir.chdir(target) do
    FileUtils.rm_rf(Dir.glob("output-#{location}"))
    exec "sh", "-c", "packer build -only=local #{template_file}"
  end
end

###########################################################
# Tasks
###########################################################
task :default => [:build]

task :build, [:target] do |t, args|
  target = args[:target] || DEFAULT_TARGET
  target = normalize_target(target)
  template_file = load_template(target, "local")

  run_build(target, template_file, "local")
end

task :build_ova, [:target] do |t, args|
  target = args[:target] || DEFAULT_TARGET
  target = normalize_target(target)
  template_file = load_template(target, "local-ova")

  run_build(target, template_file, "local")
end

task :push, [:target] do |t, args|
  target = normalize_target(args[:target])
  template_file = load_template(target, "remote")

  Dir.chdir(target) do
    exec 'packer', 'push', template_file
    File.delete(template_file)
  end
end

task :generate, [:target] do |t, args|
  target = normalize_target(args[:target])
  template_file = load_template(target, "local")
  puts "Template file '#{template_file}' generated."
end
