Gem::Specification.new do |s|
  s.name        = 'make-data'
  s.version     = '0.0.2'
  s.date        = '2018-03-15'
  s.summary     = "Generate fake data interactively!"
  s.description = <<-DESCRIPTION
  # MakeData
  A CLI for generating fake json, csv, or yaml data.

  Uses Faker to produce fake data in whatever category you choose.

  ## Quick Start
  Requires `peco`, so `brew install peco` (or however you get packages)

  ```
  mkdata
  ```

  Follow the prompts to select the category, keys, count, and format.

  ## Options

  `-h --help` Shows the help menu

  `-c --category [CATEGORY]` choose a category from Faker. (I can never remember these, so I use the interactive mode. Mostly here so that this could be used without interaction, like in a script)

  `-f --format [FORMAT]` json, csv, or yaml. What format to generate the data in.

  `-a --all` use all the keys from that Faker category.

  DESCRIPTION
  s.authors     = ["Rob Cobb"]
  s.email       = 'rwcobbjr@gmail.com'
  s.files       = ["lib/make_data.rb", "lib/runner.rb"]
  s.executables << 'mkdata'
  s.homepage    =
  'http://rubygems.org/gems/make_data'
  s.license       = 'MIT'
end
