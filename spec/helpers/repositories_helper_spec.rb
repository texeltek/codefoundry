require 'spec_helper'

describe RepositoriesHelper do
  before :each do
    @repo = mock_repository( 
      { :name => "foorepo", 
        :to_param => "foorepo", 
        :project => mock_project({ :name => "fooproj" }),
        :branches => [DummyBranch.new( "master" ), DummyBranch.new( "dev1" )]
        })
  end
  
  class DummyBranch
    def initialize(n)
      @name = n
    end
    def name
      @name
    end
  end
    
  
  describe "#git_path" do
    context "given a project named fooproj" do    
      it "should return a local path for a repo named foorepo" do
        helper.git_path( @repo ).should eq "git/fooproj/foorepo.git"
      end
    end
  end
  
  describe "#git_url" do
    it "should return a full URL for a repo named foorepo" do
      helper.git_url( @repo ).should eq "http://test.host//git/fooproj/foorepo.git"
    end
  end
  
  describe "branch_names" do
    it "should return an Array of the names of the repo's branches" do
      helper.branch_names( @repo ).should eq ["master", "dev1"]
    end
  end
end