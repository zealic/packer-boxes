require 'securerandom'
require 'fileutils'
require 'open3'

###########################################################
# Definitions
###########################################################
CONFIG           = YAML.load(IO.read('config.yml'))
FORMATS          = ["ova", "ovf", "qcow2", "vagrant"]
MANIFEST_DIR     = "manifests"

class PackerTemplate
  attr_reader :build_format, :manifest, :provider, :task
  attr_reader :file, :build_date, :spec, :packer_template
  attr_reader :atlas_name

  def initialize(opts)
    defaults = CONFIG['defaults']
    @build_format = opts[:format]
    @manifest = opts[:manifest] || defaults['manifest']
    @provider = opts[:provider] || defaults['provider']
    @runtime = opts[:runtime] || defaults['runtime']
    @region = opts[:region] || defaults['region']
    @task = opts[:task]
    @file = File.join(get_basedir(), "packer-template.json")
    @build_date = DateTime.now.strftime("%Y%m%d")
    @spec = YAML.load(IO.read("#{MANIFEST_DIR}/#{@manifest}/spec.yml"))
    validate()

    if @task == 'push' and @runtime != 'cloud' then
      @runtime = 'vagrant'
    end
    suffix = (@runtime == 'vagrant' ? '' : "-#{@runtime}")
    @atlas_name = "#{@spec['atlas_user']}/#{@manifest}#{suffix}"

    FileUtils.mkdir_p(get_basedir())
    # Load packer template
    @packer_template = {
      'variables': {
        'memory_size':    "1024",
        'cpu_count':      "1",
        'atlas_user':     @spec['atlas_user'],
        'version':        @spec['version'],
        'template_name':  @manifest,
        'ssh_username':   'root',
        'ssh_password':   SecureRandom.base64
      }.merge(generate_build_info),
      'builders': []
    }

    # Setup variables
    task_vars = @spec['variables']
    (task_vars[@task] || task_vars['default']).each do |k,v|
      @packer_template[:variables][k.to_sym] = v
    end
  end

  def run()
    send(@task)
  end

  def build()
    generate()

    # Run packer build
    Dir.chdir(get_basedir()) do
      FileUtils.rm_rf(Dir.glob("output-#{@build_format}"))
      filename = File.basename(@file)
      exec "sh", "-c", "packer build -only=#{@build_format} #{filename}"
    end
  end

  def generate()
    # Generate packer template
    template = @packer_template.clone
    provider, builder = make_builder()
    template[:builders].push(builder)

    # Generate provisioners
    provisioners = []
    shell_env = []
    env_list = generate_build_info()

    if is_debian then
      env_list['DEBIAN_FRONTEND'] = "noninteractive"
    end
    env_list.each do |k, v|
      shell_env.push("#{k.upcase}=#{v}")
    end
    (@spec['remote-shell'] || []).each do |p|
      scripts = p.kind_of?(Array) ? p : [p]
      provisioners.push({
        'type': "shell",
        'scripts': scripts,
        'execute_command': "echo '{{user `ssh_password`}}' | {{.Vars}} sudo -S -E bash '{{.Path}}'",
        'environment_vars': shell_env
      })
    end
    template[:provisioners] = provisioners

    # Generate push
    processors = []
    if @build_format == "vagrant" then
      processors.push({
        "type": "vagrant",
        "vagrantfile_template": "Vagrantfile.template",
        "keep_input_artifact": false,
        "only": ["vagrant"]
      })
    end
    if @task == 'push' then
      if @build_format != "vagrant" then
        fail("Only vagrant format support push.")
      end

      processors.push({
        "type": "atlas",
        "artifact": @atlas_name,
        "artifact_type": "vagrant.box",
        "metadata": {
            "created_at": "{{timestamp}}",
            "provider": provider,
            "version": "{{user `version`}}",
            "revision": get_revision()
        },
        "only": ["vagrant"]
      })
      template[:push] = {
        "exclude": [".*", "*.box", "output-*", "packer_*", "*.json"]
      }
    end
    template[:"post-processors"] = [processors]

    # Generate template
    fileMap = {}
    fileMap[@file] = JSON.pretty_generate(template)
    var_scope = @packer_template[:variables].each_with_object({}){|(k,v), h| h[k.to_sym] = v}

    # Generate ks
    ks_template = IO.read("#{MANIFEST_DIR}/#{@manifest}/ks.cfg")
    fileMap[File.join(get_basedir(), "ks.cfg")] = ks_template % var_scope

    # Generate scripts
    raw_files = Dir.glob("scripts/**/*.sh")
    raw_files.each do |raw_file|
      fileMap["#{get_basedir()}/#{raw_file}"] = IO.read(raw_file) % var_scope
    end

    # Generate Vagrantfile.template
    fileMap[File.join(get_basedir(), "Vagrantfile.template")] = \
      IO.read("#{MANIFEST_DIR}/#{@manifest}/Vagrantfile.template") % var_scope

    # Write generated files
    FileUtils.rm_rf(Dir.glob(get_basedir() + "/scripts"))
    fileMap.each do |k, v|
      fileDir = File.dirname(k)
      FileUtils.mkdir_p(fileDir) unless File.exists?(fileDir)
      IO.binwrite(k, v)
    end
  end

  def push()
    generate()

    Dir.chdir(get_basedir()) do
      FileUtils.rm_rf(Dir.glob("output-#{@name}"))
      filename = File.basename(@file)
      exec 'packer', 'push', "-name=#{@atlas_name}", filename
    end
  end

  private
  def generate_build_info()
    return {
      'build_format': @build_format,
      'build_date': @build_date,
      'build_manifest': @manifest,
      'build_provider': @provider,
      'build_runtime': @runtime,
      'build_region': @region,
      'build_guest_os': is_debian ? 'debian' : is_centos ? 'centos': 'other'
    }
  end

  private
  def is_debian()
    @manifest.start_with?("debian")
  end

  private
  def is_centos()
    @manifest.start_with?("centos")
  end

  private
  def make_builder()
    format = @build_format
    builder = {
      'name': format,
      'vm_name': "{{user `template_name`}}",
      'headless': "{{user `headless`}}",
      'iso_url': "{{user `iso_url`}}",
      'iso_checksum': "{{user `iso_checksum`}}",
      'iso_checksum_type': "{{user `iso_checksum_type`}}",
      'http_directory': ".",
      'ssh_username': "{{user `ssh_username`}}",
      'ssh_password': "{{user `ssh_password`}}",
      'ssh_wait_timeout': "60m",
      'boot_wait': "5s",
      'shutdown_command': "sudo -S /sbin/halt -h -p",
      'disk_size': 10240
    }

    if is_centos then
      builder['boot_command'] = [
        "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"
      ]
    elsif is_debian then
      builder['boot_command'] = [
        "<esc><wait>",
        "install <wait>",
        " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg <wait>",
        "debian-installer=en_US <wait>",
        "auto <wait>",
        "locale=en_US <wait>",
        "kbd-chooser/method=us <wait>",
        "keyboard-configuration/xkb-keymap=us <wait>",
        "netcfg/get_hostname=localhost <wait>",
        "netcfg/get_domain=localdomain <wait>",
        "fb=false <wait>",
        "debconf/frontend=noninteractive <wait>",
        "console-setup/ask_detect=false <wait>",
        "console-keymaps-at/keymap=us <wait>",
        "grub-installer/bootdev=/dev/vda <wait>",
        "<enter><wait>"
      ]
    end

    provider = @provider
    # Formats
    if format == "ova" || format == "ovf" then
      provider = "virtualbox"
      builder['hard_drive_interface'] = "scsi"
      builder['guest_additions_mode'] = "disable"
      builder['format'] = format
      builder['export_opts'] = ["--options", "manifest,nomacs"]
    elsif format == "qcow2" then
      provider = "qemu"
    end

    if provider == "virtualbox" then
      builder['type'] = "virtualbox-iso"
      if is_debian then
        builder['guest_os_type'] = "Debian_64"
      elsif is_centos then
        builder['guest_os_type'] = "RedHat_64"
      else
        builder['guest_os_type'] = "Other"
      end
      builder['vboxmanage'] = [
        ["modifyvm", "{{.Name}}", "--memory", "{{user `memory_size`}}"],
        ["modifyvm", "{{.Name}}", "--cpus", "{{user `cpu_count`}}"]
      ]
      # DNS Speed UP
      if @task != 'push' then
        builder['vboxmanage'].push(["modifyvm", "{{.Name}}", "--natdnshostresolver1", "on"])
        builder['vboxmanage'].push(["modifyvm", "{{.Name}}", "--natdnsproxy1", "on"])
      end
    elsif provider == "vmware" then
      builder['type'] = "vmware-iso"
      if is_debian then
        builder['guest_os_type'] = "debian8-64"
      elsif is_centos then
        builder['guest_os_type'] = "centos-64"
      else
        builder['guest_os_type'] = "Other"
      end
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
      builder['headless'] = "true"
    else
      fail("Not supported provider '#{provider}'.")
    end

    return provider, builder
  end

  private
  def validate()
    manifests = Dir["#{MANIFEST_DIR}/*/"].map { |a| File.basename(a) }
    unless manifests.include?(@manifest) then
      fail("Invalid manifest '#{@manifest}', must be in #{manifests}.") 
    end

    runtimes = ["local", "cloud", "vagrant"]
    unless runtimes.include?(@runtime) then
      fail("Invalid runtime '#{@runtime}', must be in #{runtimes}.") 
    end
  end

  private
  def get_basedir()
    return ".target/#{@manifest}"
  end

  private
  def get_revision()
    Open3.popen3("git rev-parse --short=8 HEAD") {|i,o,e,t|
      out = o.read().strip()
      out == '' ? '00000000' : out
    }
  end
end
