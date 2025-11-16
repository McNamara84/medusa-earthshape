# ApplicationRecord - Base class for all models in Rails 5+
# Introduced in Rails 5.0 as replacement for direct ActiveRecord::Base inheritance
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
