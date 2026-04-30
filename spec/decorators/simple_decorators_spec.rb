require "spec_helper"

describe "simple decorators" do
  [
    CollectionmethodDecorator,
    CollectorDecorator,
    FiletopicDecorator,
    LanduseDecorator,
    PreparationForClassificationDecorator,
    PreparationTypeDecorator,
    QuantityunitDecorator,
    SearchMapDecorator,
    StagingDecorator,
    StonecontainerTypeDecorator,
    TopographicPositionDecorator,
    VegetationDecorator
  ].each do |decorator_class|
    it "loads #{decorator_class} and decorates its model" do
      model_class = decorator_class.name.delete_suffix("Decorator").constantize
      decorator = decorator_class.new(model_class.new)

      expect(decorator.object).to be_a(model_class)
    end
  end
end