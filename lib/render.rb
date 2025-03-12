require 'erb'
class Render
  def self.erb(template, block_binding)
    template_path = File.join("views", "#{template}")
    raise "Template not found: #{template_path}" unless File.exist?(template_path)
    erb_content = File.read(template_path)
    ERB.new(erb_content).result(block_binding)
  end
end
