# MakeData

A CLI for generating fake json, csv, or yaml data.

Uses Faker to produce fake data in whatever category you choose.

## Quick Start

Requires `peco`, so `brew install peco` (or however you get packages)

Read more https://github.com/peco/peco

```
gem install make-data
mkdata
```

Follow the prompts to create a shape of data to generate, an output format, and the number of records to generate.

## Options

`-h --help` Shows the help menu

`-d --dry --dry-run` create a shape without generating any records

`-f --format [FORMAT]` json, csv, or yaml. What format to generate the data in.

`-n --count` how many records to generate.

`-s [FILENAME] --shape [FILENAME]` File path to a json specification for the shape of records to generate.

## Note about non-interactive mode

If you want to call `mkdata` non-interactively (like, from a script), then you have to specify all of the options (count, format, and shape).
