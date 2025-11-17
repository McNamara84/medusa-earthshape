class Array
	def to_pml(options={})
	    xml = ::Builder::XmlMarkup.new(indent: 2)
	    xml.instruct!
	    xml.acquisitions do
	      each do |obj|
	      	obj = obj.datum if obj.instance_of?(RecordProperty)
	      	if obj.instance_of?(Analysis)
	      		obj.to_pml(xml)
	      	elsif obj.respond_to?(:analysis)
	      		obj.analysis.to_pml(xml)
	      	elsif obj.respond_to?(:analyses)
	      		# Get analyses and sort by id descending for consistent output
	      		analyses = obj.analyses
	      		analyses = analyses.order(id: :desc) if analyses.respond_to?(:order)
	      		# Rails 5.0+: Convert to Array before iterating
	      		analyses = analyses.to_a if analyses.respond_to?(:to_a)
	      		analyses.each do |analysis|
	      			analysis.to_pml(xml)
	      		end
	      	end
	      end
	    end

	end
end

# Rails 6.0: Renderer block signature changed from |object, options| to |object|
ActionController::Renderers.add :pml do |object|
	self.content_type ||= Mime[:pml]
	# Rails 5.0+: Convert ActiveRecord::Relation to Array before calling to_pml
	object = object.to_a if object.respond_to?(:to_a) && !object.is_a?(Array)
	object.respond_to?(:to_pml) ? object.to_pml : object
end