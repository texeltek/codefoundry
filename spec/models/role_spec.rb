require 'spec_helper'

describe Role do
  it { should validate_presence_of :name }
  
  it "should validate uniqueness of :name" do
    Role.create( :name => 'sample role' )
    Role.new( :name => 'sample role' ).should have(1).error_on(:name) 
  end

end
