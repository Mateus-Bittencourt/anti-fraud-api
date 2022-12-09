class Api::V1::TransactionsController < Api::V1::BaseController

  # POST /api/v1/transactions
  def create
    @transaction = Transaction.new(transaction_params)
    @user = set_user
    @card = set_card
    @card.user = @user
    @card.save
    @merchant = set_merchant
    @devise = set_device
    @transaction.user = @user
    @transaction.merchant = @merchant
    @transaction.device = @devise
    @transaction.recommendation = 'approved'
    if @transaction.save
      render :recommendation, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(amout: params[:transaction_amout], date: params[:transaction_date], external_transaction_id: params[:transaction_id] )
  end

  def set_user
    @user = User.find_by(external_user_id: params[:user_id]) || User.create(external_user_id: params[:user_id])

  end

  def set_merchant
    Merchant.find_by(external_merchant_id: params[:merchant_id]) || Merchant.create(external_merchant_id: params[:merchant_id])
  end

  def set_device
    Device.find_by(external_device_id: params[:device_id]) || Device.create(external_device_id: params[:device_id])
  end

  def set_card
    Card.find_by(number: params[:card_number]) || Card.new(number: params[:card_number])
  end

end
