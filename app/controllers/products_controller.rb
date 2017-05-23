class ProductsController < ApplicationController
  before_action :validate_search_key, only: [:search]

  def index
    @products = Product.all.order("position ASC")
  end

  def show
    @product = Product.find(params[:id])
  end

  def add_to_cart
    @product = Product.find(params[:id])
    if !current_cart.products.include?(@product)
      current_cart.add_product_to_cart(@product)
      flash[:notice] = "已成功将#{@product.title}加入购物车"
    else
      flash[:warning] = "购物车内已有此物品"
    end
      redirect_to :back

  end
#-------收藏的action--------
  def join
    @product = Product.find(params[:id])

     if !current_user.is_member_of?(@product)
       current_user.join!(@product)
     end

     redirect_to product_path(@product)
   end

   def quit
     @product = Product.find(params[:id])

     if current_user.is_member_of?(@product)
       current_user.quit!(@product)
     end

     redirect_to product_path(@product)
   end
#------搜索栏------------
  def search
      if @query_string.present?
        search_result = Product.ransack(@search_criteria).result(:distinct => true)
        @products = search_result.paginate(:page => params[:page], :per_page => 10 )
      end
    end


#-------点赞功能-----------
  def upvote
    @product = Product.find(params[:id])
    @product.upvote_by current_user
    redirect_to :back
  end


    protected

    def validate_search_key
      @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
      @search_criteria = search_criteria(@query_string)
    end


    def search_criteria(query_string)
      { title_or_description_cont: @query_string }
    end
end
