# frozen_string_literal: true

class Autolink < RedmineTrackyApplicationRecord
  belongs_to :project

  validates :prefix, presence: true, length: { maximum: 20 }
  validates :target_url, presence: true, length: { maximum: 255 }
end
