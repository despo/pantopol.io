class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all
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
    data = Product.where("price > ?", 0).joins(:store).group("identifier_string").order("average_price").average(:price)
    render :json => data
  end

  def latest_prices_by_store
    data = Product.where("price > ?", 0).where(date: latest_date).joins(:store).group("identifier_string").order("average_price").average(:price)
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

  def price_graph
    data = Product.where(name: Product.find(params[:product_id]).name).group_by_day(:date).average(:price)
    render :json => data
  end

  def city_average
    Store.joins(:city).group("cities.name").joins(:products).order("cities.name").average(:price)
  end

  private
  def latest_date
    @date ||= Product.order("date DESC").pluck(:date).uniq![0]
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:store_id, :price, :date, :unit)
  end
end
