require './lib/packer_template'

namespace :generate do
  FORMATS.each do |format|
    task format.to_sym do
      template = PackerTemplate.new(format, ENV['manifest'], ENV['provider'])
      template.generate()
      puts "Template file '#{template.file}' generated."
    end
  end
end
