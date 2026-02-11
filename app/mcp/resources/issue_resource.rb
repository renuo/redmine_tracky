class IssueResource
  URI = "rails://issues"

  def self.resource
    MCP::Resource.new(
      uri: URI,
      name: "Issues",
      description: "List of all issues available to user",
      mime_type: "text/plain"
    )
  end

  def self.read(_uri)
    stats_text = generate_issue_list

    [
      MCP::Resource::TextContents.new(
        uri: URI,
        text: stats_text,
        mime_type: "text/plain"
      )
    ]
  end

  private

  def self.generate_issue_list
    <<~STATS
      # Issue liste

      ## Issues
      #{Issue.pluck(:id, :subject ).map { |id, subject| "- #{id}: #{subject}" }.join("\n") }
    STATS
  end

end
