# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'authlogic/test_case'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

module MockHelpers
  def mock_project( stubs={} )
    mock_model( Project, stubs ).as_null_object
  end

  def mock_user( stubs={} )
    mock_model( User, stubs ).as_null_object
  end
  
  def mock_role( stubs={} )
    mock_model( Role, stubs ).as_null_object
  end

  def mock_account( stubs={} )
    mock_user( stubs )
  end
end

module AuthlogicHelpers
  def current_user( stubs={} )
    @current_user ||= mock_model( User, stubs )
  end

  def user_session( stubs={}, user_stubs={} )
    @current_user_session || mock_model( UserSession, { :user => current_user(user_stubs) }.merge(stubs) )
  end

  def user_login( session_stubs = {}, user_stubs={} )
    UserSession.create(FactoryGirl.build(:user))
  end
  
  def admin_login
    UserSession.create(FactoryGirl.build(:admin_user))
  end

  def logout
    @user_session = nil
  end
end

RSpec.configure do |config|
  include Authlogic::TestCase
  
  config.include( MockHelpers )
  config.include( AuthlogicHelpers )

  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

