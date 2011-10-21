module RepositoriesHelper
  def git_path repository
    "git/#{ repository.project.name }/#{ repository.to_param }.git"
  end
  
  def git_url repository
    root_url + "/#{ git_path repository }"
  end
  
  def branch_names repository
    repository.branches.collect { |t| t.name }
  end
end