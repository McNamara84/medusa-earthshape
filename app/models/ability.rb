class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :family, :picture, :map, :download_label, :download_card, :download, to: :read

    if user.admin?
      can :manage, :all
    end
    
    can :manage, [AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Stone, Collection, Preparation] do |record|
      if (record.instance_of?(Preparation))
          true
      else
         record.writable?(user)
      end
    end

    can :read, [AttachmentFile, Bib, Box, Analysis, Chemistry, Place, Spot, Stone, Collection, Preparation] do |record|
      if (record.instance_of?(Preparation))
	 true
      else
         record.readable?(user)
      end
    end

  end
end
