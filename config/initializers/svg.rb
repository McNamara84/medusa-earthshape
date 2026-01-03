# Rails 6.0: Renderer block must accept options parameter even if unused
ActionController::Renderers.add :svg do |obj, options|
  content =
    if obj.respond_to?(:to_svg)
      obj.to_svg
    elsif obj.respond_to?(:to_a)
      obj.to_a.map { |item| item.respond_to?(:to_svg) ? item.to_svg : item.to_s }.join("")
    else
      obj.to_s
    end

  %Q|<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">#{content}</svg>|
end
