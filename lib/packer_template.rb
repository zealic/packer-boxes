require 'securerandom'

###########################################################
# Definitions
###########################################################
CONFIG           = YAML.load(IO.read('config.yml'))
FORMATS          = ["ova", "ovf", "qcow2", "vagrant"]
MANIFEST_DIR     = "manifests"

class PackerTemplate
  attr_reader :build_format, :manifest, :provider, :region
  attr_reader :file, :build_date, :spec, :packer_template

  def initialize(build_format, manifest, provider, task_env = nil)
    defaults = CONFIG['defaults']
    @build_format = build_format
    @manifest = normalize_manifest(manifest || defaults['manifest'])
    @provider = provider || defaults['provider']
    @region = region || defaults['region']
    @file = File.join(get_basedir(), "packer-template.json")
    @build_date = DateTime.now.strftime("%Y%m%d")
    @spec = YAML.load(IO.read("#{MANIFEST_DIR}/#{@manifest}/spec.yml"))
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
        'ssh_password':   SecureRandom.base64,
        'build_format':   @build_format,
        'build_date':     @build_date,
        'build_provider': @provider
      },
      'builders': []
    }

    # Setup variables
    task_vars = @spec['variables']
    (task_vars[task_env] || task_vars['default']).each do |k,v|
      @packer_template[:variables][k.to_sym] = v
    end
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

  def generate(options={})
    # Generate packer template
    template = @packer_template.clone
    provider, builder = make_builder(@build_format, options)
    template[:builders].push(builder)

    # Generate provisioners
    provisioners = []
    shell_env = []
    env_list = {
      'BUILD_FORMAT': @build_format,
      'BUILD_DATE': @build_date,
      'BUILD_MANIFEST': @manifest,
      'BUILD_PROVIDER': "{{user `build_provider`}}",
      'BUILD_GUEST_OS': is_debian ? 'debian' : is_centos ? 'centos': 'other',
      'BUILD_REGION': @region
    }

    if is_debian then
      env_list['DEBIAN_FRONTEND'] = "noninteractive"
    end
    env_list.each do |k, v|
      shell_env.push("#{k}=#{v}")
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
        "keep_input_artifact": false,
        "only": ["vagrant"]
      })
    end
    if options[:push] then
      if @build_format != "vagrant" then
        fail("Only vagrant format support push.")
      end

      processors.push({
        "type": "atlas",
        "artifact": "{{user `atlas_user`}}/{{user `template_name`}}",
        "artifact_type": "vagrant.box",
        "metadata": {
            "created_at": "{{timestamp}}",
            "provider": provider,
            "version": "{{user `version`}}"
        },
        "only": ["vagrant"]
      })
      template[:push] = {
        "exclude": [".*", "*.box", "output-*", "packer_cache", "*.json"]
      }
    end
    template[:"post-processors"] = processors

    # Generate template
    IO.binwrite(@file, JSON.pretty_generate(template))

    # Generate ks template
    ks_template = IO.read("#{MANIFEST_DIR}/#{@manifest}/ks.cfg")
    Dir.chdir(get_basedir()) do
      ks_scope = @packer_template[:variables].each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      # kickstart file not support CRLF newline
      IO.binwrite("ks.cfg", ks_template % ks_scope)
    end

    # Copy scripts
    target_dir = get_basedir()
    FileUtils.rm_rf(Dir.glob(target_dir + "/scripts"))
    FileUtils.cp_r("scripts", target_dir)
  end

  def push()
    generate(push: true)

    Dir.chdir(get_basedir()) do
      FileUtils.rm_rf(Dir.glob("output-#{@name}"))
      filename = File.basename(@file)
      atlas_name = "#{@spec['atlas_user']}/#{@manifest}"
      exec 'packer', 'push', "-name=#{atlas_name}", filename
    end
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
  def make_builder(format, options)
    builder = {
      'name': format,
      'vm_name': "{{user `template_name`}}",
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
        "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg <wait>",
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
      if not options[:push] then
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

  def normalize_manifest(manifest)
    manifests = Dir["#{MANIFEST_DIR}/*/"].map { |a| File.basename(a) }
    unless manifests.include?(manifest) then
      fail("Invalid manifest '#{manifest}', must be in #{manifests}.") 
    end
    return manifest
  end

  private
  def get_basedir()
    return ".target/#{@manifest}"
  end
end
