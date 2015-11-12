require './lib/packer_template'

namespace :build do
  FORMATS.each do |format|
    task format.to_sym do
      opts = {
        :format   => format,
        :manifest => ENV['manifest'],
        :provider => ENV['provider'],
        :runtime  => ENV['runtime'],
        :task     => 'build'
      }
      template = PackerTemplate.new(opts)
      template.run()
    end
  end
end
