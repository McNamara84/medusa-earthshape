class Ability
  include CanCan::Ability

  # List of model classes that use HasRecordProperty for permission checking
  PERMISSION_MODELS = [AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Stone, Collection, Preparation].freeze
  
  # Decorator classes that wrap the permission models (for view-level can? checks)
  DECORATOR_MODELS = [AttachmentFileDecorator, BibDecorator, BoxDecorator, AnalysisDecorator, 
                      ChemistryDecorator, PlaceDecorator, SpotDecorator, StoneDecorator, 
                      CollectionDecorator, PreparationDecorator].freeze

  def initialize(user)
    alias_action :family, :picture, :map, :download_label, :download_card, :download, to: :read

    if user.admin?
      can :manage, :all
    end
    
    # Permission rules for actual model instances
    can :manage, PERMISSION_MODELS do |record|
      check_writable(record, user)
    end

    can :read, PERMISSION_MODELS do |record|
      check_readable(record, user)
    end
    
    # Permission rules for decorated model instances (used in views)
    can :manage, DECORATOR_MODELS do |record|
      check_writable(record, user)
    end

    can :read, DECORATOR_MODELS do |record|
      check_readable(record, user)
    end
  end
  
  private
  
  # Unwrap Draper decorator if present and check writable permission
  def check_writable(record, user)
    actual_record = record.respond_to?(:object) ? record.object : record
    return true if actual_record.instance_of?(Preparation)
    actual_record.writable?(user)
  end
  
  # Unwrap Draper decorator if present and check readable permission
  def check_readable(record, user)
    actual_record = record.respond_to?(:object) ? record.object : record
    return true if actual_record.instance_of?(Preparation)
    actual_record.readable?(user)
  end
end
