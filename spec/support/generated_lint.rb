# frozen_string_literal: true

require "tmpdir"
require "open3"
require "rbconfig"

# Lints generated spec source against the export contract's rubocop config
# (spec/fixtures/generated_rubocop.yml: Lint + Layout, line length off).
#
# rubocop is invoked as `ruby <rubocop-exe>` rather than `bundle exec rubocop`
# so it works regardless of a broken local bundle binstub.
module GeneratedLint
  CONFIG = File.expand_path("../fixtures/generated_rubocop.yml", __dir__)

  def lint_generated_file(path)
    rubocop = Gem.bin_path("rubocop", "rubocop")
    Open3.capture2e(RbConfig.ruby, rubocop, "--config", CONFIG, "--only", "Lint,Layout", path)
  end

  def generated_lint_clean?(source)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "generated_spec.rb")
      File.write(path, source)
      _out, status = lint_generated_file(path)
      status.success?
    end
  end
end
