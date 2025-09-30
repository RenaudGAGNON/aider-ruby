module AiderRuby
  class Models
    # Supported model providers
    PROVIDERS = {
      openai: %w[
        gpt-4o gpt-4o-mini gpt-4-turbo gpt-4 gpt-3.5-turbo
        o1-preview o1-mini
      ],
      anthropic: %w[
        claude-3-5-sonnet-20241022 claude-3-5-haiku-20241022
        claude-3-opus-20240229 claude-3-sonnet-20240229 claude-3-haiku-20240307
      ],
      google: %w[
        gemini-1.5-pro gemini-1.5-flash gemini-pro
      ],
      groq: %w[
        llama-3.1-70b-versatile llama-3.1-8b-instant
        mixtral-8x7b-32768 gemma-7b-it
      ],
      deepseek: %w[
        deepseek-chat deepseek-coder
      ],
      xai: %w[
        grok-beta
      ],
      cohere: %w[
        command-r-plus command-r command-light
      ]
    }.freeze

    class << self
      def list_providers
        PROVIDERS.keys
      end

      def list_models(provider = nil)
        if provider
          PROVIDERS[provider.to_sym] || []
        else
          PROVIDERS.values.flatten
        end
      end

      def supported_model?(model_name)
        PROVIDERS.values.flatten.include?(model_name)
      end

      def provider_for_model(model_name)
        PROVIDERS.find { |_provider, models| models.include?(model_name) }&.first
      end

      def reasoning_models
        %w[o1-preview o1-mini]
      end

      def is_reasoning_model?(model_name)
        reasoning_models.include?(model_name)
      end

      def vision_models
        %w[
          gpt-4o gpt-4o-mini gpt-4-turbo
          claude-3-5-sonnet-20241022 claude-3-opus-20240229
          gemini-1.5-pro gemini-1.5-flash
        ]
      end

      def has_vision?(model_name)
        vision_models.include?(model_name)
      end

      def recommended_models
        {
          best_overall: 'claude-3-5-sonnet-20241022',
          fastest: 'claude-3-5-haiku-20241022',
          cheapest: 'gpt-4o-mini',
          reasoning: 'o1-preview',
          coding: 'deepseek-chat',
          vision: 'gpt-4o'
        }
      end

      def model_info(model_name)
        provider = provider_for_model(model_name)
        return nil unless provider

        {
          name: model_name,
          provider: provider,
          reasoning: is_reasoning_model?(model_name),
          vision: has_vision?(model_name),
          context_window: context_window_for_model(model_name),
          cost_per_token: cost_per_token_for_model(model_name)
        }
      end

      private

      def context_window_for_model(model_name)
        # Approximate context windows (in tokens)
        case model_name
        when /gpt-4o/
          128_000
        when /gpt-4-turbo/
          128_000
        when /gpt-4/
          8_192
        when /gpt-3.5-turbo/
          4_096
        when /o1/
          200_000
        when /claude-3-5-sonnet/
          200_000
        when /claude-3-5-haiku/
          200_000
        when /claude-3-opus/
          200_000
        when /claude-3-sonnet/
          200_000
        when /claude-3-haiku/
          200_000
        when /gemini-1.5/
          1_000_000
        when /gemini-pro/
          32_768
        when /llama-3.1-70b/
          128_000
        when /llama-3.1-8b/
          128_000
        when /mixtral/
          32_768
        when /deepseek/
          64_000
        when /grok/
          128_000
        when /command-r-plus/
          128_000
        when /command-r/
          128_000
        when /command-light/
          100_000
        else
          4_096
        end
      end

      def cost_per_token_for_model(model_name)
        # Approximate costs per 1M tokens (input/output average)
        case model_name
        when /gpt-4o/
          { input: 5.0, output: 15.0 }
        when /gpt-4o-mini/
          { input: 0.15, output: 0.6 }
        when /gpt-4-turbo/
          { input: 10.0, output: 30.0 }
        when /gpt-4/
          { input: 30.0, output: 60.0 }
        when /gpt-3.5-turbo/
          { input: 0.5, output: 1.5 }
        when /o1-preview/
          { input: 15.0, output: 60.0 }
        when /o1-mini/
          { input: 3.0, output: 12.0 }
        when /claude-3-5-sonnet/
          { input: 3.0, output: 15.0 }
        when /claude-3-5-haiku/
          { input: 0.8, output: 4.0 }
        when /claude-3-opus/
          { input: 15.0, output: 75.0 }
        when /claude-3-sonnet/
          { input: 3.0, output: 15.0 }
        when /claude-3-haiku/
          { input: 0.25, output: 1.25 }
        when /gemini-1.5-pro/
          { input: 1.25, output: 5.0 }
        when /gemini-1.5-flash/
          { input: 0.075, output: 0.3 }
        when /gemini-pro/
          { input: 0.5, output: 1.5 }
        when /llama-3.1-70b/
          { input: 0.59, output: 0.79 }
        when /llama-3.1-8b/
          { input: 0.05, output: 0.05 }
        when /mixtral/
          { input: 0.27, output: 0.27 }
        when /deepseek-chat/
          { input: 0.14, output: 0.28 }
        when /deepseek-coder/
          { input: 0.14, output: 0.28 }
        when /grok/
          { input: 0.01, output: 0.01 }
        when /command-r-plus/
          { input: 3.0, output: 15.0 }
        when /command-r/
          { input: 0.5, output: 1.5 }
        when /command-light/
          { input: 0.3, output: 0.3 }
        else
          { input: 1.0, output: 2.0 }
        end
      end
    end
  end
end
