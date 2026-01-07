require "set"

class ActionController::Parameters
  def only_presence
    raw_hash = permitted? ? to_h : to_unsafe_h

    filtered = deep_only_presence(raw_hash)

    result = ActionController::Parameters.new(filtered)
    permitted? ? result.permit! : result
  end

  private

  # Note: Rails params shouldn't contain circular structures, but if they do
  # (e.g. manually constructed input), this avoids infinite recursion.
  def deep_only_presence(value, seen = nil)
    if value.is_a?(ActionController::Parameters) || value.is_a?(Hash) || value.is_a?(Array)
      seen ||= Set.new
      object_id = value.object_id
      return nil if seen.include?(object_id)
      seen.add(object_id)
    end

    case value
    when ActionController::Parameters
      deep_only_presence(value.permitted? ? value.to_h : value.to_unsafe_h, seen)
    when Hash
      value.each_with_object({}) do |(key, child), dst|
        filtered_child = deep_only_presence(child, seen)
        dst[key] = filtered_child if filtered_child.present?
      end
    when Array
      value.map { |child| deep_only_presence(child, seen) }.select(&:present?)
    else
      value
    end
  ensure
    seen&.delete(object_id) if defined?(object_id) && seen
  end
end
