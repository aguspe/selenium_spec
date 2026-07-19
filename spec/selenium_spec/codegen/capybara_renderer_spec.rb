# frozen_string_literal: true

RSpec.describe SeleniumSpec::Codegen::CapybaraRenderer do
  def login_steps
    r = SeleniumSpec::Recorder.new
    r.record(action: :start_browser, value: "chrome", headless: true)
    r.record(action: :navigate, value: "https://example.com/login")
    r.record(action: :type, locator: %w[id email], value: "user@example.com",
             element: { tag: "input", text: "", id: "email", name: "email", type: "text" })
    r.record(action: :type, locator: %w[id password], masked: true,
             element: { tag: "input", text: "", id: "password", name: "password", type: "password" })
    r.record(action: :click, locator: %w[id login-btn],
             element: { tag: "button", text: "Log in", id: "login-btn", name: nil, type: "submit" })
    r.record(action: :wait_for, locator: ["css", ".welcome"], condition: "visible", timeout: 10)
    r.record(action: :assert_text, expected: "Welcome back", scope: ["css", ".welcome"])
    r.record(action: :close_browser)
    r.steps
  end

  it "renders the login flow exactly as the golden file" do
    golden = File.read("spec/fixtures/golden/login_flow_capybara.rb")
    expect(described_class.render(steps: login_steps, description: "Login flow")).to eq(golden)
  end

  it "falls back to find(css).click when the element has no button/link identity" do
    steps = [SeleniumSpec::Step.new(action: :click, locator: ["css", ".card"],
                                    element: { tag: "div", text: "Open", id: nil, name: nil, type: nil }),
             SeleniumSpec::Step.new(action: :assert_title, expected: "x")]
    out = described_class.render(steps: steps, description: "d")
    expect(out).to include('find(".card").click')
  end

  it "maps remaining actions to idiomatic Capybara" do # rubocop:disable RSpec/MultipleExpectations
    steps = [
      SeleniumSpec::Step.new(action: :click, locator: %w[link_text Pricing],
                             element: { tag: "a", text: "Pricing", id: nil, name: nil, type: nil }),
      SeleniumSpec::Step.new(action: :select_option, locator: %w[id country], value: "Denmark", select_by: :text,
                             element: { tag: "select", text: "", id: "country", name: "country", type: nil }),
      SeleniumSpec::Step.new(action: :wait_for, locator: ["css", ".spinner"], condition: "gone", timeout: 10),
      SeleniumSpec::Step.new(action: :assert_element, locator: %w[id cart], condition: "present"),
      SeleniumSpec::Step.new(action: :assert_url, expected: "checkout"),
      SeleniumSpec::Step.new(action: :assert_text, expected: "Done")
    ]
    out = described_class.render(steps: steps, description: "d")
    expect(out).to include('click_link "Pricing"')
    expect(out).to include('select "Denmark", from: "country"')
    expect(out).to include('expect(page).to have_no_css(".spinner")')
    expect(out).to include('expect(page).to have_css("#cart")')
    expect(out).to include('expect(page).to have_current_path(Regexp.new("checkout"), url: true)')
    expect(out).to include('expect(page).to have_content("Done")')
  end
end
