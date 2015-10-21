# Push packer template to atlas
task :push, [:target] do |t, args|
  template = load_template(args[:target], "remote")

  Dir.chdir(get_basedir(template.target)) do
    exec 'packer', 'push', "-name=#{CONFIG["atlas_user"]}/#{get_fullname(target)}", template.file
    File.delete(template.file)
  end
end
