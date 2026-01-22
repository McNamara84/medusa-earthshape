class Ability
  include CanCan::Ability

  # List of model classes that use HasRecordProperty for permission checking
  PERMISSION_MODELS = [AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Stone, Collection, Preparation].freeze

  def initialize(user)
    alias_action :family, :picture, :map, :download_label, :download_card, :download, to: :read

    if user.admin?
      can :manage, :all
    end
    
    can :manage, PERMISSION_MODELS do |record|
      # Unwrap Draper decorator if present to get the actual model
      actual_record = record.respond_to?(:object) ? record.object : record
      if actual_record.instance_of?(Preparation)
        true
      else
        actual_record.writable?(user)
      end
    end

    can :read, PERMISSION_MODELS do |record|
      # Unwrap Draper decorator if present to get the actual model
      actual_record = record.respond_to?(:object) ? record.object : record
      if actual_record.instance_of?(Preparation)
        true
      else
        actual_record.readable?(user)
      end
    end

  end
end
