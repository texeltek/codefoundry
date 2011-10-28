# Edit this Gemfile to bundle your application's dependencies.
source 'http://rubygems.org'

gem "rails", "~> 3.0"

## Bundle edge rails:
# gem "rails", :git => "git://github.com/rails/rails.git"

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
gem "sqlite3-ruby", :require => "sqlite3" # development
# eventually use mysql or mysqlplus for production

## Bundle the gems you use:
# gem "bj"
# gem "hpricot", "0.6"
# gem "sqlite3-ruby", :require => "sqlite3"
# gem "aws-s3", :require => "aws/s3"

# repository access gems
gem 'grit', '~> 2.3' # git
# gem 'amp' # mercurial

# git http server in rack
gem 'grack', :git => 'git://github.com/rdblue/grack.git', :require => 'git_http'

# x509 certs made with the power of ruby!
gem 'certificate_authority', :git => 'https://github.com/cchandler/certificate_authority'

# background processing framework
gem 'delayed_job'

# search and indexing gems
# gem 'ferret'
# gem 'acts_as_ferret'

# text formatting
gem 'marker'

# authentication
gem 'authlogic'

# pagination
gem 'will_paginate', '>= 3.0'

# image processing
gem 'paperclip'

# syntax highlighting
gem 'coderay'

## Bundle gems used only in certain environments:
# gem "rspec", :group => :test
# group :test do
#   gem "webrat"
# end

# settings yml
gem 'settingslogic'

# use jQuery instead of prototype
gem 'jquery-rails'

# use capistrano for deployment
gem 'capistrano'

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails', '~> 1.2'

  # test model relationships
  gem 'shoulda-matchers'
end
