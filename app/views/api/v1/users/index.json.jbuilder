json.users @users do |u|
	json.first_name		u.first_name
	json.last_name		u.last_name
	json.qr_code		u.qr_code
	json.pin_code		u.pin_code
end