# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: '.ruby-version'

gem 'rails', '~> 7.1.3' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'

gem 'bootsnap', '>= 1.4.2', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'dotenv', '~> 3.1'
gem 'image_processing', '~> 1.12' # Use Active Storage variants
gem 'jbuilder', github: 'excid3/jbuilder', branch: 'partial-paths' # "~> 2.11" # Build JSON APIs with ease
gem 'k8s-ruby', '~> 0.16.0'
gem 'kubeclient', '~> 4.11'
gem 'light-service', '~> 0.18.0' # business logic framework
gem 'nokogiri', '>= 1.12.5' # Security update
gem 'octokit', '~> 9.1' # github API client
gem 'omniauth-digitalocean', '~> 0.3.2' # DigitalOcean OAuth2 strategy for OmniAuth
gem 'pg' # Use postgresql as the database for Active Record
gem 'puma', '~> 6.0' # Use the Puma web server
gem 'redis', '~> 5.1' # Use Redis adapter to run Action Cable in production
gem 'sprockets-rails', '>= 3.4.1' # The original asset pipeline for Rails
gem 'stimulus-rails', '~> 1.0', '>= 1.0.2' # Hotwire's modest JavaScript framework
gem 'turbo-rails', '~> 2.0.3' # Hotwire's SPA-like page accelerator
gem 'tzinfo-data', platforms: %i[windows jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

group :development, :test do
  # debug gems
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'pry', '~> 0.14.2'

  # Lint code for consistent style
  gem 'erb_lint', require: false
  gem 'standard', require: false

  gem 'brakeman', require: false # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'letter_opener_web', '~> 3.0' # Preview mail in the browser instead of sending

  # Optional debugging tools
  # gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  # gem "pry-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'annotate', '~> 3.2' # Annotate models and tests with database columns
  gem 'web-console', '>= 4.1.0'

  gem 'overcommit', require: false # A fully configurable and extendable Git hook manager

  # Add speed badges
  # gem "rack-mini-profiler", ">= 2.3.3"

  # Speed up commands on slow machines / big apps
  # gem "spring"
end

group :test do
  # Use system testing
  gem 'capybara', '>= 3.39'
  gem 'selenium-webdriver', '>= 4.20.1'
  gem 'webmock'
end

# Jumpstart Pro dependencies
require_relative 'lib/jumpstart/lib/jumpstart/yaml_serializer'
require_relative 'lib/jumpstart/lib/jumpstart/configuration'
eval_gemfile 'Gemfile.jumpstart'

# We recommend using strong migrations when your app is in production
# gem "strong_migrations"
