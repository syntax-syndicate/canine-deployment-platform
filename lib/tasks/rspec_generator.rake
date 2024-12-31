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
    name = name.to_s.split('::').join('/')

    Rails.autoloaders.main.dirs.each do |dir|
      path = File.join(dir, "#{name}.rb")
      return Pathname.new(path) if File.exist?(path)
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
    references = parse_ruby_file(file_path)

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

    if @visited_files.include?(file_path)
      return
    end

    @visited_files.add(file_path)
    compile_file(file_path, depth)
  end

  def write_spec_file(spec_content, original_path)
    # Convert app/models/user.rb to spec/models/user_spec.rb
    spec_path = original_path.sub(/^app/, 'spec').sub(/\.rb$/, '_spec.rb')
    full_path = Rails.root.join(spec_path)
    
    # Ensure directory exists
    FileUtils.mkdir_p(File.dirname(full_path))
    
    # Don't overwrite existing specs unless configured to do so
    if File.exist?(full_path) && !@config['overwrite_existing_specs']
      puts "Skipping existing spec: #{spec_path}"
      return
    end

    File.write(full_path, spec_content)
    puts "Generated spec: #{spec_path}"
  end

  def generate_specs(code_blocks)
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

    # TODO: Replace with actual LLM API call
    response = call_llm_api(prompt)

    # Produce the parsed response
    return extract_ruby_code(response)
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
    debugger
  end
end

class ReferenceCollector < Parser::AST::Processor
  attr_reader :references

  def initialize
    @references = Set.new
    super
  end

  def on_const(node)
    const_name = node.children[1]
    @references.add(const_name.to_s) if const_name.is_a?(Symbol)
    super
  end

  def on_send(node)
    receiver, method_name, *args = *node
    
    case method_name
    when :require, :require_relative
      if args.first.is_a?(Parser::AST::Node) && args.first.type == :str
        @references.add(args.first.children.first)
      end
    when :belongs_to, :has_many, :has_one, :has_and_belongs_to_many
      if args.first.is_a?(Parser::AST::Node) && args.first.type == :sym
        @references.add(args.first.children.first.to_s.classify)
      end
    when :include, :extend
      if args.first.is_a?(Parser::AST::Node) && args.first.type == :const
        @references.add(args.first.children[1].to_s)
      end
    end

    super
  end

  def on_class(node)
    _name, superclass, _body = *node
    process(superclass) if superclass
    super
  end

  def on_module(node)
    super
  end
end
