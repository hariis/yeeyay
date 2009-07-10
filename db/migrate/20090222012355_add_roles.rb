require "migration_helpers"
class AddRoles < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
        create_table :roles,:force => true do |t|
            t.string :name
        end
        
        Role.create :name => "admin"
        Role.create :name => "private_beta_tester"
        Role.create :name => "public_beta_tester"
        Role.create :name => "member"     
  end

  def self.down
  end
end
