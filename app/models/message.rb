class Message < ActiveRecord::Base
  has_one :conversation
  has_one :sender,through: :conversation
  has_one :receiver,through: :conversation
end
