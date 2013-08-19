class Store < ActiveRecord::Base
  belongs_to :city

  has_many :products

  def display_name
    self.name or self.identifier_string
  end
end
