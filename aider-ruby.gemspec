Gem::Specification.new do |spec|
  spec.name          = 'aider-ruby'
  spec.version       = '0.1.0'
  spec.summary       = 'Ruby wrapper for aider - AI pair programming tool'
  spec.description   = 'A Ruby gem that provides a wrapper for aider, enabling configuration of LLMs and execution of tasks through command line interface'
  spec.authors       = ['Renaud Gagnon']
  spec.email         = ['renaud.gagnon@example.com']
  spec.homepage      = 'https://github.com/renaudgagnon/aider-ruby'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*', 'bin/*', 'README.md', 'LICENSE']
  spec.executables   = ['aider-ruby']
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'open3', '~> 0.1'
  spec.add_dependency 'thor', '~> 1.0'
  spec.add_dependency 'yaml', '~> 0.1'

  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
end
