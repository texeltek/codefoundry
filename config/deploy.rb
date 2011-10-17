# main capistrano settings
set :application, "codefoundry"
set :codefoundry_home, "/var/www/vhosts/codefoundry"
set :deploy_to, "#{codefoundry_home}/deployment"
role :web, "192.168.20.33"                          # Your HTTP server, Apache/etc
role :app, "192.168.20.33"                          # This may be the same as your `Web` server
role :db,  "192.168.20.33", :primary => true # This is where Rails migrations will run

# system settings
set :user, "acurry"
set :use_sudo, true
default_run_options[:pty] = true     # enable tty in the shell
default_run_options[:shell] = 'bash' # use bash

# git settings
set :repository,  "git://github.com/texeltek/codefoundry.git"
set :scm, :git
set :branch, "dev/capistrano"

# rails and RVM extensions
set :rails_env, "production"
set :rvm_ruby, "ruby-1.9.2-p290"
set :rvm_gem_home, "/usr/local/rvm/gems/#{fetch(:rvm_ruby)}"
set :rvm_ruby_path, "/usr/local/rvm/rubies/#{fetch(:rvm_ruby)}"
set :rake, "/usr/local/rvm/bin/rake"
set :default_environment, {
  'RUBY_VERSION' => "#{fetch(:rvm_ruby)}",
  'GEM_HOME' => "#{fetch(:rvm_gem_home)}:#{fetch(:rvm_gem_home)}@global",
  'BUNDLE_PATH' => "#{fetch(:rvm_gem_home)}",
  'PATH' => "#{fetch(:rvm_gem_home)}/bin:#{fetch(:rvm_gem_home)}@global/bin:#{fetch(:rvm_ruby_path)}/bin:/home/rails/.rvm/bin:$PATH",
}

# shared directories
set :shared_database_path, "#{codefoundry_home}/db"
set :shared_config_path, "#{codefoundry_home}/config"

namespace :shared do
  desc "Create shared config directory"
  task :mk_shared_dirs, :roles => :app do
    run "sudo mkdir -p #{shared_config_path}"
    run "sudo mkdir -p #{shared_database_path}"
  end
end

# sqlite3 setup
namespace :sqlite3 do
  desc "Generate a database configuration file"
  task :build_configuration, :roles => :db do
    db_options = {
      "adapter"  => "sqlite3",
      "database" => "#{shared_database_path}/production.sqlite3"
    }
    config_options = {"production" => db_options}.to_yaml
    put config_options, "#{shared_config_path}/sqlite_config.yml"
  end

  desc "Links the configuration file"
  task :link_configuration_file, :roles => :db do
    run "ln -nsf #{shared_config_path}/sqlite_config.yml #{release_path}/config/database.yml"
  end

  desc "Make a shared database folder"
  task :make_shared_folder, :roles => :db do
    run "mkdir -p -m 775 #{shared_database_path}"
  end
end

# config/settings.yml
namespace :codefoundry do
  desc "Copy settings.yml.sample to settings.yml"
  task :settings, :roles => :app do
    run "ln -nsf #{shared_config_path}/settings.yml #{release_path}/config/settings.yml"
  end
end

# post deploy hooks
after "deploy:setup", "sqlite3:make_shared_folder"
after "deploy:setup", "sqlite3:build_configuration"

after "deploy", "codefoundry:settings"
after "deploy", "sqlite3:link_configuration_file"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end