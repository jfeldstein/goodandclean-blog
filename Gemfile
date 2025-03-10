source "https://rubygems.org"

# This is the version of Jekyll being used
gem "jekyll", "~> 4.4.1"

# This is the default theme used by Jekyll (commented out to use custom theme)
# gem "minima", "~> 2.5"

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.12"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]

# Required for newer versions of Ruby
gem "webrick", "~> 1.7"

# Add the sass-embedded gem to handle Sass deprecation warnings
gem "sass-embedded", "~> 1.85.1"

# Gem for downloading images
gem "down", "~> 5.4"

# Gem for parsing HTML
gem "nokogiri", "~> 1.15"
