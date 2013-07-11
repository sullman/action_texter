require File.expand_path('../lib/action_texter/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Schuyler Ullman"]
  gem.email         = ["schuyler.ullman@gmail.com"]
  gem.description   = %q{ActionMailer inspired module for sending text messages.}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/sullman/action_texter"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "action_texter"
  gem.require_paths = ["lib"]
  gem.version       = ActionTexter::VERSION::STRING

  gem.add_dependency 'actionpack', '~> 3.2.13'
  gem.add_dependency 'twilio-ruby'
end
