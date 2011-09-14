require 'spec_helper'

describe User do

  def full_user
    FactoryGirl.build(:full_user)
  end

  it { should have_many :repositories       }
  it { should have_many :project_privileges }

  it { should have_many( :projects ).through :project_privileges }

  describe "#full_name" do
    it "should return :first_name and :last_name separated by a space" do
      full_user.full_name.should eq 'john doe'
    end
  end

  describe "#to_param" do
    it "should return :username" do
      full_user.to_param.should eq 'john_doe'
    end
  end

  describe "#param" do
    it "should call #to_param" do
      full_user.param.should eq full_user.to_param
    end
  end
  
  describe "#by_param" do
    it "should find the User by its username" do
      u2 = full_user
      u2.username = 'user2'
      u2.email = 'user2@spec.com'
      u2.save!

      User.by_param( u2.username ).email.should eq 'user2@spec.com'
    end
  end

end
