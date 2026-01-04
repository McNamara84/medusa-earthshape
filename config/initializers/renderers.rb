# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :pml do |object, options|
  self.content_type ||= Mime[:pml]

  # Keep legacy behavior for single objects (e.g. `Analysis#to_pml`), but ensure
  # consistent behavior for collections (especially ActiveRecord::Relation).
  is_collection =
    object.is_a?(Array) ||
      (object.respond_to?(:to_a) && !object.is_a?(String) && !object.is_a?(Hash))

  if !is_collection && object.respond_to?(:to_pml)
    object.to_pml
  else
    Pml::Serializer.call(object, options)
  end
end