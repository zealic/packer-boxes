require './lib/packer_template'

namespace :push do
  FORMATS.each do |format|
    task format.to_sym do
      opts = {
        :format   => format,
        :manifest => ENV['manifest'],
        :provider => ENV['provider'],
        :runtime  => ENV['runtime'],
        :task     => 'push'
      }
      template = PackerTemplate.new(opts)
      template.run()
    end
  end
end
