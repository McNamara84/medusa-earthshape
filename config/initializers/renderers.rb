# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :pml do |object, options|
  self.content_type ||= Mime[:pml]

  # Keep legacy behavior for single objects (e.g. `Analysis#to_pml`), but ensure
  # consistent behavior for collections (especially ActiveRecord::Relation).
  is_relation = defined?(ActiveRecord::Relation) && object.is_a?(ActiveRecord::Relation)
  is_array = object.is_a?(Array)

  if object.respond_to?(:to_pml) && !is_array && !is_relation
    object.to_pml
  else
    Pml::Serializer.call(object, options)
  end
end