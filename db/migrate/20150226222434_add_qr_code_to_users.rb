class AddQrCodeToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :qr_code, :integer
  	add_column :users, :pin_code, :integer
  end
end
