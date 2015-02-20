class UserProject < ActiveRecord::Base
  #validates :user, :project, presence: true
  belongs_to :user
  belongs_to :project
end
