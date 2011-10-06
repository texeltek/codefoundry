require 'spec_helper'

describe Repository do
  
  describe "#scm_str" do
    before :each do
      @repo = FactoryGirl.build :project_repository
    end

    context "when scm is 1" do
      it "should return 'git'" do
        @repo.scm = 1
        @repo.scm_str.should eq 'git'
      end
    end
    
    context "when scm is 2" do
      it "should return 'svn'" do
        @repo.scm = 2
        @repo.scm_str.should eq 'svn'
      end
    end                 
  end
  
  describe "#full_path" do
    before :each do
      @repo = FactoryGirl.build :project_repository
      @repo.project.name = 'fooproj'
    end
    
    context "when it's a git repository" do
      it "should return '/var/codefoundry/git/fooproj/foorepo.git'" do
        @repo.scm = 1
        @repo.full_path.should eq '/var/codefoundry/git/fooproj/foorepo.git'
      end
    end
  end
end
