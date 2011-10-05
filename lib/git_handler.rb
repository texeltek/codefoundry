class GitHandler
  MATCH_RE = Regexp.new('^/projects/(\\w+)/repositories/(\\w+)\.git(/.*)')

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
    # Rails.logger.debug "before match, env['PATH_INFO'] = #{env['PATH_INFO']}"
    if m = MATCH_RE.match( env['PATH_INFO'] )
      
      # spit out GIT_SSL_CERT
      # Rails.logger.debug "we have a git request"
      # Rails.logger.debug "ssl server DN = #{ENV['SSL_SERVER_S_DN']}"
      # Rails.logger.debug "ssl client DN = #{ENV['SSL_CLIENT_S_DN']}" 
      # Rails.logger.debug "script url    = #{ENV['SCRIPT_URL']}"
      
      # remove the prefix
      env['PATH_INFO'] = "/git/#{m[1]}/#{m[2]}.git#{m[3]}"
      
      # Rails.logger.debug "git env['PATH_INFO'] = #{env['PATH_INFO']}"
      @git_provider.call( env )
    else
      @app.call( env )
    end
  end
end
