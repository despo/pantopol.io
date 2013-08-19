class City < ActiveRecord::Base
  has_many :stores
  has_many :products, through: :stores
end
