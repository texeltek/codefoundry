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
  
  def pretty_hash( hash, length=7 )
    hash.to_s[0,length]
  end
  
  # extracts the last part of the path
  # e.g. repository_sub_path("projects/projname/repositories/reponame/commits") = "commits"
  def repository_sub_path( path )
    Regexp.new(/\w+$/).match(path).to_s
  end
end