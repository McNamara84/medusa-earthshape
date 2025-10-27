module HasRecursive
  extend ActiveSupport::Concern
  included do
  	# with_recursive # Temporarily disabled - gem not publicly available
  end

  def self_and_descendants
  	[self].concat(self.descendants.to_a)
  end
end
