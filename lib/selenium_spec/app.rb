# frozen_string_literal: true

module SeleniumSpec
  class App
    attr_reader :session, :recorder

    def initialize(session: BrowserSession.new, recorder: Recorder.new)
      @session = session
      @recorder = recorder
    end
  end
end
