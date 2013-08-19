module DashboardHelper
  def latest_most_expensive_city
    Store.joins(:city).group("cities.name").joins(:products).order("average_price DESC").average(:price).first
  end

  def most_expensive_city
    Store.joins(:city).group("cities.name").joins(:products).where("products.date =?", latest_import_date).order("average_price DESC").average(:price).first
  end

  def latest_import_date
    @latest_import_date ||= Product.order("date DESC").pluck(:date).uniq![0]
  end

  def latest_cheapest_city
    Store.joins(:city).group("cities.name").joins(:products).order("average_price ASC").average(:price).first
  end

  def cheapest_city
    Store.joins(:city).group("cities.name").joins(:products).where("products.date =?", latest_import_date).order("average_price ASC").average(:price).first
  end

  def latest_most_expensive_store
    Store.group("stores.identifier_string").joins(:products).where("price >?",0).order("average_price DESC").average(:price).first
  end

  def most_expensive_store
    Store.group("stores.identifier_string").joins(:products).where("price >?",0).where("products.date =?", latest_import_date).order("average_price DESC").average(:price).first
  end

  def latest_cheapest_store
    s = Store.group("stores.identifier_string").joins(:products).where("price >?",0).order("average_price ASC").average(:price).first
    puts s.inspect
    s
  end

  def cheapest_store
    Store.group("stores.identifier_string").joins(:products).where("price >?",0).where("products.date =?", latest_import_date).order("average_price ASC").average(:price).first
  end
end
