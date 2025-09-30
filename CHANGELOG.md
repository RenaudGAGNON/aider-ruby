# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-19

### Added
- Initial release of AiderRuby gem
- Complete wrapper for aider command-line tool
- Support for all aider configuration options
- Client class for programmatic usage
- Configuration management with YAML and environment files
- Model information and recommendations
- Task executor for specialized task types (coding, refactoring, debugging, documentation, test generation)
- Command-line interface using Thor
- Comprehensive test suite
- Documentation and examples
- Support for all major LLM providers (OpenAI, Anthropic, Google, GROQ, DeepSeek, xAI, Cohere)
- Reasoning model support
- Vision model support
- Git integration
- Linting and testing automation
- Voice settings
- Analytics configuration
- Multi-step task execution
- Task history tracking
- Export/import functionality for task history

### Features
- **Model Management**: Complete support for all aider-supported models
- **Configuration**: Flexible configuration via YAML files, environment variables, or programmatic API
- **Task Types**: Specialized executors for different types of programming tasks
- **CLI Interface**: Full command-line interface with all aider options
- **Programmatic API**: Clean Ruby API for integration into other applications
- **Error Handling**: Comprehensive error handling and validation
- **Documentation**: Extensive documentation with examples
- **Testing**: Complete test suite with RSpec
- **Linting**: RuboCop integration for code quality
