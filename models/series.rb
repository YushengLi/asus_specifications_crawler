class Series < ActiveRecord::Base
  belongs_to :group
  has_one    :specifications
end
