require 'spec_helper'

describe UsersController do
  
  setup :activate_authlogic

  describe "#index" do
    context "when current_user is not a CodeFoundry admin" do
      it "should redirect to the login page" do
        get :index
        response.should redirect_to login_path
      end
    end
    
    context "when current_user is a CodeFoundry admin" do
      before :each do
        @mock_users = [mock_user, mock_user]
        admin_login
      end

      it "should get all Users and store in @users" do
        User.should_receive( :all ).and_return @mock_users
        get :index
        assigns[ :users ].should eq @mock_users
      end

      context "with html" do
        it "should render users#index" do
          get :index
          response.should render_template( "index" )
        end
      end

      context "with xml" do
        it "should render @users as xml" do
          get :index, :format => :xml
          response.content_type.should eq Mime::XML
        end
      end   
    end
  end

  describe "#show" do
    before :each do
      @mock_user = mock_user
    end

    it "should find user based on params[:id] and store it as @user" do
      User.should_receive( :by_param ).with( @mock_user.id ).and_return @mock_user
      get :show, :id => @mock_user.id
      assigns[ :user ].should eq @mock_user
    end

    context "with html" do
      it "should render users#show" do
        User.stub!( :by_param ).with( @mock_user.id ).and_return @mock_user
        get :show, :id => @mock_user.id
        response.should render_template( "show" )
      end
    end
    
    context "with xml" do
      it "should render the found user as xml" do
        User.stub!( :by_param ).with( @mock_user.id ).and_return @mock_user
        get :show, :id => @mock_user.id, :format => :xml
        response.content_type.should eq Mime::XML
      end
    end
  end

  describe "#new" do
    before :each do
      @mock_user = mock_user
    end
    
    it "should build an empty user and store it as @user" do
      User.should_receive( :new ).and_return @mock_user
      get :new
      assigns[ :user ].should eq @mock_user
    end
    
    context "with html" do
      it "should render users#new" do
        get :new
        response.should render_template( "new" )
      end
    end

    context "with xml" do
      it "should render the empty user as xml" do
        get :new, :format => :xml
        response.content_type.should eq Mime::XML
      end
    end
  end

  describe "#edit" do
    it "should find user based on params[:id] and store it as @user" do
      @mock_user = mock_user
      admin_login
      User.should_receive( :by_param ).with( @mock_user.id ).and_return @mock_user
      get :edit, :id => @mock_user.id
      assigns[ :user ].should eq @mock_user
    end
  end

  describe "#create" do
    before :each do
      @mock_user = mock_user
    end
    
    it "should create a new user based on params[:user] and assign it to @user" do
      User.should_receive( :new ).with( @mock_user.attributes ).and_return @mock_user
      post :create, :user => @mock_user.attributes
      assigns[ :user ].should eq @mock_user
    end

    context "after successfully saving the new user to the database" do
      before :each do
        User.stub!( :new ).with( @mock_user.attributes ).and_return @mock_user
        @mock_user.stub!( :save ).and_return true
      end
      
      context "with html" do
        before { post:create, :user => @mock_user.attributes }

        it "should redirect to @user" do
          response.should redirect_to user_path( @mock_user.id )
        end
        
        it "should set the flash message to /successfully created/" do
          flash[:notice].should =~ /successfully created/
        end
      end

      context "with xml" do
        before { post :create, :user => @mock_user.attributes, :format => :xml }
        
        it "should render the new user as xml" do
          response.content_type.should eq Mime::XML
        end

        it "should return status 201 (create)" do
          response.status.should eq 201
        end

        it "should set location to user_url(:id)" do
          response.location.should eq user_url(@mock_user.id)
        end
      end
    end

    context "after failing to save the new user to the database" do
      before :each do
        User.stub!( :new ).with( @mock_user.attributes ).and_return @mock_user
        @mock_user.stub!( :save ).and_return false
      end  
      
      context "with html" do
        it "should render users@new" do
          post :create, :user => @mock_user.attributes
          response.should render_template("new")
        end
      end

      context "with xml" do
        before { post :create, :user => @mock_user.attributes, :format => :xml }

        it "should render @user.errors as xml" do
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
      @mock_user = mock_user
      admin_login
    end

    it "should find user based on params[:id] and assign it to @user" do
      User.should_receive( :by_param ).with( @mock_user.id ).and_return @mock_user
      put :update, :id => @mock_user.id, :params => @mock_user.attributes
      assigns[ :user ].should eq @mock_user
    end

    context "after successfully updating the user in the database" do
      before :each do
        User.stub( :by_param ).with( @mock_user.id ).and_return @mock_user
        @mock_user.stub!( :update_attributes ).with( @mock_user.attributes ).and_return true
      end

      context "with html" do
        before { put :update, :id => @mock_user.id, :user => @mock_user.attributes }

        it "should redirect to @user" do
          response.should redirect_to user_path(@mock_user.id)
        end

        it "should set the flash message to /successfully updated/" do
          flash[:notice].should =~ /successfully updated/
        end
      end

      context "with xml" do
        before { put :update, :id => @mock_user.id, :user => @mock_user.attributes, :format => :xml }

        it "should return xml" do
          response.content_type.should eq Mime::XML
        end
        
        it "should return status 201 (create)" do
          response.status.should eq 200
        end
      end
    end

    context "after failing to update the user in the databases" do
      before :each do
        User.stub( :by_param ).with( @mock_user.id ).and_return @mock_user
        @mock_user.stub!( :update_attributes ).with( @mock_user.attributes ).and_return false
      end
      
      context "with html" do
        it "should render users@edit" do
          put :update, :id => @mock_user.id, :user => @mock_user.attributes
          response.should render_template("edit")
        end
      end

      context "with xml" do
        before { put :update, :id => @mock_user.id, :user => @mock_user.attributes, :format => :xml }

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
      @mock_user = mock_user
      admin_login
    end
    
    it "should find user based on params[:id] and assign it to @user" do
      User.should_receive( :by_param ).with( @mock_user.id ).and_return @mock_user
      delete :destroy, :id => @mock_user.id
      assigns[ :user ].should eq @mock_user
    end
    
    it "should destroy the found user by calling @user.destroy" do
      User.stub!( :by_param ).with( @mock_user.id ).and_return @mock_user
      @mock_user.should_receive( :destroy ).and_return true
      delete :destroy, :id => @mock_user.id
    end

    context "with html" do
      it "should redirect to users_url" do
        User.stub!( :by_param ).with( @mock_user.id ).and_return @mock_user
        delete :destroy, :id => @mock_user.id, :format => :html
        response.should redirect_to users_url
      end
    end
  
    context "with xml" do
      it "should return OK" do
        User.stub!( :by_param ).with( @mock_user.id ).and_return @mock_user
        delete :destroy, :id => @mock_user.id, :format => :xml
        response.should be_ok
      end
    end
  end
end

