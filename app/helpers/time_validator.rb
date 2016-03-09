class TimeValidator < ActiveModel::Validator
  def validate(record)
    unless record.inTime.nil? or record.outTime.nil?
  		if record.outTime.to_time < record.inTime.to_time
    		record.errors.add(:base, 'The fundamental laws of nature prevent time travel')
    	end
    end
  end
end