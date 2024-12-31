# lib/tasks/rspec_generator.rake
require 'parser/current'
require 'unparser'
SYSTEM_PROMPT = <<~SYSTEM_PROMPT
You are a system that generates RSpec tests for Ruby on Rails code. Output the RSpec code only.
Output the content in a format like
Example:

```ruby
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
  end
end
```

SYSTEM_PROMPT

def spec_path(original_path)
  Rails.root.join(original_path.sub(/^app/, 'spec').sub(/\.rb$/, '_spec.rb'))
end


def load_config(config_path)
  config = YAML.load_file(config_path)
  validate_config(config)
  config
end

def validate_config(config)
  unless config['project_description'] && config['starting_points']
    raise "Config must contain 'project_description' and 'starting_points'"
  end
end

namespace :spec do
  desc 'Generate RSpec tests based on YAML configuration'
  task :generate, [:config_path] => :environment do |_, args|
    unless args.config_path
      puts "Usage: rake spec:generate[path/to/config.yml]"
      exit 1
    end

    config = load_config(args.config_path)
    config['starting_points'].each do |starting_point|
      Dir.glob(starting_point).map do |file_path|
        # Don't overwrite existing specs unless configured to do so
        if File.exist?(spec_path(file_path))
          puts "Skipping existing spec: #{file_path}"
          next
        end
        RspecGenerator.new(Pathname.new(file_path), config).run
      end
    end
  end
end

class RspecGenerator
  MAX_DEPTH = 5
  MAX_FILES = 10

  def initialize(starting_file, config)
    @starting_file = starting_file
    @visited_files = Set.new
    @code_blocks = []
    @parser = Parser::CurrentRuby.new
    @parser.diagnostics.consumer = lambda { |diagnostic| }
    @config = config
  end

  private

  def find_file(name)
    name = name.to_s.split('::').map(&:underscore).join('/')

    Rails.autoloaders.main.dirs.each do |dir|
      path = File.join(dir, "#{name}.rb")
      if File.exist?(path)
        return Pathname.new(path).relative_path_from(Rails.root)
      end
    end
  
    nil
  end

  def parse_ruby_file(file_path)
    content = File.read(file_path)
    @code_blocks << {
      path: file_path.to_s,
      content: content
    }

    buffer = Parser::Source::Buffer.new(file_path.to_s)
    buffer.source = content
    ast = @parser.parse(buffer)

    collector = ReferenceCollector.new
    collector.process(ast)
    
    collector.references.to_a
  rescue Parser::SyntaxError => e
    Rails.logger.warn "Syntax error in #{file_path}: #{e.message}"
    []
  end

  def compile_file(file_path, depth = 0)
    if @visited_files.include?(file_path)
      return
    end

    references = parse_ruby_file(file_path)
    @visited_files.add(file_path)

    queue = references.map { |ref| [ref, depth + 1] }
    
    until queue.empty?
      reference, current_depth = queue.shift
      compile_code(reference, current_depth)
    end
  end

  def compile_code(starting_point, depth = 0)
    return if depth >= MAX_DEPTH || @visited_files.size >= MAX_FILES

    file_path = find_file(starting_point)
    if file_path.nil?
      return
    end

    compile_file(file_path, depth)
  end

  def write_spec_file(spec_content, original_path)
    full_path = spec_path(original_path)
    
    # Ensure directory exists
    FileUtils.mkdir_p(File.dirname(full_path))

    File.write(full_path, spec_content)
    puts "Generated spec: #{original_path}"
  end

  def generate_specs(code_blocks)
    debugger
    prompt = <<~PROMPT
      Project Description: #{@config['project_description']}

      Source Code:
      #{code_blocks.map { |block| "File: #{block[:path]}\n#{block[:content]}\n" }.join("\n")}

      Please generate RSpec tests for only the first code block. Use the rest of the code blocks for understanding how the first code block should work. following these guidelines:
      1. Create comprehensive unit tests
      2. Include edge cases
      3. Follow RSpec best practices
      4. Use appropriate test doubles (mocks/stubs) where necessary
      5. Structure tests in describe/context/it blocks
      6. Consider the relationships between classes/modules
      7. Test both success and failure scenarios
      8. Include necessary setup in before blocks
      9. Use factories where appropriate
      10. Test validations, callbacks, and business logic
    PROMPT
    puts "Generated prompt length: #{prompt.length}"

    return extract_ruby_code(call_llm_api(prompt))
  end

  def extract_ruby_code(snippet)
    match = snippet.match(/```ruby\n(.*?)\n```/m)
    if match
      return match[1]
    else
      raise "No valid Ruby code found in the response:\n\n\n#{snippet}\n\n\n"
    end
  end

  public

  def call_llm_api(prompt)
    # TODO: Implement actual LLM API call
    "TODO: Implement LLM API integration"
    ENV['OPENAI_API_KEY']
    llm = Langchain::LLM::OpenAI.new(
      api_key: ENV["OPENAI_API_KEY"],
      default_options: { temperature: 0.7, chat_model: "gpt-4o" }
    )

    messages = [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: prompt }
    ]

    response = llm.chat(messages:)
    response.chat_completion
 end

  def run
    compile_file(@starting_file)
    if @code_blocks.empty?
      puts "No source files found for the given starting points"
      return
    end

    puts "Found #{@code_blocks.length} related files:"
    @code_blocks.each do |block|
      puts "- #{block[:path]}"
    end

    spec_content = generate_specs(@code_blocks)

    write_spec_file(spec_content, @starting_file)
  end
end

class ReferenceCollector
  attr_reader :references

  def initialize
    @references = Set.new
    puts "Initialized ReferenceCollector"  # Debugging output
    super
  end

  def process(ast)
    return unless ast.is_a?(Parser::AST::Node)

    if ast.type == :const
      # Extract the full constant name
      full_const_name = extract_full_const_name(ast)
      @references.add(full_const_name)
    end

    # Recursively process each child node
    ast.children.each do |child|
      process(child)
    end
  end

  private

  def extract_full_const_name(node)
    # Base case: if the parent is nil, return the current node's name
    return node.children.last.to_s if node.children.first.nil?

    # Recursive case: prepend the parent constant name
    parent_name = extract_full_const_name(node.children.first)
    "#{parent_name}::#{node.children.last}"
  end
end
