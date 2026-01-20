# frozen_string_literal: true

require "json"

class McpController < ApplicationController
  skip_before_action :verify_authenticity_token

  # TODO: no auth here!!!!!!
  # before_action :authenticate_with_bearer_token

  def handle
    transport_response = mcp_transport.handle_request(request)
    status, headers, body = transport_response

    headers.each { |key, value| response.headers[key] = value }

    if body.respond_to?(:call)
      # SSE streaming response
      response.headers["Content-Type"] = "text/event-stream"
      response.headers["Cache-Control"] = "no-cache"
      response.headers["Connection"] = "keep-alive"

      self.response_body = body
    else
      # Handle array of JSON strings (parse first element) or direct JSON object
      response_body = if body.is_a?(Array) && body.first.is_a?(String)
                        JSON.parse(body.first)
                      elsif body.is_a?(Array) && body.first.is_a?(Hash)
                        body.first
                      else
                        body
                      end

      render json: response_body, status: status
    end
  end

  private

  def mcp_transport
    @@mcp_transport ||= begin
                          Dir[Rails.root.join("plugins/redmine_tracky/app/mcp/**/*.rb")].each { |f| require f }

                          resource_classes = [IssueResource ]

                          server = MCP::Server.new(
                            name: "rails-demo-server",
                            tools: [ CreateTimerSessionTool ],
                            resources: [IssueResource.resource ],
                            prompts: []
                          )

                          server.resources_read_handler do |request|
                            uri = request[:uri]
                            resource_class = resource_classes.find { |klass| klass::URI == uri || klass.matches?(uri) }
                            resource_class ? resource_class.read(uri) : []
                          end

                          MCP::Server::Transports::StreamableHTTPTransport.new(server)
                        end
  end
end
