# frozen_string_literal: true

module Pml
  class Serializer
    def self.call(object, options = {})
      xml = ::Builder::XmlMarkup.new(indent: 2)
      xml.instruct!

      xml.acquisitions do
        each_item(object) do |item|
          serialize_item(item, xml)
        end
      end

      xml.target!
    end

    def self.each_item(object)
      return enum_for(:each_item, object) unless block_given?

      items =
        if object.nil?
          []
        elsif object.is_a?(Array)
          object
        elsif object.respond_to?(:to_a) && !object.is_a?(String) && !object.is_a?(Hash)
          object.to_a
        else
          [object]
        end

      items.each { |item| yield item }
    end

    def self.serialize_item(item, xml)
      item = item.datum if item.instance_of?(RecordProperty)

      if item.instance_of?(Analysis)
        item.to_pml(xml)
      elsif item.respond_to?(:analysis)
        item.analysis.to_pml(xml)
      elsif item.respond_to?(:analyses)
        analyses = item.analyses
        analyses ||= []
        analyses = analyses.order(id: :desc) if analyses.respond_to?(:order)
        analyses = analyses.to_a if analyses.respond_to?(:to_a)

        analyses.each { |analysis| analysis.to_pml(xml) }
      end
    end

    private_class_method :each_item, :serialize_item
  end
end
