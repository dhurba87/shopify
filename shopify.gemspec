$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "shopify/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "shopify"
  s.version     = Shopify::VERSION
  s.authors     = ["Dhurba Baral"]
  s.email       = ["dhurba87@gmail.com"]
  s.homepage    = "https://github.com/dhurba87/shopify"
  s.summary     = "Shopify reports which are not available through API"
  s.description = "Shopify reports which are not available through API"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_development_dependency "sqlite3"
end