require 'spec_helper'

describe RepositoriesHelper do
  describe "#git_path" do
    context "given a project named fooproj" do    
      it "should return a local path for a repo named foorepo" do
        repo = mock_repository( :project=>mock_project( :name=> 'fooproj' ), :name => 'foorepo' ) 
        helper.git_path( repo ).should eq "git/fooproj/foorepo.git"
      end
      
      it "should return a local path for a repo named niftyrepo" do
        repo = mock_repository( :project=>mock_project( :name=> 'fooproj' ), :name => 'niftyrepo' ) 
        helper.git_path( repo ).should eq "git/fooproj/niftyrepo.git"
      end
    end
  end
  
  describe "#git_url" do
  end
end