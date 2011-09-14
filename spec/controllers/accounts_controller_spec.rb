require 'spec_helper'

describe AccountsController do
  
  before :each do
    activate_authlogic
  end
  
  describe "#show" do
    it "should set @account to the current_user" do
      logged_in_user = FactoryGirl.build(:full_user)
      logged_in_user.username = 'blarg'
      UserSession.create(logged_in_user)
      get :show
      assigns[:account].username.should eq 'blarg'
    end

    context "when format is" do
      before :each do
        logged_in_user = FactoryGirl.build(:full_user)
        UserSession.create(logged_in_user)
      end
      
      it "xml should return xml" do
        get :show, :format => :xml
        response.headers['Content-Type'].should =~ /application\/xml/
      end

      it "html should render accounts/show" do
        get :show
        response.should render_template "show"
      end
    end
  end

  describe "#edit" do
    before :each do
      edit_user = FactoryGirl.build(:full_user)
      edit_user.username = 'editable user'
      UserSession.create(edit_user)
      get :edit
    end

    it "should set @account to the current_user" do
      assigns[:account].username.should eq 'editable user'
    end

    it "should render the accounts/edit" do
      response.should render_template "edit"
    end
  end

  describe "#update" do
    before :each do
      @account = FactoryGirl.build :user
      UserSession.create( @account )
      @mock_account = mock_account
    end

    it "should assign current_user to @account" do
      put :update, :account => @mock_account.attributes
      assigns[ :account ].should eq @account
    end
    
    context "given @account is successfully updated" do
      before :each do
        @account.stub!( :update_attributes ).with( @mock_account.attributes ).and_return true
      end
      
      context "with html" do
        before :each do
          put :update, :account => @mock_account.attributes 
        end

        it "should redirect to account_path" do
          response.should redirect_to account_path
        end

        it "should set a flash notice like 'successfully updated'" do
          flash[:notice].should =~ /successfully updated/
        end
      end

      context "with xml" do
        before :each do
          put :update, :account => @mock_account.attributes, :format => :xml 
        end

        it "should return xml" do
          response.content_type.should eq Mime::XML
        end
        it "should return 200 OK" do
          response.should be_ok
        end
      end
    end
  end

end
