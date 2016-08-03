class Vote < ActiveRecord::Base
  belongs_to :article
  belongs_to :voter,class_name: "User"
end