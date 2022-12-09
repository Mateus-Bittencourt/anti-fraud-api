class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/v1/transactions
  def create
    @transaction = Transaction.new(transaction_params)
    @user = set_user
    @card = set_card
    @card.user = @user

    @merchant = set_merchant
    @devise = set_device
    @devise.user = @user

    @user.save
    @merchant.save
    @card.save
    @devise.save

    @transaction.user = @user
    @transaction.merchant = @merchant
    @transaction.device = @devise
    @transaction.card = @card
    @transaction.recommendation = 'approved'
    if @transaction.save
      render :recommendation, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_id, :transaction_amount, :transaction_date)
  end

  # def user_params
  #   params.require(:user).permit(:user_id)
  # end

  # def merchant_params
  #   params.require(:merchant).permit(:merchant_id)
  # end

  # def device_params
  #   params.require(:device).permit(:device_id)
  # end

  # def card_params
  #   params.require(:card).permit(:card_number)
  # end

  def set_user
    User.find_by(user_id: params[:user_id]) || User.new(user_id: params[:user_id])
  end

  def set_merchant
    Merchant.find_by(merchant_id: params[:merchant_id]) || Merchant.new(merchant_id: params[:merchant_id])
  end

  def set_device
    Device.find_by(device_id: params[:device_id]) || Device.new(device_id: params[:device_id])
  end

  def set_card
    Card.find_by(card_number: params[:card_number]) || Card.new(card_number: params[:card_number])
  end
end
