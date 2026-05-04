require 'spec_helper'

describe "records routing" do
  it { expect(:get => '/records.modal').to route_to(:controller => "records", :action => "index", :format => "modal") }
  it { expect(:get => '/records/1111.json').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "json") }
  it { expect(:get => '/records/1111.xml').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "xml") }
  it { expect(:get => '/records/sample.id.v1').to route_to(:controller => "records", :action => "show", :id => "sample.id.v1") }
  it { expect(:get => '/records/sample.id.v1.json').to route_to(:controller => "records", :action => "show", :id => "sample.id.v1", :format => "json") }
  it { expect(:get => '/records/sample.id.v1/families.pml').to route_to(:controller => "records", :action => "families", :id => "sample.id.v1", :format => "pml") }
end
