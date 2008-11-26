class AddOutcomesSetting < ActiveRecord::Migration
  def self.up
      add_column( :course_settings, :enable_outcomes, :boolean, :null => false, :default => false )
    end

    def self.down
      remove_column( :course_settings, :enable_outcomes )
  end
end
