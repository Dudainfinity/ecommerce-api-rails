module Api
  module V1
    class OrdersController < ApplicationController
      before_action :authenticate_request!
      before_action :set_order, only: %i[show cancel]

      # GET /api/v1/orders  (current user's orders; admins see all)
      def index
        scope = current_user.admin? ? Order.all : current_user.orders
        orders = scope.includes(:order_items, :user)
                      .order(created_at: :desc)
                      .page(params[:page]).per(params[:per_page] || 25)

        render json: OrderSerializer.new(orders, include: [:order_items]).serializable_hash, status: :ok
      end

      # GET /api/v1/orders/:id
      def show
        render json: OrderSerializer.new(@order, include: [:order_items]).serializable_hash, status: :ok
      end

      # POST /api/v1/orders
      # body: { "items": [{ "product_id": 1, "quantity": 2 }, ...] }
      def create
        order = current_user.orders.new(status: :pending)

        items_params.each do |item|
          product = Product.find(item[:product_id])
          order.order_items.new(product: product, quantity: item[:quantity].to_i)
        end

        ActiveRecord::Base.transaction do
          order.save!
          order.order_items.each { |item| item.product.decrement_stock!(item.quantity) }
        end

        render json: OrderSerializer.new(order, include: [:order_items]).serializable_hash, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      end

      # POST /api/v1/orders/:id/cancel
      def cancel
        return render json: { error: "Order already cancelled" }, status: :unprocessable_entity if @order.cancelled?
        return render json: { error: "Only pending orders can be cancelled" }, status: :unprocessable_entity unless @order.pending?

        ActiveRecord::Base.transaction do
          @order.order_items.each { |item| item.product.update!(stock: item.product.stock + item.quantity) }
          @order.update!(status: :cancelled)
        end

        render json: OrderSerializer.new(@order, include: [:order_items]).serializable_hash, status: :ok
      end

      private

      def set_order
        @order = current_user.admin? ? Order.find(params[:id]) : current_user.orders.find(params[:id])
      end

      def items_params
        params.permit(items: %i[product_id quantity]).fetch(:items, [])
      end
    end
  end
end
