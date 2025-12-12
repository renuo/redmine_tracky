class CreateTimerSessionTool < MCP::Tool
  tool_name "create_timer_session"
  description "Book worktime on issues with start and end times"

  input_schema(
    properties: {
      issue_ids: {
        type: "array",
        items: {
          type: "number"
        },
        minContains: 1,
        description: "Collection of issue ids to book time on (distribute equally)"
      },
      description: {
        type: "string",
        description: "Summary of the work which has been done for this issue"
      },
      timer_session_start: {
        type: "string",
        format: "date-time",
        description: "When the work on this issue has been started"
      },
      timer_session_end: {
        type: "string",
        format: "date-time",
        description: "When the work on this issue stopped"
      }
    },
    required: [ "issue_ids", "description", "timer_session_start", "timer_session_end" ]
  )

  output_schema(
    properties: {
      success: {
        type: "boolean",
        description: "True for success"
      }
    }
  )

  class << self
    def call(issue_ids:, description:, timer_session_start:, timer_session_end:)
      session = TimerSession.new(
        timer_start: timer_session_start,
        comments: description,
        user: User.first,
        timer_end: timer_session_end
      )

      if session.save
        session.issues << Issue.find(issue_ids)
        success_response(session)
      else
        error_response("Error creating issue: \n#{session.errors.full_messages.join("\n")}")
      end

    rescue => e
      error_response("Error creating issue: #{e.message}")
    end

    private

    def success_response(session)
      response_text = <<~TEXT
        Success!
      TEXT

      structured_content = {
        success: true,
      }

      MCP::Tool::Response.new([ {
                                  type: "text",
                                  text: response_text.strip
                                } ], structured_content: structured_content)
    end

    def error_response(message)
      puts message
      MCP::Tool::Response.new([ {
                                  type: "text",
                                  text: message
                                } ], error: true)
    end
  end
end
