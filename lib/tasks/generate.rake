require './lib/packer_template'

namespace :generate do
  FORMATS.each do |format|
    task format.to_sym do
      opts = {
        :format   => format,
        :manifest => ENV['manifest'],
        :provider => ENV['provider'],
        :runtime  => ENV['runtime'],
        :task     => 'generate'
      }
      template = PackerTemplate.new(opts)
      template.run()
      puts "Template file '#{template.file}' generated."
    end
  end
end
