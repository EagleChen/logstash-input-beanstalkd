Gem::Specification.new do |s|
  s.name = 'logstash-input-beanstalkd'
  s.version = '0.9.0'
  s.licenses = ['Apache License (2.0)']
  s.summary = "This input will read jobs from a beanstalk tube. It uses beaneater to interact with beanstalkd."
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Eagle Chen"]
  s.email = "chygr1234@gmail.com"
  s.homepage = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 2.0.0", "< 3.0.0"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency "beaneater", ">= 1.0.0", "< 2.0.0"
  s.add_development_dependency 'logstash-devutils', '>= 0.0.16'
end
