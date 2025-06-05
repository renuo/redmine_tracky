# frozen_string_literal: true

Issue.prepend(Module.new do
  def description
    Autolink.reference(super, project_id)
  end
end)
