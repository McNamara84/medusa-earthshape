# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :pml do |object, options|

  self.content_type ||= Mime[:pml]

  # Ensure consistent behavior for collections (especially ActiveRecord::Relation).
  # We always funnel through the serializer, which already handles arrays,
  # relations, and single items.
  Pml::Serializer.call(object, options)
end