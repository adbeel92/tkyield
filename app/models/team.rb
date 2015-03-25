class Team < ActiveRecord::Base
	has_many :users , dependent: :nullify
  	validates :name, presence: true
  	acts_as_paranoid

end
