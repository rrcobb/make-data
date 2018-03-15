#! /usr/bin/env ruby
require 'optparse'
require 'faker'
require 'json'
require 'csv'
require 'yaml'

class SampleGenerator
  attr_accessor :category
  def initialize(category)
    @category = category
  end

  def self.available_categories
    Faker.constants
  end

  def klass
    Faker.const_get(@category)
  end

  def available_methods
    klass.methods - klass.superclass.methods
  end

  def generate_n_of(count, method_name)
    Array.new(count).map { [method_name.to_sym, klass.send(method_name.to_sym)] }
  end

  def generate_all(count)
    res = generate(count, available_methods)
    res
  end

  def generate(count, column_names)
    first, *rest = column_names.map { |method_name| generate_n_of(count, method_name) }
    first.zip(*rest).map(&:to_h)
  end
end

class ResultsFormatter
  def initialize(results, format)
    @results = results
    @format = format
  end

  def format_results
    send(@format.to_sym)
  end

  def self.valid_formats
    %w(json csv yaml)
  end

  def json
    JSON.generate(@results)
  end

  def csv
    CSV.generate do |csv|
      csv << @results[0].keys # column headers
      @results.map(&:values).each { |row| csv << row }
    end
  end

  def yaml
    @results.to_yaml
  end
end

class CLI
  class InvalidFormatError < StandardError; end
  class InvalidCategoryError < StandardError; end

  def initialize(format: nil, category: nil, count: 100, all: false)
    @all = all
    @format = format
    @category = category
    @count = count
    puts "count: #{count} all: #{all} format: #{format} category: #{category}"
  end

  def run
    get_category unless @category
    @generator = SampleGenerator.new(@category)
    get_keys unless @all # just choose all the keys, then
    get_format unless @format
    @results = run_generator
    print_results
  end

  def print_results
    print ResultsFormatter.new(@results, @format).format_results
  end

  def run_generator
    @all ? @generator.generate_all(@count) : @generator.generate(@count, @keys)
  end

  def get_format
    prompt = "What kind of data do you want to generate?"
    @format = choose_among(prompt, ResultsFormatter.valid_formats)
    unless ResultsFormatter.valid_formats.include?(@format)
      raise InvalidFormatError.new("File needs to be one of #{ResultsFormatter.valid_formats.join(', ')}")
    end
  end

  def puts_in_columns(strings)
    col_count = `tput cols`.chomp.to_i
    col_width = strings.max_by { |s| s.length }.length + 2
    cols = col_count / col_width
    strings.each_slice(cols) do |row|
      row.each { |s| print s.to_s.ljust(col_width) }
      puts
    end
  end

  def choose_among(prompt, strings)
    `echo "#{strings.join("\n")}" | peco --prompt="#{prompt}>"`.chomp
  end

  def get_category
    prompt = "Choose a Category"
    @category = choose_among(prompt, SampleGenerator.available_categories.map(&:to_s))
    raise ArgumentError.new("Invalid Category") unless Faker.const_get(@category)
  end

  def get_keys
    prompt = "What keys? (Ctrl + Space to select, Enter to finish)"
    @keys = choose_among(prompt, @generator.available_methods.map(&:to_s)).split(/\s+/)
  end

  def get_count
    puts "How many records?"
    @count = gets.chomp.to_i
  end
end

options = {}
OptionParser.new do |parser|
  parser.on("-n", "--count [COUNT]", OptionParser::DecimalInteger,
    "How many records to generate") do |count|
      options[:count] = count
  end

  parser.on("-f [FORMAT]", "--format [FORMAT]", ResultsFormatter.valid_formats,
    "Format for the generated records") do |format|
      options[:format] = format
  end

  parser.on("-c [CATEGORY]", "--category [CATEGORY]", SampleGenerator.available_categories,
    "Category for the generated records.") do |category|
      options[:category] = category
  end

  parser.on("-a", "--all", "All the keys for the category") do
    options[:all] = true
  end
end.parse!

CLI.new(options).run if __FILE__ == $0
