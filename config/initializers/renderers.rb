# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :pml do |object, options|
	self.content_type ||= Mime[:pml]
	if object.respond_to?(:to_pml) && !object.is_a?(Array) && !(defined?(ActiveRecord::Relation) && object.is_a?(ActiveRecord::Relation))
		object.to_pml
	else
		Pml::Serializer.call(object, options)
	end
end