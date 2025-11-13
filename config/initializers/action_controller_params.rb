class ActionController::Parameters
  def only_presence
    # Rails 5.1: ActionController::Parameters needs to_h to iterate
    to_h.each_with_object({}) do |pair, dst|
      key, value = pair
      value = value.only_presence if value.is_a?(ActionController::Parameters)
      dst[key] = value if value.present?
    end
  end
end
