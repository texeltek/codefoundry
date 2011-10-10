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
        :git_path => Settings.git_app_config.git_path,
        :upload_pack => true,
        :receive_pack => true
      }

    @git_provider = GitHttp::App.new
    @git_provider.set_config( @config )
  end

  def call( env )

    # if the request is for a git repository (name.git), then send the request to
    # the git handler
    short_match = GIT_SHORTCUT_RE.match env['PATH_INFO'] 
    long_match = MATCH_RE.match env['PATH_INFO'] 

    m = short_match if short_match
    m = long_match if long_match

    if m

      # look for the user, project and repository in CF
      user = User.find_by_x509_dn    env['SSL_CLIENT_S_DN']
      proj = Project.find_by_name    m[1]
      repo = Repository.find_by_name m[2]
      
      r_action = GIT_READ_RE.match  env['QUERY_STRING'] 
      w_action = GIT_WRITE_RE.match env['QUERY_STRING']
      
      if !user
        Rails.logger.error "User #{m[1]} not found in CodeFoundry"
        return [401, PLAIN_TYPE, [""]]

      elsif !proj
        Rails.logger.error "Project #{m[1]} not found in CodeFoundry"
        return [404, PLAIN_TYPE, [""]]

      elsif !repo
        Rails.logger.error "Repository #{m[2]} not found in project #{m[1]}"
        return [404, PLAIN_TYPE, [""]]

      elsif !proj.users.include? user
        Rails.logger.error "User #{user.username} does not have access to project #{m[1]}"
        return [403, PLAIN_TYPE, [""]]

      elsif w_action && !proj.committer?(user)
        Rails.logger.error "User #{user.username} does not have write access to project #{m[1]}"
        return [403, PLAIN_TYPE, [""]]

      else
        # remove the prefix
        env['PATH_INFO'] = "/git/#{m[1]}/#{m[2]}.git#{m[3]}"
        @git_provider.call( env )
      end
    else
      @app.call( env )
    end
  end
end
