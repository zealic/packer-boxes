require './lib/packer_template'

namespace :build do
  FORMATS.each do |format|
    task format.to_sym do
      template = PackerTemplate.new(format, ENV['manifest'], ENV['provider'])
      template.build()
    end
  end
end