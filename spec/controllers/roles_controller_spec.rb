require 'spec_helper'

describe RolesController do
  describe "#index" do
    before :each do
      @mock_roles = [mock_role, mock_role]
    end

    it "should get all Roles and store in @roles" do
      Role.should_receive( :all ).and_return @mock_roles
      get :index
      assigns[ :roles ].should eq @mock_roles
    end

    context "with html" do
      it "should render roles#index" do
        get :index
        response.should render_template( "index" )
      end
    end

    context "with xml" do
      it "should render @roles as xml" do
        get :index, :format => :xml
        response.content_type.should eq Mime::XML
      end
    end
  end

  describe "#show" do
    before :each do
      @mock_role = mock_role
    end

    it "should find role based on params[:id] and store it as @role" do
      Role.should_receive( :find ).with( @mock_role.id ).and_return @mock_role
      get :show, :id => @mock_role.id
      assigns[ :role ].should eq @mock_role
    end

    context "with html" do
      it "should render roles#show" do
        Role.stub!( :find ).with( @mock_role.id ).and_return @mock_role
        get :show, :id => @mock_role.id
        response.should render_template( "show" )
      end
    end
    
    context "with xml" do
      it "should render the found role as xml" do
        get :show, :id => @mock_role.id, :format => :xml
        response.content_type.should eq Mime::XML
      end
    end
  end

  describe "#new" do
    before :each do
      activate_authlogic
      UserSession.create(FactoryGirl.build( :user ))
      @mock_role = mock_role
    end
    
    it "should build an empty role and store it as @role" do
      Role.should_receive( :new ).and_return @mock_role
      get :new
      assigns[ :role ].should eq @mock_role
    end
    
    context "with html" do
      it "should render roles#new" do
        get :new
        response.should render_template( "new" )
      end
    end

    context "with xml" do
      it "should render the empty role as xml" do
        get :new, :format => :xml
        response.content_type.should eq Mime::XML
      end
    end
  end

  describe "#edit" do
    it "should find role based on params[:id] and store it as @role" do
      activate_authlogic
      UserSession.create(FactoryGirl.build( :user ))
      @mock_role = mock_role
      Role.should_receive( :find ).with( @mock_role.id ).and_return @mock_role
      get :edit, :id => @mock_role.id
      assigns[ :role ].should eq @mock_role
    end
  end

  describe "#create" do
    before :each do
      activate_authlogic
      UserSession.create(FactoryGirl.build( :user ))
      @mock_role = mock_role
    end
    
    it "should create a new role based on params[:role] and assign it to @role" do
      Role.should_receive( :new ).with( @mock_role.attributes ).and_return @mock_role
      post :create, :role => @mock_role.attributes
      assigns[ :role ].should eq @mock_role
    end

    context "after successfully saving the new role to the database" do
      before :each do
        Role.stub!( :new ).with( @mock_role.attributes ).and_return @mock_role
        @mock_role.stub!( :save ).and_return true
      end
      
      context "with html" do
        before { post:create, :role => @mock_role.attributes }

        it "should redirect to @role" do
          response.should redirect_to role_path( @mock_role.id )
        end
        
        it "should set the flash message to /successfully created/" do
          flash[:notice].should =~ /successfully created/
        end
      end

      context "with xml" do
        before { post :create, :role => @mock_role.attributes, :format => :xml }
        
        it "should render the new role as xml" do
          response.content_type.should eq Mime::XML
        end

        it "should return status 201 (create)" do
          response.status.should eq 201
        end

        it "should set location to role_url(:id)" do
          response.location.should eq role_url(@mock_role.id)
        end
      end
    end

    context "after failing to save the new role to the database" do
      before :each do
        Role.stub!( :new ).with( @mock_role.attributes ).and_return @mock_role
        @mock_role.stub!( :save ).and_return false
      end  
      
      context "with html" do
        it "should render roles@new" do
          post :create, :role => @mock_role.attributes
          response.should render_template("new")
        end
      end

      context "with xml" do
        before { post :create, :role => @mock_role.attributes, :format => :xml }

        it "should render @role.errors as xml" do
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
      UserSession.create(FactoryGirl.build( :user ))
      @mock_role = mock_role
    end

    it "should find role based on params[:id] and assign it to @role" do
      Role.should_receive( :find ).with( @mock_role.id ).and_return @mock_role
      put :update, :id => @mock_role.id, :params => @mock_role.attributes
      assigns[ :role ].should eq @mock_role
    end

    context "after successfully updating the role in the database" do
      before :each do
        Role.stub( :find ).with( @mock_role.id ).and_return @mock_role
        @mock_role.stub!( :update_attributes ).with( @mock_role.attributes ).and_return true
      end

      context "with html" do
        before { put :update, :id => @mock_role.id, :role => @mock_role.attributes }

        it "should redirect to @role" do
          response.should redirect_to role_path(@mock_role.id)
        end

        it "should set the flash message to /successfully updated/" do
          flash[:notice].should =~ /successfully updated/
        end
      end

      context "with xml" do
        before { put :update, :id => @mock_role.id, :role => @mock_role.attributes, :format => :xml }

        it "should return xml" do
          response.content_type.should eq Mime::XML
        end
        
        it "should return status 201 (create)" do
          response.status.should eq 200
        end
      end
    end

    context "after failing to update the role in the databases" do
      before :each do
        Role.stub( :find ).with( @mock_role.id ).and_return @mock_role
        @mock_role.stub!( :update_attributes ).with( @mock_role.attributes ).and_return false
      end
      
      context "with html" do
        it "should render roles@edit" do
          put :update, :id => @mock_role.id, :role => @mock_role.attributes
          response.should render_template("edit")
        end
      end

      context "with xml" do
        before { put :update, :id => @mock_role.id, :role => @mock_role.attributes, :format => :xml }

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
    before { @mock_role = mock_role }

    it "should find role based on params[:id] and assign it to @role" do
      Role.should_receive( :find ).with( @mock_role.id ).and_return @mock_role
      delete :destroy, :id => @mock_role.id
      assigns[ :role ].should eq @mock_role
    end
    
    it "should destroy the found role by calling @role.destroy" do
      Role.stub!( :find ).with( @mock_role.id ).and_return @mock_role
      @mock_role.should_receive( :destroy ).and_return true
      delete :destroy, :id => @mock_role.id
    end

    context "with html" do
      it "should redirect to roles_url" do
        Role.stub!( :find ).with( @mock_role.id ).and_return @mock_role
        delete :destroy, :id => @mock_role.id, :format => :html
        response.should redirect_to roles_url
      end
    end
  
    context "with xml" do
      it "should return OK" do
        delete :destroy, :id => @mock_role.id, :format => :xml
        response.should be_ok
      end
    end
  end
end
