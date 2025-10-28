module HasRecursive
  extend ActiveSupport::Concern
  included do
  	# with_recursive # Temporarily disabled - gem not publicly available
  end

  # Fallback implementation when with_recursive gem is not available
  # This provides basic functionality for hierarchical models
  def descendants
    children.flat_map { |child| [child] + child.descendants }
  end
  
  def ancestors
    parent.nil? ? [] : [parent] + parent.ancestors
  end

  def self_and_descendants
  	[self].concat(self.descendants.to_a)
  end
end
