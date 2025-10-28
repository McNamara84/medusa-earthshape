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
  has_many :analysis_stones
  has_many :analyses, through: :analysis_stones
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

  def analysis_global_id
    nil
  end

  def analysis_global_id=(global_id)
    begin
     self.analyses << Analysis.joins(:record_property).where(record_properties: {global_id: global_id}).first
    rescue
    end
  end
  def attachment_file_global_id
    nil
  end

  def attachment_file_global_id=(global_id)
    begin
     logger.info global_id   
     logger.info AttachmentFile.joins(:record_property).where(record_properties: {global_id: global_id}).first.inspect
     self.attachment_files << AttachmentFile.joins(:record_property).where(record_properties: {global_id: global_id}).first
    rescue
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
  
  #                            :collection_name => row[0], :collection_project=> row[1], :collection_strategy => row[2], :collection_weather => row[3], :collection_timeseries => row[4], 
   #                           :collection_comment => row[5], :collection_group => row[6], :place_is_parent => row[7], :place_name => row[8], :place_parent => row[9], 
    #                          :place_latitude => row[10], :place_longitude => row[11],  :place_elevation => row[12], :place_topographic_positon => row[13], :place_vegetation => row[14], 
     #                         :place_landuse => row[15], :place_lightsituation => row[16], :place_slopedescription => row[17], :place_aspect => row[18],  :place_description => row[19], 
      #                        :place_group => row[20], :box_name => row[21], :box_type => row[22], :box_parent => row[23],  :box_group => row[24], 
       #                       :sample_name => row[25], :sample_parent => row[26], :sample_igsn => row[27], :sample_collectionmethod => row[28], :sample_material => row[29], 
        #                      :sample_classification => row[30], :sample_location => row[31], :sample_campaign => row[32], :sample_depth => row[33], :sample_date => row[34], 
         #                     :sample_unit => row[35], :sample_quantityinitial => row[36], :sample_quantity => row[37], :sample_labname => row[38], :sample_storageroom => row[39], 
          #                    :sample_container => row[40], :sample_comment => row[41], :sample_group => row[42], :sample_collector => row[43], :sample_affiliation => row[44], 
           #                   :treatment_monitor1 => row[45], :treatment_monitor2 => row[46], :treatment_monitor3 => row[47], :treatment_preparation1 => row[48], :treatment_preparation2 => row[49], 
            #                  :treatment_preparation3 => row[50], :treatment_strategy => row[51], :treatment_analyticalmethod => row[52], :treatment_comment => row[53]
  
  end

  private
  
  def parent_id_cannot_self_children
    # Reload children association to ensure we have current data from database
    # This is necessary because descendants() uses the children association,
    # which may be cached with stale data
    children.reload if children.loaded?
    invalid_ids = descendants.map(&:id).unshift(self.id)
    if invalid_ids.include?(self.parent_id)
      errors.add(:parent_id, " make loop.")
    end
  end

end
