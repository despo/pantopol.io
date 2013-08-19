class Product < ActiveRecord::Base
  belongs_to :store
  has_one :city, through: :store

  validates :name, :presence => true
  validates :unit, :presence => true
  validates :store_id, :presence => true

  validates :name, :uniqueness => {:scope =>  [ :store_id, :date] }

  def select_stores_by_price order="ASC", latest_date=false
    search_params =  { name: self.name }
    search_params.merge! date: latest_date if latest_date
    Product.select("date, id, price, store_id").group("id").where(search_params).group("store_id").order("price #{order}")
  end

  def average_price date=latest_date
    Product.where(search_conditions(latest_date)).average(:price)
  end

  def lowest_price date=latest_date
    Product.where(search_conditions(latest_date)).minimum(:price)
  end

  def highest_price date=latest_date
    Product.where(search_conditions(latest_date)).maximum(:price)
  end

  def latest_date
    Product.order("date desc").limit(2).pluck(:date).first
  end

  private
  def search_conditions(date)
    search_conditions = { :name => self.name }
    search_conditions.merge! :date => date unless date.nil?
  end

end
