module HasRecordProperty
  extend ActiveSupport::Concern

  # Rails 5.0+: ActiveModel::Serializers::Xml is not included by default
  # Only include if the model needs to_xml functionality
  included do
    include ActiveModel::Serializers::Xml if defined?(ActiveModel::Serializers::Xml)
    has_one :record_property, as: :datum, dependent: :destroy
    has_one :user, through: :record_property
    has_one :group, through: :record_property
    accepts_nested_attributes_for :record_property
    delegate :global_id, :published_at, :readable?, to: :record_property
    delegate :user_id, :group_id, :published, to: :record_property, allow_nil: true

    after_create :generate_record_property
    after_save :update_record_property

    scope :readables, ->(user) { includes(:record_property).joins(:record_property).merge(RecordProperty.readables(user)) }
    scope :choose_global_id, ->(user) { RecordProperty.readables(user).where(datum_type:  self).order(:name).pluck(:name, :global_id) }
    scope :choose_id, ->(user) { includes(:record_property).joins(:record_property).merge(RecordProperty.readables(user)).order(:name).pluck(:name, :id) }
    
    # Rails 5.0+: Override to_xml AFTER ActiveModel::Serializers::Xml is included
    # This ensures our custom to_xml takes precedence
    def to_xml(options = {})
      # Delegated attributes via delegate don't work with :methods option in Rails 5.0+
      # We need to manually include global_id in the XML output
      options = options.dup
      
      # First, generate the base XML
      base_xml = super(options)
      
      # If record_property exists and has a global_id, inject it into the XML
      if record_property && record_property.global_id.present?
        # Insert global-id element before the closing tag
        base_xml.sub!(/<\/#{self.class.name.underscore.dasherize}>/, 
                      "  <global-id>#{record_property.global_id}</global-id>\n</#{self.class.name.underscore.dasherize}>")
      end
      
      base_xml
    end      
  end

  def as_json(options = {})
    super({:methods => :global_id}.merge(options))
  end

  def to_pml
    [self].to_pml
  end
  

  def form_name
    return self.physical_form.name if self.respond_to?(:physical_form) && self.physical_form
    return self.box_type.name if self.respond_to?(:box_type) && self.box_type
    return nil
  end

  def bib_title
    items = []
    #title = ""
    if self.respond_to?(:form_name) && self.form_name
      form_name = self.form_name
      if ['a', 'e', 'i', 'o', 'u'].include? form_name[0..0]
        items << 'An'
      else
        items << 'A'
      end
      # items << "#{article_for(self.form_name)}".capitalize
      items << form_name
    end
    items << "``#{self.name}''"
    if self.box_path.blank?
      items << "located at unknown"
    else
      items << "located at \\nolinkurl{#{self.box_path}}" if self.box_path
    end
    items.join(' ')    
  end

  def to_bibtex(options = {})
    if self.instance_of?(Bib)
      to_tex
    else
      dream_url = "http://dream.misasa.okayama-u.ac.jp/?q=#{self.global_id}"
      items = []
      items << self.global_id
      my_author = self.name.gsub(/\s/,'-').gsub(/"/,"''") # TK January 22, 2014 (Wed)
      my_bib_title = self.bib_title.gsub(/"/,"''")
      items << " author={#{my_author}}"
      items << " title={#{my_bib_title}}"
      items << " journal={\\href{#{dream_url}}{DREAM}}"
      items << ' volume={' + self.created_at.strftime("%y") + '}'
      items << ' pages={' + self.global_id + '}'
      items << ' year={' + self.updated_at.strftime("%Y") +'}'
      items << " url={#{dream_url}}"
      return "@article{" + items.compact.join(",\n") + ",\n}"    
    end
  end

  def box_path
    return self.blood_path if self.instance_of?(Box)
    items = []
    if self.respond_to?(:box) && self.box
      items << self.box.path
      items << self.box.name
    else
      items << ""
    end
    items << self.name
    items.join("/")
  end

  def blood_path
    items = []
    if self.respond_to?(:parent) && self.parent
      items << "/#{self.ancestors.reverse.map(&:name).join('/')}"
    else
      items << ""
    end
    items << self.name
    items.join("/")
  end

  def latex_mode(type = :blood)
    if type == :box
      path = self.box_path
    else
      path = self.blood_path
    end

    links = []
    links << "stone=#{self.stone_count}"
    links << "box=#{self.box_count}"
    links << "analysis=#{self.analysis_count}"
    links << "file=#{self.attachment_file_count}"
    links << "bib=#{self.bib_count}"
    links << "locality=#{self.place_count}"
    links << "point=#{self.point_count}"

    tokens = []
    tokens << path
    tokens << "<#{self.class.name.downcase}: #{global_id}>"
    tokens << "<link: " + links.join(" ") + ">"
    tokens << "<last-modified: #{updated_at}>"
    tokens << "<created: #{created_at}>"        
    tokens.join(" ")
  end

  def user_id=(id)
    record_property && record_property.user_id = id
  end

  def group_id=(id)
    record_property && record_property.group_id = id
  end

  def published=(published)
    record_property && record_property.published = published
  end

  def writable?(user)
    new_record? || record_property.writable?(user)
  end

  def generate_record_property
    self.build_record_property unless self.record_property
    self.record_property.user_id = User.current.id unless User.current.nil?
    self.record_property.save
  end

  def update_record_property
    record_property.name = self.try(:name)
    record_property.update_attribute(:updated_at, updated_at)
  end

  def method_missing(method_id, *args, &block)
    if method_id =~ /(.*)_count/
      count = 0
      target_method = $1.to_sym
      count = 1 if self.respond_to?(target_method) && self.send(target_method)
      target_method = $1.pluralize.to_sym
      count = self.send(target_method).length if self.respond_to?(target_method) && self.send(target_method)
      return count
    end
    super
  end
end
