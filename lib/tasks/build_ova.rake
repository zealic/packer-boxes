# Build OVA file
task :build_ova, [:target] do |t, args|
  template = load_template(args[:target], "local-ova")

  run_build(template)
end
