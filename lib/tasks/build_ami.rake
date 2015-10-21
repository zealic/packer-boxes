require 'mkmf'
require 'json'
require 'aws-sdk'

# Push packer template to atlas
task :build_ami, [:target, :profile] do |t, args|
  # Check aws cli
  fail("aws cli is required.") if find_executable('aws') == nil

  # AWS profile
  profile_name = args[:profile] || "china"
  profile = CONFIG['aws'][profile_name]
  unless profile then
    fail("Can not found aws profile '#{profile_name}'")
  end

  template = load_template(args[:target], "local")
  ova_file = File.join(get_basedir(template.target),
    "output-#{template.location}",
    "#{get_fullname(template.target)}.ova")

  Rake::Task["build_ova"].invoke

  load_env(profile)
  upload_s3_file(template, profile, ova_file)
end

def load_env(profile)
  Aws.config.update({
    region: profile["region"]
  })
  unless ENV['AWS_ACCESS_KEY_ID'] then
    env = YAML.load(IO.read('.env'))
    Aws.config.update({
      credentials: Aws::Credentials.new(
        ENV['AWS_ACCESS_KEY_ID'] || env['AWS_ACCESS_KEY_ID'],
        ENV['AWS_ACCESS_KEY_ID'] || env['AWS_SECRET_ACCESS_KEY']
      )
    })
  end
end

def upload_s3_file(template, profile, file)
  bucket      = profile['s3bucket']
  build_date  = DateTime.now.strftime("%Y%m%d")
  ami_version = "v#{CONFIG['version']}-#{build_date}"
  s3key = "#{get_fullname(template.target)}-#{ami_version}.ova"

  s3 = Aws::S3::Resource.new()
  obj = s3.bucket(bucket).object(s3key)
  puts "Uploading file '#{file}' to 's3://#{bucket}/#{s3key}'..."
  obj.upload_file(file)
end
