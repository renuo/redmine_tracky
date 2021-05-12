# Taken from Renuo - Hillary Project
module Filtering
  class BaseFilter
    include ActiveModel::Model
    include ActiveModel::Attributes

    def apply(base_scope)
      filter_chain.reduce(base_scope) { |collection_proxy, filter| filter.apply(collection_proxy) }
    end
  end
end
