class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST /api/v1/transactions
  def create
    @transaction = Transaction.new(
      transaction_id: params[:transaction_id],
      transaction_amount: params[:transaction_amount],
      transaction_date: params[:transaction_date]
    )
    @transaction.recommendation = 'approve'

    @user = set_user
    @card = set_card
    @device = set_device
    @merchant = set_merchant

    validate_card_user

    validate_device_user

    @user.save
    @merchant.save
    @card.save
    @device.save

    @transaction.user = @user
    @transaction.merchant = @merchant
    @transaction.device = @device
    @transaction.card = @card

    validate_too_many_transactions_in_a_row

    validate_transaction_above_20000_in_a_day
    if @user.blocked == true || @card.blocked == true || @device.blocked == true || @merchant.blocked == true || @user.chargeback_count.positive?
      @transaction.recommendation = 'deny'
    end

    if @transaction.save
      render json: { transaction_id: @transaction.transaction_id, recommendation: @transaction.recommendation },
      status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  private

  # def transaction_params
  #   params.require(:transaction).permit(:transaction_id, :transaction_amount, :transaction_date)
  # end

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

  def validate_card_user
    @card.user = @user if @card.user.nil?

    if @card.user != @user
      @user.blocked = true
      @card.blocked = true
      @device.blocked = true
    end

    if @user.cards.size > 3
      @user.blocked = true
      @device.blocked = true
      @user.cards.each do |card|
        card.blocked = true
        card.save
      end
    end
  end

  def validate_device_user
    @device.user = @user if @device.user.nil?

    if @device.user != @user

      @user.blocked = true
      @device.blocked = true
      @card.blocked = true
    end

    if @user.devices.size > 3
      @user.blocked = true
      @card.blocked = true
      @user.devices.each do |device|
        device.blocked = true
        device.save
      end
    end
  end

  def validate_too_many_transactions_in_a_row
    if @user.transactions.size > 0 && @transaction.transaction_date <= @user.transactions.last.transaction_date + 1 && @transaction.merchant_id == @user.transactions.last.merchant_id
      @user.blocked = true
      @card.blocked = true
      @device.blocked = true
    end

    transactions_count = 1
    @user.transactions.each do |transaction|
      if Date.parse(transaction.transaction_date.to_s) == Date.parse(@transaction.transaction_date.to_s)
        transactions_count += 1
      end
    end

    if transactions_count > 15
      @user.blocked = true
      @device.blocked = true
      @card.blocked = true
    end

    merchant_count = 0
    @user.transactions.each do |transaction|
      if transaction.merchant_id == @transaction.merchant_id && Date.parse(transaction.transaction_date.to_s) == Date.parse(@transaction.transaction_date.to_s)
        merchant_count += 1
      end
    end
    if merchant_count > 10
      @user.blocked = true
      @device.blocked = true
      @card.blocked = true
      @merchant.blocked = true
    end

    @card.save
    @device.save
    @user.save
    @merchant.save
  end

  def validate_transaction_above_20000_in_a_day
    user_transactions_amount = 0
    @user.transactions.each do |transaction|
      if Date.parse(transaction.transaction_date.to_s) == Date.parse(@transaction.transaction_date.to_s)
        user_transactions_amount += transaction.transaction_amount
      end
    end
    user_transactions_amount += @transaction.transaction_amount

    merchant_transactions_amount = 0
    @user.transactions.each do |transaction|
      if Date.parse(transaction.transaction_date.to_s) == Date.parse(@transaction.transaction_date.to_s) && transaction.merchant_id == @transaction.merchant_id
        merchant_transactions_amount += transaction.transaction_amount
      end
    end
    merchant_transactions_amount += @transaction.transaction_amount
    if merchant_transactions_amount > 10_000
      @merchant.blocked = true
      @merchant.save
      puts '*' * 100
    end

    if user_transactions_amount > 20_000 || merchant_transactions_amount > 10_000
      @user.blocked = true
      @device.blocked = true
      @card.blocked = true
      @user.save
      @device.save
      @card.save
    end
  end
end
