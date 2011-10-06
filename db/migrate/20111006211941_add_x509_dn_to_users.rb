class AddX509DnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :x509_dn, :string
  end

  def self.down
    remove_column :users, :x509_dn
  end
end
