# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in ykutils.gemspec
gemspec

gem "erubi"
gem "filex"
gem "tilt"
gem "rake", "~> 13.0"

group :development, optional: true do
  gem "yard"
end

group :test, optional: true do
  gem "rspec", "~> 3.0"

  gem "rubocop", "~> 1.21"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end
