class User < ActiveRecord::Base
	has_many :linked_account
end
