# SimpleCov Setup Documentation

This document describes the SimpleCov configuration that has been added to this project for test coverage tracking.

## What was added

### 1. SimpleCov Gem
Added `simplecov` (~> 0.22.0) to the `Gemfile` in the `:development, :test` group.

### 2. SimpleCov Configuration
Modified `spec/spec_helper.rb` to include SimpleCov initialization:

```ruby
require 'simplecov'
require 'simplecov_json_formatter'
SimpleCov.start do
    formatter SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::JSONFormatter,
      SimpleCov::Formatter::HTMLFormatter
    ])
    add_filter '/spec/'
end
```

This configuration:
- Generates both JSON and HTML coverage reports
- Excludes the `/spec/` directory from coverage calculations
- JSON report is saved to `coverage/coverage.json`
- HTML report is saved to `coverage/index.html`

### 3. GitHub Actions Workflow
Created `.github/workflows/main.yml` with:
- Automated test runs on push, pull requests, and daily schedule
- Coverage report generation
- Integration with qlty-action for coverage tracking

### 4. RSpec Configuration
Created `.rspec` file with:
- Automatic spec_helper requirement
- Colored output
- Documentation format

## Usage

### Running tests locally
```bash
bundle install
bundle exec rspec
```

After running tests, coverage reports will be available in:
- `coverage/index.html` - Human-readable HTML report
- `coverage/coverage.json` - Machine-readable JSON report

### Viewing coverage
Open the HTML report in your browser:
```bash
open coverage/index.html
```

## CI/CD Integration

The GitHub Actions workflow automatically:
1. Runs tests on every push and pull request
2. Generates coverage reports
3. Uploads coverage data to Qlty for tracking over time

## Configuration Reference

Based on the qlty-exemple project configuration, this setup follows best practices for:
- Multi-format coverage reporting
- Filtering test files from coverage
- CI/CD integration with coverage tracking

## Further Reading

- [SimpleCov Documentation](https://github.com/simplecov-ruby/simplecov)
- [SimpleCov JSON Formatter](https://github.com/vicentllongo/simplecov-json)