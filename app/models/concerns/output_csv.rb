module OutputCsv
  extend ActiveSupport::Concern
  LABEL_HEADER = ["Id","Name"]

  def build_label
    attribute_keys = ["global_id"]
    attribute_values = []

    attributes.each_key do |key|  
	    attribute_keys.push(key)
   end
    attribute_keys.each do |key| 
	    if  attributes.key?(key) then
		attribute_values.push(attributes[key])
	    elsif (key=="global_id")
		    logger.info self.class.name.inspect
		val=RecordProperty.where(datum_type:  self.class.name).where(datum_id: self.id).take
		attribute_values.push(val.global_id) 
	    else
		attribute_values.push(nil)		    
	    end
    end
	    
	    
    CSV.generate do |csv|
 #     csv << LABEL_HEADER
 #     csv << ["#{global_id}", "#{name}"]
         csv << attribute_keys
	 csv << attribute_values
    end
  end

  module ClassMethods
    def build_bundle_label(resources)
      CSV.generate do |csv|
        csv << LABEL_HEADER
        resources.each do |resource|
          csv << ["#{resource.global_id}", "#{resource.name}"]
        end
      end
    end
  end

end
