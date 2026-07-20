# frozen_string_literal: true

module SpecAI
  module Tools
    class StartBrowser < MCP::Tool
      extend Helpers

      tool_name "start_browser"
      description "Start a browser session. All subsequent actions are recorded for spec export."
      input_schema(
        properties: {
          browser: { type: "string", enum: %w[chrome firefox edge safari], default: "chrome" },
          headless: { type: "boolean", default: true }
        },
        required: []
      )

      class << self
        def call(server_context:, browser: "chrome", headless: true)
          guarded(server_context) do |app|
            restarted = app.recorder.steps.any? { |s| s.action == :start_browser }
            app.session.start(browser: browser, headless: headless)
            app.recorder.record(action: :start_browser, value: browser, headless: headless)
            message = "Started #{browser} (headless: #{headless}). Recording actions for spec export."
            if restarted
              message += " Note: the previous recording is still active and both sessions will export " \
                         "into one spec - call reset_recording for a fresh spec, or export_spec first next time."
            end
            text(message)
          end
        end
      end
    end

    class Navigate < MCP::Tool
      extend Helpers

      tool_name "navigate"
      description "Navigate the browser to a URL."
      input_schema(properties: { url: { type: "string" } }, required: ["url"])

      class << self
        def call(url:, server_context:)
          guarded(server_context) do |app|
            app.session.navigate(url)
            app.recorder.record(action: :navigate, value: url)
            text("Now at: #{app.session.title} (#{app.session.current_url})")
          end
        end
      end
    end

    class CloseBrowser < MCP::Tool
      extend Helpers

      tool_name "close_browser"
      description "Close the browser. The recording is preserved for export_spec."
      input_schema(properties: {}, required: [])

      class << self
        def call(server_context:)
          guarded(server_context) do |app|
            was_active = app.session.alive?
            app.session.quit
            # Only record a close for a session that was actually open, so a stray
            # close_browser does not leave recorder.empty? falsely false.
            app.recorder.record(action: :close_browser) if was_active
            text("Browser closed. Recording preserved - call export_spec to generate your spec.")
          end
        end
      end
    end
  end
end
