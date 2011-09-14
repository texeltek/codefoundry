require 'spec_helper'

describe Settings do
  it "should set its source to config/settings.yml" do
    Settings.source.should eq File.join( Rails.root, 'config', 'settings.yml' )
  end

  it "should set its namespace to the current Rails.env" do
    Settings.namespace.should eq 'test'
  end
end
