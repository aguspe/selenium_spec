# frozen_string_literal: true

require "erb"
require "uri"

module SeleniumSpec
  module Codegen
    class CapybaraRenderer
      TEMPLATE = File.read(File.expand_path("templates/capybara_spec.rb.erb", __dir__))

      def self.render(steps:, description:)
        new(steps, description).render
      end

      def initialize(steps, description)
        @steps = steps
        @description = description
      end

      def render
        ERB.new(TEMPLATE, trim_mode: "-").result(binding)
      end

      private

      def assertions?
        @steps.any? { |s| s.action.to_s.start_with?("assert_") }
      end

      def body_lines
        @steps.flat_map { |step| lines_for(step) }
      end

      def lines_for(step) # rubocop:disable Metrics/CyclomaticComplexity
        case step.action
        when :navigate then ["visit #{relative(step.value).inspect}"]
        when :click then [click_line(step)]
        when :type then [type_line(step)]
        when :select_option then [select_line(step)]
        when :wait_for then [wait_line(step)]
        when :execute_script then [manual_comment(step)]
        when :assert_text then [assert_text_line(step)]
        when :assert_title then ["expect(page).to have_title(#{step.expected.inspect})"]
        when :assert_element then ["expect(page).to have_css(#{css(step.locator).inspect})"]
        when :assert_url then ["expect(page).to have_current_path(Regexp.new(#{step.expected.inspect}), url: true)"]
        else []
        end
      end

      def relative(url)
        uri = URI.parse(url)
        path = uri.path.to_s.empty? ? "/" : uri.path
        uri.query ? "#{path}?#{uri.query}" : path
      end

      def css(locator)
        strategy, value = locator
        case strategy.to_s
        when "css" then value
        when "id" then "##{value}"
        when "name" then "[name='#{value}']"
        else value # rubocop:disable Lint/DuplicateBranch
        end
      end

      def finder(locator)
        strategy, value = locator
        strategy.to_s == "xpath" ? "find(:xpath, #{value.inspect})" : "find(#{css(locator).inspect})"
      end

      def click_line(step) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        el = step.element || {}
        text = el[:text].to_s
        if (el[:tag] == "button" || (el[:tag] == "input" && %w[submit button].include?(el[:type].to_s))) && !text.empty?
          "click_button #{text.inspect}"
        elsif el[:tag] == "a" && !text.empty?
          "click_link #{text.inspect}"
        else
          "#{finder(step.locator)}.click"
        end
      end

      def type_line(step)
        el = step.element || {}
        field = el[:name] || el[:id]
        value = step.masked ? 'ENV.fetch("SELENIUM_SPEC_PASSWORD")' : step.value.inspect
        if field && %w[input textarea].include?(el[:tag])
          "fill_in #{field.inspect}, with: #{value}"
        else
          "#{finder(step.locator)}.set(#{value})"
        end
      end

      def select_line(step)
        el = step.element || {}
        field = el[:name] || el[:id]
        field ? "select #{step.value.inspect}, from: #{field.inspect}" : "#{finder(step.locator)}.select_option"
      end

      def wait_line(step)
        matcher = step.condition == "gone" ? "have_no_css" : "have_css"
        "expect(page).to #{matcher}(#{css(step.locator).inspect})"
      end

      def manual_comment(step)
        snippet = step.js.to_s.lines.first.to_s.strip[0, 60]
        "# MANUAL: review this step — execute_script recorded: #{snippet}"
      end

      def assert_text_line(step)
        if step.scope
          "expect(#{finder(step.scope)}).to have_content(#{step.expected.inspect})"
        else
          "expect(page).to have_content(#{step.expected.inspect})"
        end
      end
    end
  end
end
