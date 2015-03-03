class Team < ActiveRecord::Base
	has_many :users
  	validates :name, presence: true
  	acts_as_paranoid

end
