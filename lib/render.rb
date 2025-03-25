require 'erb'

# Provides rendering functionality for ERB templates.
class Render
  # Renders an ERB template with the given binding context.
  #
  # @param template [String] The name of the ERB template file (relative to the "views" directory).
  # @param block_binding [Binding] The binding context that provides local variables to the template.
  # @return [String] The rendered HTML output.
  # @raise [RuntimeError] If the specified template file does not exist.
  def self.erb(template, block_binding)
    template_path = File.join("views", "#{template}")
    raise "Template not found: #{template_path}" unless File.exist?(template_path)
    
    erb_content = File.read(template_path)
    ERB.new(erb_content).result(block_binding)
  end
end