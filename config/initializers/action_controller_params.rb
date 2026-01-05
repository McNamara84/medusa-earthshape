class ActionController::Parameters
  def only_presence
    raw_hash = permitted? ? to_h : to_unsafe_h

    filtered = deep_only_presence(raw_hash)

    result = ActionController::Parameters.new(filtered)
    permitted? ? result.permit! : result
  end

  private

  def deep_only_presence(value)
    case value
    when ActionController::Parameters
      deep_only_presence(value.permitted? ? value.to_h : value.to_unsafe_h)
    when Hash
      value.each_with_object({}) do |(key, child), dst|
        filtered_child = deep_only_presence(child)
        dst[key] = filtered_child if filtered_child.present?
      end
    when Array
      value.map { |child| deep_only_presence(child) }.select(&:present?)
    else
      value
    end
  end
end
