class AddCodeFoundryAdminToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :codefoundry_admin, :boolean, :default => false
  end

  def self.down
    remove_column :users, :codefoundry_admin
  end
end
