class Product < ActiveRecord::Base
  belongs_to :store

  validates :name, :presence => true
  validates :unit, :presence => true
  validates :store_id, :presence => true

  validates :name, :uniqueness => {:scope =>  [ :store_id, :date] }
end
