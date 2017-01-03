class Stone < ActiveRecord::Base
  include HasRecordProperty
  include HasViewSpot
  include OutputPdf
#  include OutputCsv
  include HasAttachmentFile
  include HasRecursive
  include HasIgsn

  acts_as_taggable
 #with_recursive

  has_many :analyses
  has_many :children, class_name: "Stone", foreign_key: :parent_id, dependent: :nullify
  has_many :stones, class_name: "Stone", foreign_key: :parent_id, dependent: :nullify  
  has_many :referrings, as: :referable, dependent: :destroy
  has_many :bibs, through: :referrings
  has_many :collectors
  belongs_to :parent, class_name: "Stone", foreign_key: :parent_id
  belongs_to :box
  belongs_to :place
  belongs_to :classification
  belongs_to :physical_form
  belongs_to :stonecontainer_type
  belongs_to :collection
  belongs_to :quantityunit
  belongs_to :collectionmethod
  has_many :preparations, dependent: :destroy

  accepts_nested_attributes_for :collectors, allow_destroy: true, reject_if: lambda {|attributes| attributes['name'].blank?}

  validates :box, presence: true
  validates :place, presence: true
  validates :collection, presence: true
  validates :stonecontainer_type, presence: true
  validates :quantity_initial, numericality: true
  validates :classification, presence: true
  validates :physical_form, existence: true, allow_nil: true
  validates :name, presence: true, length: { maximum: 255 }
  validates :sampledepth, numericality: true
  validates :date, presence: true 
  validates :igsn, uniqueness: true  , allow_nil: true, :allow_blank => true
  validate :parent_id_cannot_self_children, if: ->(stone) { stone.parent_id }
	  

  # def to_pml
  #   [self].to_pml
  # end

  def copy_associations (parent)
	Preparation.where(stone_id: parent.id).find_each do |parentprep|
		prep=parentprep.dup
		prep.stone_id=self.id
		prep.save
	end
  end

  def build_label
        CSV.generate do |csv|
                csv << Stone.csvlabels
                csv << csvvalues        
        end
  end

  def self.build_bundle_label(resources)
      CSV.generate do |csv|
        csv << csvlabels
        resources.each do |resource|
          csv << resource.csvvalues
        end
      end
  end



  def self.csvlabels
      header = ["Campaign","Project","Sampling strategy","Weather conditions","Time Series","comment","group"]
      header = header + ["Is parent","Sitename","Parent","Latitude (WGS84)","Longitude (WGS84)","Elevation (m above sea level)","Topographic position","Vegetation","Landuse","Lightsituation","Hillslope","Aspect","Description","Group"]
      header = header + ["Box name","Box type","Parent","Group"]
      header = header + ["Sample name","Parent","IGSN","Collection method","Material","Classification","Sampling Location","Sampling Campaign","Depth (m from groundlevel)","Date","Quantity unit","Quantity (initial)","Quantity (current)","Labname","Storageroom/ Box","Container","Description","Group","Collector Name","Affiliation"]  
      header
  end
  
  def csvvalues
        csv = [collection.try(:name), collection.project, collection.samplingstrategy, collection.weather_conditions, collection.timeseries, collection.comment, collection.group.try(:name)]
        csv = csv + [place.is_parent, place.try(:name), place.parent.try(:name), place.latitude, place.longitude, place.elevation, place.topographic_position.try(:name), place.vegetation.try(:name), place.landuse.try(:name), place.lightsituation, place.slope_description, place.aspect, place.description, place.group.try(:name) ]
        csv = csv + [box.try(:name), box.try(:box_type).try(:name), box.parent.try(:name), box.group.try(:name)]
        csv = csv + [name, parent.try(:name), igsn, collectionmethod.try(:name), classification.get_material, classification.try(:name), place.try(:name), collection.try(:name), sampledepth, date, quantityunit.try(:name), quantity_initial, quantity, labname, box.try(:name), stonecontainer_type.try(:name), description, group.try(:name)]
        csv = csv + [collectors.select(:name).distinct.map{|c| c.try(:name)}.join(","), collectors.select(:affiliation).map{|c| c.try(:affiliation)}.join(",")]
        csv  
  end

  private
  
  def parent_id_cannot_self_children
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

end
