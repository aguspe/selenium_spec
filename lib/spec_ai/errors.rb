# frozen_string_literal: true

module SpecAI
  class Error < StandardError; end
  class SessionNotStartedError < Error; end
  class SessionDeadError < Error; end

  class ElementNotFoundError < Error
    def initialize(locator, suggestions = [])
      strategy, value = locator
      msg = "Element not found: #{strategy} #{value.inspect}."
      msg += " Did you mean: #{suggestions.join('; ')}" unless suggestions.empty?
      super(msg)
    end
  end

  class OptionNotFoundError < Error
    def initialize(by, chosen, available = [])
      msg = "No option with #{by} #{chosen.inspect} in the select."
      msg += " Available: #{available.map(&:inspect).join(', ')}" unless available.empty?
      super(msg)
    end
  end
end
