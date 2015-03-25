class AddNotesAndBelongsToTimesheet < ActiveRecord::Migration

	def self.up
		add_column :timesheets, :notes , :string 
		add_column :timesheets, :belongs_to_day , :datetime 
	end

	def self.down    
    remove_column :timesheets, :notes
	  remove_column :timesheets, :belongs_to_day
	end

end	
