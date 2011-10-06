require 'spec_helper'

describe Project do

  def make_valid_user
    User.new( 
      :id => 222,
      :first_name => 'sample', 
      :last_name => 'specname', 
      :username => 'spec user', 
      :email => 'spec@spec.com', 
      :password => 'spec pw', 
      :password_confirmation => 'spec pw'
    )
  end
  
  it { should have_many(:repositories) }
  it { should have_many(:project_privileges) }
  it { should have_many(:users).through(:project_privileges) }

  before :each do
    @proj = FactoryGirl.build(:project)
  end

  describe "#to_param" do
    it "should return a string" do
      @proj.to_param.class.should eq String
    end

    context "given project.name" do
      context "contains 1 space" do
        it "should return project.name with the space replaced with a dash" do
          @proj.name = 'sample proj'
          @proj.to_param.should eq 'sample-proj'
        end
      end

      context "contains 2 or more spaces" do
        it "should return project.name with all spaces replaced with dashes" do
          @proj.name = 'sample proj one'
          @proj.to_param.should eq 'sample-proj-one'
        end
      end

      context "contains unwanted chars" do
        it "should remove all brackets" do
          @proj.name = '[sampleproj]'
          @proj.to_param.should eq 'sampleproj'
        end

        it "should remove all chars that are not alphanumeric or underscores" do
          @proj.name = '$%^sample_proj@*('
          @proj.to_param.should eq 'sample_proj'
        end

        it "should remove all leading separator characters" do
          @proj.name = '$ [sampleproj'
          @proj.to_param.should eq 'sampleproj'
        end

        it "should remove all trailing separator characters" do
          @proj.name = 'sampleproj %^(]**'
          @proj.to_param.should eq 'sampleproj'
        end
      end
    end
  end

  describe "#save_param" do
    it "should save #to_param to its param attribute" do
      @proj.name = 'paramproj'
      @proj.save_param
      @proj.param.should eq 'paramproj'
    end
  end

  describe "#add_administrator" do
    before :each do
      @proj = FactoryGirl.create(:project)
    end
    
    it "should call find_by_name on Role" do
      Role.should_receive(:find_by_name).with('Administrator').and_return(mock_model(Role))
      @proj.add_administrator(mock_model(User))
    end
    
    context "when the Role is found" do
      before :each do
        Role.stub!(:find_by_name).with('Administrator').and_return(mock_model(Role))
        @proj.add_administrator(mock_model(User, {:name => 'mock admin user'}))
      end
      
      it "should add a new ProjectPrivilege" do
        @proj.privileges.count.should eq 1
      end

      it "should add a new ProjectPrivilege per call per User" do
        @proj.add_administrator(mock_model(User, {:name => 'mock admin user 2'}))
        @proj.privileges.count.should eq 2
      end
    end
  end 
  
  describe "#add_committer" do
    before :each do
      @proj = FactoryGirl.create :project
    end
    
    it "should call find_by_name on Role" do
      Role.should_receive( :find_by_name ).with( 'Committer' ).and_return mock_role( :name => 'Committer' )
      @proj.add_committer( mock_model(User, {:name => 'bob'}) )
    end
    
    context "when the Role is found" do
      before :each do
        Role.stub!( :find_by_name ).with( 'Committer' ).and_return mock_role( :name => 'Committer' )
      end
      
      it "should add a new ProjectPrivilege of Committer per call per User" do
        @proj.add_committer( mock_user( :name => 'alice' ) )
        @proj.privileges.count.should eq 1
      
        @proj.add_committer( mock_user( :name => 'mary' ) )
        @proj.privileges.count.should eq 2
      end
    end
  end
  
  describe "#add_reviewer" do
    before :each do
      @proj = FactoryGirl.create :project
    end
    
    it "should call find_by_name on Role" do
      Role.should_receive( :find_by_name ).with( 'Reviewer' ).and_return mock_role( :name => 'Reviewer' )
      @proj.add_reviewer( mock_user( :name => 'sam' ))
    end
    
    it "should add a new ProjectPrivilege of Reviewer per call per User" do
      Role.stub!( :find_by_name ).with( 'Reviewer' ).and_return mock_role( :name => 'Reviewer' )
      
      @proj.add_reviewer( mock_user( :name => 'nora' ))
      @proj.privileges.count.should eq 1
    
      @proj.add_reviewer( mock_user( :name => 'dora' ))
      @proj.privileges.count.should eq 2
    end
  end
  
  describe "#add_tester" do
    before :each do
      @proj = FactoryGirl.create :project
    end
    
    it "should call find_by_name on Role" do
      Role.should_receive( :find_by_name ).with( 'Tester' ).and_return mock_role( :name => 'Tester' )
      @proj.add_tester( mock_user( :name => 'tom' ))
    end
    
    it "should add a new ProjectPrivilege of Reviewer per call per User" do
      Role.stub!( :find_by_name ).with( 'Tester' ).and_return mock_role( :name => 'Tester' )
      
      @proj.add_tester( mock_user( :name => 'dom' ))
      @proj.privileges.count.should eq 1
    
      @proj.add_tester( mock_user( :name => 'crom' ))
      @proj.privileges.count.should eq 2
    end
  end

  describe "#editor?" do
    before :each do
      @user = FactoryGirl.create(:user)
      @proj = FactoryGirl.create(:project)
    end
    it "should return true if the user is an editor" do
      editor = FactoryGirl.create(:editor)
      
      @proj.privileges.create!({:user => @user, :role => editor})
      @proj.editor?(@user).should eq true
    end

    it "should return false if the user is not an editor" do
      read_only_role = FactoryGirl.create(:read_only_role)

      @proj.privileges.create!( {:user => @user, :role => read_only_role} )
      @proj.editor?(@user).should be_false
    end
  end
  
  it "should create a new instance of User given valid attributes" do
    Project.create(:name => 'proj1')
  end

  describe "validations" do
    describe "for name" do
      it "should throw an error if name is nil" do
        Project.new.should have(1).error_on(:name)
      end
    end

    describe "for param" do
      it "should fail if param is not unique" do
        proj1 = Project.create(:name => 'proj1')
        proj2 = Project.create(:name => 'proj1')
        proj1.should have(1).error_on(:param)
      end
    end
  end

  describe "before being saved" do
    it "should call #save_param" do
      proj = Project.new(:name => 'proj1')
      proj.should_receive(:save_param)
      proj.save!
    end
  end

end
