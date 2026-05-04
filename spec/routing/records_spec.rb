require 'spec_helper'

describe "records routing" do
  it { expect(:get => '/records.modal').to route_to(:controller => "records", :action => "index", :format => "modal") }
  it { expect(:get => '/records/1111?format=json').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "json") }
  it { expect(:get => '/records/1111?format=pml').to route_to(:controller => "records", :action => "show", :id => "1111", :format => "pml") }
  it { expect(:get => '/records/sample.id.v1.json').to route_to(:controller => "records", :action => "show", :id => "sample.id.v1.json") }
  it { expect(:get => '/records/sample.id.v1.json/ancestors').to route_to(:controller => "records", :action => "ancestors", :id => "sample.id.v1.json") }
end
