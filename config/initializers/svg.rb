# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :svg do |obj, options|
  items =
    if obj.nil?
      []
    elsif obj.is_a?(Array)
      obj
    elsif defined?(ActiveRecord::Relation) && obj.is_a?(ActiveRecord::Relation)
      obj.to_a
    else
      nil
    end

  content =
    if items
      items.map { |item| item.respond_to?(:to_svg) ? item.to_svg : item.to_s }.join("")
    elsif obj.respond_to?(:to_svg)
      obj.to_svg
    elsif obj.respond_to?(:to_a) && !obj.is_a?(String) && !obj.is_a?(Hash)
      obj.to_a.map { |item| item.respond_to?(:to_svg) ? item.to_svg : item.to_s }.join("")
    else
      obj.to_s
    end

  %Q|<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">#{content}</svg>|
end
