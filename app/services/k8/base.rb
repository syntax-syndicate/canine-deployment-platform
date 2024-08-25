class K8::Base
  def template_path
    class_path_parts = self.class.name.split('::').map { |part| part.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '') }

    # Generate the file name dynamically based on the last part of the class name
    file_name = "#{class_path_parts.last}.yaml"

    # Construct the full file path using Rails.root.join
    Rails.root.join('resources', *class_path_parts[..-2], file_name)
  end
  
  def to_yaml
    template_content = template_path.read
    erb_template = ERB.new(template_content)
    erb_template.result(binding)
  end
end