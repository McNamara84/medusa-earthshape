class ActionController::Parameters
  def only_presence
    # Rails 5.1+: ActionController::Parameters needs to_h to iterate
    # Rails 8.1+: Returns ActionController::Parameters to maintain permit status
    result = to_h.each_with_object({}) do |pair, dst|
      key, value = pair
      value = value.only_presence if value.is_a?(ActionController::Parameters)
      dst[key] = value if value.present?
    end
    # Return permitted ActionController::Parameters instead of plain Hash
    ActionController::Parameters.new(result).permit!
  end
end
