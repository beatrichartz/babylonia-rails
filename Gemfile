source "http://rubygems.org"

gemspec

group :development do
  gem "yard",       ">= 0.7.4"
  gem "bundler",    ">= 1.0.0"
  if ENV['RUBY_VERSION'] =~ /jruby/
    gem 'activerecord-jdbcmysql-adapter'
  else
    gem "mysql2"
  end
end

group :test do
  gem "rspec"
end
