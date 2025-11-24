require 'spec_helper'
require 'aider_ruby'

RSpec.describe AiderRuby::Constants do
  describe 'constants' do
    it 'defines AIDER_COMMAND' do
      expect(AiderRuby::Constants::AIDER_COMMAND).to eq('aider')
    end

    it 'defines DEFAULT_TEST_CMD' do
      expect(AiderRuby::Constants::DEFAULT_TEST_CMD).to eq('rspec')
    end

    it 'defines DEFAULT_DOC_MODEL' do
      expect(AiderRuby::Constants::DEFAULT_DOC_MODEL).to eq('claude-3-5-sonnet-20241022')
    end

    it 'makes constants frozen' do
      expect(AiderRuby::Constants::AIDER_COMMAND).to be_frozen
      expect(AiderRuby::Constants::DEFAULT_TEST_CMD).to be_frozen
      expect(AiderRuby::Constants::DEFAULT_DOC_MODEL).to be_frozen
    end
  end
end

