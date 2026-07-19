# frozen_string_literal: true

require "mcp"

module SeleniumSpec
  class Server
    def self.build(app: App.new)
      MCP::Server.new(
        name: "selenium_spec",
        version: SeleniumSpec::VERSION,
        tools: Tools::ALL,
        server_context: { app: app }
      )
    end

    def self.run
      transport = MCP::Server::Transports::StdioTransport.new(build)
      transport.open
    end
  end
end
