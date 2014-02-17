class AddCardTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :card_token, :string

    User.all.each do |user|
      user.card_token = SecureRandom.uuid.gsub!('-', '')
      user.save
    end
  end

  def self.down
    remove_column :users, :card_token
  end
end
