# frozen_string_literal: true

class Autolink < RedmineTrackyApplicationRecord
  PREFIX = /([A-Z_]+-)(\d+)/.freeze

  belongs_to :project

  validates :prefix, presence: true, length: { maximum: 20 },
            format: { with: /\A[A-Z_]+-\z/ }
  validates :target_url, presence: true, length: { maximum: 255 },
            format: { with: %r{\Ahttps?://.+<num>.*\z}, message: :no_num }
  
  def target_url_with(num)
    target_url.sub('<num>', num)
  end

  def self.reference(text, project_id)
    ref = text.match(PREFIX)
    return text if ref.nil?
    
    autolink = find_by(prefix: ref[1], project_id: project_id)
    return text if autolink.nil?
  
    text.sub(PREFIX, autolink.target_url_with(ref[2]))
  end
end
