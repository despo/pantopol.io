module ProductsHelper
  def latest_date
    @date ||= Product.order("date desc").limit(2).pluck(:date).first
  end

  def highest_priced_product
    @highest_product_price = Product.select("date, id, price, store_id").group("id").where(name: @product.name).order("max(price) ASC").last
  end

  def lowest_priced_product
    @highest_product_price = Product.select("date, id, price, store_id").group("id").where(name: @product.name).where("price > ?", 0).order("min(price) DESC").last
  end

  def latest_top_cheapest_stores product
    data = product.select_stores_by_price("ASC", latest_date).limit(40).inject({}) do |hash, product|
      store = product.store.identifier_string
      hash[store] = product.price unless hash[store] and hash[store] < product.price
      hash
    end.take(5).sort_by(&:last)
    data
  end

  def latest_top_expensive_stores product
    data = product.select_stores_by_price("DESC", latest_date).limit(40).inject({}) do |hash, product|
      store = product.store.identifier_string
      hash[store] = product.price unless hash[store] and hash[store] > product.price
      hash
    end.take(5).sort_by(&:last)
    data
  end
end
