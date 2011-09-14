# Define a set of factories that will create
# objects with the minimum required fields set
# to pass validations

FactoryGirl.define do
  
  factory :user do
    username "john_doe"
    email "john_doe@codefoundry.com"
    password "john pw"
    password_confirmation "john pw"

    factory :full_user do
      first_name "john"
      last_name "doe"
      time_zone "UTC"
    end
  end

  factory :project do
    name "sample-project"

    factory :full_project do
      summary "full sample project"
      description "this is a fully-defined sample project"
      hits 99
      avatar_file_name "sample-proj.jpg"
      avatar_content_type "image/jpeg"
      avatar_file_size 1024
      avatar_updated_at "2011-01-01"
    end
  end

  factory :project_privilege do
    user
    project
    role
  end

  factory :role do
    name 'user'

    factory :admin_role do
      edit_project true
      add_others true
      create_delete_repositories true
      commit true
      checkout true
    end

    factory :read_only_role do
      edit_project false
      add_others false
      create_delete_repositories false
      commit false
      checkout true
    end

    factory :editor do
      edit_project true
      add_others false
      create_delete_repositories false
      commit false
      checkout true
    end
  end

  factory :repository do
    name 'baseline'

    factory :full_repository do
      path '/baseline'
      user
      project
      size 1000
      scm 1
      summary 'baseline repo'
    end
  end

end
