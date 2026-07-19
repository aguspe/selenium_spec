# frozen_string_literal: true

module SeleniumSpec
  module Tools
    ALL = [
      StartBrowser, Navigate, Snapshot, FindElement, Click, Type, SelectOption,
      Screenshot, ExecuteScript, WaitFor, CloseBrowser,
      AssertText, AssertTitle, AssertElement, AssertUrl,
      ExportSpec, ResetRecording
    ].freeze
  end
end
