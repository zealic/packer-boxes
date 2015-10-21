###########################################################
# Definitions
###########################################################
DEFAULT_TARGET  = 'generic'
CONFIG          = YAML.load(IO.read('config.yml'))
BASE_OS         = 'centos-7'

Template = Struct.new(:file, :target, :location)


###########################################################
# Helpers
###########################################################
def normalize_target(target)
  unless  ["generic", "devenv"].include?(target) then
    fail("Invalid target '#{target}', must be in [generic, devenv].") 
  end
  return target
end

def get_basedir(target)
  return ".target/#{get_fullname(target)}"
end

def get_fullname(target)
  return "#{BASE_OS}-#{target}"
end

def load_template(target, location)
  target = normalize_target(target || DEFAULT_TARGET)

  FileUtils.mkdir_p(get_basedir(target))
  ks_file        = "ks.cfg"
  generated_file = "packer-template.json"

  template = nil
  File.open("boxes/#{get_fullname(target)}/template.json", "r" ) do |f|
    template = JSON.load(f)
  end

  if template["builders"].count != 1 then
    fail("Invalid template builders count, must be 1.") 
  end

  # For Atlas remote build
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
  template['builders'][0]['name'] = location

  # Set variables
  CONFIG["variables"][location].each do |k,v|
    template['variables'][k] = v
  end
  template['variables']['atlas_user']     = CONFIG['atlas_user']
  template['variables']['version']        = CONFIG['version']
  template['variables']['build_location'] = location

  # Generate template
  ks_template = IO.read("boxes/#{get_fullname(target)}/ks.cfg")
  Dir.chdir(get_basedir(target)) do
    IO.write(generated_file, JSON.dump(template))
    ks_scope = template['variables'].each_with_object({}){|(k,v), h| h[k.to_sym] = v}
    # kickstart file not support CRLF newline
    IO.binwrite(ks_file, ks_template % ks_scope)
  end
  # Copy scripts
  FileUtils.rm_rf(Dir.glob(get_basedir(target) + "/scripts"))
  FileUtils.cp_r("scripts", get_basedir(target))

  return Template.new(generated_file, target, location)
end

def run_build(template)
  Dir.chdir(get_basedir(template.target)) do
    FileUtils.rm_rf(Dir.glob("output-#{template.location}"))
    exec "sh", "-c", "packer build -only=local #{template.file}"
  end
end
