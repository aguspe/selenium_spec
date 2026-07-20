# Changelog

## 0.1.0 - 2026-07-20

Hardening from first real-world sessions:

- Generated waits poll through async DOM insertion and navigation (NoSuchElementError + StaleElementReferenceError ignored); every assertion exports as wait-then-expect.
- Capybara export: select-by-value, DOM-presence semantics for "present"/"gone", append-typing fidelity, link_text finders, query + fragment preserved in paths.
- Snapshot never echoes typed password values; "Did you mean" suggestions dropped after navigation; dead-session restarts quit the old driver; export failures return tool errors.
- Recorded steps are frozen; restarting the browser mid-recording warns about mixed-session exports.

- Initial release: 17-tool MCP server driving selenium-webdriver.
- Session recording (IR) with password masking.
- Spec export: plain RSpec + selenium-webdriver, or Capybara Rails system spec.
- Snapshot tool with locator suggestions; live-checked assertion tools.
