Gem::Specification.new do |s|
  s.name          = "mq_reader"
  s.version       = "0.0.1"
  s.summary       = "Mapquest api wrapper"
  s.date          = "2013-02-18"
  s.description   = "This is a wrapper for mapquest's geocoding api."
  s.authors       = ["Santiago Piria"]
  s.email         = ["santiago.piria@gmail.com"]
  s.homepage      = "http://rubylearning.org/"
  s.files         = %w[Rakefile mq_reader.gemspec]
  s.files        += Dir.glob('lib/**/*.rb')
  s.files        += Dir.glob('spec/**/*')
  s.require_paths = %w[lib]
  s.test_files    = Dir.glob('spec/**/*')
  s.add_dependency 'httparty', '0.13.1'
  s.license       = 'MIT'
end