set :application, "codefoundry"
set :repository,  "git://github.com/texeltek/codefoundry.git"
set :scm, :git

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, "vagrant"
set :password, "vagrant"

set :codefoundry_home, "/var/www/vhosts/codefoundry"

set :deploy_to, "#{codefoundry_home}/current"

role :web, "127.0.0.1"                          # Your HTTP server, Apache/etc
role :app, "127.0.0.1"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run

set :shared_database_path, "#{codefoundry_home}/db"

namespace :sqlite3 do
  desc "Generate a database configuration file"
  task :build_configuration, :roles => :db do
    db_options = {
      "adapter"  => "sqlite3",
      "database" => "#{shared_database_path}/development.sqlite3"
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
    run "mkdir -p #{shared_database_path}"
  end
end

after "deploy:setup", "sqlite3:make_shared_folder"
after "deploy:setup", "sqlite3:build_configuration"
 
before "deploy:migrate", "sqlite3:link_configuration_file"


# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end