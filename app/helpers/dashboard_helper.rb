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
end
