# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :svg do |obj, options|
  content = if obj.nil?
    ""
  elsif obj.respond_to?(:to_svg)
    obj.to_svg
  else
    items =
      if obj.is_a?(Array)
        obj
      elsif defined?(ActiveRecord::Relation) && obj.is_a?(ActiveRecord::Relation)
        obj.to_a
      elsif obj.respond_to?(:to_a) && !obj.is_a?(String) && !obj.is_a?(Hash)
        obj.to_a
      else
        [obj]
      end

    # Empty collections intentionally render an empty SVG (no placeholder).
    items.map { |item| item.respond_to?(:to_svg) ? item.to_svg : item.to_s }.join("")
  end

  %Q|<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">#{content}</svg>|
end
