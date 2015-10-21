# Build vagrant box
task :build, [:target] do |t, args|
  template = load_template(args[:target], "local")

  run_build(template)
end
