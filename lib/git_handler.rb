class GitHandler
  MATCH_RE        = Regexp.new('^/projects/(\\w+)/repositories/(\\w+)\.git(/.*)')
  GIT_SHORTCUT_RE = Regexp.new('^/git/(\\w+)/(\\w+)\.git(/.*)')
  GIT_READ_RE     = Regexp.new('git-upload-pack')  # git clone, git fetch, git pull
  GIT_WRITE_RE    = Regexp.new('git-receive-pack') # git push

  PLAIN_TYPE = {"Content-Type" => "text/plain"}

  def initialize( app )
    @logger = ActiveRecord::Base.logger

    @app = app

    @config = {
        :project_root => Settings.repository_base_path,
        :git_path => Settings.git.path,
        :upload_pack => Settings.git.upload_pack,
        :receive_pack => Settings.git.receive_pack
      }

    @git_provider = GitHttp::App.new
    @git_provider.set_config( @config )
  end

  def call( env )

    # if the request is for a git repository (name.git), then send the request to
    # the git handler
    short_match = GIT_SHORTCUT_RE.match env['PATH_INFO'] 
    long_match = MATCH_RE.match env['PATH_INFO'] 

    path = short_match if short_match
    path = long_match if long_match

    if path

      # anybody with a valid cert and key can clone any repository of any project if true
      git_global_readonly_enabled = Settings.git.global_readonly_enabled || false

      # look for the user, project and repository in CF
      user = User.find_by_x509_dn    env['SSL_CLIENT_S_DN']
      proj = Project.by_param        path[1]
      repo = Repository.by_param     path[2]
      
      r_action = GIT_READ_RE.match  env['QUERY_STRING'] 
      w_action = GIT_WRITE_RE.match env['QUERY_STRING']
      
      if !user
        Rails.logger.error "User #{path[1]} not found in CodeFoundry"
        return [401, PLAIN_TYPE, [""]]

      elsif !proj
        Rails.logger.error "Project #{path[1]} not found in CodeFoundry"
        return [404, PLAIN_TYPE, [""]]

      elsif !repo
        Rails.logger.error "Repository #{path[2]} not found in project #{path[1]}"
        return [404, PLAIN_TYPE, [""]]
      
      elsif !proj.users.include?(user) && !git_global_readonly_enabled 
        Rails.logger.error "User #{user.username} does not have access to project #{path[1]}"
        Rails.logger.error "git_global_readonly_enabled is set to #{git_global_readonly_enabled}" 
        return [403, PLAIN_TYPE, [""]]

      elsif w_action && !proj.committer?(user)
        Rails.logger.error "User #{user.username} does not have write access to project #{path[1]}"
        return [403, PLAIN_TYPE, [""]]
        
      else
        # remove the prefix
        env['PATH_INFO'] = "/git/#{path[1]}/#{path[2]}.git#{path[3]}"
        @git_provider.call( env )
      end
    else
      @app.call( env )
    end
  end
end
