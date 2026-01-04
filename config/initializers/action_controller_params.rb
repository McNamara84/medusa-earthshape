class ActionController::Parameters
  def only_presence
    raw_hash = permitted? ? to_h : to_unsafe_h

    filtered = raw_hash.each_with_object({}) do |(key, value), dst|
      dst[key] = value if value.present?
    end

    result = ActionController::Parameters.new(filtered)
    permitted? ? result.permit! : result
  end
end
