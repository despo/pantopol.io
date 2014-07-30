class ProductsController < ApplicationController
  include ProductsHelper

  before_action :set_product, only: [:show, :edit, :update, :destroy, :top_expensive_stores, :top_cheapest_stores, :city_stores_prices]

  def index
    @products = Product.paginate pagination
  end

  def show
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
    end
  end

  def grouped_by_name
    render json: Store.joins(:city).group("cities.name").joins(:products).average(:price)
  end

  def prices_by_store
    data = [ { :name => t("total"), :data =>  Product.where("price > ?", 0).joins(:store).group("identifier_string").order("average_price").average(:price) },
             { :name => l(latest_date), :data => Product.where("price > ?", 0).where(date: latest_date).joins(:store).group("identifier_string").order("average_price").average(:price) } ]
    render :json => data
  end

  def latest_city_average
    dates =  Product.order("date DESC").pluck(:date).uniq![0..2]
    data = dates.reverse.map do |date|
      { :name => date.to_s, :data  => Store.where("products.date =?", date).joins(:city).group("cities.name").joins(:products).order("cities.name").average(:price)}
    end
    data << { :name => "Total", :data => city_average }
    render :json => data
  end

  def most_expensive
    data = Product.select("name, price").where("date = ?", latest_date).where("price > ?", 0).group("name, price").order("price DESC").limit(50).map.inject({}) { |hash, p| hash[p.name] = p.price unless hash[p.name] and hash[p.name] > p.price; hash }
    render :json => data
  end

  def cheapest
    data = Product.select("name, price").where("date = ?", latest_date).where("price > ?", 0).group("name, price").order("price ASC").limit(50).reverse.map.inject({}) do |hash, p|
      hash[p.name] = p.price unless hash[p.name] and hash[p.name] > p.price
      hash
    end
    render :json => data
  end

  def all_cities_average_price_graph
    all_data = { :name => t("across_cyprus"), :data => Product.where(name: Product.find(params[:product_id]).name).group_by_month(:date).average(:price) }
    data = City.all.map do |city|
      { :name => city.name,
        :data => city.products.where(name: Product.find(params[:product_id]).name).group_by_month("products.date").average("price") }
    end
    data << all_data
    render :json => data
  end

  def all_cities_max_price_graph
    all_data = { :name => t("across_cyprus"), :data => Product.where(name: Product.find(params[:product_id]).name).group_by_month(:date).maximum(:price) }
    data = City.all.map do |city|
      { :name => city.name,
        :data => city.products.where(name: Product.find(params[:product_id]).name).group_by_month("products.date").maximum("price") }
    end
    data << all_data
    render :json => data
  end

  def all_cities_min_price_graph
    all_data = { :name => t("across_cyprus"), :data => Product.where(name: Product.find(params[:product_id]).name).group_by_month(:date).minimum(:price) }
    data = City.all.map do |city|
      { :name => city.name,
        :data => city.products.where(name: Product.find(params[:product_id]).name).group_by_month("products.date").minimum("price") }
    end
    data << all_data
    render :json => data
  end

  def top_expensive_stores
    data = @product.select_stores_by_price("DESC").limit(40).inject({}) do |hash, product|
      store = product.store.identifier_string
      hash[store] = product.price unless hash[store] and hash[store] > product.price
      hash
    end.take(5).sort_by(&:last).reverse
    render :json => data
  end

  def top_cheapest_stores
    data = @product.select_stores_by_price.limit(40).inject({}) do |hash, product|
      store = product.store.identifier_string
      hash[store] = product.price unless hash[store] and hash[store] < product.price
      hash
    end.take(5).sort_by(&:last)

    render :json => data
  end

  def city_average
    Store.joins(:city).group("cities.name").joins(:products).order("cities.name").average(:price)
  end

  def city_stores_prices
    data = { name: "flare",
             children: [{
              name: "city_prices",
              children: flare_data
            }]}

    render json: data
  end

  def all
    data = all_products_list

    render :json => { :text => "products", :children => data, :url => nil }
  end

  private
  def flare_data
    min = City.all.map do |city|
      { :name => "min",
        :children => [
          {
            :name => city.name, :children => min_price_by_store(city)
          }]
      }
    end
    max = City.all.map do |city|
      { :name => "max",
        :children => [
          {
            :name => city.name, :children => max_price_by_store(city) }]
      }
    end
    avg = City.all.map do |city|
      { :name => "average",
        :children => [
          {
            :name => city.name, :children => average_price_by_store(city) }]
      }
    end
    min + avg + max
  end

  def all_products_list
    key = "all_products_list_#{latest_date}"
    return $redis.get(key) if $redis.keys.include? key

    all_results = Product.select("id, name, price").
      where("price > ?",0).
      group('name').
      average("price").map do |product|
        { :text => product[0],
          :size => product[1],
          :url => url_for(product_group(product[0]).first),
          :highest_price => (product_group(product[0]).order("price desc").first.price rescue 0),
          :highest_price_store => (product_group(product[0]).order("price desc").first.store.display_name rescue ""),
          :lowest_price => (product_group(product[0]).order("price asc").first.price rescue 0),
          :lowest_price_store => (product_group(product[0]).order("price asc").first.store.display_name rescue "")
        }
      end
      $redis.set(key, all_results)
  end

  def product_group name
    @product_group = Product.where(:name => name, :date => latest_date).where("price > ?", 0) unless @search.eql? name
    @search = name

    return @product_group unless @product_group.empty?
    @product_group = Product.where(:name => name)
    @product_group.first.price = 0
    @product_group
  end

  def min_price_by_store city
    city.products.where("products.name = ?", @product.name).where("price > ?",0).joins(:store)
    .select('stores.identifier_string, minimum_price as price')
    .group('stores.identifier_string')
    .order("minimum_price")
    .minimum('price').map do |o|
      { :name => "#{o.first}\nmin:#{I18n.t(o.last, format: "number.currency")}", :size => o.last }
    end
  end

  def max_price_by_store city
    city.products.where("products.name = ?", @product.name).where("price > ?",0).joins(:store)
    .select('stores.identifier_string, maximum_price as price')
    .group('stores.identifier_string')
    .maximum('price').map do |o|
      { :name => "#{o.first}\n max:#{I18n.t(o.last, format: "number.currency")}", :size => o.last }
    end
  end

  def average_price_by_store city
    city.products.where("products.name = ?", @product.name).where("price > ?",0).joins(:store)
    .select('stores.identifier_string, average_price as price')
    .group('stores.identifier_string')
    .average('price').map do |o|
      { :name => "#{o.first}\n average:#{I18n.t(o.last, format: "number.currency")}", :size => o.last }
    end
  end

  def latest_date
    @date ||= Product.order("date DESC").pluck(:date).uniq![0]
  end

  def set_product
    @product = Product.find(params[:id]) rescue Product.find(params[:product_id])
  end

  def product_params
    params.require(:product).permit(:store_id, :price, :date, :unit)
  end
end
