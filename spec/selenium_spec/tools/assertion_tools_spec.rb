# frozen_string_literal: true

RSpec.describe "assertion tools" do
  let(:session) { FakeSession.new }
  let(:app) { SeleniumSpec::App.new(session: session, recorder: SeleniumSpec::Recorder.new) }
  let(:ctx) { { app: app } }

  before { session.alive = true }

  def response_text(response)
    response.content.first[:text]
  end

  it "assert_text passes against page text and records with nil scope" do
    allow(session).to receive(:execute_script).and_return("Welcome back, user")
    res = SeleniumSpec::Tools::AssertText.call(text: "Welcome back", server_context: ctx)
    expect(response_text(res)).to include("Assertion passed")
    step = app.recorder.steps.last
    expect(step.action).to eq(:assert_text)
    expect(step.expected).to eq("Welcome back")
    expect(step.scope).to be_nil
  end

  it "assert_text fails cleanly and records nothing" do
    allow(session).to receive(:execute_script).and_return("Nope")
    res = SeleniumSpec::Tools::AssertText.call(text: "Welcome back", server_context: ctx)
    expect(response_text(res)).to start_with("ERROR: Assertion failed")
    expect(app.recorder).to be_empty
  end

  it "assert_text with scope checks the scoped element" do
    # rubocop:disable RSpec/VerifiedDoubles
    element = double("el", text: "Welcome back")
    # rubocop:enable RSpec/VerifiedDoubles
    allow(session).to receive(:find).with(["css", ".welcome"]).and_return(element)
    SeleniumSpec::Tools::AssertText.call(text: "Welcome back", scope_strategy: "css",
                                         scope_value: ".welcome", server_context: ctx)
    expect(app.recorder.steps.last.scope).to eq(["css", ".welcome"])
  end

  it "assert_title compares exactly" do
    res = SeleniumSpec::Tools::AssertTitle.call(expected: "Example Login", server_context: ctx)
    expect(response_text(res)).to include("Assertion passed")
    res2 = SeleniumSpec::Tools::AssertTitle.call(expected: "Wrong", server_context: ctx)
    expect(response_text(res2)).to include('actual: "Example Login"')
  end

  it "assert_element records state under condition" do
    SeleniumSpec::Tools::AssertElement.call(strategy: "css", value: ".welcome", state: "visible",
                                            server_context: ctx)
    step = app.recorder.steps.last
    expect(step.action).to eq(:assert_element)
    expect(step.condition).to eq("visible")
  end

  it "assert_url matches pattern against current url" do
    res = SeleniumSpec::Tools::AssertUrl.call(pattern: "example\\.com/log", server_context: ctx)
    expect(response_text(res)).to include("Assertion passed")
    step = app.recorder.steps.last
    expect(step.expected).to eq("example\\.com/log")
  end

  it "assert_url rejects an invalid regexp" do
    res = SeleniumSpec::Tools::AssertUrl.call(pattern: "([", server_context: ctx)
    expect(response_text(res)).to start_with("ERROR: Invalid pattern")
    expect(app.recorder).to be_empty
  end
end
