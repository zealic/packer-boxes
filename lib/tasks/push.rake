require './lib/packer_template'

namespace :push do
  FORMATS.each do |format|
    task format.to_sym do
      template = PackerTemplate.new(format, ENV['target'], ENV['provider'], task_env = 'push')
      template.push()
    end
  end
end
