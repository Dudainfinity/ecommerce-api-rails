module Api
  module V1
    class ProductsController < ApplicationController
      before_action :authenticate_request!, except: %i[index show]
      before_action :authorize_admin!, except: %i[index show]
      before_action :set_product, only: %i[show update destroy]

      # GET /api/v1/products
      def index
        products = Product.includes(:category)
        products = products.where(category_id: params[:category_id]) if params[:category_id].present?
        products = products.active if params[:active] == "true"
        products = products.search(params[:q]) if params[:q].present?
        products = products.order(:name).page(params[:page]).per(params[:per_page] || 25)

        render json: ProductSerializer.new(products).serializable_hash, status: :ok
      end

      # GET /api/v1/products/:id
      def show
        render json: ProductSerializer.new(@product).serializable_hash, status: :ok
      end

      # POST /api/v1/products
      def create
        product = Product.new(product_params)
        if product.save
          render json: ProductSerializer.new(product).serializable_hash, status: :created
        else
          render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        if @product.update(product_params)
          render json: ProductSerializer.new(@product).serializable_hash, status: :ok
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        if @product.destroy
          head :no_content
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.permit(:name, :description, :price, :sku, :stock, :active, :category_id)
      end
    end
  end
end
