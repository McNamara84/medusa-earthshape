class Place < ApplicationRecord
  include HasRecordProperty
  include OutputPdf
  include OutputCsv
  include HasAttachmentFile
  include HasRecursive

  TEMPLATE_HEADER = "name,latitude(decimal degree),longitude(decimal degree),elevation(m),description\n"
  PERMIT_IMPORT_TYPES = ["text/plain", "text/csv", "application/csv", "application/vnd.ms-excel"]

  # acts_as_mappable # Temporarily disabled - gem not publicly available

  has_many :stones
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  has_many :collectors, through: :stones  
  belongs_to :landuse, optional: true
  belongs_to :vegetation, optional: true
  belongs_to :topographic_position, optional: true
   has_many :children, class_name: "Place", foreign_key: :parent_id, dependent: :nullify
   has_many :places,    class_name: "Place", foreign_key: :parent_id, dependent: :nullify     
   belongs_to :parent,  class_name: "Place", foreign_key: :parent_id, optional: true  
   
   scope :choose_parent_global_id, ->(user) { 
	ids=Place.where(is_parent: true).map(&:id)		 
	RecordProperty.readables(user).where(datum_type:  self).where("datum_id IN (?)",  ids).order(:name).pluck(:name, :global_id)
   }
   
   # Virtual attribute for forms: allows setting parent via global_id
   def parent_global_id
     parent&.global_id
   end
   
   def parent_global_id=(global_id)
     return if global_id.blank?
     record_property = RecordProperty.find_by_global_id(global_id)
     self.parent_id = record_property&.datum_id if record_property&.datum_type == 'Place'
   end
   
   validates :name, presence: true, length: { maximum: 255 }
   with_options unless: :is_parent? do |childvalidations|
	   childvalidations.validates :latitude, presence: true, length: { maximum: 255 }
	   childvalidations.validates :longitude, presence: true, length: { maximum: 255 }
	   childvalidations.validates :elevation, presence: true, length: { maximum: 255 }
	   childvalidations.validates :parent, presence: true
	   childvalidations.validates :topographic_position_id, presence: true
	   childvalidations.validates :description, presence: true
   end
   validate :parent_id_cannot_self_children, if: ->(place) { place.parent_id }

  def self.import_csv(file)
    if file && PERMIT_IMPORT_TYPES.include?(file.content_type)
      table = CSV.parse(file.read, headers: [:name, :latitude, :longitude, :elevation, :description])
      ActiveRecord::Base.transaction do
        table.delete(0)
        table.each do |row|
          place = new(row.to_hash)
          place.save!
        end
      end
    end
  end

  def analyses
    analyses = []
    stones.each do |stone| 
      (analyses = analyses + stone.analyses) unless stone.analyses.empty?
    end
    analyses
  end


  def initialize(*args)	  
	if args.length > 0					  
		attributes=args[0]
		attributes[:latitude].gsub!(/\s+/i,'')
		attributes[:latitude].gsub!(/,/i,'.')
		attributes[:longitude].gsub!(/\s+/i,'')		
		attributes[:longitude].gsub!(/,/i,'.')		
		super(attributes)		
		
		if attributes[:latitude].downcase =~ /s/ and self.latitude > 0
			self.latitude= - self.latitude
		end
		    
		if attributes[:longitude].downcase =~ /w/ and self.longitude > 0
			self.longitude= - self.longitude
		end	
	else
		super
	end
  end

  
  def update_attributes(*args)
	if args.length > 0					  
		attributes=args[0]
		
		if attributes[:latitude].present?
			attributes[:latitude].gsub!(/\s+/i,'')
			attributes[:latitude].gsub!(/,/i,'.')
		end
		if attributes[:longitude].present?
			attributes[:longitude].gsub!(/\s+/i,'')		
			attributes[:longitude].gsub!(/,/i,'.')	
		end
		super(attributes)		
		
		if attributes[:latitude].present? and attributes[:latitude].downcase =~ /s/ and self.latitude > 0
			self.latitude= - self.latitude
		end
		    
		if attributes[:longitude].present? and attributes[:longitude].downcase =~ /w/ and self.longitude > 0
			self.longitude= - self.longitude
		end	
		
		self.save

	else
		super
	end
	
	
  end
  
  def validate_stringlatlon(lat, lon)
	if is_parent.blank?
		
		if  lat.split(".").length < 2 or lat.split(".").last.gsub(/[^0-9]/i,'').length < 4
			self.errors.add(:latitude, " <b>"+Place.human_attribute_name("latitude")+"</b> four decimal places required after period") 
		end

		if  lon.split(".").length < 2 or lon.split(".").last.gsub(/[^0-9]/i,'').length < 4
			self.errors.add(:longitude, " <b>"+Place.human_attribute_name("longitude")+"</b> four decimal places required after period")
		end
		
	end
end

  private

  def parent_id_cannot_self_children
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end
  
end
