# frozen_string_literal: true

class Autolink < RedmineTrackyApplicationRecord
  belongs_to :project

  validates :prefix, presence: true, length: { maximum: 20 }
  validates :target_url, presence: true, length: { maximum: 255 },
            format: { with: %r{\Ahttps?://.+<num>.*\z}, message: :no_num }
end
