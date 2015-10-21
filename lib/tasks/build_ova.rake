# Build OVA file
task :build_ova, [:target] do |t, args|
  template = load_template(args[:target], "local-ova")

  File.join(File.basename(template.file), "output-#{template.location}", "#{template.target}.ova")
  run_build(template)
end
