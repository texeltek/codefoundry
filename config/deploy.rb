set :application, "codefoundry"
set :repository,  "git://github.com/texeltek/codefoundry.git"
set :scm, :git
set :branch, "dev/capistrano"

set :rails_env, "production"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "acurry"

set :use_sudo, true

set :codefoundry_home, "/var/www/vhosts/codefoundry"

set :deploy_to, "#{codefoundry_home}/deployment"

role :web, "192.168.20.33"                          # Your HTTP server, Apache/etc
role :app, "192.168.20.33"                          # This may be the same as your `Web` server
role :db,  "192.168.20.33", :primary => true # This is where Rails migrations will run

# enable tty in the shell
default_run_options[:pty] = true

set :shared_database_path, "#{codefoundry_home}/db"
set :shared_config_path, "#{codefoundry_home}/config"

namespace :shared do
  desc "Create shared config directory"
  task :mk_shared_dirs, :roles => :app do
    run "sudo mkdir -p #{shared_config_path}"
    run "sudo mkdir -p #{shared_database_path}"
    # run "sudo chown -R #{user}.#{user} #{shared_config_path}"
    # run "sudo chown -R #{user}.#{user} #{shared_database_path}"
  end
end

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
    run "cp #{shared_config_path}/sqlite_config.yml #{release_path}/config/database.yml"
  end
 
  desc "Make a shared database folder"
  task :make_shared_folder, :roles => :db do
    run "mkdir -p -m 775 #{shared_database_path}"
    # run "sudo chown -R #{user}.#{user} #{shared_database_path}"
  end
end

namespace :deps do
  desc "Install gems from Gemfile"
  task :bundle_install, :roles => [:app, :web] do
    run "bundle install"
  end
end

after "deploy:setup", "sqlite3:make_shared_folder"
after "deploy:setup", "sqlite3:build_configuration"

before "deploy:migrate", "sqlite3:link_configuration_file"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end