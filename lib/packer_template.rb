###########################################################
# Definitions
###########################################################
CONFIG           = YAML.load(IO.read('config.yml'))
BASE_OS          = 'centos-7'
FORMATS          = ["ami", "ova", "vagrant", "qemu"]
TARGETS          = ["generic", "devenv"]
DEFAULT_TARGET   = TARGETS.first()
DEFAULT_PROVIDER = 'virtualbox'

class PackerTemplate
  attr_accessor :file
  attr_accessor :target
  attr_accessor :provider
  attr_accessor :build_format
  attr_reader   :builder_template
  attr_reader   :packer_template

  def initialize(build_format, target, provider, task_env = nil)
    @target = normalize_target(target || DEFAULT_TARGET)
    @build_format = build_format
    @provider = provider || DEFAULT_PROVIDER
    @file = File.join(get_basedir(@target), "packer-template.json")
    FileUtils.mkdir_p(get_basedir(@target))

    # Load packer template
    File.open("boxes/#{get_fullname(@target)}/template.json", "r" ) do |f|
      @packer_template = JSON.load(f)
    end
    if @packer_template["builders"].count != 1 then
      fail("Invalid template builders count, must be 1.") 
    end
    @builder_template = @packer_template['builders'][0].clone
    @packer_template['builders'] = []

    # Setup variables
    variables = CONFIG["variables"][task_env] || CONFIG["variables"]['_'].each do |k,v|
      @packer_template['variables'][k] = v
    end
    @packer_template['variables']['atlas_user']     = CONFIG['atlas_user']
    @packer_template['variables']['version']        = CONFIG['version']
    @packer_template['variables']['template_name']  = get_fullname(@target)
    @packer_template['variables']['build_format']   = build_format
    @packer_template['variables']['provider']       = @provider
  end

  def build()
    generate()

    # Run packer build
    Dir.chdir(get_basedir(@target)) do
      FileUtils.rm_rf(Dir.glob("output-#{@build_format}"))
      filename = File.basename(@file)
      exec "sh", "-c", "packer build -only=#{@build_format} #{filename}"
    end
  end

  def generate()
    # Generate packer template
    template = @packer_template.clone
    template['builders'].push(make_builder(@build_format))

    # For only content
    if @build_format != 'vagrant' then
      template['builders'].push(make_builder('vagrant'))
    end
    IO.write(@file, JSON.dump(template))

    # Generate ks template
    ks_template = IO.read("boxes/#{get_fullname(@target)}/ks.cfg")
    Dir.chdir(get_basedir(@target)) do
      ks_scope = @packer_template['variables'].each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      # kickstart file not support CRLF newline
      IO.binwrite("ks.cfg", ks_template % ks_scope)
    end

    # Copy scripts
    target_dir = get_basedir(@target)
    FileUtils.rm_rf(Dir.glob(target_dir + "/scripts"))
    FileUtils.cp_r("scripts", target_dir)
  end

  def push()
    generate()

    Dir.chdir(get_basedir(@target)) do
      FileUtils.rm_rf(Dir.glob("output-#{@name}"))
      filename = File.basename(@file)
      atlas_name = "#{CONFIG["atlas_user"]}/#{get_fullname(@target)}"
      exec 'packer', 'push', "-name=#{atlas_name}", filename
    end
  end

  private
  def make_builders(name)
    builder = @builder_template.clone
    builder['name'] = name
    template['builders'].push(builder)
    return builder
  end

  private
  def make_builder(format)
    builder = @builder_template.clone
    builder['name'] = format

    # Formats
    if format == "vagrant" then
      provider = "virtualbox"
    elsif format == "ami" then
      if (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil then
        provider = "vmware"
      else
        provider = "qemu"
      end
    elsif format == "ova" then
      provider = "virtualbox"
      builder['hard_drive_interface'] = "scsi"
      builder['guest_additions_mode'] = "disable"
      builder['format'] = "ova"
      builder['export_opts'] = ["--options", "manifest,nomacs"]
    end

    if provider == "virtualbox" then
      builder['type'] = "virtualbox-iso"
      builder['guest_os_type'] = "RedHat_64"
      builder['vboxmanage'] = [
        ["modifyvm", "{{.Name}}", "--memory", "{{user `memory_size`}}"],
        ["modifyvm", "{{.Name}}", "--cpus", "{{user `cpu_count`}}"]
      ]
    elsif provider == "vmware" then
      builder['type'] = "vmware-iso"
      builder['guest_os_type'] = "centos-64"
      builder['version'] = '11'
      builder['vmx_data'] = {
        "memsize": "{{user `memory_size`}}",
        "numvcpus": "{{user `cpu_count`}}",
        "vhv.enable": "TRUE"
      }
    elsif provider == "qemu" then
      builder['type'] = "qemu"
      builder['qemuargs'] = [
        ["-nographic", ""]
      ]
      builder["headless"] = "true"
    end

    return builder
  end

  def normalize_target(target)
    unless TARGETS.include?(target) then
      fail("Invalid target '#{target}', must be in #{TARGETS}.") 
    end
    return target
  end

  def get_basedir(target)
    return ".target/#{get_fullname(target)}"
  end

  def get_fullname(target)
    return "#{BASE_OS}-#{target}"
  end
end
