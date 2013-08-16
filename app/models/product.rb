class Product < ActiveRecord::Base
  belongs_to :store

  validates :name, :presence => true
  validates :unit, :presence => true
end
