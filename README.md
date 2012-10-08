# Readability to Instapaper

A simple script for exportingj all your bookmarked articles from **readability.com** to **instapaper.com**.

## Usage

Clone the repo, install the bundled gems, run the script, it will prompt for
your credentials.

```bash
bundle install
ruby import.rb
```

## Development state

The script works fine, but is kinda slow (2 HTTP requestes per imported link).
