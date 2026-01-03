class ActionController::Parameters
  def only_presence
    # Intentionally only operates on already-permitted parameters.
    # Returning a plain Hash avoids accidentally widening permissions via `permit!`.
    raise ActionController::UnfilteredParameters unless permitted?

    to_h.each_with_object({}) do |(key, value), dst|
      dst[key] = value if value.present?
    end
  end
end
