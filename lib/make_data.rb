#! /usr/bin/env ruby
require 'faker'
require 'json'
require 'csv'
require 'yaml'

module MakeData
  class FakerFinder
    attr_accessor :category

    def initialize(category)
      @category = category
      raise ArgumentError.new("Invalid Category") unless Faker.const_get(@category)
    end

    def self.available_categories
      Faker.constants - [:Config, :VERSION, :Base, :UniqueGenerator]
    end

    def klass
      Faker.const_get(@category)
    end

    def available_methods
      klass.methods - klass.superclass.methods
    end
  end

  class SampleGenerator
    attr_accessor :shape

    # shape is a mapping from names to [category, method] pairs
    # so, { name => ['FunnyName', 'name'], location => ['GameOfThrones', 'location'] }
    def initialize(shape)
      @shape = shape
    end

    def self.generate(category_name, method_name)
      Faker.const_get(category_name).send(method_name.to_sym)
    end

    def make_one_from_shape
      @shape.transform_values do |category, method|
        self.class.generate(category, method)
      end
    end

    def generate(count)
      Array.new(count).map { make_one_from_shape }
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

    def initialize(format: nil, count: nil, shape: nil, dry: false)
      @dry = dry
      @format = @dry ? :json : format
      @count = count
      @shape = shape
    end

    def run
      @format ||= get_format
      @count ||= get_count unless @dry
      @shape ||= get_shape
      @results = @dry ? @shape : SampleGenerator.new(@shape).generate(@count)
      print_results
    end

    def print_results
      print ResultsFormatter.new(@results, @format).format_results
    end

    def get_format
      prompt = "What kind of data do you want to generate?"
      format = choose_among(prompt, ResultsFormatter.valid_formats)
      unless ResultsFormatter.valid_formats.include?(format)
        raise InvalidFormatError.new("File needs to be one of #{ResultsFormatter.valid_formats.join(', ')}")
      end
      format
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
      prompt = "What faker category?"
      choose_among(prompt, FakerFinder.available_categories.map(&:to_s))
    end

    def get_method(category)
      prompt = "What method?"
      choose_among(prompt, FakerFinder.new(category).available_methods.map(&:to_s))
    end

    def get_shape(shape = {})
      action = choose_among("What do you want to do?", ["Add a key", "Done"])
      case action
      when "Done"
        return shape
      when "Add a key"
        updated = add_key(shape)
        get_shape(updated)
      end
    end

    def get_key
      puts "What key do you want to add?"
      gets.chomp
    end

    def add_key(shape)
      key = get_key
      cat = get_category
      method = get_method(cat)
      shape[key] = [cat, method]
      shape
    end

    def get_count
      puts "How many records?"
      gets.chomp.to_i
    end
  end
end
