# frozen_string_literal: true

class Autolink < RedmineTrackyApplicationRecord
  belongs_to :project

  validates :prefix, presence: true
  validates :target_url, presence: true
end
