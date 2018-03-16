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

Follow the prompts to select the category, keys, count, and format.

## Options

`-h --help` Shows the help menu

`-c --category [CATEGORY]` choose a category from Faker. (I can never remember these, so I use the interactive mode. Mostly here so that this could be used without interaction, like in a script)

`-f --format [FORMAT]` json, csv, or yaml. What format to generate the data in.

`-k --keys` specify specific keys/columns for the faker category. Again, this is really only here so that interactive mode isn't impossible to disable.

`-n --count` how many records to generate.

`-a --all` use all the keys from that Faker category.

## Note about non-interactive mode

If you want to call `mkdata` non-interactively (like, from a script), then you have to specify all of the options (category, count, format, and either keys or all).

## Examples

Generate 100 rows of random World of Warcraft stuff, save it in `wow.csv`.

```
mkdata --count 100 --format csv --category WorldOfWarcraft --all > wow.csv
```

Generate 1000 json objects with half wind, quarter wind, and ordinal abbreviation from the Compass faker category, save it in directions.json

```
mkdata -n 1000 -f json -c Compass -k half_wind,quarter_wind,ordinal_abbreviation > directions.json
```

Generate 63 quotes from the MostInterestingManInTheWorld, save to quotes.yaml

```
mkdata --category MostInterestingManInTheWorld -n 63 --keys quote -f yaml > quotes.yaml
```
