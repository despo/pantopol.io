class Store < ActiveRecord::Base
  belongs_to :city

  has_many :products
end
