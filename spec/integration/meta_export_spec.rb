# frozen_string_literal: true

require "tmpdir"
require "open3"

RSpec.describe "exported spec runs green", :browser do
  let(:fixture_url) { "file://#{File.expand_path('../fixtures/site/login.html', __dir__)}" }
  let(:app) { SeleniumSpec::App.new }
  let(:ctx) { { app: app } }

  def call(tool, **args)
    tool.call(**args, server_context: ctx)
  end

  it "drives the tools end-to-end, exports, and the generated spec passes" do
    call(SeleniumSpec::Tools::StartBrowser, browser: "chrome", headless: true)
    call(SeleniumSpec::Tools::Navigate, url: fixture_url)
    call(SeleniumSpec::Tools::Type, strategy: "id", value: "email", text: "user@example.com")
    call(SeleniumSpec::Tools::Type, strategy: "id", value: "password", text: "secret123")
    call(SeleniumSpec::Tools::Click, strategy: "id", value: "login-btn")
    call(SeleniumSpec::Tools::WaitFor, strategy: "css", value: ".welcome", condition: "visible", timeout: 5)
    call(SeleniumSpec::Tools::AssertText, text: "Welcome back", scope_strategy: "css", scope_value: ".welcome")
    call(SeleniumSpec::Tools::CloseBrowser)

    Dir.mktmpdir do |dir|
      path = File.join(dir, "login_flow_spec.rb")
      call(SeleniumSpec::Tools::ExportSpec, description: "Login flow", path: path)
      source = File.read(path)
      expect(source).to include('ENV.fetch("SELENIUM_SPEC_PASSWORD")')
      expect(source).not_to include("secret123")

      lint_out, lint_status = Open3.capture2e(
        "bundle", "exec", "rubocop", "--force-default-config", "--only", "Lint,Layout", path
      )
      expect(lint_status).to be_success, "generated code failed rubocop:\n#{lint_out}"

      run_out, run_status = Open3.capture2e(
        { "SELENIUM_SPEC_PASSWORD" => "secret123" },
        "bundle", "exec", "rspec", path
      )
      expect(run_status).to be_success, "generated spec failed:\n#{run_out}"
    end
  end
end
