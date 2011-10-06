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

  describe "#add_user_privilege" do
    before :each do
      @proj = FactoryGirl.create :project
      Role.stub!( :find_by_name ).with( 'awesome_keeper' ).and_return mock_role( :name => 'awesome_keeper' )
      @proj.add_user_privilege( mock_user(:name => 'jan'), 'awesome_keeper' )
    end
    
    it "should add a new privilege for the user" do
      @proj.privileges.count.should eq 1
    end
    
    it "should have one privilege for that user with the specified role" do  
      @proj.privileges.stub!( :find_by_id ).with( @proj.id ).and_return mock_role( :name => 'awesome_keeper' )
      @proj.privileges.find_by_id( @proj.id ).role.name.should eq 'awesome_keeper'
    end
  end
  
  describe "#remove_user_privilege" do
    before :each do
      @proj = FactoryGirl.create :project
      @user = mock_user( :name => 'fish' )
      Role.stub!( :find_by_name ).with( 'bad_guy_remover' ).and_return mock_role( :name => 'bad_guy_remover' )
      @proj.add_user_privilege( @user, 'bad_guy_remover' )
    end
    
    it "should remove the user's privilege" do
      @proj.remove_user_privilege( @user, 'bad_guy_remover' )
      @proj.privileges.count.should eq 0
    end
  end
  
  describe "#administrator?" do
    before :each do
      @user = FactoryGirl.create :user
      @proj = FactoryGirl.create :project
    end
    it "should return true if the user is an administrator (all administrator privileges)" do
      administrator_role = FactoryGirl.create :administrator
      
      @proj.privileges.create!({:user => @user, :role => administrator_role})
      @proj.administrator?( @user ).should be_true
    end

    it "should return false if the user is not an editor" do
      reviewer_role = FactoryGirl.create :reviewer

      @proj.privileges.create!( {:user => @user, :role => reviewer_role} )
      @proj.administrator?( @user ).should be_false
    end
  end
  
  describe "#editor?" do
    before :each do
      @user = FactoryGirl.create :user
      @proj = FactoryGirl.create :project
    end
    it "should return true if the user is an editor (all administrator privileges)" do
      editor_role = FactoryGirl.create :administrator
      
      @proj.privileges.create!({:user => @user, :role => editor_role})
      @proj.editor?( @user ).should be_true
    end

    it "should return false if the user is not an editor" do
      reviewer_role = FactoryGirl.create :reviewer

      @proj.privileges.create!( {:user => @user, :role => reviewer_role} )
      @proj.editor?( @user ).should be_false
    end
  end
  
  describe "#committer?" do
    before :each do
      @user = FactoryGirl.create :user
      @proj = FactoryGirl.create :project
    end
    
    it "should return true if the user is a committer (has commit and checkout privileges only)" do
      committer_role = FactoryGirl.create :committer

      @proj.privileges.create!({ :user => @user, :role => committer_role })
      @proj.committer?( @user ).should be_true
    end
    
    it "should return false if otherwise" do
      reviewer_role = FactoryGirl.create :reviewer
      
      @proj.privileges.create!({ :user => @user, :role => reviewer_role })
      @proj.committer?( @user ).should be_false
    end
  end
  
  describe "#reviewer?" do
    before :each do
      @user = FactoryGirl.create :user
      @proj = FactoryGirl.create :project
    end
    
    it "should return true if the user is a reviewer (has checkout privileges only)" do
      reviewer_role = FactoryGirl.create :reviewer

      @proj.privileges.create!({ :user => @user, :role => reviewer_role })
      @proj.reviewer?( @user ).should be_true
    end
    
    it "should return false if otherwise" do
      blank_role = FactoryGirl.create :role
      
      @proj.privileges.create!({ :user => @user, :role => blank_role })
      @proj.reviewer?( @user ).should be_false
    end
  end

  describe "#tester?" do
    before :each do
      @user = FactoryGirl.create :user
      @proj = FactoryGirl.create :project
    end
    
    it "should return true if the user is a tester (has checkout privileges only)" do
      tester_role = FactoryGirl.create :tester

      @proj.privileges.create!({ :user => @user, :role => tester_role })
      @proj.tester?( @user ).should be_true
    end
    
    it "should return false if otherwise" do
      blank_role = FactoryGirl.create :role
      
      @proj.privileges.create!({ :user => @user, :role => blank_role })
      @proj.tester?( @user ).should be_false
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
