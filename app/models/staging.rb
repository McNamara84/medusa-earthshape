class Staging < ApplicationRecord
  include HasRecordProperty	
  PERMIT_IMPORT_TYPES = ["text/plain", "text/csv", "text/comma-separated-values","application/csv", "application/vnd.ms-excel"]

  def self.import_csv(file)

    if !file
	raise StandardError, "The server failed to retrieve the file. Contact the administrator."
    end	
    if !PERMIT_IMPORT_TYPES.include?(file.content_type)
	raise StandardError, "The file \""+file.original_filename+"\" is not in the list of known file types. Please provide a CSV-file!"
    end

    if file && PERMIT_IMPORT_TYPES.include?(file.content_type)
 #     table = CSV.parse(file.read, headers: [
 #     :collection_name, :collection_project, :collection_strategy, :collection_weather, :collection_timeseries, :collection_comment, :collection_group,
 #     :place_is_parent, :place_name, :place_parent, :place_latitude, :place_longitude,  :place_elevation, :place_topographic_position,
 #     :place_vegetation, :place_landuse, :place_lightsituation,:place_slopedescription, :place_aspect,  :place_description, :place_group,
 #     :box_name, :box_type, :box_parent,  :box_group,
 #     :sample_name, :sample_parent, :sample_igsn, :sample_collectionmethod, :sample_material, :sample_classification, :sample_location, :sample_campaign,
 #     :sample_depth, :sample_date, :sample_unit, :sample_quantityinitial, :sample_quantity, :sample_labname, :sample_storageroom, :sample_container, 
 #     :sample_comment, :sample_group, :sample_collector, :sample_affiliation,
 #     :treatment_monitor1, :treatment_monitor2, :treatment_monitor3, 
 #     :treatment_preparation1, :treatment_preparation2, :treatment_preparation3, 
 #     :treatment_strategy, :treatment_analyticalmethod, :treatment_comment, 
 #    :hidden_column
 #     ])
      
      table=CSV.parse(file.read)
      found=0
      validheader=false	      
      ActiveRecord::Base.transaction do
        delcount=0
        pass=0
        table.each do |row|
                pass=pass+1
                if pass == 1
                        collection_name=row[0]
                        delcount=delcount+1
                        if collection_name.present? and collection_name.downcase=="campaign"
                                validheader=true
                        end   
                end
                if pass == 2
                        collection_name=row[0]
                        if collection_name.present? and collection_name.downcase=="campaign"
                                delcount=delcount+1
                                validheader=true
                        end
                end

        end
                        
        if validheader
                table.each_with_index do |row,index|
                
                
                     if index >= delcount
                  
                             rowhash = {
                              :collection_name => row[0], :collection_project=> row[1], :collection_strategy => row[2], :collection_weather => row[3], :collection_timeseries => row[4], 
                              :collection_comment => row[5], :collection_group => row[6], :place_is_parent => row[7], :place_name => row[8], :place_parent => row[9], 
                              :place_latitude => row[10], :place_longitude => row[11],  :place_elevation => row[12], :place_topographic_position => row[13], :place_vegetation => row[14], 
                              :place_landuse => row[15], :place_lightsituation => row[16], :place_slopedescription => row[17], :place_aspect => row[18],  :place_description => row[19], 
                              :place_group => row[20], :box_name => row[21], :box_type => row[22], :box_parent => row[23],  :box_group => row[24], 
                              :sample_name => row[25], :sample_parent => row[26], :sample_igsn => row[27], :sample_collectionmethod => row[28], :sample_material => row[29], 
                              :sample_classification => row[30], :sample_location => row[31], :sample_campaign => row[32], :sample_depth => row[33], :sample_date => row[34], 
                              :sample_unit => row[35], :sample_quantityinitial => row[36], :sample_quantity => row[37], :sample_labname => row[38], :sample_storageroom => row[39], 
                              :sample_container => row[40], :sample_comment => row[41], :sample_group => row[42], :sample_collector => row[43], :sample_affiliation => row[44], 
                              :treatment_monitor1 => row[45], :treatment_monitor2 => row[46], :treatment_monitor3 => row[47], :treatment_preparation1 => row[48], :treatment_preparation2 => row[49], 
                              :treatment_preparation3 => row[50], :treatment_strategy => row[51], :treatment_analyticalmethod => row[52], :treatment_comment => row[53]
                             }                  
                          
                          staging = new(rowhash)
	                  
	                  if staging.collection_name.present? and staging.sample_name.present?
	                        found=found+1
		                staging.save!
	                  end
	            end
                end
        end
      end
      
      if not validheader or found==0
	raise StandardError, "The CSV file is invalid or is empty. Columns should be separated by commas \",\". The first or second row should begin with \"Campaign\" - rows after that are interpreted as import data. Every data row should contain at least a campaign name and a sample name"       
      end
      
      true
            
    end
  end


  def name
	return self.collection_name+"-"+self.sample_name
  end
  
  def create_collections
	collection_params={
		:name => self.collection_name, 
		:project => self.collection_project, 
		:collector => self.collection_collector,
		:affiliation => self.collection_affiliation,		
		:timeseries =>self.collection_timeseries,
#		:collection_start => self.collection_start, 
#		:collection_end => self.collection_end, 
#		:depth_min => self.collection_depth_min, 
#		:depth_max => self.collectin_depth_max, 
		:comment => self.collection_comment,
#		:samplingstrategy =>self.treatment_strategy,
		:weather_conditions => self.place_weather,
#		:collectionmethod_id => self.sample_collectionmethod,		
	}
	return Collection.new (collection_params)
  end
  def create_places
	place_params = {
	:name => self.place_name, 
	:longitude => self.place_longitude, 
	:latitude => self.place_latitude, 
	:elevation => self.place_elevation, 
	:topographic_position_id => self.place_topographic_position,
	:slope_description => self.place_slopedescription, 
	:aspect => self.place_aspect, 
	:vegetation_id => self.place_vegetation, 
	:landuse_id => self.place_landuse, 
	:description => self.place_description,
	:lightsituation => self.place_lightsituation}
	return Place.new (place_params)
  end
  def create_samples
        sample_params = {
		:name => self.sample_name, 
		:igsn => self.sample_igsn, 
		:labname => self.sample_labname, 
		:date => self.sample_date, 
		:sampledepth => self.sample_depth, 
		:description => self.sample_comment, 
#		:parent => self.sample_parent, 
#		:material => self.sample_material, 
		:classification_id => self.sample_classification, 
		:stonecontainer_type_id => self.sample_container,
		:quantity_initial => self.sample_quantityinitial, 
		:quantity_unit => self.sample_unit, 
		:quantity => self.sample_quantity, 	
	}
	return Stone.new (sample_params)
end
def create_box
		box_params = {
		:name =>  :box_name, 
		:parent => :box_parent,
		:type_type_id =>  :box_type
		}
		return Box.new(box_params)
end
def create_preparations
end
  
  def ingest
	  

	
#	create_preparations



	
#      :treatment_monitor1, :treatment_monitor2,
#      :treatment_monitor3, :treatment_preparation1, :treatment_preparation2, :treatment_preparation3, :treatment_strategy,
#      :treatment_analyticalmethod, :treatment_comment, :hidden_column	
	


#	place.new
#	stone.new
#	box.new
  end
end
