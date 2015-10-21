# Generate packer template
task :generate, [:target] do |t, args|
  template = load_template(args[:target], "local")

  generated_file = "#{get_basedir(template.target)}/#{template.file}"
  puts "Template file '#{generated_file}' generated."
end
