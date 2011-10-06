require 'spec_helper'

describe RepositoriesHelper do
  before :all do
    @repo = FactoryGirl.build :repository
    @repo.name = "foorepo"
    @repo.project.name = "fooproj"
  end
  
  describe "#git_path" do
    context "given a project named fooproj" do    
      it "should return a local path for a repo named foorepo" do
        
        helper.git_path( @repo ).should eq "git/fooproj/foorepo.git"
      
      end
    end
  end
  
  describe "#git_url" do
    https = 'on'
    host = 'spechost:1234'
    
    it "should return a full URL for a repo named foorepo" do
      
      helper.git_url( @repo, https, host ).should eq "https://spechost:1234/git/fooproj/foorepo.git"
    
    end
  end
end