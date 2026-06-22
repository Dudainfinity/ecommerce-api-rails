module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :authenticate_request!, except: %i[index show]
      before_action :authorize_admin!, except: %i[index show]
      before_action :set_category, only: %i[show update destroy]

      # GET /api/v1/categories
      def index
        categories = Category.order(:name).page(params[:page]).per(params[:per_page] || 25)
        render json: CategorySerializer.new(categories).serializable_hash, status: :ok
      end

      # GET /api/v1/categories/:id
      def show
        render json: CategorySerializer.new(@category).serializable_hash, status: :ok
      end

      # POST /api/v1/categories
      def create
        category = Category.new(category_params)
        if category.save
          render json: CategorySerializer.new(category).serializable_hash, status: :created
        else
          render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/categories/:id
      def update
        if @category.update(category_params)
          render json: CategorySerializer.new(@category).serializable_hash, status: :ok
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/categories/:id
      def destroy
        if @category.destroy
          head :no_content
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def category_params
        params.permit(:name, :description)
      end
    end
  end
end
