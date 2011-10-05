module RepositoriesHelper
  def git_path repository
    return "git/#{repository.project.name}/#{repository.name}.git"
  end
end
