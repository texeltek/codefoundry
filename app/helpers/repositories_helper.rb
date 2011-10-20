module RepositoriesHelper
  def git_path repository
    "git/#{ repository.project.name }/#{ repository.to_param }.git"
  end
  
  def git_url repository, https, host
    protocol = "http"
    protocol = "https" if https == "on"
    
    "#{ protocol }://#{ host }/#{ git_path repository }"
  end
end