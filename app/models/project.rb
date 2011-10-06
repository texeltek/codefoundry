class Project < ActiveRecord::Base
  has_many :repositories
  has_many :project_privileges
  has_many :users, :through => :project_privileges
  alias_method :privileges, :project_privileges
  
  default_scope order(:name)
  scope :by_param_scope, lambda { |param| where(:param => param)}
  scope :newest, lambda { with_exclusive_scope {order('created_at DESC')} }
  scope :by_hits, lambda { with_exclusive_scope {order('hits DESC')} }

  validates_presence_of :name
  validates_uniqueness_of :param
  before_save :save_param
  has_attached_file :avatar, :styles => { :thumb => "48x48>" },
    :default_url => "/images/project_:style.png",
    :default_style => :thumb,
    :url => "/projects/:attachment/:id/:style/:filename",
    :path => ":rails_root/public/projects/avatars/:id/:style/:filename"

  cattr_reader :per_page
  @@per_page = 30

  # Hack to make scope always return single item instead of array
  def self.by_param(param)
    by_param_scope(param).first
  end

  # for nice urls
  def to_param
    result = "#{self.name}"
    result.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
    result.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
    result.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
    result.mb_chars.downcase.to_s
  end

  def save_param
    self.param = to_param
  end

  # privilege management
  def add_user_privilege user, priv
    privileges.create!({ :user => user, :role => Role.find_by_name( priv )})
  end
  
  def remove_user_privilege user, priv
    privileges.find_by_user_id_and_role_id( user.id, Role.find_by_name( priv )).destroy
  end
 
  def add_administrator user
    add_user_privilege user, 'Administrator' 
  end
  
  def add_committer user
    add_user_privilege user, 'Committer' 
  end

  def add_reviewer user
    add_user_privilege user, 'Reviewer'
  end

  def add_tester user
    add_user_privilege user, 'Tester'
  end
  
  def remove_administrator user
    remove_user_privilege user, 'Administrator'
  end
  
  def remove_committer user
    remove_user_privilege user, 'Committer'
  end
  
  def remove_reviewer user
    remove_user_privilege user, 'Reviewer'
  end
  
  def remove_tester user
    remove_user_privilege user, 'Tester'
  end
  # end privilege management

  # is user an administrator (has all administrative privileges)?
  def administrator? arg
    editor? arg
  end

  # is user an editor (has all administrative privileges)?
  def editor? arg
    privileges.joins( :role ).where( :user_id => arg ).where( :roles => { :edit_project => true }).first ? true : false
  end
  
  # is user a committer (has commit and checkout privileges)?
  def committer? arg
    privileges.joins( :role ).where( :user_id => arg ).where( :roles => { :commit => true }).first ? true : false
  end
  
  # is user a committer (has checkout privileges only)?
  def reviewer? arg
    privileges.joins( :role ).where( :user_id => arg ).where( :roles => { :checkout => true }).first ? true : false
  end
  
  # is user a tester (has checkout privileges only, same as a reviewer)?
  def tester? arg
    reviewer? arg
  end
end
