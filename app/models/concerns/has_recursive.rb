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
  
  def siblings
    parent.nil? ? self.class.none : parent.children.where.not(id: self.id)
  end
  
  def self_and_siblings
    parent.nil? ? [self] : parent.children
  end
  
  def root
    parent.nil? ? self : parent.root
  end
  
  def families
    # For Stone/Box: Returns analyses of parent + self + siblings + children
    # This provides a "family view" showing the immediate hierarchy context
    family_nodes = []
    family_nodes << parent if parent.present?
    family_nodes += self_and_siblings.to_a
    family_nodes += children.to_a if respond_to?(:children)
    
    # Get all analyses for these nodes
    if respond_to?(:analyses)
      family_nodes.flat_map { |node| node.respond_to?(:analyses) ? node.analyses.to_a : [] }.uniq
    else
      []
    end
  end
end
