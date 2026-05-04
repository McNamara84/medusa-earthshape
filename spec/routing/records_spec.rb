require 'spec_helper'

describe "records routing" do
  it { expect(:get => '/records.modal').to route_to(:controller => "records", :action => "index", :format => "modal") }
  it { expect(:get => '/records/by-global-id/sample.id.v1.json/exact').to route_to(:controller => "records", :action => "show", :id => "sample.id.v1.json") }
  it { expect(:get => '/records/by-global-id/sample.id.v1.json/exact.json').to route_to(:controller => "records", :action => "show", :id => "sample.id.v1.json", :format => "json") }
  it { expect(:delete => '/records/by-global-id/sample.id.v1.json/exact').to route_to(:controller => "records", :action => "destroy", :id => "sample.id.v1.json") }
  it { expect(:get => '/records/1111.json').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "json") }
  it { expect(:get => '/records/1111.xml').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "xml") }
  it { expect(:get => '/records/sample.id.v1').to route_to(:controller => "records", :action => "show", :id => "sample.id.v1") }
  it { expect(:get => '/records/sample.id.modal/record_property').to route_to(:controller => "records", :action => "property", :id => "sample.id.modal") }
  it { expect(:get => '/records/sample.id.v1/families.pml').to route_to(:controller => "records", :action => "families", :id => "sample.id.v1", :format => "pml") }
  it { expect(:get => '/records/sample.id.modal/families.pml').to route_to(:controller => "records", :action => "families", :id => "sample.id.modal", :format => "pml") }
  it { expect(:get => '/records/sample.id.v1.pml/families.pml').to route_to(:controller => "records", :action => "families", :id => "sample.id.v1.pml", :format => "pml") }
end
