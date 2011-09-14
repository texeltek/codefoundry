require 'spec_helper'

describe ProjectsController do
  describe "#index" do
    it "should call paginate on Project and pass in params[:page]" do
      Project.should_receive(:paginate).with(:page => 10)
      get :index, :page => 10
    end
    
    it "should render index" do
      Project.stub!(:paginate)
      get :index, :page => 10
      response.should render_template :index
    end
    
    it "should render @projects as xml" do
      Project.stub!(:paginate).and_return []
      get :index, :format => :xml
      response.headers['Content-Type'].should =~ /application\/xml/
    end
  end

  describe "#show" do
    it "should call by_param on Project and pass in params[:id]" do
      Project.should_receive(:by_param).with(111).and_return Project.new
      get :show, :id => 111
    end
    context "given a Project exists with :id" do
      before :each do
        @project = mock_model(Project)
        Project.stub!(:by_param).with(222).and_return @project
      end
      
      it "should increment project's :hits" do
        @project.should_receive(:increment!).with(:hits).and_return nil
        get :show, :id => 222
      end

      it "should render show" do
        @project.stub!(:increment!)
        get :show, :id => 222
        response.should render_template :show
      end

      it "should render @project as xml" do
        @project.stub!(:increment!)
        get :show, :id => 222, :format => :xml
        response.headers["Content-Type"].should =~ /application\/xml/
      end
    end
  end

  describe "#new" do
    it "should make a new empty Project" do
      Project.should_receive(:new).and_return Project.new
      get :new
    end

    it "should assign a new empty Project to @project" do
      Project.stub!(:new).and_return Project.new
      get :new
      assigns[:project].should eq Project.new
    end

    it "should render the new Project form" do
      activate_authlogic
      UserSession.create(FactoryGirl.build(:user))
      Project.stub!(:new).and_return Project.new
      get :new
      response.should render_template :new
    end
  end

  describe "#edit" do
    before :each do
      activate_authlogic
      UserSession.create(FactoryGirl.build(:user))
    end

    it "should call by_param on Project and pass in params[:id]" do
      Project.should_receive(:by_param).with(111).and_return Project.new
      get :edit, :id => 111
    end
    
    context "given a Project exists with :id" do
      it "should assign the found Project to @project" do
        editable_proj = mock_project
        Project.stub!(:by_param).with(111).and_return editable_proj
        get :edit, :id => 111
        assigns[:project].should eq editable_proj
      end

      it "should render the Project edit form" do
        Project.stub!(:by_param).with(111).and_return Project.new
        get :edit, :id => 111
        response.should render_template :edit
      end
    end
  end

  describe "#create" do
    before :each do
      activate_authlogic
      @create_user = FactoryGirl.build :user 
      UserSession.create @create_user 
      @project = mock_project
    end

    it "should build a new Project based on the project hash" do
      Project.should_receive( :new ).with( @project.attributes ).and_return @project
      post :create, :project => @project.attributes
      @project.stub!( :save ).and_return false
    end

    it "should assign the newly built Project to @project" do
      Project .should_receive( :new )
              .with( @project.attributes )
              .and_return( @project )
      
      post :create, :project => @project.attributes
      assigns[ :project ].should eq @project
    end

    context "after saving the project to the database" do
      before :each do
        Project.stub!( :new ).with( @project.attributes ).and_return @project 
        @project.stub!( :save ).and_return true
      end

      it "should call add_administrator on @project and pass in current_user" do
        @project.should_receive!( :add_administrator ).with @create_user 
      end
      
      context "with html" do
        before :each do
          post :create, :project => @project.attributes
          assigns[ :project ] = @project
        end
        
        it "should redirect_to @project" do
          response.should redirect_to @project
        end
        
        it "should set the flash to /successfully created/" do
          flash[ :notice ].should =~ /successfully created/
        end
      end
      
      context "with xml" do
        before :each do
          post :create, :project => @project.attributes, :format => :xml
          assigns[ :project ] = @project
        end
        
        it "should return xml" do
          response.content_type.should eq Mime::XML
        end
        
        it "should return status 201 (created)" do
          response.status.should eq 201
        end

        it "should go to @project" do
          response.location.should eq project_url(@project.id)
        end
      end
    end

    context "after failing to save the project to the database" do
      before :each do
        Project.stub!( :new ).with( @project.attributes ).and_return @project
        @project.stub!( :save ).and_return false
      end

      context "with html" do
        it "should redirect_to the new Project form" do
          post :create, :project => @project.attributes
          response.should render_template("new")
        end
      end
      
      context "with xml" do
        before :each do
          post :create, :project => @project.attributes, :format => :xml
        end
        
        it "should return xml" do
          response.content_type.should eq Mime::XML
        end

        it "should return status 422 (unprocessable_entity)" do
          response.status.should eq 422
        end
      end
    end
  end

  describe "#update" do
    before :each do
      activate_authlogic
      @create_user = FactoryGirl.build :user 
      UserSession.create @create_user 
      @project = mock_project
    end

    it "should call by_param on Project and find the project with the specified id" do
      Project.should_receive( :by_param ).with( @project.id ).and_return @project
      post :update, :id => @project.id
      @project.stub!( :save ).and_return false
    end

    it "should update the found project with params[:project]" do
      Project .should_receive( :by_param )
              .with( @project.id )
              .and_return( @project )
      
      post :update, :id => @project.id
      assigns[ :project ].should eq @project
    end

    context "after saving the updated project to the database" do
      before :each do
        Project.stub!( :by_param ).with( @project.id ).and_return @project 
      end
      
      context "with html" do
        before :each do
          @project.stub!( :update_attributes ).and_return true
          post :update, :id => @project.id, :project => @project
          assigns[ :project ] = @project  
        end
        
        it "should redirect_to @project" do
          response.should redirect_to @project
        end
        
        it "should set the flash to /successfully created/" do
          flash[ :notice ].should =~ /successfully updated/
        end
      end

      context "with xml" do
        it "should return OK response" do
          post :update, :id => @project.id, :project => @project, :format => :xml
          assigns[ :project ] = @project
          response.should be_ok
        end
      end
    end

    context "after failing to save the project to the database" do
      before :each do
        Project.stub!( :by_param ).with( @project.id ).and_return @project
        @project.stub!( :update_attributes ).and_return false
      end

      context "with html" do
        it "should redirect_to the edit Project form" do
          post :update, :id => @project.id, :project => @project
          assigns[ :project ] = @project
          response.should render_template("edit")
        end                                             
      end

      context "with xml" do
        before :each do
          post :update, :id => @project.id, :project => @project, :format => :xml
          assigns[ :project ] = @project
        end
        
        it "should return xml" do
          response.content_type.should eq Mime::XML
        end

        it "should return status 422 (unprocessable_entity)" do
          response.status.should eq 422
        end
      end
    end                               
  end

  describe "#destroy" do
    before :each do
      @project = mock_project
    end

    it "should call by_param on Project and find the project with the specified id" do
      Project.should_receive( :by_param ).with( @project.id ).and_return @project
      delete :destroy, :id => @project.id
    end
    
    context "when project is found" do
      before :each do
        Project.stub!( :by_param ).with( @project.id ).and_return @project
      end

      it "should destroy the found project" do
        @project.should_receive( :destroy )
        delete :destroy, :id => @project.id
      end
      
      it "should redirect_to projects_url" do
        delete :destroy, :id => @project.id
        response.should redirect_to projects_url
      end
    end
  end
end
