# frozen_string_literal: true

require_relative "selenium_spec/version"
require_relative "selenium_spec/errors"
require_relative "selenium_spec/recorder"
require_relative "selenium_spec/browser_session"
require_relative "selenium_spec/app"
require_relative "selenium_spec/codegen/rspec_renderer"
require_relative "selenium_spec/codegen/capybara_renderer"
require_relative "selenium_spec/tools/helpers"
require_relative "selenium_spec/tools/session_tools"
require_relative "selenium_spec/tools/interaction_tools"
require_relative "selenium_spec/tools/snapshot_tool"
require_relative "selenium_spec/tools/assertion_tools"
require_relative "selenium_spec/tools/codegen_tools"
require_relative "selenium_spec/tools"
require_relative "selenium_spec/server"

module SeleniumSpec
end
